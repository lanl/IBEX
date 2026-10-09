/*	$Id: processcull.c,v 1.28 2020/01/03 00:01:12 pjanzen Exp $	*/
/* Generic processing of culled "good times" files.
 * Do not handle any Lo culling.
 * Use a char to represent energy steps (even Lo has only 8 ESA settings).
 */

static const char rcsid[] = "@(#) $Id: processcull.c,v 1.28 2020/01/03 00:01:12 pjanzen Exp $";

#include <ctype.h>
#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ibexhi.h"


/* Internally, I base cull times on time of histogram creation (plus slop).
 * The ISOC wants more clearly a START time and an END time, and this makes
 * sense.  Officially both the ISOC and I round to the closest <n>-spin
 * boundary.  I fix on 48 spins (hb cadence); the ISOC formally says 24.
 *
 * I will assume that histogram creation time is close enough to END time
 * to count.  I will determine START time as the second following the
 * creation of the previous qABC packet.
 *
 * While I'm at it, I'll check the cadence of qABCs inbetween and emit a
 * warning if it turns out that we aren't within +-20% of APPROX_HBTIME at any
 * point.  This should be enough to catch dropped packets or transitions
 * out of HVSCI.
 *
 * Modification:  not just qABC; sync on despun DEs instead if you can.
 */
/* THIS IS FOR WRITING */
static void
spiffup_times(int starti, int endi, uint32_t *met1, uint32_t *met2,
    int syncwith)
{
	int i, j, k;
	long l;

	if (endi < starti) {
		if (l_verbosity > -10)
			fprintf(stderr, "spiffup_times:  b0rked call (end < start)\n");
		*met1 = *met2 = 0;
		return;
	}
	*met2 = alltimes[endi];
	/* Look for previous packet.  If for some reason gts start on the
	 * first packet, fudge.
	 */
	i = 0;
	while (i < hbs[syncwith].n &&
	    hbs[syncwith].met[i] + HBtimeSlop < alltimes[starti])
		i++;
	i--;
	if (i < 0) {
		if (l_verbosity > -10)
			fprintf(stderr,
			    "spiffup_times:  gt block starts on first packet...\n");
		*met1 = hbs[syncwith].met[0] - (0.98 * APPROX_HBTIME);
	} else
		*met1 = hbs[syncwith].met[i] + 1;

	/* Now find the packet corresponding to the end time, just so we can
	 * do a cadence check on the interval.
	 */
	j = i;
	if (i < 0)
		j = 0;
	while (j < hbs[syncwith].n && hbs[syncwith].met[j] + HBtimeSlop < *met2)
		j++;
	if (j == hbs[syncwith].n) {
		j--;
		if (l_verbosity > -10)
			fprintf(stderr,
			    "spiffup_times: gt block goes to end of HVSCI...\n");
		*met2 = hbs[syncwith].met[j];
	}
	for (k = (i<0?0:i); k < j; k++) {
		l = (long)(hbs[syncwith].met[k+1]) - (long)hbs[syncwith].met[k];
		if (l < 0.8 * APPROX_HBTIME || l > 1.2 * APPROX_HBTIME) {
			/* Allow being next to a gap. */
			if (k == i) {
				/* Technically, we're outside the good time interval,
				 * except that we use the previous packet for timing.
				 * So we need to adjust that.
				 */
				if (i >= 0 && i < hbs[syncwith].n - 1)
					*met1 = hbs[syncwith].met[i+1] - (0.98 * APPROX_HBTIME);
			} else {
				if (l_verbosity > -10)
					fprintf(stderr,
	    "spiffup_times:  gt block has bad cadence %ld near MET %u %u\n",
					    l, hbs[syncwith].met[k], hbs[syncwith].met[k+1]);
				k = j;	/* break */
			}
		}
		/* XXX really should complain if we expect 96 but get 48 */
		if (hbs[syncwith].spincount[k + 1] != 48 &&
		    hbs[syncwith].spincount[k + 1] != 96 &&
		    l_verbosity > -10)
			fprintf(stderr,
	    "spiffup_times:  gt block has bad spincount %d near MET %u %u\n",
		    hbs[syncwith].spincount[k+1], hbs[syncwith].met[k],
		    hbs[syncwith].met[k+1]);
	}
}


