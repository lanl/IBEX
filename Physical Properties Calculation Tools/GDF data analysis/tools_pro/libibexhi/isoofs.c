/*	$Id: isoofs.c,v 1.44 2014/11/29 03:26:02 pjanzen Exp $	*/
/* There are a variety of multiple-cull things sitting around in xhihb.
 * This is where the canonical loose-cull (isotropic) offset calculation
 * lives.
 */
#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: isoofs.c,v 1.44 2014/11/29 03:26:02 pjanzen Exp $";

/* How many 6-degree angle bins do you need to make a loose cull
 * worthwhile?  Stuff will crash if this is less than 2.
 */
#define NCALCMIN (3)


/* Return 1 if the given time/ESA/angle is included in mculls[culln], zero
 * if not.  For speed, there's no sanity checking of inputs.  There is some
 * caching based on how I expect this to be called.
 */
int
isincull(int culln, uint32_t met, int esa, int angbin)
{
	static uint32_t omet = 0;
	static int oi = 0;

	/* No reason a calling program can't load different packet setups.
	 * XXX really though, in that case, you could possibly have METs
	 * matching erroneously.  However the only _likely_ issue on changed
	 * packets is trying to read past the end of a shorter orbit .
	 */
	if (oi > nallt) {
		omet = 0;
		oi = 0;
	}
	esa = (1 << esa);
	if (omet == met) {
		if (mculls[culln][oi * HI_AZ_BINS + angbin] & esa)
			return(1);
		else
			return(0);
	}
	omet = met;
	/* Assume in general we'll get called sequentially, so start at oi and
	 * work up.
	 */
	if (alltimes[oi] > met + HBtimeSlop)
		oi = 0;
	while (nallt > oi && alltimes[oi] < met - HBtimeSlop)
		oi++;
	if (oi == nallt ||
	    (alltimes[oi] > met + HBtimeSlop)) {
		/* XXX b0rked timing */
		printf("X %d %u\n", oi, met);
		oi = 0;
	}
	if (mculls[culln][oi * HI_AZ_BINS + angbin] & esa)
		return(1);
	else
		return(0);
}

/* This is a slower version of isincull() that will behave correctly for
 * ALL times, not just METs within HBtimeSlop of entries in alltimes[].
 * This is the version that you have to use if there's despun stuff at one
 * cadence and histograms at another, and you want to compare.
 * Returns the same as isincull() for data that's within HBtimeSlop -
 * otherwise, both the time prior and the time after have to be "good" for
 * safe_isincull() to return true.
 *
 * WARNING!  safe_isincull() is intended for data that's histogrammed at
 * some cadence, so that the met actually corresponds, at least roughly,
 * to data collected in the prior 48 spins.  It should NOT be used for
 * individual direct events, if you have them.
 */
int
safe_isincull(int culln, uint32_t met, int esa, int angbin)
{
	static uint32_t omet = 0;
	static int oi = 0;
	static int oi2 = 0;

	if (met < alltimes[0] || met > alltimes[nallt-1])
		return(0);
	if (oi > nallt) {
		omet = 0;
		oi = 0;
		oi2 = 0;
	}
	esa = (1 << esa);
	if (omet == met) {
		if ((mculls[culln][oi * HI_AZ_BINS + angbin] & esa) &&
		    (oi == oi2 || mculls[culln][oi2 * HI_AZ_BINS + angbin] & esa))
			return(1);
		else
			return(0);
	}
	omet = met;
	while (oi >= 0 && alltimes[oi] > met + HBtimeSlop)
		oi--;
	if (oi < 0) {
		/* debug/warning printf() will show up in oi2 case */
		oi = 0;
	}
	while (nallt > oi && alltimes[oi] < met - HBtimeSlop)
		oi++;
	if (oi == nallt) {
		printf("XX- %d %u\n", oi, met);
		oi = 0;
	}
	oi2 = oi;
	while (oi2 >= 0 && alltimes[oi2] > met + HBtimeSlop)
		oi2--;
	if (oi2 < 0) {
		printf("XX+ %d %d %u\n", oi2, oi, met);
		oi2 = 0;
	}
	if ((mculls[culln][oi * HI_AZ_BINS + angbin] & esa) &&
	    (oi == oi2 || mculls[culln][oi2 * HI_AZ_BINS + angbin] & esa))
		return(1);
	else
		return(0);
}

/* Nonzero if any angle in any energy is good at this time. */
int
is_any_goodcull(int whichcull, uint32_t met, char esas)
{
	static int oi = 0;
	static int oi2 = 0;
	int i;

	if (met < alltimes[0] || met > alltimes[nallt-1])
		return(0);
	if (oi > nallt) {
		oi = 0;
		oi2 = 0;
	}
	while (oi >= 0 && alltimes[oi] > met + HBtimeSlop)
		oi--;
	if (oi < 0) {
		/* debug/warning printf() will show up in oi2 case */
		oi = 0;
	}
	while (nallt > oi && alltimes[oi] < met - HBtimeSlop)
		oi++;
	if (oi == nallt) {
		printf("XX- %d %u\n", oi, met);
		oi = 0;
	}
	oi2 = oi;
	while (oi2 >= 0 && alltimes[oi2] > met + HBtimeSlop)
		oi2--;
	if (oi2 < 0) {
		printf("XX+ %d %d %u\n", oi2, oi, met);
		oi2 = 0;
	}
	for (i = 0; i < HI_AZ_BINS; i++) {
		if ((mculls[whichcull][oi * HI_AZ_BINS + i] & esas) &&
		    (oi == oi2 || mculls[whichcull][oi2 * HI_AZ_BINS + i] & esas))
			return(1);
	}
	return(0);
}

/* If the choice of energies includes ESA 1, we need to worry about the
 * flyback bin and its lower exposure time.  This would be easy, except for
 * despun orbits, when the flyback bin may occur over pretty much any angle
 * range.
 *
 * Because hbtime is provided as an argument to the function calling this,
 * it's reasonably safe to assume that any relevant osbdba and osbd2a data
 * has been read in.
 *
 * Return NULL on failure, which is why I didn't label this function static.
 */
/* static */ double *
get_flyback_correction_array(char esa, int hbtype, int whichcull, int verbos)
{
	int i, j;
	double *fcor;

	if (esa & 1) {
		i = is_OSBdb_initialized();
		if (i == 0 && verbos > 2)
			printf("flyback correction: no OSBdba data read; assuming not spun\n");
		if (i < 2) {
			if ((fcor = (double *)calloc(HI_AZ_BINS, sizeof(double))) == NULL)
				return(NULL);
			fcor[0] = 0.5;
			for (j = 1; j < HI_AZ_BINS; j++)
				fcor[j] = 1.;
		} else {
			j = get_spun_flyback_correction(&fcor, hbtype, whichcull);
			if (j != 0) {
				if (verbos > 2)
					printf("flyback correction:  failed spun (%d)\n", j);
				return(NULL);
			}
		}
		/* If ESA 1 is the same voltage setting as some other ESA, we
		 * need to weight down the flyback correction in the overall
		 * data.  This is actually a situation that should never happen
		 * under conceivable operation, but we should handle it and warn.
		 */
		j = bitsofchar(esa);
		if (j > 1) {
			printf("flyback correction:  ESA 1 flyback being partially applied - you might want to look at this!\n");
			for (i = 0; i < HI_AZ_BINS; i++)
				fcor[i] = ((j - 1) * 1. + fcor[i])/(double)j;
		}
	} else {
		if ((fcor = (double *)calloc(HI_AZ_BINS, sizeof(double))) == NULL)
			return(NULL);
		for (i = 0; i < HI_AZ_BINS; i++)
			fcor[i] = 1.;
	}
	return(fcor);
}

/* Convenience function to make get_offs() easier to read.  Put a zero or 1
 * by angle as appropriate in "exact" and "overlaps" arrays for all angles
 * with matching "good times" as per kull-array.  No sanity checking on
 * inputs.
 *
 * Note that with esa as a bitmap, we just need each included ESA to match
 * on its own.
 */
static void
tag_all_matching_angs(int baseang, int *kull, char esa, int kn,
    int exac[HI_AZ_BINS], int ovr[HI_AZ_BINS])
{
	int i, j;
	int ii, jj;

	for (i = 0; i < HI_AZ_BINS; i++) {
		exac[i] = ovr[i] = 1;
		jj = 0;
		for (ii = 0; ii < HI_ENERGIES; ii++) {
			if ((1 << ii) & esa) {
				for (j = 0; j < kn; j++) {
					if (kull[jj * HI_AZ_BINS * kn + j * HI_AZ_BINS + i] !=
					    kull[jj * HI_AZ_BINS * kn + j * HI_AZ_BINS + baseang]) {
						exac[i] = 0;
						if (kull[jj * HI_AZ_BINS * kn + j * HI_AZ_BINS + baseang])
							ovr[i] = 0;
					}
				}
				jj++;
			}
		}
	}
}

