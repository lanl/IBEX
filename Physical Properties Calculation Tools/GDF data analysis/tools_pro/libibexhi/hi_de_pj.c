/*	$Id: hi_de_pj.c,v 1.8 2020/02/20 04:14:28 pjanzen Exp $	*/
/* This is a reimplementation of the direct event handling code, not using
 * ISOC code.  It is not quite a plug-in replacement but "all" the "useful"
 * interfaces are replicated.  The basic framework is read_in_des(), which
 * takes a filename, a start time, an end time, and a mask of DE types to
 * look for, and a function to call with each found DE as an argument.
 * Each DE is represented as an exact MET, an exact spin phase according to
 * the spacecraft [Note:  I do use the nearly concurrent spin_info packets,
 * not the osbdba file], an ESA, and a DE type.
 *
 * Events are sorted by spin and then timewise by event.  This means that
 * the raw stream of events is not quite chronological, although all the
 * events IN ONE SPIN are listed before any event in the next spin.  For
 * speed, the basic routine does not actually time-order events.  If this
 * is needed, read_in_des_ordered() exists.  TO BE WRITTEN XXX
 *
 * This interface is remarkably close to previous, now removed hooks to
 * build up any and all previous DE reading jazz of mine...
 *
 * The hope is to replace the gbc code - it's not necessary, but it's
 * possibly faster, and the straightforward(?) framework here will allow a
 * Python-native DE reader in the future.
 */
#include <err.h>
#include <fcntl.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h> /* really only for DEBUG */
#include <unistd.h>
#include "ccsds_msg.h"
#include "hi_de_flt.h"
#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: hi_de_pj.c,v 1.8 2020/02/20 04:14:28 pjanzen Exp $";

/* There are 16 Hi DE types.  Most of them we never think of keeping.
 * hi_type_00=--c-BC
 * hi_type_01=--cA-C
 * hi_type_02=--cABC
 * hi_type_03=-b--BC
 * hi_type_04=-b-AB-
 * hi_type_05=-b-ABC
 * hi_type_06=-bc-BC
 * hi_type_07=-bcABC
 * hi_type_08=a--A-C
 * hi_type_09=a--AB-
 * hi_type_10=a--ABC
 * hi_type_11=a-cA-C
 * hi_type_12=a-cABC
 * hi_type_13=ab-AB-
 * hi_type_14=ab-ABC
 * hi_type_15=abcABC
 */


/* First spin is the one with the matching spinct in the spin_info packet,
 * preceding the actual packet MET.  Return -1 on fail.
 *
 * bsearch rip-off, varieties of which exist throughout libibexhi for
 * things that can be close matches but not exact ones.  Probably would be
 * faster just to increment -- everything happens in a time series, right?
 *
 * This is complicated by the observed fact that 96-spin spin_info packets
 * and 12-spin DE packets do NOT have to fall on the same cadence - they
 * can be off by some number of spins less than 12.
 *
 * XXX we get hosed if we drop SPININFO packets then, although they could
 * be reconstructed on the ground.  Our choice here is either to require an
 * osbdba file, which will have that all reconstructed for us, or to NOT
 * bail but simply drop DEs that happen where we don't have spintime info.
 * Or, to reproduce all the logic that goes into an osbdba file.  We don't
 * do that yet.  I suppose we could eventually.
 */
static int
getmyspintime(int spinct, uint32_t pktmet)
{
	int mid, lo, hi;

	if (nspin_times <= 0)
		return(-1);
	lo = 0;
	hi = nspin_times - 1;
	/* This is a weak check because it's nominally (up to) 96 spins in a
	 * packet
	 */
	if (pktmet + 6 + 2 * APPROX_HBTIME < spin_times[lo].pktmet ||
	    pktmet > spin_times[hi].pktmet + 3)
		return(-1);
	/* There may or may not be a spin stored for this spin since we may
	 * have left HVSCI, so add one second to avoid integer truncation
	 * issues and then subtract one spin to get the time of the
	 * previous spin.  Bear with me...
	 */
	pktmet = pktmet - 13;
	while (lo < hi) {
		mid = lo + (hi - lo)/2;
		if (spin_times[mid].met < pktmet)
			lo = mid + 1;
		else
			hi = mid;
	}
	if (lo >= nspin_times || lo < 0)
		return(-2);	/* should never execute */
	/* lo should now be the index for the spin prior to when the packet was
	 * created.  Find the s/c spin count of this spin.  Repurpose mid & hi.
	 */
	hi = spin_times[lo].spin;
	mid = lo;
	while (mid > 0 && spin_times[mid].spin == spin_times[mid - 1].spin) {
		mid--;
		hi++;
	}
	/* hi is now the s/c spin count, almost mod 256, of spin index "lo".
	 * We expect, often, it's about 12 more than function arg spinct.
	 * We do not expect it's ever more than 12 (mod 256).
	 * Repurpose mid again to be the offset.
	 */
	mid = (hi + 256 - spinct) % 256;
	if (lo < mid || mid > 12)
		warnx("DE packet appears at slower than 12-spin cadence?");
	lo -= mid;
#ifdef DEBUG
	printf(">~> entry s/c spin %d on packet time %u\n", spinct, pktmet+13);
	printf(">~> return %d (%.4lf) as last spin\n", lo, spin_times[lo].met);
#endif
	return(lo);
}