/* When reading in a cull file, I need to shift the start times back to
 * first histogram clearly AFTER it (i.e., within 20% of one APPROX_HBTIME
 * following).  Well, kind of.  If it's a despun orbit there's no guarantee
 * that things line up well at all (in which case I should print some short
 * warning).
 */
/* THIS IS FOR READING */
static uint32_t
unspiff_startmet(uint32_t wmet, int syncwith)
{
	int i;
	long l;

	/* Find the first qABC packet after this time + 20% of APPROX_HBTIME.
	 * Possibly warn if it's not approx one APPROX_HBTIME later.
	 */
	i = 0;
	while (i < hbs[syncwith].n &&
	    hbs[syncwith].met[i] < 0.2 * APPROX_HBTIME + HBtimeSlop + wmet)
		i++;
	/* i is now the packet time; we want to make sure the following 48
	 * spins are good.
	 */
	if (i == 0) {
		/* Sometimes I've started culls right at the first good packet,
		 * meaning that if we've cull-partialled, there may BE no packet
		 * prior, which is all right.  Try not to print a warning in
		 * such a case.
		 */
		if (l_verbosity > -10 && hbs[syncwith].met[0] >
		    wmet + APPROX_HBTIME + HBtimeSlop)
			fprintf(stderr,
	    "unspiff_startmet:  good times start before %s data does (?!?)\n",
			    hbs[syncwith].name);
		return(hbs[syncwith].met[0]);
	}
	if (i >= hbs[syncwith].n - 1) {
		if (l_verbosity > -10)
			fprintf(stderr,
		    "unspiff_startmet:  good times start after data does (?!?)\n");
		return(hbs[syncwith].met[hbs[syncwith].n - 1]);
	}
	l = (long)(hbs[syncwith].met[i+1]) - (long)(hbs[syncwith].met[i]);
	if (l < 0.8 * APPROX_HBTIME && l_verbosity > -10)
		fprintf(stderr,
"unspiff_startmet:  good times appear to have a nonfull packet circa %u\n",
		    hbs[syncwith].met[i]);
	if (l > 1.2 * APPROX_HBTIME && l_verbosity > -10)
		fprintf(stderr,
"unspiff_startmet:  good times appear to contain a gap circa %u\n",
		    hbs[syncwith].met[i]);
	return(hbs[syncwith].met[i]);
}

/* Return nonzero if the given MET is more than 20s off qABC, because the
 * timing is _supposed_ to sync to qABC histograms, independent of anything
 * else.  This is basically to catch using a "despun" good times list on a
 * nondespun orbit or vice versa.
 * Note that you can ask to sync to DEs if they're despun.  Syncing to a
 * '-F' file is automatic since they live in the qABCs.
 */
#define VERYBADHBTIMING (20)
static int
poorpkttiming(uint32_t wmet, int syncwith)
{
	int i;

	i = 0;
	while (i < hbs[syncwith].n && hbs[syncwith].met[i] + VERYBADHBTIMING <
	    wmet)
		i++;
	if (i == hbs[syncwith].n)
		return(-1);
	if (labs((long)(hbs[syncwith].met[i]) - wmet) > VERYBADHBTIMING)
		return(1);
	return(0);
}

void
print_culls_populated()
{
	int i, j, k, s, junk;

	printf("Culls populated: ");
	s = 0;
	for (k = 0; k < 8; k++) {
		junk = 0;
		for (i = 0; i < nallt; i++)
			for (j = 0; j < HI_AZ_BINS; j++)
				if (mculls[k][i * HI_AZ_BINS + j]) {
					junk = 1;
					j = HI_AZ_BINS;
					i = nallt;
				}
		if (junk) {
			printf(" %d", k+1);
			s = 1;
		}
	}
	if (!s)
		printf("NONE");
	printf("\n");
}

/* Return 0 on success, -1 if file couldn't be opened, or the line number
 * of the problem.  Note that a NEGATIVE return value means the current
 * cull settings remain untouched.
 *
 * Temporarily reset l_verbosity for everything called underneath this.
 */