static void
printfpn_esas(char esa, int flag)
{
	int i, j;

	i = 0;
	for (j = 0; j < HI_ENERGIES; j++)
		if ((1<<j) & esa) {
			if (i)
				printf("+");
			i = 1;
			printf("%d", j+1);
		}
	if (i == 0)
		printf("-");
	if (flag)
		printf(".\n");
}

static int
comp_ints_descend(const void *a, const void *b)
{
	return(*((int *)b) - *((int *)a));
}

/* Basic entry point.  For a given ESA map (1 << (0-5), so that we can use
 * multiple ESAs if they're at the same voltage), a given hb type (i.e.,
 * number), a given good cull number, and a given loose cull number, return
 * the 60-angle-bin offsets and uncertainties.  ofs and ofsunc need to be
 * allocated externally and be of size HI_AZ_BIN.  verbosity < 0 is silent;
 * verbosity > 0 is verbose.
 *
 * There's no sanity checking done on the esa bitmap.
 *
 * Algorithm described in code.
 *
 * Return value is zero on success.  Failure modes include invalid inputs,
 * and loose-cull angle ranges that add nothing to the good cull information.
 *
 * The good cull and the loose cull should NOT OVERLAP for this to make
 * sense.  It is the responsibility of the calling routine to ensure this.
 * Numbers will still be returned if the culls do overlap, but they will
 * make less sense.
 *
 * The offset is just that:  it's what to subtract from the loose cull to
 * make it equivalent to the good cull.  It does not include any CR
 * background.  It is in /hb for one ESA, 6 degrees, not in Hz.  This is
 * historical:  this can run independent of penetrating background or ion
 * gun corrections.
 *
 * If zanyISOCoverlap is nonzero, it's assumed that I want the offset not
 * for non-overlapping loose and good culls, but for the ISOC framework of
 * loose cull entirely including good cull.  That is to say, loose and good
 * still should not overlap, but the offset is to apply to the cull made by
 * (loose OR good).  This is less zany than I originally thought, as long
 * as you don't think of it as an offset but instead as a background to
 * subtract, I guess.  I may still have some interest in what the
 * angle-by-angle straightforward loose cull offset is, because it's
 * clearly bad if it goes negative, and it's where one looks to see if
 * solar wind background's snuck in.
 *
 * If rat is non-NULL, rat and ratunc are populated with the overall rates
 * and rate uncertainties, in /hb.  It is getting increasingly silly to do
 * this in /hb for the qABC given that everything else is in /s, but it
 * keeps it historically consistent and useful for other data types.
 *
 * So it turns out that if an ion gun correction is to be included, which will
 * generally be the case for qABC, it has to happen FIRST and go into this
 * calculation.  Otherwise, there's no way to do the loose cull right,
 * particularly for angles that appear only in the loose cull, for which
 * there is no direct ion gun correction.
 * Therefore, ion gun corrections and uncertainties need to get passed in.
 * If they're NULL, they're not used.  They are in Hz, because they always
 * are, so hbtime needs to be passed along as well to convert to the
 * standard /hb that iso_get_offs uses.
 *
 * So the sequence is:  penetrating background, ion gun, loose cull offset.
 */