/* This is trickier than you'd think since consecutive entries in the
 * spin_info packets need not relate to consecutive spins.  When in doubt,
 * the spin either BEFORE or AFTER can be pressed into service.
 *
 * There are also weird accommodations we need to make (e.g., orbit 13):
 * if the orbit is "spun", we may have periods shorter than 10 seconds, and
 * it used to default to 15.0 s if there wasn't a valid spin pulse.  We're
 * more worried about dropped spin pulses than bogus additional spin pulses
 * (which I think have never occurred), so limit the "sensible period"
 * range to a broad, not very sensible range.
 *
 * Also, do better than APPROX_HBTIME / 48. as a guess otherwise.
 */
static double
get_sensible_period(int cursp)
{
	double tmp;

	if (cursp >= nspin_times || cursp < 0)
		return(-1.);
	if (cursp < nspin_times - 1) {
		tmp = spin_times[cursp + 1].met - spin_times[cursp].met;
		if (tmp <= 8. || tmp >= 15.2)
			tmp = get_mode_period();
		/* XXX could divide interstitial gaps and do better */
		if (spin_times[cursp].pktmet == spin_times[cursp + 1].pktmet)
			return(tmp);
		/* See if following packet is sensible:  96 spins later with a
		 * reasonable delta.  Otherwise do the spin period prior.
		 */
		if ((spin_times[cursp + 1].spin - spin_times[cursp].spin + 256) % 256
		    == 96 && tmp > 8. && tmp < 15.2)
			return(tmp);
		if (cursp == 0)
			return(tmp);
	}
	tmp = spin_times[cursp].met - spin_times[cursp - 1].met;
	if (tmp <= 8. || tmp >= 15.2)
		tmp = get_mode_period();
	return(tmp);
}

static double
not_more_than_1(double foo)
{
	if (foo > 1.)
		return(1.);
	return(foo);
}

/* returns negative on failure, else the number of DEs processed; note that
 * processing happens externally by the function in argument 5.
 */
