/*	$Id: hi_de_gbc.c,v 1.10 2020/02/15 03:53:36 pjanzen Exp $	*/
/* For library inclusion, I'm pasting together a bunch of ISOC code.  One
 * reason is so I can make a bunch of stuff static and thus keep functions
 * that shouldn't be called remotely from being called remotely.
 */

static const char rcsid[] = "@(#) $Id: hi_de_gbc.c,v 1.10 2020/02/15 03:53:36 pjanzen Exp $";

#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ibexhi.h"

/* libccsds */
#include "ccsds_msg.h"
#include "hi_de_flt.h"

#include "hi_de_pack.h"

static int		_gbcverb = 0;
static int		howtosave = 0;

static HI_DE	post_pack[NSPINS][NAZIMS][MAX_DE_BIN];
static int	max_de_bin = MAX_DE_BIN, totals[NTYPES];

static PKTword  de_totals[16];
static PKTword	got_data[16];
static PKTword	vev_work[200 + MAX_DE_PKT + 1];
static PKTword	*violators = vev_work;
static PKTword	*ev_list;
static int	nev, nvi;
static int	nev_unpacked;

/*
 * Cache management
 */
static IBEXmsg	hi_de_frags[16];
static int	hi_de_fnum = 0, hi_de_done = 0;
static int	next_seqn = -1;
static Uint	cur_met;
static int	cur_spin;
static int	bb_errs = 0;

/*
 * The original packed stream, really need at most 1.5B/DE, but slop is good.
 */
static Byte	packed[6*MAX_HI_DE_FLT_PER_PACKET];


static void bit_bucket(int,int,int,int);
static void sort_cullage(HI_DE p[NSPINS][NAZIMS][MAX_DE_BIN]);

/* WAS
 * hi_de_raw.c
 *
 * Take the DEs unpacked from the telemetry and shove them into hbs[],
 * eventually.
 */

/* First bundle is pasted in from de_timetag.c and hacked up slightly.  */
/*
 * Take the MET time of packet generation, assume it is about
 * nspins after the time the number of the first spin was caught,
 * and generate a first spin value with upper bits correctly set.
 *
 * PJ: 'first' is spin % 256 from the data stream, so this all implies that
 * gbc lined things up to match the s/c spin count.  I should check.  If
 * so, this just puts the high bits back. 
 *
 * In theory first and spin should only be off by a few, and indeed,
 * probably not anywhere near +/- 127 or something is wrong....
 */
int
osb_orb_1st(double met, int first, int nspins, int *full_spin)
{
	double period;
	int spin;

	spin = get_OSBdbstuff(met, &period);
	if (spin < 0)
		return(-1);
	*full_spin = 0xFFFF;
	spin -= nspins;
	first |= (spin & 0xFF00);
	if (first - spin >  127)
		first -= 0x0100;
	else if (first - spin < -127)
		first += 0x0100;
	*full_spin = first & 0xFFFF;
	return(0);
}

/* I don't think anything I use cares if we don't just sit at 15.0s all the
 * time here.
 */
#if 0
/*
 * This is used if we are unpacking real data
 * TIMESTAMP_LIMIT is set to invoke this in *_de_unpack.c via *_de_gather.c
 */
int
timestamp_limit_spin(int spin)
{
	double 	period, pulse;
	int	tt_limit;

	if (first_OSBdb_entry)
		pulse = pulse_OSBdb(current_orbit,
			(unsigned short)(spin + first_cull_spin), &period);
	else
		period = est_spin_period;

	tt_limit = (int)(period*1e6/(double)USEC_PER_DE_TICK);
	return(tt_limit+1);
}
#endif

static int dotwiddle = 0;
static int bittwiddler = 0;
static void
printtwiddle()
{
	if (dotwiddle) {
		dotwiddle++;
		if (dotwiddle % 40 == 0) {
			bittwiddler = (bittwiddler + 1) % 4;
			switch(bittwiddler) {
			case 0:
				putchar('|');
				break;
			case 1:
				putchar('/');
				break;
			case 2:
				putchar('-');
				break;
			case 3:
				putchar('\\');
				break;
			}
			putchar(8);	/* ^H; puts cursor over packet pump */
			fflush(stdout);
		}
	}
}

/* Wow, this is exactly like save_events() except it calls a different
 * function in the innermost loop.
 */