int
read_goodtimes(char *fname, int clr, int verbosity, int *whichorb,
    int syncwith)
{
	FILE *fp;
	char foo[8192];
	char *p;
	int junk, esa1, esa2, esa3, esa4, esa5, esa6, esa7, esa8;
	int angbin1, angbin2, i, j, k;
	int line;
	int nlastline;
	double met1, met2;
	char side[3];
	char emap;
	int thisorb, notedbad;
	int old_lverbos;

	if ((fp = fopen(fname, "r")) == NULL)
		return(-1);
	old_lverbos = l_verbosity;
	l_verbosity = verbosity;
	nlastline = 0;
	line = 0;
	notedbad = 0;
	thisorb = -1;
	if (clr)
		memset(mculls[defaultmcull], 0, HI_AZ_BINS * nallt);
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
				if (nlastline == 0) {
					nlastline = i;
					if (i == 13 && clr) {
						/* Need to clear not just the working cull,
						 * but all of the rest, too.
						 * XXX no way to undo.
						 */
						for (j = 0; j < 8; j++)
							memset(mculls[j], 0, HI_AZ_BINS * nallt);
					}
				}
				if ((i != 12 && i != 13 && i != nlastline) ||
				    angbin1 < 0 || angbin2 < angbin1 ||
				    met1 >= met2 || angbin2 > HI_AZ_BINS - 1) {
					fclose(fp);
					l_verbosity = old_lverbos;
					return(line);
				}
				if (alltimes[0] <= met2 && alltimes[nallt-1] >= met1) {
					if (thisorb > 0 && thisorb != junk) {
						fprintf(stderr,
"reading Hi cull:  seems there's more than one orbit here!\n");
					}
					thisorb = junk;
#ifndef OLDSCHOOLREAD
					met1 = unspiff_startmet(met1, syncwith);
					/* If despun, there could be a second or two of
					 * slop on met2, so just make met2 slightly later.
					 */
					met2 += HBtimeSlop;
#endif
					if (!notedbad && (poorpkttiming(met1, syncwith) ||
					    poorpkttiming(met2, syncwith))) {
						notedbad = 1;
						if (verbosity > -10)
							fprintf(stderr,
"warning: Hi good times cull doesn't seem to line up with %s cadence\n",
							    hbs[syncwith].name);
					}
				}
				emap = 0;
				if (esa1) emap |= 1;
				if (esa2) emap |= 2;
				if (esa3) emap |= 4;
				if (esa4) emap |= 8;
				if (esa5) emap |= 16;
				if (esa6) emap |= 32;
				/* nlastline == 13 if it's a "new" cull file.  Populate
				 * relevant culls; later, set defaultmcull.
				 */
				if (nlastline == 13) {
					for (i = 0; i < nallt; i++) {
						if ((alltimes[i] <= (uint32_t)met2) &&
						    (alltimes[i] >= (uint32_t)met1)) {
							for (j = angbin1; j <= angbin2; j++) {
								for (k = 0; k < 8; k++)
									if ((1<<k) & esa7)
										mculls[k][i * HI_AZ_BINS + j] |= emap;
							}
						}
					}
				} else {
					for (i = 0; i < nallt; i++) {
						if ((alltimes[i] <= (uint32_t)met2) &&
						    (alltimes[i] >= (uint32_t)met1)) {
							for (j = angbin1; j <= angbin2; j++) {
#ifdef CHECKDUPE
if (mculls[defaultmcull][i * HI_AZ_BINS + j] & emap)
	printf("Dupe %d\n", line);
#endif
mculls[defaultmcull][i * HI_AZ_BINS + j] |= emap;
							}
						}
					}
				}
			} else if (!strcasecmp(side, "lo")) {
				/* Sanity check the line, but do no more. */
				if (i != 14 || angbin1 < 0 || angbin2 < 0 ||
				    angbin1 > HI_AZ_BINS - 1 ||
				    angbin2 > HI_AZ_BINS - 1) {
					fclose(fp);
					l_verbosity = old_lverbos;
					return(line);
				}
			} else {
				fclose(fp);
				l_verbosity = old_lverbos;
				return(line);
			}
		}
	}
	fclose(fp);
	if (nlastline == 13 && verbosity > 0)
		print_culls_populated();
	else if (verbosity > 0)
		printf("working cull populated.\n");
	/* Make work cull the same as second multicull by default. */
	if (nlastline == 13)
		defaultmcull = 1;
	if (whichorb)
		*whichorb = thisorb;
	l_verbosity = old_lverbos;
	return(0);
}


