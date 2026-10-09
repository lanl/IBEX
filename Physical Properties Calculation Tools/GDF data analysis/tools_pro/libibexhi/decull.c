/*	$Id: decull.c,v 1.5 2020/02/25 21:02:18 pjanzen Exp $	*/
/* This is associated to a bunch of stuff all living in processcull.c, but
 * everything there deals with the histogram binned structure and this here
 * is relevant only to direct events. */

static const char rcsid[] = "@(#) $Id: decull.c,v 1.5 2020/02/25 21:02:18 pjanzen Exp $";

#include <ctype.h>
#include <err.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ibexhi.h"

/* This is a kind of odd place to stick this, but it's where it's most
 * relevant:  we need to assert that spin_times are monotonically
 * increasing.  I suppose if they aren't I could fix them, but first I'll
 * see if that's needed.  Return 0 on success.  On failure return the first
 * element that's NOT monotonically increasing.
 */
int
sanity_check_spininfo(void)
{
	int i;

	if (nspin_times <= 1)
		return(0);
	for (i = 1; i < nspin_times; i++)
		if (spin_times[i].met <= spin_times[i-1].met)
			return(i);
	return(0);
}

/* Assume we're basically going in sequence.  Not like we have a choice,
 * but the linked list ought never to be insanely long.  Assume culls are
 * in order.  XXX we never check that this is the case when we read in.
 */
int
DE_isincull(int culln, double met, int esa, int angbin, degt *culz)
{
	static degt *q = NULL;
	static degt *qbase = NULL;

	if (angbin < 0 || angbin > HI_AZ_BINS)
		return(0);
	/* Sometimes we can get phase angle 1.0000 which is angle bin 60:
	 * move to angle bin 59.
	 */
	if (angbin == HI_AZ_BINS)
		angbin--;
	esa = (1 << esa);
	culln = (1 << culln);
	if (!q || !qbase || qbase != culz) {
		q = culz;
		qbase = culz;
	}
	if (!q)
		return(0);
	if ((q->met1 > met && q->whichcull == culln) || q->whichcull > culln)
		q = culz;
	while (q && q->whichcull < culln)
		q = q->next;
	if (!q)
		return(0);
	while (q && q->whichcull == culln && q->met2 < met)
		q = q->next;
	if (!q || q->whichcull != culln || q->met1 > met)
		return(0);
	if (q->cul[angbin] & esa)
		return(1);
	return(0);
}


/* For calculating exposure times on the direct events, we should actually
 * ignore the hb cadence.  We need to have the osbdba loaded (and the
 * osbd2a, if it's relevant), and we need the good times filename and the
 * startMET and endMET that we care about.  We can then return a linked
 * list of data relevant to good times times.
 *
 * One thing to be concerned about:  all times in the good times file
 * should be rounded to closest spin boundary (likely preceding, or at
 * least within a second or two of).  Ideally, this would always be rounded
 * to closest spin boundary as determined by IBEX, so that DEs and hbs
 * correspond to the same time interval (because, well, we use hbs to
 * determine backgrounds, right?).  However, historically I've aligned spun
 * times for some reason on ACTUAL spin boundaries.  So make that a flag.
 * timeoff is 0 if we align off osbdba, or nonzero if we align off osbd2a.
 *
 * Return 0 on success, else the line of the good times that was a problem,
 * or -1 if there was another issue (e.g., couldn't open file, or osbdba
 * not loaded).
 * Allocates a pile of stuff if it's successful.
 *
 * Doesn't do a FULL parsing of the good times file and assumes culls are
 * listed in sequential order.
 *
 * XXX the culls are set by a bitmask, so valid culls are 1,2,4,8, etc.
 * In theory a given time is allowed to belong to MULTIPLE culls.  We
 * have never done this in practice though.  This routine will break if
 * you try.  XXX it should complain if it finds such times. (# bits set)
 */