int
read_in_des(char *fname, uint32_t stm, uint32_t endm, uint16_t evts,
    void (*hook)(double, uint16_t, int, int, double))
{
	static IBEXpkt pkt;
	static IBEXmsg msg;
	HI_DE_FLT_msg *hde;
	int fd, err;
	uint16_t *unpk, *untmp;
	uint16_t *totals, *flags, *nv, *violators, *des;
	int i, j, n, lasti;
	int curev, curspin;
	int spin0, startn, doit, fresh, sflag, cursize;
	double curspinmet, curper;

	err = 0;
	cursize = startn = 0;
	fd = open(fname, O_RDONLY);
	if (fd < 0) {
		warn("read_in_des:");
		return(-1);
	}
	n = 0;
	lasti = 0;
	unpk = NULL;
	/* as in process_tlm(), loop through gathering HI_DE_FLT msgs */
	while (1) {
		err = Read_IBEXpkt(pkt, fd, 0);
		if (err < 0) {
			if (err != IBEX_PKT_ERR_EOF)
				warnx("%s", report_IBEXpkt_error(err, 1));
			else
				err = 0;
			break;	/* eof, typically */
		}
		IBEX_pkt2msg(pkt, &msg);
		if (msg.apid == HI_DE_FLT) {
			/* If in valid time range, process; note that we interpret
			 * valid time range to be applicable to 48-spin histogram
			 * packets, and so we infer 12-spin timings to go earlier.
			 * Note that since we don't process DEs outside the window,
			 * we can't keep a count of truly total DEs seen, just
			 * packets; we do track DEs in the time range but not in
			 * the event map requested.
			 *
			 * Note also the (integer) comparison for startmet:  a
			 * startmet of 0 will be a common thing and we don't want to
			 * wrap an unsigned int by subtracting.
			 */
			hde = (HI_DE_FLT_msg *)(msg.msg);
			if (hde->met + (uint32_t)(0.8 * APPROX_HBTIME) > stm &&
			    hde->met <= endm) {
				/* Sanity check; can't be < 0 because it's unsigned */
				if (hde->count > 1091) {
					warnx("read_in_des:  bogus count MET %u", hde->met);
					free(msg.msg);	 /* hah */
					continue;
				}
#ifdef DEBUG
/* hde->count is the number of packed bytes claimed to exist in this packet
 * and officially it can never be wrong at this stage of the processing.
 * We did do a sanity check on it being too big.  Note we won't ever
 * overflow unpk at least.
 */
printf(">! Found packet in time range:  MET %u sequence %d group %d size %d\n",
    hde->met, msg.seqn, msg.grup, hde->count);
#endif
/* shift indent! */
	/* We need to go look at some more header, because DEs can
	 * be split.  If we have just the start, store for later.
	 * Basically, though, if the time's at all useful, all the DEs will
	 * show up in one packet and the fancy next 60 lines of logic is
	 * decorative.
	 */
	switch(msg.grup) {
	case PKT_GRP_SINGLE:
		if (unpk) {
			free(unpk);
			warnx("read_in_des:  dropped a partial packet (%d)", startn);
		}
		if ((unpk = (uint16_t *) calloc(hde->count, sizeof(uint16_t))) == NULL)
			errx(100, "FATAL: read_in_des out of mem");
		doit = 1;	/* process packet entirely */
		startn = 0; /* start storing at start of packet */
		lasti = 0;
		cursize = hde->count;
		break;
	case PKT_GRP_START:
		if (unpk) {
			free(unpk);
			warnx("read_in_des:  dropped a partial packet (%d)", startn);
		}
		if ((unpk = (uint16_t *) calloc(hde->count, sizeof(uint16_t))) == NULL)
			errx(100, "FATAL: read_in_des out of mem");
		doit = 0;
		startn = 0;
		lasti = 0;
		cursize = hde->count;
		break;
	case PKT_GRP_MIDDLE:
		if (!unpk) {
			warnx("read_in_des:  middle packet found before start");
			startn = 0;
			doit = 0;	/* Just ignore this one! */
			continue;
		}
		warnx("read_in_des:  found a middle packet which should never exist!");
		if (cursize - startn < hde->count) {
			/* should be a reallocarray() but it's less standard) */
			untmp = (uint16_t *)realloc(unpk,
			    (hde->count + startn) * sizeof(uint16_t));
			if (untmp == NULL)
				errx(101, "FATAL: read_in_des out of mem");
			unpk = untmp;
			cursize = hde->count + startn;
		}
		doit = 0;	/* Don't change startn */
		break;
	case PKT_GRP_FINISH:
		if (!unpk) {
			warnx("read_in_des:  finish packet found before start");
			startn = 0;
			doit = 0;	/* Just ignore this one! */
			continue;
		}
		if (cursize - startn < hde->count) {
			/* should be a reallocarray() but it's less standard) */
			untmp = (uint16_t *)realloc(unpk,
			    (hde->count + startn) * sizeof(uint16_t));
			if (untmp == NULL)
				errx(101, "FATAL: read_in_des out of mem");
			unpk = untmp;
			cursize = hde->count + startn;
		}
		doit = 1;	/* Don't change startn */
		break;
	default:
		warnx("read_in_des:  found DE packet of ridiculous type (%d)",
		    msg.grup);
		doit = 0;
		break;
	}
	/* Unpack.  In theory you can end with 2 bytes, which would be ONE
	 * quantity, or 3 bytes, in which case you've both BOTH quantities.
	 * Really, packets can split anywhere so you can't count on having
	 * both bytes at the same time.
	 */
	for (i = 0; i < hde->count; i++) {
		switch((i + lasti) % 3) {
		case 0:
			unpk[startn] = (hde->packed[i] << 4);
			break;
		case 1:  /* we can now read the first 12-bit quantity */
			unpk[startn] |= (hde->packed[i] >> 4);
			startn++;
			unpk[startn] = (hde->packed[i] & 0x0F) << 8;
			break;
		case 2:	/* we can read the other quantity */
			unpk[startn] |= hde->packed[i];
			startn++;
			break;
		}
	}
	lasti = i % 3;
	if (doit) {
		/* We're not guaranteed 12 spins:  we need to compare
		 * hde->first, which is a s/c spin number, to where we are now.
		 * In theory the ISOC's osbdba files are synced to s/c spin
		 * number.  Since I keep the spin_info packets and they've
		 * already been read in, I can just use them...  Note then that
		 * if the ISOC smooths spins in the osbdba rather than the
		 * osbd2a, I lose this info.
		 * spin0 becomes the index in spin_times[] of the start of the first
		 * spin in this DE packet.
		 */
		if ((spin0 = getmyspintime(hde->first, hde->met)) < 0) {
			warnx("read_in_des:  found time outside spin_info (first spin %.2lf, wanted %u; bailing",
			    spin_times[0].met, hde->met);
			free(msg.msg);
			close(fd);
			return(-3);
		}
		/* Pleasant (?) accounting */
		totals = unpk;
		flags = totals + 16;
		/* nv is not really NUMBER OF VIOLATORS but offset to timestamps,
		 * including itself.
		 * The last element of the "violators" list is the total number
		 * of events.
		 */
		nv = flags + 16;
		violators = nv + 1;
		des = violators + *nv - 1;
#ifdef DEBUG
printf(">!    Totals: ");
for (i = 0; i < 16; i++) printf(" %d", totals[i]);
printf("\n>!    Flags: ");
for (i = 0; i < 16; i++) printf(" %X", flags[i]);
j = 0;
for (i = 0; i < 16; i++)
	if (flags[i])
		j += totals[i];
printf("\n>!    There are %d possible events to store.\n", j);
printf(">!    (Size implies %d stored events.)\n",
    (startn - 32 - ((*nv > 0 && *nv < startn-33)?*nv:0)));
printf("\n>!    Violators: %d violators and %d events.\n>!  ", *nv - 2,
    (*nv > 0 && *nv <= startn - 33)?violators[*nv-2]:-1);
if (*nv > 0 && *nv <= startn - 33) {
	for (i = 0; i < *nv - 1; i++)
		printf(" %d", violators[i]);
	printf(" (%d)\n", violators[i]);
}
#endif
		curspin = 0;
		curspinmet = spin_times[spin0 + curspin].met;
		curper = get_sensible_period(spin0 + curspin);
		curev = 0;
		i = 0;
		j = 0;
		while (curspin < 12) {
			while (curspin < 12 && !(flags[curev] & (1 << curspin))) {
				curev++;
				if (curev >= 16 && curspin < 12) {
					curev = 0;
					curspin++;
					/* Sanity-check on jumps in spin time, because
					 * gaps in spin_info packets can make the spin
					 * following the last spin of DE data appear far
					 * too late.  Sometimes I wedge curper, so give
					 * margin.
					 */
					if (spin_times[spin0 + curspin].met -
					    spin_times[spin0 + curspin - 1].met > curper +
					    0.05)
						curspinmet += curper;
					else
						curspinmet = spin_times[spin0 + curspin].met;
					curper = get_sensible_period(spin0 + curspin);
				}
			}
			if (curspin < 12) {
#ifdef DEBUG
printf(">!  event/spin _%d/%d_ (%.4lf at %.3lf from %d)\n",
	  curev, curspin, curper, curspinmet, spin0);
#endif
				/* We're "fresh" if we just passed a violator */
				fresh = 1;
				sflag = 1;
				while (sflag && i < startn - (des - unpk)) {
					if (!fresh) {
						/* >= : we can have 2 DEs on the same ms (observed) */
						if ((des[i] >= des[i-1] &&
						    ((j < *nv - 1 && i != violators[j]) || j >= *nv - 1))) {
				/* timestamp, event-type, ESA, s/c spin phase */
							/* Got an event to hand off */
							if (evts & (1 << curev)) {
								n++;
				/* timestamp, event-type, ESA, spin1/2, s/c spin phase */
				hook(curspinmet + des[i] * ME_TIME_SEC_PER_TICK,
				    curev, curspin >> 1, curspin % 2,
				    not_more_than_1(des[i] * ME_TIME_SEC_PER_TICK / curper));
							}
							i++;
						} else if (j < *nv - 1 && i == violators[j]) {
							j++;
							/* fresh = 1; not needed */
							sflag = 0;
							/* Don't increment i */
							/* printf(">V>"); */
						} else if (des[i] < des[i-1]) {
							/* Not <=, by observation */
							sflag = 0;
							/* Don't increment i */
						}
					} else {
						/* Got an event to hand off */
						if (evts & (1 << curev)) {
							n++;
				/* timestamp, event-type, ESA, spin1/2, s/c spin phase */
				hook(curspinmet + des[i] * ME_TIME_SEC_PER_TICK,
				    curev, curspin >> 1, curspin % 2,
				    not_more_than_1(des[i] * ME_TIME_SEC_PER_TICK / curper));
						}
						fresh = 0;
						i++;
					}
				}
				/* reset flag to go to next data type */
				flags[curev] ^= (1 << curspin);
			}
		} /* while (curspin < 12) */
		free(unpk);
		unpk = NULL;
#ifdef DEBUG
printf(">!  --- j and nv are %d %d\n", j, *nv);
#endif
	} /* if (doit) */
	/* shift indent back*/
			}	/* if (in time range) */
		} /* if (it's a HI DE packet) */
		free(msg.msg);
	}	/* while (1) main loop */
	close(fd);
	return(n);
}