/* Return true if no ESAs are to be on for time i */
static int
is_cullnull(int i)
{
	int j;

	for (j = 0; j < HI_AZ_BINS; j++)
		if (mculls[defaultmcull][i * HI_AZ_BINS + j])
			return(0);
	return(1);
}
static int
is_cullsame(int i1, int i2)
{
	int j;

	for (j = 0; j < HI_AZ_BINS; j++)
		if (mculls[defaultmcull][i1 * HI_AZ_BINS + j] !=
		    mculls[defaultmcull][i2 * HI_AZ_BINS + j])
			return(0);
	return(1);
}
static int
is_cullEmatch(int i1, int i2, int t)
{
	int j;

	for (j = 0; j < HI_AZ_BINS; j++)
		if (((mculls[defaultmcull][t * HI_AZ_BINS + j] & (1 << i1)) >> i1) !=
		    ((mculls[defaultmcull][t * HI_AZ_BINS + j] & (1 << i2)) >> i2))
		return(0);
	return(1);
}


/* XXX here's a tricky one -- if we're working on a -c (-c?), we need to CUT
 * OUT good times between any overly long intervals.  If we can assume
 * we're only ever using -c (-c?) files, we don't need to look for intervals
 * that don't have enough spins and cut them.  But we need to make sure
 * when we write that we don't gloss over non-HVSCI times or non-full-bin
 * times.
 * multi == 0 --> old style cullfile.  Otherwise, it's cull (1<<(multi-1)
 * syncwith:  which HB to sync on.  Usually it's HB_QABC, but if we've
 * despun it could be something else.
 */
int
write_goodtimes(char *fname, int orbit, int multi, int syncwith)
{
	FILE *fp;
	int i, j, k, starti, startk;
	int done[HI_ENERGIES];
	char estring[HI_ENERGIES * 2 + 1];
	char multistr[10];
	uint32_t metstrt, metstop;

	/* Whatever we do, don't nuke something that's already there,
	 * although it's best if this is a new file.
	 */
	if (multi < 0 || multi > 8 || syncwith < 0 || syncwith >= BIN_TYPES)
		return(-2);
	if (multi > 0)
		snprintf(multistr, sizeof(multistr), "  %d", 1 << (multi - 1));
	else
		multistr[0] = '\0';
	if ((fp = fopen(fname, "a")) == NULL)
		return(-1);
	fprintf(fp, "# xhihb Hi culled times dump\n#\n");
	/* One loop covers everything, even funky angle-bin stuff.  There's a
	 * lot of that as long as angle bin 0 from ESA 1 is not being accepted.
	 * Strategy is:  find longest time period for which none of the 60
	 * angle bins change.  Then, starting at ESA 1 and working up, figure
	 * out the angle ranges, one by one.  If the angle bins match exactly
	 * for multiple ESA settings, book'em together.
	 */
	i = 0;
	while (i < nallt) {
		if (!is_cullnull(i)) {
			starti = i;
			i++;
			while (i < nallt && is_cullsame(starti, i))
				i++;
			i--;
			for (j = 0; j < HI_ENERGIES; j++)
				done[j] = -1;
			j = 0;
			/* Only group energies if they're identical throughout;
			 * don't pick little matching subangle ranges.
			 */
			while (j < HI_ENERGIES) {
				if (done[j] == -1) {
					done[j] = j;
					for (k = j + 1; k < HI_ENERGIES; k++)
						if (is_cullEmatch(j, k, i)) {
							if (done[k] != -1)
		printf("write_goodtimes: botch 1 for %d, %d\n", j, k);
							done[k] = j;
						}
					/* XXX hah, stop pretense that HI_ENERGIES is ever
					 * not 6.
					 */
					snprintf(estring, HI_ENERGIES * 2 + 1,
    "%c %c %c %c %c %c", (done[0] == j)?'1':'0', (done[1] == j)?'1':'0',
    (done[2] == j)?'1':'0', (done[3] == j)?'1':'0', (done[4] == j)?'1':'0',
    (done[5] == j)?'1':'0');
					k = 0;
					while (k < HI_AZ_BINS) {
						if (mculls[defaultmcull][i * HI_AZ_BINS + k] &
						    (1<<j)) {
							startk = k;
							k++;
							while (k < HI_AZ_BINS &&
							    (mculls[defaultmcull][i * HI_AZ_BINS + k]
							    & (1<<j)))
								k++;
							k--;
#ifndef OLDSCHOOLWRITE
							spiffup_times(starti, i, &metstrt, &metstop,
							    syncwith);
#else
							metstrt = alltimes[starti];
							metstop = alltimes[i];
#endif
							fprintf(fp,
				    "%04d %u.0 %u.0 %2d %2d Hi %s%s\n",
				    orbit, metstrt, metstop, startk, k,
				    estring, multistr);
						}
						k++;
					}
				}
				j++;
			}
		}
		i++;
	}
	fclose(fp);
	return(0);
}

