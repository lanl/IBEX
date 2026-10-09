/*	$Id: dode.c,v 1.41 2020/02/20 03:56:42 pjanzen Exp $	*/
/* Internals for populating fake histogram bins with direct event data.
 * The actual reading is done by Geoff's library elsewhere, and the orbital
 * spin bin database stuff is external too.
 *
 * The assumption is that the hbs have been read through and initialized
 * already, and that we're rereading a pkt_pl file to put the DEs into one
 * or more of the extant hbs.
 */

static const char rcsid[] = "@(#) $Id: dode.c,v 1.41 2020/02/20 03:56:42 pjanzen Exp $";

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/uio.h>
#include <ctype.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ibexhi.h"

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
 *
 * qABC = 5 | 10 | 14
 * lABC = qABC | 2 | 7 | 15, except we don't actually keep 2, 7, or 15.
 * lBC = 0 | 3 | 6
 * qAC = 8
 */
#define HI_DE_TYPES (16)


/* We can "zoom in" on a range, if we want, by limiting the phase allowed.
 * Nominal DE resolution is about .1 degree, or a phase of .1/360 = .0003
 */
static double phase_min = 0.0;
static double phase_max = 1.0;

/* We can either despin or not.  For this round, I don't see the point of
 * allowing cadences other than 48 spins; that could go in, but xhihb has
 * certain assumptions as to relative hb cadences.
 *
 * Thus not despinning amounts to storing up data until we're done
 * processing a packet, and if that packet's MET is close to (i.e. within a
 * spin) of a qABC packet, dump to that time.
 *
 * Despinning is more involved, because we want to stop on a despun spin
 * boundary, and the timing gets all mucked up.  But basically, we want to
 * dump up to spin <x> into one temporary pile, dump after spin <x> into
 * another temporary pile, and write out the first pile when we're sure
 * it's properly full (i.e., it's enough time later, like at least 12 real
 * spins).  Whatever does the calling then has to worry about MET, because
 * truly everything ought to be reset to the new timing.
 */

/* What hbs to replace:  if the value is nonzero, it's a bitmap of the DEs
 * to put in.
 */
static uint16_t hbreplacer[BIN_TYPES];

/* Next two used only by shove_..._despun(), but need to be resettable
 * externally.  Also used by adp_despin().
 */
static uint32_t SDE_lastmet = 0;
static int SDE_lastn = 0;
/* And likewise for shove_.._nodespin(). */
static uint32_t SSP_lastmet = 0;

#ifdef DO_PS
typedef struct {
	double met;
	double phase;
	int esa;
	uint16_t ev;
} DElog_c;

static DElog_c *de_list;
static long de_listn = 0;
static long de_listnmax = 0;

static void
add_ev(double mett, double phase, int esa, uint16_t evtype)
{
	DElog_c *tmp1;

	if (de_listn >= de_listnmax) {
		if (de_listnmax <= 0) {
			tmp1 = (DElog_c *)calloc(sizeof(DElog_c), 10000);
			de_listnmax = 10000;
		} else {
			tmp1 = (DElog_c *)realloc(de_list, sizeof(DElog_c) *
			    (de_listnmax + 10000));
			de_listnmax += 10000;
		}
		if (!tmp1)
			errx(100, "FATAL: add_ev out of mem");
		de_list = tmp1;
	}
	de_list[de_listn].met = mett;
	de_list[de_listn].phase = phase;
	de_list[de_listn].esa = esa;
	de_list[de_listn].ev = (1<<evtype);
	de_listn++;
}

/* XXX - note that I am NOT rounding to 12-spin boundaries, and that basing
 * DE goodness on histogram timestamping will therefore do questionable
 * things at the start of ESA 1 and the end of ESA 6.  Kludge accordingly.
 * XXX
 */
static int
PSDE_isincull(int culln, uint32_t met, int esa, int angbin)
{
	static int oi = 0;
	int shifty;

	if (esa == 0)
		shifty = -3 * HBtimeSlop;
	else if (esa == 5)
		shifty = 3 * HBtimeSlop;
	else
		shifty = 0;
	if (met < alltimes[0] || met > alltimes[nallt-1])
		return(0);
	if (oi > nallt) {
		oi = 0;
	}
	esa = (1 << esa);
	while (oi >= 0 && alltimes[oi] > met + shifty)
		oi--;
	if (oi < 0) {
		/* debug/warning printf() might be a good idea */
		oi = 0;
	}
	while (nallt > oi && alltimes[oi] < met - shifty)
		oi++;
	if (oi == nallt) {
		printf("XX- %d %u\n", oi, met);
		oi = 0;
	}
	if ((mculls[culln][oi * HI_AZ_BINS + angbin] & esa))
		return(1);
	else
		return(0);
}