int
iso_get_offs(char esa, int hbtype, int gcull, int lcull, int verbosity,
    double *ofs, double *ofsunc, int zanyISOCoverlap, double *rat,
    double *ratunc, int nonneg,
    double *igb, double *igu, double hbtime)
{
	int i, j, k, ii, jj, kk, iii, jjj;
	long gtsum[HI_AZ_BINS];
	int  gtn[HI_AZ_BINS], gtsort[HI_AZ_BINS];
	int  gtsortn;
	int  ltn[HI_AZ_BINS];
	int  tmpsrt[HI_AZ_BINS];
	int  exactl[HI_AZ_BINS], overlapl[HI_AZ_BINS];
	double *gtfly, *ltfly;
	int *loos;
	int  tmp1, tmp2, tmp3;
	double tmpf;
	long ngsum, nlsum, nig, nigu;
	double nlang, ngang;
	double sumig, igunc;
	double runavg, runvar, tmp;
	double lig[HI_AZ_BINS], liu[HI_AZ_BINS];
	double badigavg;
	int nbigav;
	int lcflag;

	if (gcull < 0 || gcull > 7 ||
	    lcull < 0 || lcull > 7 || hbtype < 0 || hbtype >= BIN_TYPES) {
		if (verbosity > 2)
			printf("iso_get_offs(): called with invalid parameters.\n");
		return(1);
	}
	lcflag = 0;
	gtfly = NULL;
	if (igb == NULL) {
		/* If no ion gun correction, set up to subtract exactly zero */
		for (i = 0; i < HI_AZ_BINS; i++)
			lig[i] = liu[i] = 0.;
		hbtime = APPROX_HBTIME;
	} else
		for (i = 0; i < HI_AZ_BINS; i++) {
			lig[i] = igb[i];
			liu[i] = igu[i];
		}
	/* Make it a more convenient factor to convert from /s to /hb */
	hbtime = hbtime / HI_AZ_BINS / HI_ENERGIES;
	for (i = 0; i < HI_AZ_BINS; i++) {
		ofs[i] = ofsunc[i] = 0.0;
		gtsum[i] = 0;
		gtn[i] = gtsort[i] = ltn[i] = 0;
	}
	if (rat) {
		for (i = 0; i < HI_AZ_BINS; i++) {
			rat[i] = ratunc[i] = 0.;
		}
	}
	/* (1) Sum up the good times by total counts and # of hb packets.
	 *     For convenience set up an array ranking the good time angle
	 *     bins by # of hb packets.
	 */
for (iii = 0; iii < HI_ENERGIES; iii++) {
	if ((1 << iii) & esa) {
		for (i = 0; i < hbs[hbtype].n; i++) {
			for (j = 0; j < HI_AZ_BINS; j++) {
				if (isincull(gcull, hbs[hbtype].met[i], iii, j)) {
					gtsum[j] += (*(hbs[hbtype].data[i]))[iii][j];
					gtn[j]++;
				}
			}
		}
	}
}
/* XXX There's a kind of strange assumption going through all of this.
 * For speed(?) I decided to sort things by how many good bins they have.
 * The assumption is that if the number of hbs that are good match between
 * two different angles, they share all their good times.  This is not
 * necessarily the case.
 * I may therefore be rewriting this whole ungainly function to be
 * slower...
 */
	memcpy(tmpsrt, gtn, HI_AZ_BINS * sizeof(int));
	qsort(tmpsrt, HI_AZ_BINS, sizeof(int), comp_ints_descend);
	if (tmpsrt[0] < 1) {
		if (verbosity > 2)
			printf("iso_get_offs(): called with no good times.\n");
		return(2);
	}
	i = 0;
	gtsortn = 0;
	while (i < HI_AZ_BINS && tmpsrt[i] > 0) {
		k = tmpsrt[i];
		gtsortn++;
		for (j = 0; j < HI_AZ_BINS; j++)
			if (gtn[j] == k)
				gtsort[j] = gtsortn;
		while (i < HI_AZ_BINS && tmpsrt[i] == k)
			i++;
	}
	/* Stupid paranoia:  I believe this can never happen. */
	if (gtsortn < 1) {
		if (verbosity > 0)
			printf("iso_get_offs():  unlikely gtsortn value?\n");
		return(2);
	}
/* If the choice of energies includes ESA 1, we need to worry about the
 * flyback bin and its lower exposure time.  This would be easy, except for
 * despun orbits, when the flyback bin may occur over pretty much any angle
 * range.
 *
 * To make processing easier, if slightly slower, always set up a gtfly[]
 * array.  Most of the time it'll all be ones.  Then, every time we use a
 * gtn[] to count an exposure time, always multiply by gtfly[].
 */
	gtfly = get_flyback_correction_array(esa, hbtype, gcull, verbosity);
	if (!gtfly) {
		if (verbosity > 1)
			printf("iso_get_offs(): failed getting good time flyback\n");
		return(2);
	}
	/* gtsort[] goes 0 .. gtsortn, where 1 .. gtsortn are valid ranges
	 * and 0 means Not a Good Time Ever.  Note that all good times are
	 * considered equivalent, so all that matters is how many of them
	 * there are.
	 */
	/* (2) Populate a nhb x HI_AZ_BIN array with 0 or 1 as per
	 *     presence in the loose cull.  (It'll be convenient.)
	 *     In the process, count # of hbs per angle range in the
	 *     loose cull, as we just did for the good cull, and set
	 *     up a similar descending sort.
	 */
	if ((loos = (int *)calloc(HI_AZ_BINS * hbs[hbtype].n * bitsofchar(esa),
	    sizeof(int))) == NULL) {
		if (verbosity >= 0)
			printf("iso_get_offs(): out of memory.\n");
		free(gtfly);
		return(-1);
	}
jjj = 0;
for (iii = 0; iii < HI_ENERGIES; iii++) {
	if ((1 << iii) & esa) {
		for (i = 0; i < hbs[hbtype].n; i++) {
			for (j = 0; j < HI_AZ_BINS; j++) {
				if (isincull(lcull, hbs[hbtype].met[i], iii, j)) {
					loos[jjj * HI_AZ_BINS * hbs[hbtype].n +
					    i * HI_AZ_BINS + j] = 1;
					ltn[j]++;
				}
			}
		}
		jjj++;
	}
}
	memcpy(tmpsrt, ltn, HI_AZ_BINS * sizeof(int));
	qsort(tmpsrt, HI_AZ_BINS, sizeof(int), comp_ints_descend);
	if (tmpsrt[0] < 1) {
		if (verbosity >= 0) {
			printf("iso_get_offs(): called with no loose cull times for ESA ");
			printfpn_esas(esa, 1);
		}
		/* Not an error - there's just no offset (except maybe for the ion gun) */
		/* Can use i as an index because we're returning and not looping. */
		if (rat) {
			/* Note that we have to subtract the ion gun background here
			 * to be consistent with the loose-cull return.
			 */
			for (i = 0; i < HI_AZ_BINS; i++)
				if (gtn[i]) {
					rat[i] = (double)gtsum[i] / (gtn[i] * gtfly[i]) - lig[i] * hbtime;
					if (liu[i] > -0.001)
						ratunc[i] = sqrt((double)gtsum[i]/
						    (gtn[i] * gtfly[i])/(gtn[i] * gtfly[i])
						    + liu[i] * liu[i] * hbtime * hbtime);
					else
						ratunc[i] = -1.;
				} else
					ratunc[i] = -1.;
		}
		for (i = 0; i < HI_AZ_BINS; i++)
			if (gtn[i]) {
				ofs[i] = lig[i] * hbtime;
				if (liu[i] < -0.001) {
					ofsunc[i] = -1.;
				} else {
					ofsunc[i] = liu[i] * hbtime;
				}
			} else
				ofsunc[i] = -1.;
		free(loos);
		free(gtfly);
		return(0);
	}
/* Flyback for loose cull.  Well might one ask how this can possibly make
 * useful sense for spun data.  Hmm. XXX
 * At least make it useful for nonspun data.
 */
	ltfly = get_flyback_correction_array(esa, hbtype, lcull, verbosity);
	if (ltfly == NULL) {
		if (verbosity > 1)
			printf("iso_get_offs(): failed on loose cull flyback?\n");
		free(loos);
		free(gtfly);
		return(2);
	}
	/* (3) From max-nhb angle-bin on down, find the first angle bin that has
	 *     this number of nhbs (there may be more than one and they may
	 *     not actually share all their times).  For the entire in-cull
	 *     time range of this bin, find all the angle bins that are always
	 *     present (this may include angles which are also present at
	 *     times beyond those in the "working" angle bin's times).  Note
	 *     also the range that has this exact range and no more:  all
	 *     these angles get the same offset, from this calculation.
	 *
	 *     Complain if there are fewer than NCALCMIN angles in this range,
	 *     or more particularly if fewer than NCALCMIN angles in this
	 *     range overlap with any good cull times, because it means the
	 *     loose cull is essentially meaningless for this angle range.
	 */
	if (verbosity > 0) {
		printf("ESA ");
		printfpn_esas(esa, 0);
		printf(", good cull %d, loose cull %d, %s:\n",
		    gcull + 1, lcull + 1, hbs[hbtype].name);
	}
	i = 0;
	while (i < HI_AZ_BINS) {
		k = tmpsrt[i];
		for (j = 0; j < HI_AZ_BINS; j++) {
			/* ofsunc is zero iff we haven't done this one yet */
			if (ltn[j] == k && fabs(ofsunc[j]) < 1e-20) {
				tag_all_matching_angs(j, loos, esa, hbs[hbtype].n,
				    exactl, overlapl);
				tmp1 = tmp2 = tmp3 = 0;
				for (ii = 0; ii < HI_AZ_BINS; ii++) {
					tmp1 += exactl[ii];
					tmp2 += overlapl[ii];
					if (gtn[ii] > 0)
						tmp3 += overlapl[ii];
				}
				if (verbosity > 0) {
					printf("Found region of %d angle bins:\n ", tmp2);
					for (ii = 0; ii < HI_AZ_BINS; ii++)
						if (exactl[ii])
							printf("1");
						else
							printf("0");
					printf(" exact and\n ");
					for (ii = 0; ii < HI_AZ_BINS; ii++)
						if (overlapl[ii]) {
							if (gtn[ii] > 0)
								printf("1");
							else
								printf("-");
						} else
							printf("0");
					printf(" overlapping.\n");
				}
				if (tmp3 < NCALCMIN) {
					/* Officially we can't do stats on this.
					 * Print an error if appropriate, and always
					 * set ofsunc for these to -1. as a signal.
					 * Leave ofs at zero.
					 */
					if (verbosity >= 0)
						printf(
"iso_get_offs():  CANNOT calculate loose cull offset for angle bin %d due to\n\
             insufficient statistics (edit loose cull and try again).\n", j);
					for (ii = 0; ii < HI_AZ_BINS; ii++)
						if (exactl[ii])
							ofsunc[ii] = -1.;
				} else {
	/* (4) For each overlap of loose angle range and good angle range,
	 *     calculate the rate offset and uncertainty, assuming Poisson
	 *     statistics and pretending the counts are high enough to go
	 *     Gaussian as required.  Simulations have determined that the
	 *     answer is most accurate if I just sum it all up and don't do
	 *     any weighted averaging, although some is still needed for (5).
	 */
					runavg = 0.0;
					runvar = 0.0;
					igunc = 0.;
					nigu = 0;
					badigavg = 0.;
					nbigav = 0;
					for (ii = 1; ii <= gtsortn; ii++) {
						ngsum = nlsum = 0;
						ngang = nlang = 0.;
						nig = 0; sumig = 0.;
						for (jj = 0; jj < HI_AZ_BINS; jj++) {
							if (gtsort[jj] == ii && overlapl[jj] == 1) {
								ngang += gtn[jj] * gtfly[jj];
								ngsum += gtsum[jj];
								if (liu[jj] > -0.001) {
									nig++;
									sumig += lig[jj];
									nigu++;
									igunc += liu[jj];
								} else {
	fprintf(stderr, "Ackthpht!  Good time with bad ion gun correction?  (%d)\n",
	    jj);
	/* This should not trigger, but it can for poorly chosen culls.  In
	 * such a case, proceed with the ion gun correction closest to it, for
	 * now.  Ideally gtclean will save us eventually.
	 */
	if (jj > 0 && liu[jj-1] > -0.001) {
		nig++;
		sumig += lig[jj-1];
		nigu++;
		igunc += liu[jj-1];
		fprintf(stderr, "using next angle less for ion gun.\n");
	} else if (jj < HI_AZ_BINS - 1 && liu[jj+1] > -0.001) {
		nig++;
		sumig += lig[jj+1];
		nigu++;
		igunc += liu[jj+1];
		fprintf(stderr, "using next angle less for ion gun.\n");
	}
								}
jjj = 0;
for (iii = 0; iii < HI_ENERGIES; iii++) {
	if ((1 << iii) & esa) {
		for (kk = 0; kk < hbs[hbtype].n; kk++) {
			if (loos[jjj * HI_AZ_BINS * hbs[hbtype].n + kk * HI_AZ_BINS + j]) {
				nlsum += (*(hbs[hbtype].data[kk]))[iii][jj];
				tmpf = get_flyback_correction_bybin(hbtype, kk, iii, jj);
				if (tmpf > 0.)
					nlang += tmpf;
				else {
					/* We hit this on a loose cull when no osbdba file
					 * exists.  In such a case we should assume no
					 * despinning is needed and so the answer is
					 * the default of 0.5 in spin bin 0 and 1.0
					 * elsewhere.
					 */
					lcflag = 1;
#if 0
					fprintf(stderr,
					"continuing through flyback error %d %d %d %lf\n",
					    iii, kk, jj, tmpf);
#endif
					if (iii == 0 && jj == 0)
						nlang += 0.5;
					else
						nlang += 1.;
				}
			}
		}
		jjj++;
	}
}
							}
						}
						if (nig > 0) {
							nbigav++;
							badigavg += sumig / (double) nig;
						}
	/* (5) Do a weighted average of all the parts of (4), and use that for
	 *     the angle range of (3).  Then repeat for angles not done yet,
	 *     back up to step (3).
	 */
						if (ngang > 0.) {
	/* Here's where we need to subtract the ion gun offset.  At this
	 * point, do not factor the ion gun offset uncertainty into the
	 * calculation.  It will reappear when the ion gun offset is
	 * explicitly added in for the good times.  I think all we need is
	 * that its uncertainty is reasonably the same for most relevant
	 * angles, which might even often be the case.  So the weighting
	 * remains entirely Poisson-based.
	 */
							tmp = nlsum / nlang / nlang + ngsum / ngang / ngang;
							if (nig > 0) {
							runavg += (nlsum / nlang - (ngsum / ngang -
							    sumig / (double)nig * hbtime)) / tmp;
							} else {
								/* This shouldn't happen? */
							runavg += (nlsum / nlang - (ngsum / ngang )) / tmp;
							fprintf(stderr, "temporary diagnostic warning!\n");
							}
							runvar += 1./tmp;
						if (verbosity > 2)
	printf("Region %d overlap with gt had offset %lf +- %lf\n", ii,
	    nlsum / nlang - (ngsum / ngang -
	    sumig / (double)nig * hbtime), sqrt(tmp));
	if (verbosity > 5) {
		int frrob;
		printf("[");
		for (frrob = 0; frrob < HI_AZ_BINS; frrob++)
			if (gtsort[frrob] == ii && overlapl[frrob] == 1)
				printf("1");
			else
				printf("0");
		printf("]\n");
	}
						}
					}
					runavg = runavg / runvar;
					runvar = 1/sqrt(runvar);
					for (ii = 0; ii < HI_AZ_BINS; ii++) {
						if (exactl[ii]) {
							ofs[ii] = runavg;
							/* (ibexhi.h documents nonneg values) */
							if (nonneg == 2) {
	/* This is a rather suspicious point, because there _should_ be an ion
	 * gun correction to the loose cull, which we haven't made.  So, if
	 * the offset is even close to zero, it means the loose cull nominally
	 * has a negative offset.  The comparison should be if the loose
	 * cull offset here is larger or smaller than the ion gun correction
	 * for this angle, or, if that doesn't exist, the average ion gun
	 * correction applied so far.
	 */
								if (liu[ii] > -0.001 && ofs[ii] < lig[ii] * hbtime) {
									ofs[ii] = lig[ii] * hbtime;
								} else if (liu[ii] <= -0.001 && nbigav > 0
								    && ofs[ii] < badigavg/(double)nbigav * hbtime) {
									/* Kind of gross XXX ? */
									ofs[ii] = badigavg/(double)nbigav * hbtime;
								}
							}
							ofsunc[ii] = runvar;
							if (!(overlapl[ii] == 1 && gtn[ii] > 0) && nigu > 0) {
/* No good times, just loose, so add ion gun uncertainty.  It won't get
 * added in otherwise from the good times.  Note I've gone and AVERAGED the
 * uncertainties that went into this, which is not really correct, but is
 * close.
 */
								ofsunc[ii] = sqrt(runvar * runvar +
	    hbtime * hbtime * igunc * igunc / (double)nigu / (double)nigu);	
							}
							if (rat) {
nlsum = 0;
jjj = 0;
for (iii = 0; iii < HI_ENERGIES; iii++) {
	if ((1 << iii) & esa) {
		for (kk = 0; kk < hbs[hbtype].n; kk++)
			if (loos[jjj*HI_AZ_BINS * hbs[hbtype].n + kk * HI_AZ_BINS + ii])
				nlsum += (*(hbs[hbtype].data[kk]))[iii][ii];
		jjj++;
	}
}
/* rate = ((good times rate) * (# of good times) + (loose rate - offset) *
 *         (# of loose times)) / (total # of times)
 *      = ((good times counts) + (loose counts) - offset * (# of loose times)
 *           / (total # of times))
 * note ltn[ii] == ltn[j] if we are here.
 *
 * We do need to subtract ion gun background here, because it's
 * automatically subtracted from angle ranges present only in the loose
 * cull, and after this point we can't tell loose-cull-only apart from the
 * rest.  So the "loose cull offset" ceases to be a pure offset, because
 * there is not necessarily a single "good cull" value from which to offset
 * it.  This also means that if we return because there _is_ no loose cull,
 * that we have to return having subtracting the ion gun background then
 * too (see comment somewhere above).
 */
if (nonneg && ofs[ii] < 0.)
	rat[ii] = ((double)gtsum[ii] + nlsum) /
	    (ltn[ii] * ltfly[ii] + gtn[ii] * gtfly[ii]);
else
	rat[ii] = ((double)gtsum[ii] + nlsum - (double)ltn[ii] * ltfly[ii] * ofs[ii]) /
	    (ltn[ii] * ltfly[ii] + gtn[ii] * gtfly[ii]);
ratunc[ii] = sqrt((double)gtsum[ii] + nlsum +
    (double)ltn[ii] * ltfly[ii] * ofsunc[ii] * (double)ltn[ii] * ltfly[ii] * ofsunc[i]) /
    (double)(ltn[ii] * ltfly[ii] + gtn[ii] * gtfly[ii]);
/* Rats, so by here the LOOSE CULL part has the ion gun subtracted from it,
 * but the GOOD CULL doesn't, yet, even though that's what we used to get
 * the ion gun correction.
 */
if (liu[ii] > -0.001) {
	rat[ii] -= (gtn[ii] * gtfly[ii] * lig[ii] * hbtime) /
	    (gtn[ii] * gtfly[ii] + ltn[ii] * ltfly[ii]);
	ratunc[ii] = sqrt(ratunc[ii] * ratunc[ii] +
	    liu[ii] * liu[ii] * hbtime * hbtime);
} else if (gtn[ii] > 0)
	ratunc[ii] = -1.;
							}
						}
					}
					if (zanyISOCoverlap) {
						/* scale ofs and ofsunc by angle by
						 * nloosehbs / (nloosehbs + ngoodhbs)
						 * - however, must include ion gun
						 * correction too.
						 */
						for (ii = 0; ii < HI_AZ_BINS; ii++) {
							if (exactl[ii]) {
								if (overlapl[ii] == 1) {
									tmp = ltn[ii] * ltfly[ii]/
									    (ltfly[ii] * ltn[ii] + gtfly[ii]*gtn[ii]);
									if (liu[ii] > -0.001) {
										ofs[ii] = (ofs[ii] - lig[ii] * hbtime)
												* tmp + lig[ii] * hbtime;
										ofsunc[ii] =
sqrt(ofsunc[ii] * ofsunc[ii] *tmp*tmp + liu[ii] * liu[ii] * hbtime * hbtime);
									} else if (gtn[ii] > 0)
										ofsunc[ii] = -1.;
								}
		/* if overlapl is zero or more likely gtn[ii] is zero, it means
		 * the good cull didn't overlap this angle, and so we already
		 * calculated the right ofsunc[] earlier.
		 */
							}
/* In this case, tmp == 1., and we had only a loose cull at this angle.
 * What to do?
 * Ion gun's already averaged over as many angles as it can be, so I can't just
 * keep track of 'nig' incorporated numbers and statistically average.
 * I suppose I could take the statistical average of the uncertainties used
 * for the offsets and incorporate that... it's wrong to count the
 * uncertainty in the ion gun both for the offset wrt "good" and for
 * "good", that's for sure.  Maybe I should do weighted averaging of ion
 * gun unc?  Hmm.
 * XXX
 */
						}
					}
				}
			}
		}
		while (i < HI_AZ_BINS && tmpsrt[i] == k)
			i++;
		/* Stop if the remaining angles don't appear in the loose cull:
		 * the offset and offset uncertainty are zero (for ISOC purposes).
		 * If we're filling in rates, fill in just the good time rates,
		 * if there are any.
		 */
		if (i < HI_AZ_BINS && tmpsrt[i] == 0) {
			/* Need to subtract ion gun here to be consistent */
			if (rat) {
				for (j = 0; j < HI_AZ_BINS; j++)
					if (ltn[j] == 0 && gtn[j] != 0) {
						rat[j] = (double)gtsum[j] / (gtn[j] * gtfly[j])
						    - lig[j] * hbtime;
						if (liu[j] > -0.001)
							ratunc[j] = sqrt((double)gtsum[j]/
							    (gtn[j] * gtfly[j])/(gtn[j] * gtfly[j])
							    + liu[j] * liu[j] * hbtime * hbtime);
						else
							ratunc[j] = -1.;
					}
			}
			for (j = 0; j < HI_AZ_BINS; j++)
				if (ltn[j] == 0 && gtn[j] != 0) {
					if (liu[j] > -0.001) {
						ofs[j] = lig[j] * hbtime;
						ofsunc[j] = liu[j] * hbtime;
					} else {
						ofs[j] = lig[j] * hbtime;
						ofsunc[j] = -1.;
					}
				}
			i = HI_AZ_BINS;
		}
	}

	/* There may be angles that were in neither the good nor loose culls
	 * and were never handled.
	 *
	 * Set ofsunc (and ratunc if applicable) to -1. to indicate this fact.
	 */
	for (j = 0; j < HI_AZ_BINS; j++)
		if (gtn[j] == 0 && ltn[j] == 0) {
			ofsunc[j] = -1.;
			if (rat)
				ratunc[j] = -1;
		}

	free(ltfly);
	free(loos);
	free(gtfly);
	return(0);
}