int
read_goodDEtimes(char *fname, degt **gtlist, int verbos,
    uint32_t startmet, uint32_t endmet, int timeoff)
{
	int i, line;
	double stm, endm;
	FILE *fp;
	char foo[8192];
	char *p;
	int junk, esa1, esa2, esa3, esa4, esa5, esa6, esa7, esa8;
	int angbin1, angbin2;
	double met1, met2;
	double qmet1, qmet2, tmp;
	char qcull[HI_AZ_BINS];
	char side[3];
	char emap;
	degt *q;

	HBtimeSlop = 3;
	*gtlist = NULL;
	q = *gtlist;
	i = is_OSBdb_initialized();
	if (i < 1 || (timeoff != 0 && i < 2))
		return(-1);
	if ((fp = fopen(fname, "r")) == NULL)
		return(-1);
	line = 0;
	/* spec a time:  it doesn't have to correlate to what osbdba has been
	 * loaded (although you'll get a -1 error returned if the good times
	 * in this range don't match loaded times).
	 */
	stm = (double)startmet;
	endm = (double)endmet;
	/* Now read the file. read_goodtimes() handles "old" cull files which
	 * don't even specify a cull, but that's utterly obsolete.  So we
	 * expect 13 fields back, period.
	 */
	while (fgets(foo, sizeof(foo), fp)) {
		line++;
		p = foo;
		while (isspace(*p))
			p++;
		if (*p != '#' && *p) {
			i = sscanf(p, "%d%lf%lf%d%d%2s%d%d%d%d%d%d%d%d",
			    &junk, &met1, &met2, &angbin1, &angbin2, side,
			    &esa1, &esa2, &esa3, &esa4, &esa5, &esa6, &esa7, &esa8);
			if (!strcasecmp(side, "hi")) {
				if ((i != 13 || angbin1 < 0 || angbin2 < angbin1 ||
				    met1 >= met2 || angbin2 > HI_AZ_BINS - 1)) {
					fclose(fp);
					free_degt(*gtlist);
					*gtlist = NULL;
					return(line);
				}
				/* Time range is IN or OUT, else it's an error */
				if ((met1 < stm && met2 >= stm) ||
				    (met2 > endm && met1 <= endm)) {
					if (verbos >= 0)
						warnx("get_goodtimes_for_des:  overlapping time range %.1lf %.1lf", met1, met2);
					fclose(fp);
					free_degt(*gtlist);
					*gtlist = NULL;
					return(line);
				}
				if (met1 >= stm && met2 <= endm) {
					/* Cool, populate stuff. */
					emap = 0;
					if (esa1) emap |= 1;
					if (esa2) emap |= 2;
					if (esa3) emap |= 4;
					if (esa4) emap |= 8;
					if (esa5) emap |= 16;
					if (esa6) emap |= 32;
					if (!timeoff) {
						qmet1 = get_metfromspin(get_OSBdbstuff(met1 + 1.,
						    &tmp));
						qmet2 = get_metfromspin(get_OSBdbstuff(met2 + 1.,
						    &tmp));
					} else {
						qmet1 = get_metfromspin2(get_OSBdb2stuff(met1 + 1.,
						    &tmp));
						qmet2 = get_metfromspin2(get_OSBdb2stuff(met2 + 1.,
						    &tmp));
					}
					if (qmet1 <= 0. || qmet2 <= 0.) {
						if (verbos >= 0)
							warnx("get_goodtimes_for_des: loaded spins don't cover range %.1lf %.1lf", met1, met2);
						fclose(fp);
						free_degt(*gtlist);
						*gtlist = NULL;
						return(-1);
					}
					if (fabs(qmet1 - met1) > (double)HBtimeSlop) {
						if (verbos > 0)
							warnx("get_goodtimes_for_des:  start time %.1lf is misaligned with spin %.1lf", qmet1, met1);
					}
					if (fabs(qmet2 - met2) > (double)HBtimeSlop) {
						if (verbos > 0)
							warnx("get_goodtimes_for_des:  end time %.1lf is misaligned with spin %.1lf", qmet2, met2);
					}
					/* XXX We could be considerably more paranoid
					 * here.  Boundaries SHOULD be close to 12-spin
					 * cadences.  But they really needn't have to be,
					 * I suppose.
					 */
					/* Build the bitmap. */
					for (i = 0; i < HI_AZ_BINS; i++)
						qcull[i] = 0;
					for (i = angbin1; i <= angbin2; i++)
						qcull[i] = emap;
					/* If this cull's time range matches the last one,
					 * extend its bitmap.  Otherwise make a new one.
					 */
					if (q && q->met1 == qmet1 && q->met2 == qmet2 &&
					    q->whichcull == esa7) {
						for (i = 0; i < HI_AZ_BINS; i++) {
							if (q->cul[i] & qcull[i]) {
								if (verbos >= 0)
									warnx("get_goodtimes_for_des: overlapping cull angle %d line %d and preceding", i, line);
							} else
								q->cul[i] |= qcull[i];
						}
					} else if (q && q->met2 > qmet1 && q->whichcull == esa7) {
						if (verbos >= 0)
							warnx("get_goodtimes_for_des: overlapping times line %d and preceding -- dropping", line);
					} else {
						if (q) {
							if ((q->next = (degt *)malloc(sizeof(degt)))
							    == NULL)
								err(1, "get_goodtimes_for_des");
							q = q->next;
						} else {
							if ((*gtlist = (degt *)malloc(sizeof(degt)))
							    == NULL)
								err(1, "get_goodtimes_for_des");
							q = *gtlist;
						}
						q->whichcull = esa7;
						q->met1 = qmet1;
						q->met2 = qmet2;
						memcpy(q->cul, qcull, HI_AZ_BINS);
						q->next = NULL;
					}
				}
			}
		}
	}
	fclose(fp);
	return(0);
}