static int
save_eventsdespin(int first_spin, uint32_t met)
{
	int sp, az, ev;
	int orbit, spin;

	orbit = osb_orb_1st((double)met, first_spin, NSPINS, &spin);

	for (sp = 0; sp < NSPINS; sp++) {
		for (az = 0; az < NAZIMS; az++)
			for (ev = 0; ev < MAX_DE_BIN; ev++) {
				if (post_pack[sp][az][ev].yn == TM_YES) {
	shove_des_into_hbs_despun(met, post_pack[sp][az][ev].type,
	    post_pack[sp][az][ev].timestamp, sp/2, sp, spin);
				}
			}
	}
	printtwiddle();
	return(0);
}
/*
 * Take the events from this cull cycle and added them to the list.
 * The spin logic here assumes that the packet time (met) in the
 * spin(s) just following the data.  If the low byte of the spin
 * for the packing time is less than the first_spin value, it means
 * the true spin upper byte rolled-over (by 1) between the first
 * spin and the packing byte.
 */
static int
save_events(int first_spin, uint32_t met)
{
	int sp, az, ev;
	int orbit, spin;
	int this_spin_had_data, spinswithdata;

	orbit = osb_orb_1st((double)met, first_spin, NSPINS, &spin);

	spinswithdata = 0;
	for (sp = 0; sp < NSPINS; sp++) {
		this_spin_had_data = 0;
		for (az = 0; az < NAZIMS; az++)
			for (ev = 0; ev < MAX_DE_BIN; ev++) {
				if (post_pack[sp][az][ev].yn == TM_YES) {
					this_spin_had_data = 1;
	shove_des_into_hbs_nodespin(met, post_pack[sp][az][ev].type,
	    post_pack[sp][az][ev].timestamp, sp/2, sp, spin);
				}
			}
		spinswithdata += this_spin_had_data;
	}
	printtwiddle();
	return(0);
}


/* WAS 
 * hi_de_gather.c
 *
 * Simple version of a HI_DE_FLT assembler that assumes
 * the packets are time and sequence sorted on input.
 */


/*
 * Suck in a large universe of unpacking code
 */
#define USEC_PER_DE_TICK (4200)        /* common/global.h */
#define TIMESTAMP_LIMIT        ((int)(18.5 * 1e6/(double)USEC_PER_DE_TICK))
/* #define TIMESTAMP_LIMIT	timestamp_limit_spin(sp)
extern int timestamp_limit_spin(int spin);
 */
/* #include "hi_de_unpack.c" */
/* ..pasting hi_de_unpack.c below.. */
/* WAS
 * hi_de_unpack.c
 *
 * HI DE packing test material unpack routines
 */

/*
 * For unstuffTwoTwelvesByN()
 */
/* #include "unpackTwoTwelves.c" */
/* ..pasting unpackTwoTwelves.c below.. */
/* WAS
 * unpackTwoTwelves.c
 */

/* #include "TwoTwelves.h" */
/* ..pasting TwoTwelves.h below.. */
/* WAS
 * TwoTwelves.h
 */

#ifndef TwoTwelves_h
#define TwoTwelves_h

/*
 * From John Hanley:
 *
 > If wVal1[15:0] and wVal2[15:0] each represented a 16-bit memory location
 > but contained only 12-bit numbers, we would be storing the nybbles in
 > this order in the stream:
 >
 > First  byte, first  nybble: wVal1[11: 8]  // more significant nybble
 > First  byte, second nybble: wVal1[ 7: 4]  // less significant nybble
 >
 > Second byte, first  nybble: wVal1[ 3: 0]
 > Second byte, second nybble: wVal2[11: 8]
 >
 > Third  byte, first  nybble: wVal2[ 7: 4]
 > Third  byte, second nybble: wVal2[ 3: 0]
 >
 > The code from SWAP:
 */

typedef struct _TRIBYTE {
	BYTE	abyData[3];
} TRIBYTE;

typedef struct _TWOWORD {
	WORD	awdData[2];
} TWOWORD;

/*
 * This function takes two 12-bits in shorts and turns it into a tri-byte
 */
/* extern TRIBYTE packTwoTwelves(WORD wVal1, WORD wVal2);
 */

/*
 * This version works with two byte streams:
 *      inWptr points to ntwos pairs of words with 12-bit quantities,
 *      outTptr points to 2*ntwos/3 byte-triples of storage;
 * The advanced outTptr pointer is returned.
 */
/* extern BYTE *stuffTwoTwelvesByN(WORD *inWptr, int npairs, BYTE *outTptr);
 */

/*
 * This is the corresponding unpack routine
 */
/* extern TWOWORD unpackTwoTwelves(TRIBYTE tVal);
 */

/*
 * This version works with two byte streams:
 *	inTptr points to ntribes byte triples,
 *	outWptr points 3*ntribes/2 byte-pairs of storage;
 * The advanced outWptr pointer is returned.
 */