/* An even better entrance:  get all ESAs.
 * If rates is NULL, we return just offsets.
 * Optionally, don't bail on iso_get_offs() error 2:  it means no good
 * times, but that may be acceptable.  If it is, just fill 0 in rates
 * and -1 in uncs.
 */
int
iso_get_all_ofs(int hbtype, int gcull, int lcull, int verbosity,
    double ofs[HI_ENERGIES][HI_AZ_BINS], double ofsunc[HI_ENERGIES][HI_AZ_BINS],
    int ISOCstyle, double rates[HI_ENERGIES][HI_AZ_BINS],
    double ratesunc[HI_ENERGIES][HI_AZ_BINS], int nonneg, int keepbad,
    double iong[HI_ENERGIES][HI_AZ_BINS],
    double iongu[HI_ENERGIES][HI_AZ_BINS], double avghbtim)
{
	int i, j;
	uint32_t mmet;
	int swptable[HI_ENERGIES];
	char ens;

	mmet = alltimes[3] / 2 + alltimes[nallt - 4] / 2;
	if (get_sweeptable(mmet, swptable)) {
		if (verbosity > 1)
			printf("iso_get_all_ofs(): no sweep table?\n");
		return(-1);
	}
	for (i = 0; i < HI_ENERGIES; i++) {
		ens = '\0';
		/* This is not super-efficient in that it'll run twice when the
		 * ESA is doubled, but I'll worry about that only when speed here
		 * becomes an issue.
		 */
		for (j = 0; j < HI_ENERGIES; j++)
			if (swptable[j] == swptable[i])
				ens |= (1 << j);
		j = iso_get_offs(ens, hbtype, gcull, lcull, verbosity, ofs[i],
		    ofsunc[i], ISOCstyle, (rates != NULL ? rates[i]: NULL),
		    (rates != NULL ? ratesunc[i]: NULL), nonneg,
		    iong?iong[i]:NULL, iongu?iongu[i]:NULL, avghbtim);
		if (j) {
			if (j == 2 && keepbad) {
				if (verbosity > 0)
					printf("iso_get_all_ofs() had no gts for ESA %d.\n",
					    i+1);
				if (rates != NULL) {
					for (j = 0; j < HI_AZ_BINS; j++)
						rates[i][j] = 0.;
					if (ratesunc != NULL)
						for (j = 0; j < HI_AZ_BINS; j++)
							ratesunc[i][j] = -1.;
				}
				/* XXX reset offsets too? XXX */
			} else {
				if (verbosity > 0)
					printf("iso_get_all_ofs() bailing at ESA %d.\n", i+1);
				return(j);
			}
		}
	}
	return(0);
}