/* Needs inertial pointing loaded.  Dump is 2 columns of pointing info, one
 * integer of "nominal spin bin" for correlating to backgrounds, and
 * then alternating total counts and exposure times in "Hz" for our 6-deg
 * bins.  timinghb has to be 48-spin cadence.  Note that for no good reason
 * everything has to be in ONE cull, so if good+loose is the goal, this
 * needs an "ISOC"-style loose cull.  In such a case, though, I'd need to
 * transmit along what the offset is.  That'll be a separate "ISOC"-style
 * offset file too...
 */
void
dump_good_evs(char *fname, int whichcull, uint16_t whichevs, int nbins,
    int timinghb)
{
	FILE *fp;
	long *ds;
	int dsn[HI_ENERGIES][HI_AZ_BINS], i, j, k;
	double la, lng;
	int orbit, arc;

	if (whichcull < 0 || whichcull >= 8 || nbins <= 0 || timinghb < 0 ||
	    timinghb >= BIN_TYPES || de_listn < 2)
		return;
	for (i = 0; i < HI_AZ_BINS; i++)
		for (j = 0; j < HI_ENERGIES; j++)
			dsn[j][i] = 0;
	if (nbins % HI_AZ_BINS)
		warnx("dump_good_evs is dumping to bins which do NOT\n\
line up with 6-degree histogramming:  exposure times may be erroneously\n\
calculated");
	orbit = get_orbit_at_met((uint32_t)(de_list[0].met), &arc);
	i = get_orbit_at_met((uint32_t)(de_list[de_listn - 1].met), &j);
	if (orbit < 0)
		errx(1, "called dump_good_evs() without pointing information loaded");
	if (i != orbit || j != arc)
		errx(1, "not one arc? (%d %d vs %d %d)", orbit, arc, i, j);
	ds = (long *)calloc(nbins * HI_ENERGIES, sizeof(long));
	if (!ds)
		err(100, "dump_good_evs");
	for (i = 0; i < de_listn; i++) {
		if ((whichevs & de_list[i].ev) &&
		    PSDE_isincull(whichcull, de_list[i].met + 0.5, de_list[i].esa,
		    de_list[i].phase * HI_AZ_BINS)) {
			j = de_list[i].phase * nbins;
			if (j >= 0 && j < nbins)
				ds[j + nbins * de_list[i].esa]++;
			else
				warnx("dump_good_evs - odd phase?");
		}
	}
	for (i = 0; i < HI_AZ_BINS; i++)
		for (j = 0; j < HI_ENERGIES; j++)
			for (k = 0; k < hbs[timinghb].n; k++)
				if (isincull(whichcull, hbs[timinghb].met[k], j, i))
					dsn[j][i]++;
	if ((fp = fopen(fname, "w")) == NULL)
		err(1, "dump_good_evs fopen");
	fprintf(fp, "# Dump of events 0x%X in cull %d, into %d bins\n",
	    whichevs, whichcull, nbins);
	fprintf(fp,
"# ESAs are AS ON SPACECRAFT regardless of sweep table.\n\
# First two columns: ecliptic lat and long of central look direction.\n\
# Next column:  nominal spin bin number (0-59).\n\
# Remaining columns:  total counts in the angle range, and exposure time\n\
# per six degree bin.\n");
	for (i = 0; i < nbins; i++) {
		/* Have to subtract 3 degrees since spin pulse is 3 deg short of
		 * closest-to-NEP?  No, because we want the _centre_ of the spin bin.
		 */
		get_la_lng_from_orb_ang(orbit, arc,
		    360. / nbins * i + 180. / nbins - 3., &la, &lng);
		/* Do NOT have to subtract 3 degrees here since all bins are
		 * lined up off spin pulse.
		 */
		j = (double)HI_AZ_BINS/nbins * i + 1e-5;
		fprintf(fp, "%lf\t%lf\t%d", la, lng, j);
		for (j = 0; j < HI_ENERGIES; j++) {
			k = (double)HI_AZ_BINS * i / (double)nbins;
			/* XXX TODO: convert to Hz from /hb */
			fprintf(fp, "\t%ld\t%d", ds[nbins * j + i], dsn[j][k]);
		}
		fprintf(fp, "\n");
	}
	fclose(fp);
	free(ds);
}
#endif

void
setup_hb_to_DEang(double pmin, double pmax)
{
	if (pmin < 0.)
		pmin = 0.0;
	if (pmax > 1.)
		pmax = 1.0;
	if (pmax < pmin) {
		phase_min = pmax;
		phase_max = pmin;
	} else {
		phase_min = pmin;
		phase_max = pmax;
	}
}

void
setup_hb_to_DE(int which, uint16_t map)
{
	if (which == HB_QABC || which == HB_BM || which < 0 || which > BIN_TYPES)
		return;
	hbreplacer[which] = map;
}

void
clear_hb_to_DE()
{
	int i;
	
	for (i = 0; i < BIN_TYPES; i++)
		hbreplacer[i] = 0;
}

/* Excluding the 'DE' at the start, convert a typical name to a bitmap.
 * Don't be case-sensitive.  Return all bits 0 on failure.
 */