void
free_degt(degt *gtlist)
{
	degt *q;

	while (gtlist) {
		q = gtlist->next;
		free(gtlist);
		gtlist = q;
	}
}

/* Try to get exposure times on a .1 deg grid.
 * usedb2 :  nonzero to despin *
 * We don't actually want to calculate periods here:  we're going to claim
 * that ignoring clock drift, the entire arc had the same spin period, and
 * we can figure that out elsewhere.  Just count how many times we spun by
 * an angle, truly.  (Do use local period to determine phase, however.)
 */
int
build_exp(degt *gtlist, int whcull, int usedb2, int expos[HI_ENERGIES][3600])
{
	int i, j, k;
	int aa, bb, mid, nspins;
	int tspin, tspinp;
	int s1, s2, esa, eesa;
	degt *q;
	double tmet, tmp;
	double tstart, tend, pstart, pend;

	i = is_OSBdb_initialized();
	if (i < 1 || (i < 2 && usedb2))
	    return(-1);
	for (j = 0; j < HI_ENERGIES; j++)
		for (i = 0; i < 3600; i++)
			expos[j][i] = 0;
	q = gtlist;
	whcull = (1 << whcull);
	while (q && q->whichcull < whcull)
		q = q->next;
	if (!q || q->whichcull != whcull)
		return(0);
	i = 0;
	tmet = get_metfromspin((tspin = get_OSBdbstuff(
	    (double)hidetotlist[i]->met + 2, &tmp)));
	tspinp = -1;
while(1) {
	/* Advance to the first DE packet that overlaps with good times;
	 * we log every header packet, which should be every 12 HVSCI spins.
	 */
	while (tmet <= q->met1 && i < nhidetotlist - 1) {
		i++;
		tspinp = tspin;
		tmet = get_metfromspin((tspin = get_OSBdbstuff(
		    (double)hidetotlist[i]->met + 2, &tmp)));
		if (tmet < 0.) {
			warnx("build_exp:  don't have METs for DE intervals");
			return(1);
		}
	}
	if (i == nhidetotlist - 1 && tmet <= q->met1)
		return(0);
	/* How many spins are in a DE packet?  Use osbdba spin count since
	 * it's not stored in the packet.  We need full packets in good times
	 * because otherwise it's too difficult mapping spins to ESA.
	 *
	 * The previous packet must be at least 12 spins prior for this packet
	 * to be full.  If it is, ASSUME this packet is full.  If it's not,
	 * we're not allowed to have good times in it.
	 */
	if (tspin - tspinp < 12) {
		warnx("build_exp:  good times in a partly filled DE packet!");
		return(2);
	}
	if (tspin - tspinp > 12 && get_metfromspin(tspin - 12) > q->met1) {
		warnx("build_exp:  good times include a gap in DE packets!");
		return(3);
	}
	/* So we have 12 spins.  We proceed in groups of two.
	 * We need a start time, which is either spin start or gt start,
	 * and a spin end, which is either spin end or gt end.
	 */
	for (j = tspin - 12, esa = 1, eesa = 0;
	    j < tspin && esa < (1<<7); j += 2, esa <<= 1, eesa++) {
		tstart = get_metfromspin(j);
		tend = get_metfromspin(j+2);
		if (tstart < 0. || tend < 0.) {
			warnx("build_exp:  unknown spin times circa spin %d", j);
			continue;
		}
		if (eesa == 0) {
			/* shift the start one flyback bin later; flyback is taken
			 * from the period of the PREVIOUS spin (if we have it),
			 * because that's what the s/c knows at the time.
			 */
			if (get_OSBdbstuff(j - 1, &tmp) < 0)
				get_OSBdbstuff(j, &tmp);
			tstart += tmp/HI_AZ_BINS;
		}
		if (tstart < q->met1)
			tstart = q->met1;
		if (tend > q->met2)
			tend = q->met2;
		if (tstart >= tend)
			continue;	/* in for() loop */
		/* Get actual angle at start and end, and actual number of
		 * spins, if we need an osbd2a; otherwise, we start at phase 0.
		 * and end at phase 0.
		 */
		if (usedb2) {
			pstart = get_metfromspin2((s1 = get_OSBdb2stuff(tstart, &tmp)));
			pstart = (tstart - pstart)/tmp;
			pend = get_metfromspin2((s2 = get_OSBdb2stuff(tend, &tmp)));
			pend = (tend - pend)/tmp;
			nspins = s2 - s1 + 1;
		} else {
			/* Philosophy:  it's two full spins, so it STARTS at 0.0
			 * phase and ends just before phase 0.0 three spins later.
			 */
			nspins = 3;
			if (eesa == 0)
				pstart = 1./HI_AZ_BINS;
			else
				pstart = 0.0;
			pend = 0.0;
		}
		/* And now we know exactly how many spins to add! */ 
		if (pend < pstart) {
			aa = 3600. * pend + 0.5;	/* cheap rounding */
			bb = 3600. * pstart + 0.5;
			nspins--;
			mid = nspins -1;
		} else {
			aa = 3600. * pstart + 0.5;	/* cheap rounding */
			bb = 3600. * pend + 0.5;
			mid = nspins;
			nspins--;
		}
		for (k = 0; k < aa; k++)
			if (q->cul[k / 60] & esa)
				expos[eesa][k] += nspins;
		for (k = bb; k < 3600; k++)
			if (q->cul[k / 60] & esa)
				expos[eesa][k] += nspins;
		for (k = aa; k < bb; k++)
			if (q->cul[k / 60] & esa)
				expos[eesa][k] += mid;
	}
	/* Move to the next DE packet */
	i++;
	if (i == nhidetotlist)
		return(0);
	if (tmet > q->met2) {
		q = q->next;
		if (!q || q->whichcull != whcull)
			return(0);
	}
	tspinp = tspin;
	tmet = get_metfromspin((tspin = get_OSBdbstuff(
	    (double)hidetotlist[i]->met + 2, &tmp)));
	if (tmet < 0.) {
		warnx("build_exp:  don't have METs for DE intervals");
		return(1);
	}
}
	/* NOT REACHED */
	return(0);
}