static int
ofs_different(double *s1, double *s2, double t1[HI_ENERGIES][HI_AZ_BINS],
    double t2[HI_ENERGIES][HI_AZ_BINS], int k)
{
	int i, rv;

	rv = 0;
	for (i = 0; i < HI_ENERGIES; i++)
		if (fabs(s1[i] - t1[i][k]) > 1e-10 ||
		    fabs(s2[i] - t2[i][k]) > 1e-10)
			rv = 1;
	return(rv);
}


/* fp must be open for writing. */
static void
make_ISOC_ofs_dump(FILE *fp, double arr1[HI_ENERGIES][HI_AZ_BINS],
    double arr2[HI_ENERGIES][HI_AZ_BINS], int orbit, uint32_t met1,
    uint32_t met2, int nonneg)
{
	int i, k1, k2;
	double oldr[HI_ENERGIES], oldu[HI_ENERGIES];

	k1 = 0; k2 = 1;
	for (i = 0; i < HI_ENERGIES; i++) {
		oldr[i] = arr1[i][0];
		oldu[i] = arr2[i][0];
	}
	do {
		while ((k2 < HI_AZ_BINS) &&
		    !ofs_different(oldr, oldu, arr1, arr2, k2))
			k2++;
		fprintf(fp, "%04d %u.0 %u.0 %d %d Hi ", orbit, met1, met2, k1, k2-1);
		for (i = 0; i < HI_ENERGIES; i++) {
			if (nonneg && arr1[i][k1] < 0.)
				fprintf(fp, "%.5lf ", 0.);
			else
				fprintf(fp, "%.5lf ", arr1[i][k1]);
			if (k2 < HI_AZ_BINS)
				oldr[i] = arr1[i][k2];
		}
		fprintf(fp, "rate\n");
		fprintf(fp, "%04d %u.0 %u.0 %d %d Hi ", orbit, met1, met2, k1, k2-1);
		for (i = 0; i < HI_ENERGIES; i++) {
			fprintf(fp, "%.5lf ", arr2[i][k1]);
			if (k2 < HI_AZ_BINS)
				oldu[i] = arr2[i][k2];
		}
		fprintf(fp, "sigma\n");
		k1 = k2;
		k2++;
	} while (k1 < HI_AZ_BINS);
}

/* Statistically merge up to three sets of offsets and uncertainties:
 * Penetrating background (same for all angles and energies)
 * A bonus offset (same for all angles at a given energy)
 * Another offset like ion gun (could be different by angle and by energy).
 *
 * Note:  the original idea was that the ion gun correction could be merged
 * as the last step.  That's no good - the ion gun has to go in before the
 * loose cull.  I'm keeping the additional-background-by-angle
 * functionality in case it's ever needed, assuming for now it'll be NULL
 * most of the time.
 *
 * Either of the last two may be NULL to indicate it doesn't exist and
 * shouldn't be added in.
 *
 * If the ion gun background matrix is non-NULL but an angle is flagged
 * with a negative uncertainty, that angle is considered BAD and retains a
 * negative uncertainty.
 *
 * Everything going in must be in Hz.
 *
 * retoffs will ALREADY have a loose cull offset in it (maybe all zeros).
 * Merge with that.  Or, it may have RATES, not offsets.  Set a flag for
 * that, and if that's the flag, subtract bgs rather than add them.
 * Let the rate go below zero here.
 */
static void
iso___add_uncs(double penbg, double penbgu, double addbg[HI_ENERGIES],
    double addbgu[HI_ENERGIES], double bg1r[HI_ENERGIES][HI_AZ_BINS],
    double bg1u[HI_ENERGIES][HI_AZ_BINS],
    double retoffs[HI_ENERGIES][HI_AZ_BINS],
    double retuncs[HI_ENERGIES][HI_AZ_BINS], int rateflag)
{
	int i, j;
	double tmp, tmpu;
	double tmp2, tmp2u;
	double m;

	m = 1.;
	if (rateflag)
		m = -1.;
	for (i = 0; i < HI_ENERGIES; i++) {
		tmp = penbg;
		tmpu = penbgu;
		if (addbg != NULL) {
			tmp += addbg[i];
			tmpu = sqrt(addbgu[i] * addbgu[i] + tmpu * tmpu);
		}
		for (j = 0; j < HI_AZ_BINS; j++) {
			tmp2 = tmp;
			tmp2u = tmpu;
			if (bg1r != NULL) {
				if (bg1u[i][j] >= 0.) {
					tmp2 += bg1r[i][j];
					tmp2u = sqrt(bg1u[i][j] * bg1u[i][j] + tmpu * tmpu);
				} else {
					tmp2u = -1.;
				}
			}
			/* Might as well always do the subtraction, even if the data
			 * is bogus.
			 */
			retoffs[i][j] += m * tmp2;
			if (tmp2u < 0. || retuncs[i][j] < 0.)
				retuncs[i][j] = -1.;
			else {
				retuncs[i][j] = sqrt(retuncs[i][j] * retuncs[i][j] +
				    tmp2u * tmp2u);
			}
		}
	}
}

/* Dump data in one of the following ftype formats:
 *-1:  ISOC-style but for non-overlapping good and loose culls, in /hb
 *     (basically a local diagnostic)
 * 0:  ISOC-style BG file (rates and sigmas), in Hz (needs "orbit"; start
 *        and end times must be filled in by hand later).  Also needs a
 *        CR bg and offset to combine in, since ISOC takes a grand total of
 *        ONE file for all this.
 * NULL fname means stdout.
 *
 * This automatically merges ESA 2 and ESA 3 into ESA 3 and moves ESA 1
 * into ESA 2 for the new sweep table.
 */