typedef struct {
	double met;
	uint16_t evtype;
	int esa, s12;
	double phase;
} foofarraw;
/* Claim we can't have more than 2k events in two spins */
#define MAXEVS (2048)
static foofarraw spinwrth[MAXEVS];
static int nspw = 0;
static void (*_internal_DE_hook)(double, uint16_t, int, int, double) = NULL;
static int _lastesa = 0;

static int
_comp_evs(const void *a, const void *b)
{
	const foofarraw *dea = (const foofarraw *)a;
	const foofarraw *deb = (const foofarraw *)b;

	if (dea->met < deb->met)
		return(-1);
	if (dea->met > deb->met)
		return(1);
	if (dea->evtype < deb->evtype)
		return(-1);
	if (dea->evtype > deb->evtype)
		return(1);
	return(0);
}


void
_add_an_ev(double met, uint16_t ev, int esa, int s12, double ph)
{
	int i;

	if (esa != _lastesa) {
		qsort(spinwrth, nspw, sizeof(foofarraw), _comp_evs);
		for (i = 0; i < nspw; i++)
			_internal_DE_hook(spinwrth[i].met, spinwrth[i].evtype,
			    spinwrth[i].esa, spinwrth[i].s12, spinwrth[i].phase);
		nspw = 0;
		_lastesa = esa;
	}
	if (nspw < MAXEVS) {
		spinwrth[nspw].met = met;
		spinwrth[nspw].evtype = ev;
		spinwrth[nspw].esa = esa;
		spinwrth[nspw].s12 = s12;
		spinwrth[nspw].phase = ph;
		nspw++;
	} else
		errx(1, "_add_an_ev ran out of space");
}


