/*	$Id: readsweep.c,v 1.7 2018/01/10 03:45:00 pjanzen Exp $	*/
/* Read in the sweep table file and provide useful interfaces based on it.
 * 1,2,3,4,5,6 refer to sweep table entries as per table 1 of the IBEX-Hi
 * cal memo (Phase 3).  0 refers to any setting that's a background test.
 * Further numbers may become defined later.
 *
 * Originally, we always swept 1,2,3,4,5,6; eventually we dropped ESA 1 in
 * favour of doubling ESA 3.  Even without this, background tests kind of
 * mess this up.
 *
 * Map-making and Compton-Getting care about sweep table; so does the
 * penetrating background calculation, for the signal-based correction.
 *
 * Note that with a sweep table, penetrating background calculations are no
 * longer immutable -- they depend on actual data AND a secondary file.
 * further that backgrounds may not be calculated identically across
 * different sweep tables, although that's really the goal (since some
 * orbits one ESA may have no good times, and some other orbit it may have
 * more than other ESAs).
 */
static const char rcsid[] = "@(#) $Id: readsweep.c,v 1.7 2018/01/10 03:45:00 pjanzen Exp $";

#include <sys/types.h>
#include <ctype.h>
#include <err.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "ibexhi.h"

/* Sweep table file format:
 * # are comment lines
 * all other lines have 8 columns of integer:
 * start MET
 * end MET
 * sweep table entry 1 - 6.
 *
 * Entries are 0 (background test of some sort), 1,2,3,4,5,6 related to
 * nominal step.
 * Entries need to be chronological and not to overlap (it's checked).
 */

/* Reallocing is such work */
#define MAX_SWEEPS (256)
typedef struct {
	uint32_t startmet, endmet;
	int sweep[6];
} sweep_struct;
static sweep_struct weeps[MAX_SWEEPS];
static int nweep = 0;

int
init_sweeptable(char *fname)
{
	FILE *fp;
	char foo[1024], *p;
	int i, l;
	int s[6];
	unsigned long int m1, m2;

	nweep = 0;
	if ((fp = fopen(fname, "r")) == NULL)
		return(1);
	l = 1;
	while (fgets(foo, sizeof(foo), fp)) {
		p = foo;
		while (isspace(*p))
			p++;
		if (*p != '#' && *p) {
			/* I wanted 0xffffffff to represent the end of time, but the
			 * ISOC likes making MET decimal, which does create silly
			 * 1-second gaps of undefined status, and they want
			 * 1500000000.0 to be the end of time.  Avoid long long
			 * for now...
			 */
			if (sscanf(foo, "%ld.0%ld.0 Hi %d%d%d%d%d%d", &m1, &m2, s, s+1,
			    s+2, s+3, s+4, s+5) != 8 ||
			    m2 < m1 ||
			    (nweep > 0 && (unsigned long)(weeps[nweep-1].endmet) >= m1)) {
				fclose(fp);
				return(l);
			}
			for (i = 0; i < 6; i++)
				if (s[i] < 0 || s[i] > 6) {
					fclose(fp);
					return(l);
				}
			if (nweep >= MAX_SWEEPS) {
				fclose(fp);
				return(-2);
			}
			weeps[nweep].startmet = m1;
			weeps[nweep].endmet = m2;
			for (i = 0; i < 6; i++)
				weeps[nweep].sweep[i] = s[i];
			nweep++;
		}
		l++;
	}
	fclose(fp);
	return(0);
}

/* convenience */
void
nice_sweeptable()
{
	char *p;
	int i;

	p = getenv("IBEX_HISWEEPTABLE");
	if (!p)
		i = init_sweeptable("./HiSweepTable");
	else
		i = init_sweeptable(p);
	if (i)
		errx(1, "init_sweeptable error %d", i);
}

/* short list - search linearly */
int
get_sweeptable(uint32_t met, int sweep[6])
{
	int i, j;

	j = -1;
	for (i = 0; i < nweep; i++)
		if (met >= weeps[i].startmet && met <= weeps[i].endmet) {
			j = i;
			i = nweep;
		}
	if (j < 0)
		return(-1);
	for (i = 0; i < 6; i++)
		sweep[i] = weeps[j].sweep[i];
	return(0);
}