static int
iso___internal_dump_ofs_file(FILE *fp, int hbtype, int gcull, int lcull,
    int verbosity, int orbit, double crbghz, double crbgunchz,
    double esaoffs[HI_ENERGIES], double esauncs[HI_ENERGIES],
    double morebgs[HI_ENERGIES][HI_AZ_BINS],
    double morebgus[HI_ENERGIES][HI_AZ_BINS],
    uint32_t starmet, uint32_t enmet, int nonneg, double avhbtim)
{
	double offsets[HI_ENERGIES][HI_AZ_BINS];
	double offuncs[HI_ENERGIES][HI_AZ_BINS];
	double rates[HI_ENERGIES][HI_AZ_BINS];
	double rateuncs[HI_ENERGIES][HI_AZ_BINS];
	int i, j;
	double tmp;
	uint32_t mmet;
	int swptable[HI_ENERGIES];

	i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
	    1, rates, rateuncs, nonneg, 1, morebgs, morebgus, avhbtim);
	if (i) {
		fprintf(fp, "XXX\n");
		fclose(fp);
		return(i);
	}
	tmp = avhbtim / HI_ENERGIES / HI_AZ_BINS;
	/* Below as per internal_bgsubfile() */
	if (!strcasecmp(hbs[hbtype].name, "lABC") ||
	    !strcasecmp(hbs[hbtype].name, "lBC") ||
	    !strcasecmp(hbs[hbtype].name, "lAC"))
	    tmp *= 2.;
	/* Convert to Hz */
	for (i = 0; i < HI_ENERGIES; i++)
		for (j = 0; j < HI_AZ_BINS; j++) {
			offsets[i][j] /= tmp;
			if (nonneg && offsets[i][j] < 0.)
				offsets[i][j] = 0.;
			offuncs[i][j] /= tmp;
		}
	iso___add_uncs(crbghz, crbgunchz, esaoffs, esauncs, NULL, NULL,
	    offsets, offuncs, 0);
	/* Shift stuff over so that 'ESA 1' means 'Original ESA voltage
	 * setting 1', etc.  This is specifically for the new sweep table.
	 */
	mmet = alltimes[3] / 2 + alltimes[nallt - 4] / 2;
	/* Can't fail because it's run already in another function we called */
	if (get_sweeptable(mmet, swptable)) {
		if (verbosity > 1)
			printf("internal_dump_ofs_file: no sweep table?\n");
		return(-1);
	}
	/* Check for new sweep table and push stuff around if needed. */
	if (swptable[0] == 2 && swptable[1] == 3 && swptable[2] == 3) {
		fprintf(fp, "# ESAs shifted to original energies (1->2, 2+3->3)\n");
		for (i = 0; i < HI_AZ_BINS; i++) {
			/* paranoia */
			if (offsets[1][i] != offsets[2][i] ||
			    offuncs[1][i] != offuncs[2][i])
				fprintf(stderr, "internal_dump_ofs_file: found impossible offset variation angle %d\n", i);
			offsets[1][i] = offsets[0][i];
			offuncs[1][i] = offuncs[0][i];
			offsets[0][i] = 0.;
			offuncs[0][i] = 0.;
		}
	}
	make_ISOC_ofs_dump(fp, offsets, offuncs, orbit, starmet, enmet, 0);
	fclose(fp);
	return(0);
}

int
iso_dump_ofs_file(char *fname, int ftype, int hbtype, int gcull, int lcull,
    int verbosity, int orbit, double crbghz, double crbgunchz, int nonneg,
    uint32_t starmet, uint32_t enmet, double morebgs[HI_ENERGIES][HI_AZ_BINS],
    double morebgus[HI_ENERGIES][HI_AZ_BINS])
{
	double offsets[HI_ENERGIES][HI_AZ_BINS];
	double offuncs[HI_ENERGIES][HI_AZ_BINS];
	double rates[HI_ENERGIES][HI_AZ_BINS];
	double rateuncs[HI_ENERGIES][HI_AZ_BINS];
	FILE *fp;
	int i, j, k, l;
	double lhbtim;

	if (ftype < -1 || ftype > 0) {
		if (verbosity> 0)
			printf("dump_ofs_file() failed:  invalid file type.\n");
		return(1);
	}
	if (fname == NULL)
		fp = stdout;
	else if ((fp = fopen(fname, "a")) == NULL) {
		if (verbosity> 0)
			printf("dump_ofs_file() failed:  could not create file.\n");
		return(2);
	}
	/* Don't have a filename; at least tag this somehow. */
	fprintf(fp, "# Orbit %d (hb MET range %u - %u)\n", orbit,
	    hbs[hbtype].met[0], hbs[hbtype].met[hbs[hbtype].n - 1]);
	/* Make enough time encapsulation for the log file... */
	if (starmet == 0)
		starmet = hbs[hbtype].met[0] - (5 * 1.1 * APPROX_HBTIME);
	if (enmet == 0xFFFFFFFF)
		enmet = hbs[hbtype].met[hbs[hbtype].n - 1] + (4*1.1*APPROX_HBTIME);
	/* Need inertial_pointing already loaded */
	i = get_orbit_at_met(starmet, &j);
	k = get_orbit_at_met(enmet, &l);
	lhbtim = APPROX_HBTIME;
	if (i == -1 || i != k || j != l) {
		fprintf(fp,
"XXX Caution: data extends beyond a single arc (or bad initialization)\n");
	} else {
		k = getdefault_osbdba(i, j);
		if (k > 0) {
			l = get_hbtime(k - 1, -1, 0xFF, &lhbtim);
			if (l != 0)
				lhbtim = APPROX_HBTIME;
		}
	}
	switch (ftype) {
	case -1:
		fprintf(fp, "# Diagnostic loose/good offsets file\n\
# Rates and uncertainties are in /hb, not in Hz.\n\
# Histogram data used is %s.\n\
# Loose cull %d; good cull %d\n", hbs[hbtype].name, lcull+1, gcull+1);
		i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
		    0, rates, rateuncs, nonneg, 1, morebgs, morebgus, lhbtim);
		if (i) {
			fprintf(fp, "XXX\n");
			fclose(fp);
			return(i);
		}
		make_ISOC_ofs_dump(fp, offsets, offuncs, orbit, starmet, enmet,
		    nonneg);
		break;
	case 0:
		fprintf(fp, "# ISOC-style loose+good offsets file\n\
# Rates and uncertainties are in Hz.\n\
# Histogram data used is %s at a%s cadence of %.3lf s.\n\
# Loose cull %d; good cull %d\n", hbs[hbtype].name,
		    lhbtim == APPROX_HBTIME ? " DEFAULT":"", lhbtim, lcull+1, gcull+1);
		if (morebgs != NULL)
			fprintf(fp, "# Ion Gun background subtracted.\n");
		return(iso___internal_dump_ofs_file(fp, hbtype, gcull, lcull,
		    verbosity, orbit, crbghz, crbgunchz, NULL, NULL, morebgs,
		    morebgus, starmet, enmet, nonneg, lhbtim));
		break;
	}
	return(0);
}

int
iso_dump_ofs_file2(char *fname, int hbtype, int gcull, int lcull,
    int verbosity, int orbit, double crbghz, double crbgunchz,
    double morebgs[HI_ENERGIES], double morebgus[HI_ENERGIES],
    int nonneg, uint32_t starmet, uint32_t enmet,
    double ibgs[HI_ENERGIES][HI_AZ_BINS],
    double ibgus[HI_ENERGIES][HI_AZ_BINS])
{
	FILE *fp;
	int i, j, k, l;
	double lhbtim;

	if (fname == NULL)
		fp = stdout;
	else if ((fp = fopen(fname, "a")) == NULL) {
		if (verbosity> 0)
			printf("dump_ofs_file() failed:  could not create file.\n");
		return(2);
	}
	/* Don't have a filename; at least tag this somehow. */
	fprintf(fp, "# Orbit %d (hb MET range %u - %u)\n", orbit,
	    hbs[hbtype].met[0], hbs[hbtype].met[hbs[hbtype].n - 1]);
	/* Make enough time encapsulation for the log file... */
	if (starmet == 0)
		starmet = hbs[hbtype].met[0] - (5 * 1.1 * APPROX_HBTIME);
	if (enmet == 0xFFFFFFFF)
		enmet = hbs[hbtype].met[hbs[hbtype].n - 1] + (4 * 1.1*APPROX_HBTIME);
	/* Need inertial_pointing read in */
	i = get_orbit_at_met(starmet, &j);
	k = get_orbit_at_met(enmet, &l);
	lhbtim = APPROX_HBTIME;
	if (i == -1 || i != k || j != l) {
		fprintf(fp,
"XXX Caution: data extends beyond a single arc (or bad initialization)\n");
	} else {
		k = getdefault_osbdba(i, j);
		if (k > 0) {
			l = get_hbtime(k - 1, -1, 0xFF, &lhbtim);
			if (l != 0)
				lhbtim = APPROX_HBTIME;
		}
	}
	fprintf(fp, "# ISOC-style loose+good offsets file\n\
# Rates and uncertainties are in Hz.\n\
# Histogram data used is %s at a%s cadence of %.3lf s.\n\
# Loose cull %d; good cull %d\n", hbs[hbtype].name,
	    lhbtim == APPROX_HBTIME ? " DEFAULT":"", lhbtim, lcull+1, gcull+1);
	if (morebgs != NULL) {
		fprintf(fp, "# Additional inexplicable offsets added:\n");
		for (i = 0; i < HI_ENERGIES; i++)
			fprintf(fp, "# ESA %d: %lf +- %lf\n", i+1, morebgs[i],
			    morebgus[i]);
	}
	return(iso___internal_dump_ofs_file(fp, hbtype, gcull, lcull,
	    verbosity, orbit, crbghz, crbgunchz, morebgs, morebgus,
	    ibgs, ibgus, starmet, enmet, nonneg, lhbtim));
}