uint16_t
convert_de_name_to_bitmap(char *foo)
{
	uint16_t toset;
	char *q;
	int j;

	toset = 0;
	if (!strcasecmp(foo, "qABC"))
		toset = 0x4420;
	else if (!strcasecmp(foo, "sdub"))
		toset = 0x0149;
	else if (!strcasecmp(foo, "lABC"))
		toset = 0xC4A4;
	else if (!strcasecmp(foo, "lBC"))
		toset = 0x0049;
	else if (!strcasecmp(foo, "qBC"))
		toset = 0x0008;
	else if (!strcasecmp(foo, "qAC"))
		toset = 0x0100;
	else if (!strcasecmp(foo, "lAC"))
		toset = 0x0902;
	else if (!strcasecmp(foo, "qAB"))
		toset = 0x0200;
	else if (!strcasecmp(foo, "lAB"))
		toset = 0x2210;
	else if (strlen(foo) == 16) {
		q = foo;
		for (j = (1<<15); j > 0; j /= 2) {
			if (*q == '1')
				toset |= j;
			else if (*q != '0') {
				toset = 0;
				j = 0;	/* i.e., break */
			}
			q++;
		}
	}
	return(toset);
}


/* Allocate a nice name for our DEs.  It's actually pretty ugly if it's not
 * one of the usual suspects:  I shove the bitmap into the 16 characters
 * starting with 'f'.
 */
static char *
get_de_name(uint16_t foo)
{
	char *bar;

	switch(foo) {
	case 0x4420:
		bar = strdup("DEqabc");
		break;
	case 0xC4A4:
		bar = strdup("DElabc");
		break;
	case 0x0049:
		bar = strdup("DElbc");
		break;
	case 0x0008:
		bar = strdup("DEqbc");
		break;
	case 0x0100:
		bar = strdup("DEqac");
		break;
	case 0x0902:
		bar = strdup("DElac");
		break;
	case 0x0200:
		bar = strdup("DEqab");
		break;
	case 0x2210:
		bar = strdup("DElab");
		break;
	case 0x0149:
		bar = strdup("DEsdub");
		break;
	default:
		bar = strdup("DExxxx");
		if (bar == NULL)
			err(1, "silly strdup fail");
		bar[3] = 'f' + ((foo & 0xF000) >> 12);
		bar[4] = 'f' + ((foo & 0x0F00) >> 8);
		bar[5] = 'f' + ((foo & 0x00F0) >> 4);
		bar[6] = 'f' +  (foo & 0x000F);
		break;
	}
	if (bar == NULL)
		err(1, "silly strdup fail");
	return(bar);
}

static void
make_de_names_unique()
{
	int i, j;
	char *bar;

	/* Keep out duplicate names - compare to what's already in the hbs.
	 * First hb is always qABC.
	 */
	for (i = 0; i < BIN_TYPES - 1; i++) {
		if ((hbs[i].name)[0] == 'D') {
			for (j = i+1; j < BIN_TYPES; j++) {
				bar = hbs[j].name;
				if (!strcmp(bar, hbs[i].name)) {
					bar[1]++;
					i = 0;
				}
			}
		}
	}
}

static void
clear_one_hb(int i)
{
	int j;

	if (i < 0 || i >= BIN_TYPES)
		return;
	free(hbs[i].name);
	for (j = hbs[i].n - 1; j >= 0; j--)
		free(*(hbs[i].data[j]));
	if (hbs[i].n) {
		free(hbs[i].met);
		free(hbs[i].spincount);
		free(hbs[i].data);
	}
}

/* hbs[i].nmax must hold the required size. */
static void
alloc_a_hb(int i)
{
	int j;

	if (i < 0 || i >= BIN_TYPES)
		return;
	if ((hbs[i].met = (uint32_t *)
	    calloc(hbs[i].nmax, sizeof(uint32_t))) == NULL ||
	    (hbs[i].spincount = (int *)
	    calloc(hbs[i].nmax, sizeof (int))) == NULL ||
	    (hbs[i].data = (garray **)
	    calloc(hbs[i].nmax, sizeof (garray *))) == NULL)
		err(1, "alloc_a_hb()");
	for (j = 0; j < hbs[i].nmax; j++)
		if ((*(hbs[i].data + j) = (garray *)
		    calloc(sizeof(garray), 1)) == NULL)
			err(1, "alloc_a_hb()");
}

/* Add a hundred more to existing nmax.  I wish recalloc() were standard. */
static void
grow_a_hb(int i)
{
	int j, k;

	if (i < 0 || i >= BIN_TYPES)
		return;
	k = hbs[i].nmax;
	hbs[i].nmax += 100;
	/* Since we immediately err() out on failure, it doesn't matter that
	 * we leak memory on a realloc() fail.  If we didn't, this would need
	 * to be rewritten!
	 */
	if ((hbs[i].met = (uint32_t *)
	    realloc(hbs[i].met, hbs[i].nmax * sizeof(uint32_t))) == NULL ||
	    (hbs[i].spincount = (int *)
	    realloc(hbs[i].spincount, hbs[i].nmax * sizeof (int))) == NULL ||
	    (hbs[i].data = (garray **)
	    realloc(hbs[i].data, hbs[i].nmax * sizeof (garray *))) == NULL)
		err(1, "grow_a_hb()");
	for (j = k; j < hbs[i].nmax; j++)
		if ((*(hbs[i].data + j) = (garray *)
		    calloc(sizeof(garray), 1)) == NULL)
			err(1, "grow_a_hb()");
}