/* For a given ESA at a given time, figure the ratio of signal-generated
 * unqualifieds to qualifieds.
 *
 * Values have been revised and made time-dependent as per 2015 bgstudy
 * work, and following work at the start of 2018.  Not only does this
 * depend on time but because of map 11 it also depends on CEM voltage.
 *
 * For now, these values apply ONLY to 1700V, or 1780V after map 10.
 * There's no way to get 1700V in map 11.  XXX
 */
int
get_sweep_unq_ratio(uint32_t met, int esa, double *retmin, double *retbest,
    double *retmax)
{
	int s[6], i;

	if (esa < 1 || esa > 6)
		return(-1);
	if (met < 912296003)
		return(-1);
	i = get_sweeptable(met, s);
	if (i != 0)
		return(i);
	/* Default to 1700V before start of map 12.
	 * Default to 1780V in map 11.
	 */
#if 0
	if (met < 1087800000) {
#else  /* Map 11 at 1780V */
	if (met <	1072170000) {
#endif
		switch(s[esa-1]) {
		case 1:
			*retbest= 0.0056;
			*retmin = 0.0043;
			*retmax = 0.0083;
			break;
		case 2:
			*retbest= 0.0056 - 0.0008 * (met - 986904142.)/31557600.;
			*retmin = 0.0044;
			*retmax = 0.0079;
			break;
		case 3:
			*retbest= 0.0095 - 0.00094 * (met - 986904142.)/31557600.;
			*retmin = 0.0077 - 0.00078 * (met - 986904142.)/31557600.;
			*retmax = 0.0124 - 0.00146 * (met - 986904142.)/31557600.;
			break;
		case 4:
			*retbest= 0.0167 - 0.00081 * (met - 986904142.)/31557600.;
			*retmin = 0.0142 - 0.00079 * (met - 986904142.)/31557600.;
			*retmax = 0.0201 - 0.0011 * (met - 986904142.)/31557600.;
			break;
		case 5:
			*retbest= 0.02782 - 0.00121 * (met - 986904142.)/31557600.;
			*retmin = 0.0254 - 0.00124 * (met - 986904142.)/31557600.;
			*retmax = 0.0309 - 0.00146 * (met - 986904142.)/31557600.;
			break;
		case 6:
			*retbest= 0.04028 - 0.00310 * (met - 986904142.)/31557600.;
			*retmin = 0.0367 - 0.0029 * (met - 986904142.)/31557600.;
			*retmax = 0.0444 - 0.00376 * (met - 986904142.)/31557600.;
			break;
		case 0:
			/* Background tests cover a number of possible voltages, so they
			 * can't necessarily always be trusted to represent just clean
			 * background.  But in theory there are no signal counts to deal
			 * with, period, and the rate you see of background is the rate
			 * you want.  XXX
			 */
			*retbest= 0.0;
			*retmin = 0.0;
			*retmax = 0.0;
			break;
		default:
			/* Should never happen - what to do?  Kill the program, I guess */
			errx(1, "readsweep:get_sweep_unq_ratio() missed case");
			break;
		}
	} else {
		/* For now, 1780V is taken as a constant, until we have more
		 * orbits to fit on.
		 * XXX Also, we use the 1700V ESA 1 values, since ESA 1 returned
		 * rather late. XXX TO FIX
		 */
		switch(s[esa-1]) {
		case 1:
			/* warnx("spurious ESA 1 in get_sweep_unq_ratio()"); */
			*retbest= 0.0065;
			*retmin = 0.0054;
			*retmax = 0.0085;
			break;
		case 2:
			*retbest= 0.0063 + 0.00146 * (met - 1142030976.)/31557600.;
			*retmin = 0.0054;
			*retmax = 0.00724;
			break;
		case 3:
			*retbest= 0.00972 + 0.00175 * (met - 1142030976.)/31557600.;
			*retmin = 0.0074 + 0.00089 * (met - 1142030976.)/31557600.;
			*retmax = 0.0116;
			break;
		case 4:
			*retbest= 0.01632 + 0.00133 * (met - 1142030976.)/31557600.;
			*retmin = 0.0134  + 0.0006 * (met - 1142030976.)/31557600.;
			*retmax = 0.0178;
			break;
		case 5:
			*retbest= 0.0299 + 0.00225 * (met - 1142030976.)/31557600.;
			*retmin = 0.0256 + 0.00163 * (met - 1142030976.)/31557600.;
			*retmax = 0.0327 + 0.00103 * (met - 1142030976.)/31557600.;
			break;
		case 6:
			*retbest= 0.0498 + 0.00269 * (met - 1142030976.)/31557600.;
			*retmin = 0.0436 + 0.00175 * (met - 1142030976.)/31557600.;
			*retmax = 0.0542 + 0.00247 * (met - 1142030976.)/31557600.;
			break;
		case 0:
			/* Background tests cover a number of possible voltages, so they
			 * can't necessarily always be trusted to represent just clean
			 * background.  But in theory there are no signal counts to deal
			 * with, period, and the rate you see of background is the rate
			 * you want.  XXX
			 */
			*retbest= 0.0;
			*retmin = 0.0;
			*retmax = 0.0;
			break;
		default:
			/* Should never happen - what to do?  Kill the program, I guess */
			errx(1, "readsweep:get_sweep_unq_ratio() missed case");
			break;
		}
	}
	return(0);
}

/* Convenience to check if the sweep table is consistent over a given time
 * interval, for the ESA entries in a bitmap (1 << x, x = 0 .. 5)
 * Returns nonzero if it is the same, zero if it isn't, or if there is a
 * failure (e.g., some time interval has no entry).
 * Needs met1 <= met2.
 */
int
is_sweep_same(uint32_t met1, uint32_t met2, char esabitmap)
{
	int i, j, k, l;

	j = k = -1;
	for (i = 0; i < nweep; i++)
		if (met1 >= weeps[i].startmet && met1 <= weeps[i].endmet) {
			j = i;
			i = nweep;
		}
	if (j < 0)
		return(0);
	for (i = j; i < nweep; i++)
		if (met2 >= weeps[i].startmet && met2 <= weeps[i].endmet) {
			k = i;
			i = nweep;
		}
	if (k < 0)
		return(0);
	for (i = j + 1; i <= k; i++) {
		for (l = 0; l < HI_ENERGIES; l++)
			if ((esabitmap & (1 << l)) &&
			    (weeps[i].sweep[l] != weeps[j].sweep[l]))
				return(0);
	}
	return(1);
}

/* Argh!  If we have a period with multiple sweep tables, which is the case
 * for every arc with a background test that gets commanded from the
 * ground, try to pick the best single table entry to use for the interval.
 * Return a time for which this sweep table is valid.
 * esa ranges from 0 ... 5.
 * Return 0 if there was a problem.
 */
uint32_t
MET_for_most_appropriate_sweep_table(uint32_t met1, uint32_t met2,
    int esa)
{
	uint32_t i;
	int j;
	int s[HI_ENERGIES];
	/* 7 possible settings at present (bg test) */
	uint32_t ts[HI_ENERGIES + 1];
	long tots[HI_ENERGIES + 1], tmax;

	if (met1 > met2 || esa < 0 || esa >= HI_ENERGIES)
		return(0);
	for (i = 0; i < HI_ENERGIES + 1; i++) {
		ts[i] = 0;
		tots[i] = 0;
	}
	for (i = met1; i <= met2; i += APPROX_HBTIME) {
		if (get_sweeptable(i, s) != 0)
			return(0);
		j = s[esa];
		if (j >= 0 && j <= HI_ENERGIES) {
			tots[j]++;
			if (ts[j] == 0)
				ts[j] = i;
		} else
			return(0);
	}
	/* get max */
	j = 0;
	tmax = tots[0];
	for (i = 1; i < HI_ENERGIES + 1; i++)
		if (tots[i] > tmax) {
			tmax = tots[i];
			j = i;
		}
	return(ts[j]);
}

static char _esastringer[50];

/* Range is 0 to 5 for ESA */
char *
ESAstr_at_met(uint32_t met1, int esa)
{
	int s[6], i;

	strlcpy(_esastringer, "> BOGUS <", sizeof(_esastringer));
	if (esa >= 0 && esa < HI_ENERGIES && get_sweeptable(met1, s) == 0) {
		i = s[esa];
		if (i == 0)
			strlcpy(_esastringer, "BG test", sizeof(_esastringer));
		else
			snprintf(_esastringer, sizeof(_esastringer), "ESA setting %d", i);
	}
	return(_esastringer);
}