/* For now, to dump the cull in "new" format, just dump the nonzero
 * culls sequentially, and avoid all the difficulties associated with
 * interspersing and overlapping.  It may be less aesthetic.
 * Anyhow, to be convenient, just step defaultmcull and call
 * write_goodtimes() repeatedly.
 */
int
write_all_culls(char *fname, int orbit, int verbosity, int syncwith)
{
	char statii[1024];
	int cullmtmp;
	int gotsome, tmpflag, retflag;
	int i, j, k;

	cullmtmp = defaultmcull;
	strlcpy(statii, "Culls saved:  ", sizeof(statii));
	gotsome = 0;
	retflag = 0;
	for (k = 0; k < 8; k++) {
		tmpflag = 0;
		defaultmcull = k;
		for (i = 0; i < nallt; i++)
			for (j = 0; j < HI_AZ_BINS; j++)
				if (mculls[defaultmcull][i * HI_AZ_BINS + j]) {
					tmpflag = 1;
					j = HI_AZ_BINS;
					i = nallt;
				}
		if (tmpflag) {
			if (write_goodtimes(fname, orbit, k+1, syncwith)) {
				if (!gotsome)
					strlcat(statii, "NONE", sizeof(statii));
				gotsome = 1;
				strlcat(statii, "...and then there was an error.",
				    sizeof(statii));
				retflag = -1;
				k = 8;	/* break */
			} else {
				gotsome = strlen(statii);
				snprintf(statii + gotsome, sizeof(statii) - gotsome,
				    " %d", k+1);
				gotsome = 1;
			}
		}
	}
	if (!gotsome)
		strlcat(statii, "NONE", sizeof(statii));
	if (verbosity > 0)
		printf("%s\n", statii);
	defaultmcull = cullmtmp;
	return(retflag);
}

/* Merge 2 -> 1, keeping 2 and modifying 1.
 * How:  0 == OR, 1 == AND, 2 == XOR;
 *      -1 == (1 and not 2)
 */
void
cull_merge(int which1, int which2, int how)
{
	int i;

	if (which1 < 0 || which1 >= 8 || which2 < 0 || which2 >= 8 ||
	    how < -1 || how > 2) {
		/* Nothing can be done.  Not this function's problem. */
		return;
	}
	switch(how) {
	case 0:
		for (i = 0; i < HI_AZ_BINS * nallt; i++)
			mculls[which1][i] |= mculls[which2][i];
		break;
	case 1:
		for (i = 0; i < HI_AZ_BINS * nallt; i++)
			mculls[which1][i] &= mculls[which2][i];
		break;
	case 2:
		for (i = 0; i < HI_AZ_BINS * nallt; i++)
			mculls[which1][i] ^= mculls[which2][i];
		break;
	case -1:
		for (i = 0; i < HI_AZ_BINS * nallt; i++)
			mculls[which1][i] &= (~mculls[which2][i]);
		break;
	default:	/* NOT REACHED */
		break;
	}
}