/* set up hbs[dst] to match hbs[src] in terms of timing and spincounts. */
static void
copyover_hb(int dst, int src)
{
	if (dst < 0 || src < 0 || dst >= BIN_TYPES || src >= BIN_TYPES)
		return;
	hbs[dst].n = hbs[src].n;
	hbs[dst].nmax = hbs[src].n;
	alloc_a_hb(dst);
	memcpy(hbs[dst].met, hbs[src].met,
	    hbs[src].n * sizeof(uint32_t));
	memcpy(hbs[dst].spincount, hbs[src].spincount,
	    hbs[src].n * sizeof(int));
}


/* Once hbreplacer[] is initialized, prep the associated hbs by freeing
 * them and copying over the met and spincount arrays of the qABCs.
 * Reset names as necessary?  Yes; xhihb:kbd.c parses on that, as long as
 * the names are space-free and simple.
 * The data array is calloc()ed too.
 */
void
setup_spundata()
{
	int i, tot;

	/* Reset the speed-increasing statics in shove_des_into_hbs_nodespin() */
	SSP_lastmet = 0;
	/* We must keep the qABCs. HB_QABC has to be 0 here.  */
	if (0 != HB_QABC)
		errx(1, "someone refined HB_QABC and setup_spundata() can't have that.");
	if (hbreplacer[HB_QABC])
		fprintf(stderr,
		    "setup_spundata:  request to update qABC hbs ignored.\n");
	tot = 0;
	for (i = 1; i < BIN_TYPES; i++) {
		if (hbreplacer[i]) {
			tot++;
			/* Clear it. */
			clear_one_hb(i);
			/* Copy over qABC stuff.  Die on malloc() fail. */
			copyover_hb(i, HB_QABC);
			/* Twiddle */
			hbs[i].flag = TLC_HIDE;
			hbs[i].name = get_de_name(hbreplacer[i]);
		}
	}
	make_de_names_unique();
}

/* utility:  grow hbs[i].n (up to nmax) by 48-spin jumps, not to exceed
 * given met.  fill should be 48 unless we're inserting gap frames.
 */
static void
fill_unperturbed_until(uint32_t met, int i, int fill)
{
	int j, k;
	double tmp;

	/* hb packet MET may be before the actual end of spin due to truncation */
	if ((j = get_OSBdb2stuff((double)met + 1.5, &tmp)) < 0)
		return;
	/* we have set the MET of the packet to 1s past the start of the first
	 * spin outside the range.
	 */
	if ((k = get_OSBdb2stuff((double)(hbs[i].met[(hbs[i].n - 1)]) + 1.5, &tmp))	    < 0)
		return;
	while (k + 48 <= j) {
		k += 48;
		tmp = get_metfromspin2(k);
		if (tmp > 0.) {
			/* Avoid truncation issues again by adding a second */
			hbs[i].met[(hbs[i].n)] = (uint32_t)tmp + 1;
			hbs[i].spincount[(hbs[i].n)] = fill;
			(hbs[i].n)++;
			if (hbs[i].n == hbs[i].nmax)
				grow_a_hb(i);
		}
	}
#ifdef DEBUG
	printf("u");
#endif
}

/* utility:  make a partial hb up to a given spin.  Last number is
 * how many spins to use; none of them are exact because despun means
 * partial spins.
 */
static void
fill_perturbed_to(uint32_t met, int i, int spinz)
{
	if (spinz <= 0)
		spinz = 1;
	if (spinz > 48)
		spinz = 48;
	if (hbs[i].n == hbs[i].nmax)
		grow_a_hb(i);
	/* Avoid truncation issues shifting spin by adding a second */
	hbs[i].met[(hbs[i].n)] = met + 1;
	hbs[i].spincount[(hbs[i].n)] = spinz;
	(hbs[i].n)++;
#ifdef DEBUG
	printf("P");
#endif
}

/* As setup_spundata(), but more complicated because the timing can get
 * screwy.  Rather than simply copying METs and spincounts from the hbs,
 * maximize full data periods as follows:
 * - the first hb packet may start at any angle, so create a hb to catch
 * the partial stuff at the start (spincount = 12, MET = first multiple of
 * 12 spins at least one spin later).
 * - then, as long as all hb packets have 48 spins and are a plausible time
 * apart, keep setting up METs 48 spins later than previous, with a full
 * spincount.
 * - whenever there's a gap or an ending, make partial packets as at the
 * start to catch anywhere where we didn't definitely get 48 full spins.
 *
 * This logic means it's definitely best to run this before culling partial
 * hbs.
 *
 * ESA 1 has a spin bin that's not properly filled when this goes through,
 * but fortunately we don't really use ESA 1...
 */