/* extern WORD *unstuffTwoTwelvesByN(BYTE *inTptr, int ntriples, WORD *outWptr);
 */

#endif /* TwoTwelves_h */

/*
 * eof
 */

#if 0
/*
 * This unpacks a triple of bytes into the lower 12 bits of two words
 */
static TWOWORD unpackTwoTwelves(TRIBYTE tVal)
{
	TWOWORD unpacked;
	unpacked.awdData[0] = (tVal.abyData[0] << 4)
	                    | ((tVal.abyData[1] & 0xF0) >> 4);
	unpacked.awdData[1] = ((tVal.abyData[1] & 0x0F) << 8)
			    | (tVal.abyData[2]);

	return unpacked;
}
#endif

/*
 * This version works with two byte streams:
 *	inTptr points to ntribes byte triples,
 *	outWptr points 3*ntribes/2 byte-pairs of storage;
 * The advanced outWptr pointer is returned.
 */
static WORD *unstuffTwoTwelvesByN(BYTE *inTptr, int ntriples, WORD *outWptr)
{
	while (ntriples-- > 0) {
		*outWptr    = (*inTptr++) << 4;
		*outWptr++ |= (*inTptr & 0xF0) >> 4;
		*outWptr    = ((*inTptr++) & 0x0F) << 8;
		*outWptr++ |= (*inTptr++);
	}
	return outWptr;
}

/*
 * End of unpackTwoTwelves.c
 */

/*
 * Invert the packing into the work arrays, resetting pointers & counters.
 */
static void
unpack_hide_to_work(PKTword *pkt, int size)
{
	/* invert the packing back into the working arrays */
	unstuffTwoTwelvesByN((BYTE*)(pkt),      2*12/3,          de_totals);
	unstuffTwoTwelvesByN((BYTE*)(pkt + 12), 2*12/3,          got_data);
	unstuffTwoTwelvesByN((BYTE*)(pkt + 24), 2*(size-24+2)/3, vev_work);
	nvi = vev_work[0];
	nev = vev_work[nvi-1];
	ev_list = vev_work + nvi;
}

/*
 * We probably want to do other processing with the events,
 * but unloading to post_pack is a good way to test.
 */
static void
reload_post_pack_spin_first(void)
{
	int	ty, sp, az, ev, mask;
	int	vio = 0, evi = 0, evn, this, next;
	HI_DE	*dep;

	nev_unpacked = 0;	/* count number of events unpacked */

	this = ev_list[evi];
	/* violators[0] has nvi */
	evn = violators[++vio];
	for (sp = 0, mask = 0x1; sp < NSPINS; sp++, mask <<= 1) {
	     for (ty = 0; ty < NTYPES; ty++) {
		if ((got_data[ty] & mask) == DE_ABSENT) continue;

		do {

			/* figure out where to stick this stamp */
			az = (this * NAZIMS) / TIMESTAMP_LIMIT;
			if (az >= NAZIMS) az = NAZIMS-1;
			dep = &post_pack[sp][az][ev = 0];
			while (dep->yn && ++ev < MAX_DE_BIN) dep++;
			//assert(ev < max_de_bin);
			if (ev < max_de_bin) {
			    /* ok to assign it */
			    dep->timestamp = this;
			    dep->type = ty;
			    dep->yn = TM_YES;
			} else {
			    /* this should not happen */
				bit_bucket(ty,sp,az,this);
			}
			nev_unpacked ++;

			/* are we staying with this spin-type? */
			next = ev_list[++evi];
			ev = next - this;
			this = next;

		} while (evi < evn && ev >= 0);

		/* protection against mal-formed packets */
		if (vio == nvi) return;

		if (evi == evn) evn = violators[++vio];

	    }
	}
}

/*
 * Invert the packing operation, saving results to post_pack.
 * Returns nonzero on error.
 */
static int
unpack_hide(PKTword *pkt, int size)
{
	int	ty;

	/* unpack into working arrays */
	vev_work[200 + MAX_DE_PKT] = 0xFF;
	unpack_hide_to_work(pkt, size);
	assert(vev_work[200 + MAX_DE_PKT] == 0xFF);

	reload_post_pack_spin_first();
	sort_cullage(post_pack);

	/* export */
	for (ty = 0; ty < NTYPES; ty++) totals[ty] = de_totals[ty];

	return(nev - nev_unpacked);
}


/*
 * END of hi_de_unpack.c
 */

/*
 * Actually we probably want the events put back into time-sorted order.
 */