/* Dump data in one of the following ftype formats:
 * 0:  xhihb "/f" style (in /hb) using ISOC-based rates (but no additional
 *     offset -- no cosmic rays)
 * 1:  xhihb "/f" style  (in /hb)
 * 2:  xhihb "/fo" style  (in /hb)
 * fname == NULL means stdout
 */
int
iso_dump_rate_file(char *fname, int ftype, int hbtype, int gcull, int lcull,
    int verbosity, int nonneg)
{
	double offsets[HI_ENERGIES][HI_AZ_BINS];
	double offuncs[HI_ENERGIES][HI_AZ_BINS];
	double rates[HI_ENERGIES][HI_AZ_BINS];
	double rateuncs[HI_ENERGIES][HI_AZ_BINS];
	FILE *fp;
	int i, j, k, gn;
	long gct;

	if (ftype < 0 || ftype > 2) {
		if (verbosity> 0)
			printf("dump_rate_file() failed:  invalid file type.\n");
		return(1);
	}
	if (fname == NULL)
		fp = stdout;
	else if ((fp = fopen(fname, "w")) == NULL) {
		if (verbosity> 0)
			printf("dump_rate_file() failed:  could not create file.\n");
		return(2);
	}
	/* Don't have a filename; at least tag this somehow. */
	fprintf(fp, "# MET range %u - %u\n", hbs[hbtype].met[0],
	    hbs[hbtype].met[hbs[hbtype].n - 1]);
	switch (ftype) {
	case 0:
	case 1:
		fprintf(fp, "# 24x60 multiple cull dump\n\
# Rows are the 60 angle bins; columns are ESA 1 -- 6 rates and\n\
# uncertainties of combined culls \"%d\" and \"%d\", with the latter\n\
# serving as the base good cull, followed by rates and uncertainties\n\
# of cull \"%d\" on its own.\n\
#\n", lcull+1, gcull+1, gcull+1);
		if (ftype == 0)
			fprintf(fp, "# ...uses ISOC-style rates.\n");
		fprintf(fp, "# histogram bin type %s\n", hbs[hbtype].name);
		i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
		    abs(ftype-1), rates, rateuncs, nonneg, 1, NULL, NULL,
		    APPROX_HBTIME);
		if (i) {
			fprintf(fp, "XXX\n");
			fclose(fp);
			return(i);
		}
		for (i = 0; i < HI_AZ_BINS; i++) {
			for (j = 0; j < HI_ENERGIES; j++)
				fprintf(fp, "\t%lf\t%lf", rates[j][i], rateuncs[j][i]);
			for (j = 0; j < HI_ENERGIES; j++) {
				/* Get the good cull info, again... */
				gct = 0;
				gn = 0;
				for (k = 0; k < hbs[hbtype].n; k++) {
					if (isincull(gcull, hbs[hbtype].met[k], j, i)) {
						gct += (*(hbs[hbtype].data[k]))[j][i];
						gn++;
					}
				}
				if (gn > 0)
					fprintf(fp, "\t%lf\t%lf", (double)gct / gn,
					    sqrt((double)gct) / gn);
				else
					fprintf(fp, "\t0\t-1");
			}
			fprintf(fp, "\n");
		}
		break;
	case 2:
		fprintf(fp,
"# Culled, \"good\"-time histogram of rates over angle\n\
# -- this is meant to look similar to a single-cull count/histogram plot,\n\
# only it uses the merging of two culls\n\
# Each row is one angle bin (0--59)\n\
# Column 2n is rate (/hb), column 2n+1 is 1.0,\n\
# for n in 0-5 for the six ESA settings.\n");
		fprintf(fp, "# histogram bin type %s\n", hbs[hbtype].name);
		i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
		    0, rates, rateuncs, nonneg, 1, NULL, NULL, APPROX_HBTIME);
		if (i) {
			fprintf(fp, "XXX\n");
			fclose(fp);
			return(i);
		}
		for (i = 0; i < HI_AZ_BINS; i++) {
			for (j = 0; j < HI_ENERGIES; j++)
				fprintf(fp, "\t%lf\t1.0", rates[j][i]);
			fprintf(fp, "\n");
		}
		break;
	}
	fclose(fp);
	return(0);
}

/* This almost could be in the above function, except to do background
 * subtraction, you need to pass along a background and an uncertainty.
 * This assumes Gaussian statistics.
 */
static int
iso__internal_bgsubfile(FILE *fp, int hbtype, int gcull, int lcull,
    int verbosity, double pbg, double pbu, int nonneg, double avghbtime,
    double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igr[HI_ENERGIES][HI_AZ_BINS], double igu[HI_ENERGIES][HI_AZ_BINS])
{
	double offsets[HI_ENERGIES][HI_AZ_BINS];
	double offuncs[HI_ENERGIES][HI_AZ_BINS];
	double rates[HI_ENERGIES][HI_AZ_BINS];
	double rateuncs[HI_ENERGIES][HI_AZ_BINS];
	double shifter;
	int i, j, nflag;
	uint32_t mmet;
	int swptable[HI_ENERGIES];

	nflag = 0;
	i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
	    0, rates, rateuncs, nonneg, 1, igr, igu, avghbtime);
	if (i) {
		fprintf(fp, "XXX\n");
		fclose(fp);
		return(i);
	}
	/* In the conversion to Hz, need to account for HIST_L having half
	 * cadence -- everything so far has been in /hb.
	 * XXX First off, cadence is adjustable on s/c.  Secondly, we can move
	 * XXX data types around.  Assume I haven't and just adjust HB_LABC,
	 * XXX HB_LBC, HB_LAC.  Obviously despun stuff is on standard cadence.
	 */
	if (!strcasecmp(hbs[hbtype].name, "lABC") ||
	    !strcasecmp(hbs[hbtype].name, "lBC") ||
	    !strcasecmp(hbs[hbtype].name, "lAC"))
		shifter = 0.5;
	else
		shifter = 1.;
	shifter *= HI_AZ_BINS * HI_ENERGIES / avghbtime;
	/* Need to convert from /hb to Hz, then subtract bgs */
	for (i = 0; i < HI_AZ_BINS; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
				rates[j][i] *= shifter;
				if (rateuncs[j][i] >= 0.)
					rateuncs[j][i] *= shifter;
			}
	}
	iso___add_uncs(pbg, pbu, abg, abu, NULL, NULL, rates, rateuncs, 1);
	/* Merge ESAs 2 & 3 if we're on the new sweep map. */
	mmet = alltimes[3] / 2 + alltimes[nallt - 4] / 2;
	/* Can't fail because it's run already in another function we called */
	if (get_sweeptable(mmet, swptable)) {
		if (verbosity > 1)
			printf("internal_dump_ofs_file: no sweep table?\n");
		fprintf(fp, "XXX\n");
		fclose(fp);
		return(-1);
	}
	/* Check for new sweep table and push stuff around if needed. */
	if (swptable[0] == 2 && swptable[1] == 3 && swptable[2] == 3) {
		fprintf(fp, "# ESAs shifted to original energies (1->2, 2+3->3)\n");
		nflag = 1;
	}

	for (i = 0; i < HI_AZ_BINS; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
			if (rates[j][i] < 0.)
				rates[j][i] = 0.;
			if (nflag) {
				if (j == 0)
					fprintf(fp, "\t0\t0");
				else if (j == 1)
					fprintf(fp, "\t%lf\t%lf", rates[0][i], rateuncs[0][i]);
				else
					fprintf(fp, "\t%lf\t%lf", rates[j][i], rateuncs[j][i]);
			} else
				fprintf(fp, "\t%lf\t%lf", rates[j][i], rateuncs[j][i]);
		}
		fprintf(fp, "\n");
	}
	fclose(fp);
	return(0);
}