void
setup_despundata()
{
	int i, j, k, ii;
	int donethisone;
	double tmp;

	/* Interesting:  shove_des_into_hbs_despun() has some statics that
	 * will cause grief if we get called more than once (particularly
	 * if it's different orbits.  So reset them here.
	 */
	SDE_lastmet = 0;
	SDE_lastn = 0;
	/* Only go through the MET calculation suffering once, and copy it if
	 * more than one array's being set up.
	 */
	donethisone = -1;
	/* We must keep the qABCs. HB_QABC has to be 0 here.  */
	if (0 != HB_QABC)
		errx(1, "someone refined HB_QABC and setup_spundata() can't have that.");
	if (hbreplacer[HB_QABC])
		fprintf(stderr,
		    "setup_despundata:  request to update qABC hbs ignored.\n");
	for (i = 1; i < BIN_TYPES; i++) {
		if (hbreplacer[i]) {
			/* Clear it. */
			clear_one_hb(i);
			if (donethisone >= 0)
				copyover_hb(i, donethisone);
			else {
				/* max possible number will be final qABC spin minus
				 * first qABC spin divided by 48 plus 2, except there
				 * can be partials every time we drop out of HVSCI.
				 * Usually we won't drop out of HVSCI more than 30 times.
				 * Shift over a second later so truncation doesn't shift
				 * spin.
				 */
				j = get_OSBdb2stuff((double)
				    (hbs[HB_QABC].met[hbs[HB_QABC].n - 1]) + 1.5, &tmp);
				k = get_OSBdb2stuff((double)
				    (hbs[HB_QABC].met[0]) + 1.5, &tmp);
				if (j < 0 || k < 0 || j < k)
					errx(1,
"trying to despin data without a sufficient spin bin database (%lf).",
(double) (hbs[HB_QABC].met[hbs[HB_QABC].n - 1]) + 1.5);
				hbs[i].nmax = 32 + (j - k)/48;
				alloc_a_hb(i);
/* XXX ? There are likely philosophical issues in offsetting all the DE
 * stuff 12 spins from the hbs, particularly since the ISOC likes to track
 * on 24 spin boundaries to match ESA sweeps Hi and Lo.  So rather than
 * potentially maximizing data by this shift, start with the same MET as
 * the first hb, but put the spincount to 47.
 *
 * Hmm.  Well, on further consideration, 24-spin boundaries become
 * nonsensical once the spin misses, so screw that.  The goal then is just
 * to match up as much as possible timewise to first HVSCI packets of a
 * chunk.
 */
				hbs[i].spincount[0] = 47;
				tmp = get_metfromspin2(k);
#ifdef DEBUG
				printf("%lf from %u\n", tmp, hbs[HB_QABC].met[0]);
#endif
				if (tmp < 0.)
					errx(2, "this shouldn't happen.");
				hbs[i].met[0] = (uint32_t)tmp + 1;
				hbs[i].n = 1;
				for (ii = 1; ii < hbs[HB_QABC].n; ii++) {
/* March along unperturbed if we have 48 spins, if there isn't a gap (i.e.,
 * the time since the previous packet isn't more than default cadence plus
 * a spin plus a bit), and if we've covered enough despun spins in our 48
 * "spun" spins.
 * If we don't have 48 spins, put a lower number in our new spin cadence
 * and fake an appropriate intermediate MET, staying on 24-spin despun
 * boundaries.
 * If there's a gap, do as for the first packet:  it's 47 spins aligned to
 * our 24-spin despun end boundary.
 * If we haven't covered enough, just skip and continue; note that it's
 * also possible to have TWO entries in despun from 48 spun spins.
 */
					if (hbs[HB_QABC].spincount[ii] == 48 &&
					    hbs[HB_QABC].met[ii] - hbs[HB_QABC].met[ii-1] <
					    (APPROX_HBTIME + 40))
						fill_unperturbed_until(hbs[HB_QABC].met[ii], i, 48);
					else if (hbs[HB_QABC].spincount[ii] < 48) {
						/* very unlikely that we have a non-full hb
						 * AND a gap.  Fill to extant time and insert
						 * a non-full hb right up to present time.
						 */
						fill_unperturbed_until(hbs[HB_QABC].met[ii], i, 48);
						fill_perturbed_to(hbs[HB_QABC].met[ii], i, 12);
					} else {
						/* There's a gap.  Start fresh with a 47-spin
						 * catchall that includes everything up
						 * through this packet (AND the crap at the
						 * end of the last, if it had a full spin
						 * count).  No; at this point we might as
						 * well show the timing gap, if only for
						 * debugging.
						 */
						fill_unperturbed_until(hbs[HB_QABC].met[ii], i, 0);
						fill_perturbed_to(hbs[HB_QABC].met[ii], i, 47);
					}
				}
				/* a catch-all at the end */
				fill_perturbed_to(hbs[HB_QABC].met[hbs[HB_QABC].n - 1],
				    i, 12);
				donethisone = i;
			}
			/* Twiddle */
			hbs[i].flag = TLC_HIDE;
			hbs[i].name = get_de_name(hbreplacer[i]);
		}
	}
	make_de_names_unique();
}