static int
compare_events(const void *a, const void *b)
{
	const HI_DE	*dea = (const HI_DE *)a;
	const HI_DE	*deb = (const HI_DE *)b;
	if (dea->timestamp < deb->timestamp) return(-1);
	if (dea->timestamp > deb->timestamp) return( 1);
	if (dea->type	   < deb->type)	     return(-1);
	if (dea->type	   > deb->type)	     return( 1);
	return(0);
}
static void
sort_cullage(HI_DE p[NSPINS][NAZIMS][MAX_DE_BIN])
{
	int	spin, azi, ev, n;
	HI_DE q[MAX_DE_BIN];

	for (spin = 0; spin < NSPINS; spin++)
	    for (azi = 0; azi < NAZIMS; azi++) {
		n = 0;
		for (ev = 0; ev < MAX_DE_BIN; ev++)
			if (p[spin][azi][ev].yn == TM_YES) {
				memcpy(&q[n], &p[spin][azi][ev], sizeof(HI_DE));
				n++;
			}
		qsort(q, n, sizeof(HI_DE), compare_events);
		memcpy(&p[spin][azi][0], q, n * sizeof(HI_DE));
		bzero(&p[spin][azi][n], (MAX_DE_BIN - n) * sizeof(HI_DE));
#if 0
		for (ev = 0; ev < MAX_DE_BIN-1; ev++)
			assert((p[spin][azi][ev].timestamp <=
				p[spin][azi][ev+1].timestamp) ||
			       (p[spin][azi][ev+1].yn == TM_ZIP));
#endif
	    }
	return;
}

static void
bit_bucket(int ty,int sp,int az,int ts)
{
    bb_errs ++;
    if (_gbcverb>0) fprintf(stderr,
	"Extra[%d] type %d spin %d bin %d at %d (%u)\n",
	    bb_errs, ty, sp, az, ts, cur_met);
}


/*
 * we don't really need much of a cache--just 2 or 3 messages
 */
static void
init_de_cache(void)
{
	while (hi_de_fnum-- > 0) {
		if (!hi_de_frags[hi_de_fnum].msg) break;
		if (_gbcverb>2) fprintf(stdout,
			"Freeing fragment %d (%08X)\n",
			hi_de_fnum, (int)hi_de_frags[hi_de_fnum].msg);
		free(hi_de_frags[hi_de_fnum].msg);
		hi_de_frags[hi_de_fnum].msg = 0;
	}
	hi_de_fnum = 0;
	hi_de_done = 0;
	next_seqn = -1;	/* unknown */
	cur_spin = cur_met = 0;
}

/*
 * States:
 *	nothing in progress	(fnum = 0)
 *		if single, save and mark done
 *		if start, save and bump seqn
 *	have a start
 *		if middle, save and bump seqn
 *		if finish, save and mark done
 *		if start | single wipe and reenter
 */
static void
cache_de_flt(IBEXmsg *m)
{
	HI_DE_FLT_msg	*mp = (HI_DE_FLT_msg *)(m->msg);

	assert(hi_de_fnum <= 16);
	memcpy(&hi_de_frags[hi_de_fnum], m, sizeof(IBEXmsg));

	if (_gbcverb>1) fprintf(stdout,
		"HI_DE_FLT #%04X%c First%4d Count%5d MET %d.0 (%08X) [%02d]\n",
		m->seqn, grup_labels[m->grup],
		mp->first, mp->count, m->met.ui, (int)m->msg, hi_de_fnum);

	if (hi_de_fnum == 0) {
		if (m->grup == PKT_GRP_MIDDLE ||
		    m->grup == PKT_GRP_FINISH ) {
			init_de_cache();
			return;
		}

		hi_de_fnum++;
		if (m->grup == PKT_GRP_SINGLE) hi_de_done = 1;
		cur_met = m->met.ui;
		cur_spin = mp->first;

	} else {
		if (m->seqn != next_seqn ||
		    m->grup == PKT_GRP_START ||
		    m->grup == PKT_GRP_SINGLE) {
			/* current msg safe: hi_de_fnum not yet bumped */
			init_de_cache();
			cache_de_flt(m);	/* start over */
			return;
		}

		hi_de_fnum++;
		if (m->grup == PKT_GRP_FINISH) hi_de_done = 1;
	}

	if (_gbcverb>2 && hi_de_done) fprintf(stdout,
		"Have a complete set of %d fragments.\n", hi_de_fnum);
	if (hi_de_done) return;

	assert (m->grup == PKT_GRP_START || m->grup == PKT_GRP_MIDDLE);
	next_seqn = (m->seqn + 1) & PKT_SEQ_MASK;
}