int
iso_dump_rate_bgsub_file(char *fname, int hbtype, int gcull, int lcull,
    int verbosity, double penbg, double penbgunc, int nonneg,
    double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igbr[HI_ENERGIES][HI_AZ_BINS],
    double igbu[HI_ENERGIES][HI_AZ_BINS])
{
	FILE *fp;
	int i, j, k, l;
	double lhbtim;

	if (fname == NULL)
		fp = stdout;
	else if ((fp = fopen(fname, "w")) == NULL) {
		if (verbosity> 0)
			printf("dump_rate_bgsub_file() failed:  could not create file.\n");
		return(2);
	}
	/* Don't have a filename; at least tag this somehow. */
	fprintf(fp, "# MET range %u - %u\n", hbs[hbtype].met[0],
	    hbs[hbtype].met[hbs[hbtype].n - 1]);
	fprintf(fp, "# 12x60 multiple cull dump\n\
# Rows are the 60 angle bins; columns are ESA 1 -- 6 rates and\n\
# uncertainties of combined culls \"%d\" and \"%d\", with the latter\n\
# serving as the base good cull.  Penetrating background has been\n\
# subtracted:  %lf +- %lf Hz.  Rates below are in Hz.\n\
#\n", lcull+1, gcull+1, penbg, penbgunc);
	if (abg != NULL) {
		fprintf(fp, "# Additional background has been subtracted:\n");
		for (i = 0; i < HI_ENERGIES; i++)
			fprintf(fp, "# ESA %d:  %lf +- %lf\n", i+1, abg[i], abu[i]);
	}
	fprintf(fp, "# histogram bin type %s\n", hbs[hbtype].name);
	if (igbr != NULL)
		fprintf(fp, "# Ion Gun background was subtracted.\n");
	/* Need inertial_pointing read in */
	i = get_orbit_at_met(hbs[hbtype].met[0] - 1.1 * APPROX_HBTIME, &j);
	k = get_orbit_at_met(hbs[hbtype].met[hbs[hbtype].n - 1], &l);
	lhbtim = APPROX_HBTIME;
	if (i == -1 || i != k || j != l) {
		fprintf(fp,
"XXX Caution: data extends beyond a single arc (or bad initialization)\n");
	} else {
		k = getdefault_osbdba(i, j);
		if (k > 0) {
			l = get_hbtime(k - 1, -1, 0xFF, &lhbtim);
			if (l != 0)
				lhbtim = APPROX_HBTIME;
		}
	}
	fprintf(fp, "#%s histogram cadence used (%.3lf s)\n",
	    lhbtim == APPROX_HBTIME ? " DEFAULT":"", lhbtim);
	/* this calls fclose() */
	return(iso__internal_bgsubfile(fp, hbtype, gcull, lcull, verbosity,
	    penbg, penbgunc, nonneg, lhbtim, abg, abu, igbr, igbu));
}

/* This is awful duplication of the above functions without the 'X'.
 * The only difference is that when dumping here, we record pointing.
 */
static int
iso__internal_bgsubfileX(FILE *fp, int hbtype, int gcull, int lcull,
    int verbosity, double pbg, double pbu, int nonneg, double avghbtime,
    int orbit, int whicharc,
    double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igr[HI_ENERGIES][HI_AZ_BINS], double igu[HI_ENERGIES][HI_AZ_BINS])
{
	double offsets[HI_ENERGIES][HI_AZ_BINS];
	double offuncs[HI_ENERGIES][HI_AZ_BINS];
	double rates[HI_ENERGIES][HI_AZ_BINS];
	double rateuncs[HI_ENERGIES][HI_AZ_BINS];
	double shifter;
	int i, j, nflag;
	double la, lng;
	uint32_t mmet;
	int swptable[HI_ENERGIES];

	nflag = 0;
	i = iso_get_all_ofs(hbtype, gcull, lcull, verbosity, offsets, offuncs,
	    0, rates, rateuncs, nonneg, 1, igr, igu, avghbtime);
	if (i) {
		fprintf(fp, "XXX\n");
		fclose(fp);
		return(i);
	}
	/* In the conversion to Hz, need to account for HIST_L having half
	 * cadence -- everything so far has been in /hb.
	 * XXX First off, cadence is adjustable on s/c.  Secondly, we can move
	 * XXX data types around.  Assume I haven't and just adjust HB_LABC,
	 * XXX HB_LBC, HB_LAC.  Obviously despun stuff is on standard cadence.
	 */
	if (hbtype == HB_LABC || hbtype == HB_LBC || hbtype == HB_LAC)
		shifter = 0.5;
	else
		shifter = 1.;
	shifter *= HI_AZ_BINS * HI_ENERGIES / avghbtime;
	/* Need to convert from /hb to Hz, then subtract bgs */
	for (i = 0; i < HI_AZ_BINS; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
				rates[j][i] *= shifter;
				if (rateuncs[j][i] >= 0.)
					rateuncs[j][i] *= shifter;
			}
	}
	iso___add_uncs(pbg, pbu, abg, abu, NULL, NULL, rates, rateuncs, 1);
	/* Merge ESAs 2 & 3 if we're on the new sweep map. */
	mmet = alltimes[3] / 2 + alltimes[nallt - 4] / 2;
	/* Can't fail because it's run already in another function we called */
	if (get_sweeptable(mmet, swptable)) {
		if (verbosity > 1)
			printf("internal_dump_ofs_file: no sweep table?\n");
		fprintf(fp, "XXX\n");
		fclose(fp);
		return(-1);
	}
	/* Check for new sweep table and push stuff around if needed. */
	if (swptable[0] == 2 && swptable[1] == 3 && swptable[2] == 3) {
		fprintf(fp, "# ESAs shifted to original energies (1->2, 2+3->3)\n");
		nflag = 1;
	}

	for (i = 0; i < HI_AZ_BINS; i++) {
		get_la_lng_from_orb_ang(orbit, whicharc, 6. * i, &la, &lng);
		fprintf(fp, "%lf\t%lf", la, lng);
		for (j = 0; j < HI_ENERGIES; j++) {
			if (rates[j][i] < 0.)
				rates[j][i] = 0.;
			if (nflag) {
				if (j == 0)
					fprintf(fp, "\t0\t0");
				else if (j == 1)
					fprintf(fp, "\t%lf\t%lf", rates[0][i], rateuncs[0][i]);
				else
					fprintf(fp, "\t%lf\t%lf", rates[j][i], rateuncs[j][i]);
			} else
				fprintf(fp, "\t%lf\t%lf", rates[j][i], rateuncs[j][i]);
		}
		fprintf(fp, "\n");
	}
	fclose(fp);
	return(0);
}

int
iso_dump_rate_bgsub_fileX(char *fname, int hbtype, int gcull, int lcull,
    int verbosity, double bgratehz, double bgrateunchz, int nonneg,
    int orbit, int whicharc, double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igbr[HI_ENERGIES][HI_AZ_BINS], double igbu[HI_ENERGIES][HI_AZ_BINS])
{
	FILE *fp;
	int i, j, k, l;
	double lhbtim;

	if (fname == NULL)
		fp = stdout;
	else if ((fp = fopen(fname, "w")) == NULL) {
		if (verbosity> 0)
			printf("dump_rate_bgsub_fileX() failed:  could not create file.\n");
		return(2);
	}
	/* Don't have a filename; at least tag this somehow. */
	fprintf(fp, "# MET range %u - %u\n", hbs[hbtype].met[0],
	    hbs[hbtype].met[hbs[hbtype].n - 1]);
	fprintf(fp, "# 12x60 multiple cull dump\n\
# Rows are the 60 angle bins; columns are ESA 1 -- 6 rates and\n\
# uncertainties of combined culls \"%d\" and \"%d\", with the latter\n\
# serving as the base good cull.  Penetrating background has been\n\
# subtracted:  %lf +- %lf Hz.  Rates below are in Hz.\n\
# First two columns: ecliptic lat and long of central look direction.\n\
#\n", lcull+1, gcull+1, bgratehz, bgrateunchz);
	if (abg != NULL) {
		fprintf(fp, "# Additional background has been subtracted:\n");
		for (i = 0; i < HI_ENERGIES; i++)
			fprintf(fp, "# ESA %d:  %lf +- %lf\n", i+1, abg[i], abu[i]);
	}
	fprintf(fp, "# histogram bin type %s\n", hbs[hbtype].name);
	if (igbr != NULL)
		fprintf(fp, "# Ion Gun background was subtracted.\n");
	/* Need inertial_pointing read in */
	i = get_orbit_at_met(hbs[hbtype].met[0] - 1.1 * APPROX_HBTIME, &j);
	k = get_orbit_at_met(hbs[hbtype].met[hbs[hbtype].n - 1], &l);
	lhbtim = APPROX_HBTIME;
	k = getdefault_osbdba(orbit, whicharc);
	if (k > 0) {
		l = get_hbtime(k - 1, -1, 0xFF, &lhbtim);
		if (l != 0)
			lhbtim = APPROX_HBTIME;
	}
	fprintf(fp, "#%s histogram cadence used (%.3lf s)\n",
	    lhbtim == APPROX_HBTIME ? " DEFAULT":"", lhbtim);
	/* this calls fclose() */
	return(iso__internal_bgsubfileX(fp, hbtype, gcull, lcull, verbosity,
	    bgratehz, bgrateunchz, nonneg, lhbtim, orbit, whicharc, abg, abu,
	    igbr, igbu));
}