/* Man, I knew this would have to happen.  Chop the given cull on a 96-spin
 * boundary:  i.e., force the cull to work with the half-cadence "L"
 * packets.  Of course, this makes sense only for non-despun situations.
 * In fact, nonsense may be returned if hbs[HB_QABC] and hbs[HB_LABC] do
 * not accurately represent hist_q and hist_l packet times, or if timing
 * has been resynced to despun data.
 *
 * If the packets are not fully culled, where now 'cull' means dropping
 * lousy packets (cull_partial_hbs() and further_cull_hbs()) and not good
 * times, this routine will possibly return overly harsh results.
 */
void
trim_cull_to_slow_cadence(int whichone, int verbosity)
{
	int i, ii, j, jj, jjj, k;
	int dropped, dp;
	char l, ll;

	if (whichone < 0 || whichone >= 8)
		return;
	dropped = 0;
	/* If we culled, things have to line up:  there are twice as many qABC
	 * histograms as lABC histograms.  Check anyhow and warn, then assume
	 * (in a safe manner) it's the case.  At worst we just drop a bit more
	 * than we have to.
	 */
	if ((hbs[HB_LABC].n * 2 != hbs[HB_QABC].n ||
	    hbs[HB_QAC].n != 2 * hbs[HB_LAC].n) && verbosity >= 0) {
		printf("Warning: trim_cull_to_slow_cadence() called on non-culled data!\n");
	}
	j = 0;
	k = 0;
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		while (nallt > j &&
		    alltimes[j] < hbs[HB_LABC].met[i] - HBtimeSlop)
			j++;
		if (j >= nallt) {
			warnx("impossible trim_cull_to_slow_cadence()");
			return;	/* shouldn't ever happen */
		}
		/* If all the times from alltimes[k] to alltimes[j] aren't
		 * identically culled, zero out the energies that changed.
		 */
		l = 0;
		/* somewhat of a rewrite of is_cullsame() */
		for (ii = k + 1; ii <= j; ii++) 
			for (jjj = 0; jjj < HI_AZ_BINS; jjj++)
				l |= ((mculls[whichone][k * HI_AZ_BINS + jjj]) ^
				    (mculls[whichone][ii * HI_AZ_BINS + jjj]));
		if (l) {
			for (ii = k; ii <= j; ii++) {
				dp = 0;
				for (jj = 0; jj < HI_AZ_BINS; jj++) {
					ll = mculls[whichone][ii * HI_AZ_BINS + jj];
					mculls[whichone][ii * HI_AZ_BINS + jj] &= (~l);
					if (ll != mculls[whichone][ii * HI_AZ_BINS + jj])
						dp = 1;
				}
				dropped += dp;
			}
		}
		k = j + 1;
	}
	if (verbosity > 0)
		printf("Dropped %d time(s) to make cull %d match hist_l cadence.\n",
		    dropped, whichone + 1);
}


/* Add a threshold to an existing cull, corresponding to the given
 * threshold per HI_AZ_BIN bins (the idea is, if we've already blocked off
 * part of the sky due to a foreground object, we can still apply a
 * reasonably consistent cull).
 *
 * First argument is a threshold for each ESA, on the packet type in
 * histogram bin hb.  Note that if you want to threshold on the BM, use
 * HB_BM here -- this is DIFFERENT slightly from the 'v' command in xhihb
 * because that command kind of puts a one-hb margin on the edges (not
 * centred on the data, though, really).  If you want to threshold on more
 * than one thing, call this function multiple times.
 * Note that any hb is legit -- even stuff at Lo cadence or half cadence.
 *
 * The flag parameter works as follows:
 *   flag == 0 --> we are filtering each ESA step by the data in that ESA
 * step only.
 *   flag == -1 --> it's BM data and so we want to sum over the 4 hbs kept
 * in the BM data.
 *   flag > 0 --> interpret as (1 << ESA) or'ed together as to what has to
 * go into the thresholding.
 *
 * The 'margin' is a minimum time in seconds from packet creation time
 * (which isn't the same as average data collection time, but matches
 * old-school xhihb 'v' work) for which stuff gets zeroed, and which makes
 * sense anyhow since everything's tagged the same way.  Note that data has
 * to be IN the good times to be used in the cull, so MARGINS DEPEND ON THE
 * EXTANT CULLING.  For example, after
 *      cull_by_threshold(1, HB_BM, 50000, -1, 0);
 * the call
 *      cull_by_threshold(1, HB_BM, 50000, -1, 800);
 * will do exactly nothing further, whereas if it were called on a completely
 * cleared cull, it'd behave just like xhihb's 'v 50000'.  Consequently,
 * this is NOT a plug-in replacement for 'v 50000'.  It's another tool.
 *
 * Returns zero on success.
 */