/* Called by save_events() in some cases.  This is if we're NOT despinning,
 * in which simple case we just want to dump everything from a given DE
 * packet (characterized by its MET creation time) into one place.
 * Cache the met lookup to save time.
 */
void
shove_des_into_hbs_nodespin(uint32_t met, uint16_t evtype, int timestamp,
    int esa, int spinofpkt, int firstspin)
{
	static int lastn = -1;
	static int lasti = 0;
	static uint16_t wanted = 0;
	int i, sp, nbin;
	double perd, phase;

	if (SSP_lastmet == 0) {
		lastn = -1;
		lasti = 0;
		wanted = 0;
		for (i = 0; i < BIN_TYPES; i++)
			wanted |= hbreplacer[i];
	}
	if (met != SSP_lastmet) {
		SSP_lastmet = met;
		lastn = -1;
		/* Find which data element to put stuff in.  -1 means nothing
		 * lined up, which can happen if data was culled.  Anyhow, we
		 * want the first datapacket MET that's after ours less slop
		 * plus a second.
		 */
		if (lasti > 0 && hbs[HB_QABC].met[lasti - 1] > met + HBtimeSlop)
			lasti = 0;
		while (lasti < hbs[HB_QABC].n &&
		    hbs[HB_QABC].met[lasti] + HBtimeSlop + 5 < met)
			lasti++;
		if (lasti == hbs[HB_QABC].n)
		/* drop; this happens when the hb data is culled and the last
		 * partial packet has been deleted. */
			return;
		/* Now have to make sure that our data belongs here (it might not
		 * if we culled).
		 */
		sp = get_OSBdbstuff((double)(hbs[HB_QABC].met[lasti]), &perd);
		if (sp < 0) {
			fprintf(stderr, "shove_des_into_hbs_nodespin(): hb data out of time range?\n");
			return;
		}
		if (sp - 1 - hbs[HB_QABC].spincount[lasti] > firstspin)
			return;
		lastn = lasti;
	}
	if (lastn < 0 || !(wanted & (1 << evtype)))
		return;

	phase = get_OSBdbphase(firstspin + spinofpkt, timestamp);
#ifdef DO_PS
	add_ev(get_metfromspin(firstspin + spinofpkt) +
	    timestamp * ME_TIME_SEC_PER_TICK, phase, esa, evtype);
#endif
	nbin = 1. + (phase - phase_min) / (phase_max - phase_min) * HI_AZ_BINS;
	nbin--;
	if (nbin < 0 || nbin >= HI_AZ_BINS)
		return;
	for (i = 1; i < BIN_TYPES; i++)
		if ((1 << evtype) & hbreplacer[i])
			(*hbs[i].data[lastn])[esa][nbin]++;
}

/* Called by save_events() in some cases.  This is if we're despinning,
 * in which case we have already set up the timestamps with
 * setup_despundata() and so events just go into the first packet with
 * despun spin larger than theirs.  It's slightly slowed because we don't
 * store spin number conveniently.
 */
void
shove_des_into_hbs_despun(uint32_t met, uint16_t evtype, int timestamp,
    int esa, int spinofpkt, int firstspin)
{
	static int lasti = 0;
	static uint16_t wanted;
	int i, nbin;
	double perd, phase;
	int newspin;

	if (SDE_lastmet == 0) {
		SDE_lastmet = met;
		wanted = 0;
		lasti = 0;
		for (i = 0; i < BIN_TYPES; i++) {
			wanted |= hbreplacer[i];
			/* Set up lasti as one of the DE hbs.  Need/assume
			 * the same timing for all, as per setup_despundata().
			 */
			if (hbreplacer[i])
				lasti = i;
		}
	}
	if (!((1 << evtype) & wanted) || !lasti)
		return;
	phase = get_OSBdbphase2(firstspin + spinofpkt, timestamp, &newspin);
#ifdef DO_PS
	/* timestamp is still based on SPUN data, even if phase is fixed. */
	add_ev(get_metfromspin(firstspin + spinofpkt) +
	    timestamp * ME_TIME_SEC_PER_TICK, phase, esa, evtype);
#endif
	/* Next line truncates -0.999..+0.999 all to zero, which doubles that
	 * bin, so offset by one and subtract.
	 */
	nbin = 1. + (phase - phase_min) / (phase_max - phase_min) * HI_AZ_BINS;
	nbin--;
	if (nbin < 0 || nbin >= HI_AZ_BINS)
		return;
	/* Likely we'll be oscillating between two despun packets for each
	 * spun packet, so we can save most of the lookups by going one packet
	 * earlier before we return.
	 */
	if (get_OSBdb2stuff((double)(hbs[lasti].met[SDE_lastn]), &perd) > newspin)
		SDE_lastn = 0;
	while (SDE_lastn < hbs[lasti].n &&
	    get_OSBdb2stuff((double)(hbs[lasti].met[SDE_lastn]), &perd) <= newspin)
		SDE_lastn++;
	if (SDE_lastn == hbs[lasti].n) {
		/* Dropping stuff off the end.  Hmm... XXX? */
		SDE_lastn--;
		return;
	}
	for (i = 1; i < BIN_TYPES; i++)
		if ((1 << evtype) & hbreplacer[i])
			(*hbs[i].data[SDE_lastn])[esa][nbin]++;
	if (SDE_lastn)
		SDE_lastn--;
}