#ifdef TESTING
/* cc -DTESTING -o decull decull.c -L obj/ -libexhi -lm -lz */
/* prints out pretty exact actual gt boundaries by cull */
int
main(int argc, char **argv)
{
	int i, j, k;
	uint32_t sm, em;
	degt *gts;

	simple_init_inertialpointing("no inertial pointing", 1);
	/* Testing only:  it's really icky.  Need args: orbit arc */
	i = getdefault_osbdba(atoi(argv[1]), atoi(argv[2]));
	printf("osdba: %d\n", i);
	get_burn_MET_of_orbit(atoi(argv[1]), atoi(argv[2]), &sm);
	get_burn_MET_after_orbit(atoi(argv[1]), atoi(argv[2]), &em);
	j = read_goodDEtimes(getenv("HI_CULL_FILE"), &gts, 1,
	    sm, em, (i > 1));
	printf("getgoodtimes: %d\n", j);
	while (gts) {
		printf("%d %.1lf %.1lf ", gts->whichcull, gts->met1, gts->met2);
		for (j = 0; j < HI_ENERGIES; j++) {
			k = 0;
			for (i = 0; i < HI_AZ_BINS; i++)
				if (gts->cul[i] & (1<<j))
					k++;
			if (k)
				printf(" 1");
			else
				printf(" 0");
		}
		printf("\n");
		gts = gts->next;
	}
	exit(0);
}
#endif