/* Use the preceding routine but sort events per spin before calling hook() */
int
read_in_des_ordered(char *fname, uint32_t stm, uint32_t endm, uint16_t evts,
    void (*hook)(double, uint16_t, int, int, double))
{
	int i;

	_internal_DE_hook = hook;
	_lastesa = 0;
	i = read_in_des(fname, stm, endm, evts, _add_an_ev);
	/* Won't have dumped the last esa worth, so flush it here */
	_add_an_ev(12345., 0, 20, 1, 0.1);
	nspw = 0;
	return(i);
}


/* This recreates the traditional interface; it's not necessarily the
 * optimal route to anything.  Return 0 on success.
 * The packet pumper no longer prints.
 */
int
assemble_de_packets(char *fname, int printpump, int whichtreat,
    uint32_t stm, uint32_t endm)
{
	int i;

	/* There better be just one arc */
	if (nst_pps == 0) {
		nst_pps = fix_PPS_issue_as_per_ISOC(stm, endm);
		fix_gaps_in_spins();
	}
	/* need to be ordered if we're not rounding on 12-spin boundary;
	 * otherwise don't -- but it's not really much slower, so might as
	 * well.
	 */
	if (whichtreat == 1)
		i = read_in_des_ordered(fname, stm, endm, 0xFFFF, adp_despin);
	else
		i = read_in_des_ordered(fname, stm, endm, 0xFFFF, adp_nodespin);
	return(!(i > 0));
}