/* This is based on what was shove_des_into_hbs_despun() in the gbc version.
 *
 * We need to discuss cadence.  For the last decade, on spun orbits, I
 * decided that we'd base things on true spacecraft spin, and try to hold
 * data binned by 48 true spins, retiming packets to make it so.  The
 * downside is that you don't really get 8 full spins per ESA when you do
 * this, but it's close.  The upside is that the nominal framework of spins
 * stays legit.  (I've never to date done truly correct "exposure time" in
 * this case.)
 *
 * But NOW, I have it in mind to track by spacecraft-opinion spins.  You
 * still don't get truly 8 spins of 360 degrees per ESA, but so what, you
 * didn't in the other case either.  However, now your DEs line up with
 * your hbs, which is simply easier to coordinate, and doesn't require any
 * retiming.  Data packets are simply on a 12-spin pretend cadence, just
 * like the hbs are on 48-spin pretend cadence, and we worry about what
 * this truly corresponds to later.
 *
 * If we weren't doing the traditional retiming:
 ** Now, we have a real time.  But since everything in the 12-spin DE packet
 ** has to go into the same hb, we need to calculate which hb that is only
 ** on either (a) the first esa==0 DE we get after an esa!=0 DE, because
 ** that's the start of a packet [or, to be more general, the first time we
 ** see any esa LOWER than the previous esa] or
 ** (b) DE time is later than hb time (+ 1 to avoid integer rounding), which
 ** could happen if we exited HVSCI while in the first ESA setting.  Note
 ** there'll always be at least a minute plus gap here, so it'll never be
 ** anything less than a blatant time shift.
 **
 ** DEs will always at least be sent by spin; there's no going backwards in
 ** time.  Assume if we're despinning that we did NOT cull out time
 ** intervals of unfull packets, so that each packet is a catch-all for
 ** things generated AFTER the last packet and not after the current packet.
 **
 ** I sense I'm going to have to undo a bunch of retiming I did so that each
 ** "hb" had full real spins; as it stands, our spun cadence may be far from
 ** actual 12-spin DEs.  But that's for the future.
 *
 * Since we're still doing traditional retiming for now:
 * I'll probably move to the new system, but for comparison with the old, I
 * need to stick in some code so that the whole 12 spins DON'T necessarily
 * end up in the same time bin.
 */