int
cull_by_threshold(int whichcull, int whichhb, long thres, int flag, int margin)
{
	int i, j, k, ke;
	int ii, jj;
	char kc;
	int t1, t2, tt1, tt2;
	int n;
	long li;
	char *tcull;

	if (whichcull < 0 || whichcull >= 8 || whichhb < 0 || whichhb >= BIN_TYPES)
		return(-1);
	if (thres < 0)
		return(0);
	if ((tcull = (char *)calloc(HI_AZ_BINS, nallt)) == NULL) {
		warn("cull_by_threshold alloc");
		return(-10);
	}
	t1 = 0;
	for (i = 0; i < hbs[whichhb].n; i++) {
		/* We have no guarantee the hbtype we asked for lines up
		 * within HBtimeSlop of alltimes.  If it doesn't, isincull()
		 * fails awkwardly.  Further, we may be at low cadence and
		 * there may therefore not be 1:1 correspondence between
		 * alltimes and hbs.
		 * Thus, figure out what times we're talking about.
		 * Note that safe_isincull() isn't all that helpful once the
		 * 'margin' option comes into play.
		 */
		if (i > 0) {
			while (t1 < nallt &&
			    alltimes[t1] - HBtimeSlop < hbs[whichhb].met[i-1])
				t1++;
		}
		/* t2 is the first element PAST the last one we want for this hb. */
		t2 = t1;
		while (t2 < nallt && alltimes[t2] - HBtimeSlop < hbs[whichhb].met[i])
			t2++;
		/* On to analyzing the histogram. */
		for (ke = 0; ke < HI_ENERGIES; ke++) {
			li = 0;
			n = 0;
			kc = (1 << ke);
			for (j = 0; j < HI_AZ_BINS; j++) {
				jj = 0;
				for (ii = t1; ii < t2; ii++)
					if (!isincull(whichcull, alltimes[ii], ke, j))
						jj++;
				if (jj == 0) {
					if (flag == 0) {
						li += (*(hbs[whichhb].data[i]))[ke][j];
						n++;
					} else if (flag == -1) {
						/* BM:  sum up 4 entries but count as one. */
						for (k = 0; k < HI_BG_SWEEPS; k++)
							li += (*(hbs[whichhb].data[i]))[k][j];
						n++;
					} else {
						for (k = 0; k < get_max_E(hbs[whichhb].flag);
						    k++) {
							if ((1 << k) & flag) {
								li += (*(hbs[whichhb].data[i]))[k][j];
								n++;
							}
						}
					}
				}
			}
			if (((double)li) / (double)n >
			    ((double)thres) / (double)HI_AZ_BINS) {
				if (margin > 0) {
					tt1 = t1 - 1;
					while (tt1 >= 0 && (int)(hbs[whichhb].met[i] -
					    alltimes[tt1]) < margin)
						tt1--;
					tt1++;
					tt2 = t2;
					while (tt2 < nallt && (int)(alltimes[tt2] -
					    hbs[whichhb].met[i]) < margin)
						tt2++;
				} else {
					tt1 = t1;
					tt2 = t2;
				}
				for (k = tt1; k < tt2; k++)
					for (j = 0; j < HI_AZ_BINS; j++)
						tcull[k * HI_AZ_BINS + j] |= kc;
			}
		}
	}
	/* We needed an intermediate cull array, tcull, so that we wouldn't
	 * take data that would cause culling out of the cull due to it being
	 * inside a previous margin.  That whole margin nonsense is why we
	 * have tcull in the first place.  Now we want simply to merge it into
	 * mculls.
	 */
	for (i = 0; i < nallt * HI_AZ_BINS; i++)
		mculls[whichcull][i] &= ~(tcull[i]);
	free(tcull);
	return(0);
}