/*
 * We have no work if no complete sequence, otherwise gather
 * the bytes and ship them off for unpacking and other actions.
 */
static int
check_de_cache(void)
{
	HI_DE_FLT_msg	*mp;
	int		bytes = 0, by, frag, lost;
	Byte		*pp = packed;
	/* Word		full_spin; */

	if (!hi_de_done) return(0);
	hi_de_done = 0;
	memset(post_pack, 0, sizeof(post_pack));

	for (frag = 0; frag < hi_de_fnum; frag++) {
		mp = (HI_DE_FLT_msg *)(hi_de_frags[frag].msg);
		by = mp->count;
		/* PJ paranoia */
		if (by < 0  || pp + by > packed + 6*MAX_HI_DE_FLT_PER_PACKET) {
			fprintf(stderr, "by bye");
			exit(10);
		}
		memcpy(pp, mp->packed, by);
		pp += by;
		bytes += by;
	}

#if 0
	/* unpack it -- need to get timestamp limit */
	current_orbit = osb_orb_1st((double)cur_met,
		cur_spin, NSPINS, &full_spin);
	first_cull_spin = full_spin;
	if (_gbcverb>2) fprintf(stdout,
		"Unpack_hide() on %d words @MET %u spin %d => orbit %d %d\n",
		bytes/2, cur_met, cur_spin, current_orbit, first_cull_spin);
#endif
	lost = unpack_hide((Word*)packed, bytes / 2);

	/* lost == 0 on a successful unpack */
	if (lost) fprintf(stderr, "Unable to unpack %d events!!!\n", lost);

#if 0
	if (show_unpack) { 	/* debugging */
		unpack_report(got_data, violators, ev_list, nev, nvi, lost);
	}
	if (show_cullage)
		post_pack_dump(cur_spin, cur_met);
#endif
	if (/*hide_ofile &&*/ !lost) {
		if (howtosave == 1) {
	    if (save_eventsdespin(cur_spin, cur_met))
		fprintf(stderr, "Problem with events at %d.0\n", cur_met);
		} else {
	    if (save_events(cur_spin, cur_met))
		fprintf(stderr, "Problem with events at %d.0\n", cur_met);
		}
	}
#if 0
	if (tcde_ofile && !lost) {
	    if (save_totcnt(cur_spin, cur_met))
		fprintf(stderr, "Problem with totcnt at %d.0\n", cur_met);
	}
#endif

	init_de_cache();
	return(1);
}

/*
 * read HI_DE_FLT packets from the file, returning nonzero on error
 */
/* ENTRY POINT */
int
assemble_de_packets_old(char *file, int printpump, int whichtreat,
    uint32_t stm, uint32_t endm)
{
	int	gtot, ftot;
	static IBEXpkt	pkt;
	static IBEXmsg	msg[16];	/* round robin */
	int		fd;
	int		cm, locerr;
	int		pkts, frags, good;

	gtot = ftot = 0;
	cm = locerr = pkts = frags = good = 0;
	fd = open(file, O_RDONLY);
	if (fd < 0) {
		perror("assemble_de_packets");
		return(-1);
	}
	init_de_cache();
	bb_errs = 0;
	dotwiddle = printpump;
	howtosave = whichtreat;

	/* loop through file gathering HI_DE_FLT msgs */
	while (1) {
		locerr = Read_IBEXpkt(pkt, fd, 0);
		if (locerr < 0) {
			if (locerr != IBEX_PKT_ERR_EOF)
				fputs(report_IBEXpkt_error(locerr, 1), stderr);
			else
				locerr = 0;
			break;	/* eof, typically */
		}
		IBEX_pkt2msg(pkt, &msg[cm]);
		if (msg[cm].apid == HI_DE_FLT &&
		    ((HI_DE_FLT_msg *)(msg[cm].msg))->met + 690 >= stm &&
		    ((HI_DE_FLT_msg *)(msg[cm].msg))->met <= endm) {
			cache_de_flt(&msg[cm]);
			frags++;
			good += check_de_cache();
		} else {
			/* dispose of allocated space */
			free(msg[cm].msg);
		}
		cm = (cm + 1) & 0xF;
		pkts++;
	}
	ftot += frags;
	gtot += good;

	if (_gbcverb>0) fprintf(stdout,
		"Processed %s with %d pkts, %d HI_DE_FLT msgs in %d frags,"
		" for %d/%d total.\n", 
		file, pkts, good, frags, ftot, gtot);

	if (bb_errs) {
	    fprintf(stderr,
		"Discarded %d events which should not exist.\n", bb_errs);
	    locerr++;
	}
	close(fd);

	return(locerr);
}