void
adp_despin(double t, uint16_t ev, int esa, int s12, double ph)
{
	static int lasti = 0;
	static int lastesa = 5;
	static uint16_t wanted;
	int i, nbin;
	double tmp, per;
	int newspin;	/* bleah! */

	/* Initial initialization */
	if (SDE_lastmet == 0) {
		SDE_lastmet = (uint32_t)t;
		wanted = 0;
		lastesa = 5;
		lasti = 0;
		for (i = 0; i < BIN_TYPES; i++) {
			wanted |= hbreplacer[i];
			/* set up lasti as one of the DE hbs.  Need/assume
			 * the same timing for all, as per setup_despundata().
			 */
			if (hbreplacer[i])
				lasti = i;
		}
	}
	if (!((1 << ev) & wanted) || !lasti) {
		lastesa = esa;
		return;
	}
	/* We ONLY want to update if we went to a lower ESA or we're not even
	 * CLOSE to the right packet, right?
	 * Note:  my gbc code was hard-edged and I did NOT try to keep all 12
	 * spins in a packet.  I cut RIGHT at the edge, strictly.
	 * So, to match THAT, I need to kill all the slop and oscillate back &
	 * forth, OR do the sorted version on incoming.  I'll do that...
	 * XXX
	 */
#if 0
	if (SDE_lastn < 0 || t > hbs[lasti].met[SDE_lastn] + 1 || esa < lastesa) {
		/* need to reset SDE_lastn; assume we're going in chronological
		 * order.  If esa < lastesa, we do NOT want the 1-second slop
		 * though -- in fact we want slop the other way.
		 */
		if (esa < lastesa && t + 10 > hbs[lasti].met[SDE_lastn])
			SDE_lastn++;
		while (SDE_lastn < hbs[lasti].n && t > hbs[lasti].met[SDE_lastn] + 10)
			SDE_lastn++;
		if (SDE_lastn == hbs[lasti].n) {
			/* Dropping stuff off the end.  Hmmm... XXX? */
			SDE_lastn--;
		}
	}
#else
	if (SDE_lastn < 0 || t > hbs[lasti].met[SDE_lastn]) {
		while (SDE_lastn < hbs[lasti].n && t > hbs[lasti].met[SDE_lastn])
			SDE_lastn++;
		if (SDE_lastn == hbs[lasti].n) {
			/* Dropping stuff off the end.  Hmmm... XXX? */
			SDE_lastn--;
		}
	}
#endif
	lastesa = esa;
	/* We're despinning, so get the phase right.  Phase sent is bogus. */
	tmp = get_metfromspin2(get_OSBdb2stuff(t, &per));
	if (tmp < 0.)
		errx(1, "handle_DE:  bad SPIN and MET");
	ph = (t - tmp)/per;
	/* Next line truncates -0.999..+0.999 all to zero, which doubles that
	 * bin, so offset by one and subtract.
	 */
	nbin = 1. + (ph - phase_min) / (phase_max - phase_min) * HI_AZ_BINS;
	nbin--;
	if (nbin < 0 || nbin >= HI_AZ_BINS)
		return;
/* XXX next block is just to match timing with old method, and should
 * go away eventually...
 */
	/* Likely we'll be oscillating between two despun packets for each
	 * spun packet, so we can save most of the lookups by going one packet
	 * earlier before we return.
	 */
	if (SDE_lastn > 0)
		SDE_lastn--;
	newspin = get_OSBdb2stuff(t, &per);
	if (get_OSBdb2stuff((double)(hbs[lasti].met[SDE_lastn]), &per) > newspin)
		SDE_lastn = 0;
	while (SDE_lastn < hbs[lasti].n &&
	    get_OSBdb2stuff((double)(hbs[lasti].met[SDE_lastn]), &per) <= newspin)
		SDE_lastn++;
	if (SDE_lastn == hbs[lasti].n) {
		/* Dropping stuff off the end.  Hmm... XXX? */
		SDE_lastn--;
		return;
	}
/* ... go away eventually .. to here */
	for (i = 1; i < BIN_TYPES; i++)
		if ((1 << ev) & hbreplacer[i])
			(*hbs[i].data[SDE_lastn])[esa][nbin]++;
}


/* This one's actually a little trickier than the spun case because there
 * could have been culling.  Still, everything in a 12-spin DE packet goes
 * in the same place, so we need to check no more than in adp_despin().
 * We just need a flag for "ditch this whole packet" which I take as
 * flagit.
 */
void
adp_nodespin(double t, uint16_t ev, int esa, int s12, double ph)
{
	static int lastn = 0;
	static int flagit = 0;
	static int lastesa = 5;
	static uint16_t wanted = 0;
	int i, nbin;
	double tmp;

	if (SSP_lastmet == 0) {
		SSP_lastmet = (uint32_t)t;
		lastn = 0;
		wanted = 0;
		flagit = 0;
		lastesa = 5;
		for (i = 0; i < BIN_TYPES; i++)
			wanted |= hbreplacer[i];
	}
	if (!(wanted & (1 << ev))) {
		lastesa = esa;
		return;
	}
	flagit = 0;
	i = get_OSBdbstuff((double)hbs[HB_QABC].met[lastn] + 2., &tmp);
	if (i < 1) {
		flagit = 1;
		tmp = t + 1.;
	} else
		tmp = get_metfromspin(i);
	if (t >= tmp || esa < lastesa) {
		/* need to reset lastn; assume we're going in chronological order */
		if (esa < lastesa && t >= tmp) {
			lastn++;
			i = get_OSBdbstuff((double)hbs[HB_QABC].met[lastn] + 2., &tmp);
			if (i < 1) {
				tmp = t + 1.;
				flagit = 1;
			} else
				tmp = get_metfromspin(i);
		}
		while (lastn < hbs[HB_QABC].n && t >= tmp) {
			lastn++;
			i = get_OSBdbstuff((double)hbs[HB_QABC].met[lastn] + 2., &tmp);
			if (i < 1) {
				tmp = t + 1.;
				flagit = 1;
			} else
				tmp = get_metfromspin(i);
		}
		if (lastn == hbs[HB_QABC].n) {
			/* Dropping stuff off the end.  Hmmm... XXX? */
			lastn--;
			flagit = 1;
		} else {
			/* See if our data is prior to the spins included in this
			 * HB_QABC packet.
			 */
			i--;
			if (i < hbs[HB_QABC].spincount[lastn] /* includes returning -1 */
			    || t < get_metfromspin(i - hbs[HB_QABC].spincount[lastn]))
				flagit = 1;
		}
	}
	lastesa = esa;
	if (flagit)
		return;
	nbin = 1. + (ph - phase_min) / (phase_max - phase_min) * HI_AZ_BINS;
	nbin--;
	if (nbin < 0 || nbin >= HI_AZ_BINS)
		return;
	for (i = 1; i < BIN_TYPES; i++)
		if ((1 << ev) & hbreplacer[i])
			(*hbs[i].data[lastn])[esa][nbin]++;
}
