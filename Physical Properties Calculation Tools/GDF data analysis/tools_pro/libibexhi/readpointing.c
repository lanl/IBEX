/*	$Id: readpointing.c,v 1.16 2016/06/17 19:41:16 pjanzen Exp $	*/
/* Read in ISOC inertial_pointing file, and provide functions either to
 * return pointing/orbit for a given time or the direction in space of a
 * given angle (bin) in an orbit.
 */
static const char rcsid[] = "@(#) $Id: readpointing.c,v 1.16 2016/06/17 19:41:16 pjanzen Exp $";

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

/* Inertial pointing file format:
 * # are comment lines
 * all other lines have 8 columns:
 *  orbit number
 *    possibly a letter following, indicating arc
 *  1 if it's a hand modification, 0 if it's automatic
 * RA and Dec as planned
 * planned maneuvre time (yyyy/mm:dd:hh:mm:ss)
 * offset from this time for which the following RA and Dec are "exact"
 * actual RA and Dec.  These are set to 0 for unprocessed/future orbits.
 *
 * We keep one orbit of bogus RA and dec, because its burn time delineates
 * the last time for which our pointing information is good.  For this
 * orbit, we can return which orbit we are in (return value is negative
 * because we could be in any orbit following), but we can't return pointing
 * information.
 */

/* I don't feel like reallocing today, for something this small */
#define MAX_ORBITS (1024)
typedef struct {
	int orbit;
	int arc;
	uint32_t burntime;
	double ra;
	double dec;
} ip_struct;
static ip_struct ipoint[MAX_ORBITS];
static int  nipoint = 0;

static char orbitbuffer[7];

/* Return 0 on failure */
static uint32_t
strtomet(char *foo)
{
	int y, mo, d, h, m, s;
	struct tm baz;
	time_t t;

	if (sscanf(foo, "%d/%d:%d:%d:%d:%d", &y, &mo, &d, &h, &m, &s) != 6 ||
	    y < 2008 || y > 2038 || mo < 1 || mo > 12 || d < 1 || d > 31 ||
	    h < 0 || h > 23 || m < 0 || m > 60 || s < 0 || s > 62)
		return(0);
	baz.tm_sec = s;
	baz.tm_min = m;
	baz.tm_hour = h;
	baz.tm_mday = d;
	baz.tm_mon = mo - 1;
	baz.tm_year = y - 1900;
	t = timegm(&baz);
	if (t == -1)
		return(0);
	t -= EPOCHDIFF;
	return((uint32_t) t);
}

/* Lookup function.  For now it's just linear, and it treats arc 0 the same
 * as an arc of -1 (i.e., an orbit that didn't initialize different arcs).
 * Returns nipoint on failure, because that's easy.
 */
static int
findorbitn_(int orbit, int arc)
{
	int i;

	if (orbit < 1 || arc < -1)
		return(nipoint);
	i = 0;
	while (i < nipoint) { /* && (ipoint[i].orbit != orbit || ipoint[i].arc) */
		if (ipoint[i].orbit != orbit)
			i++;
		else if (ipoint[i].arc == arc ||
		    (arc == 0  && ipoint[i].arc == -1) ||
		    (arc == -1 && ipoint[i].arc == 0))
			break;
		else
			i++;
	}
	return(i);
}

/* Return 0 on success, negative on file open problems, positive line
 * number on parse errors.
 */
int
init_inertialpointing(char *fname)
{
	FILE *fp;
	char foo[1024], datstr[21];
	char *p, tmparc;
	int l;
	int tmporb, tmpm, tmpof;
	double junk1, junk2, tmpra, tmpdec;

	nipoint = 0;
	if ((fp = fopen(fname, "r")) == NULL)
		return(1);
	l = 1;
	while (fgets(foo, sizeof(foo), fp)) {
		p = foo;
		while (isspace(*p))
			p++;
		if (*p != '#') {
			tmparc = '-';
			if ((sscanf(foo, "%d%d%lf%lf%20s%d%lf%lf", &tmporb, &tmpm,
			    &junk1, &junk2, datstr, &tmpof, &tmpra, &tmpdec) != 8) &&
			   (sscanf(foo, "%d%c %d%lf%lf%20s%d%lf%lf", &tmporb, 
			    &tmparc, &tmpm, &junk1, &junk2, datstr, &tmpof,
			    &tmpra, &tmpdec) != 9)) {
				fclose(fp);
				return(l);
			}
			if (nipoint >= MAX_ORBITS) {
				fclose(fp);
				return(-2);
			}
			ipoint[nipoint].orbit = tmporb;
			if (tmparc != '-')
				ipoint[nipoint].arc = toupper(tmparc) - 'A';
			else
				ipoint[nipoint].arc = -1;
			ipoint[nipoint].burntime = strtomet(datstr);
			ipoint[nipoint].ra  = tmpra;
			ipoint[nipoint].dec = tmpdec;
			if (ipoint[nipoint].burntime == 0) {
				fclose(fp);
				return(l);
			}
			/* Further sanity checks:  we need consecutive orbits,
			 * or at least consecutive arcs.  We allow the pattern
			 * orbit, orbit-arc-a, orbit-arc-b, since it looks like
			 * that's what we'll get, but we treat (and store) "orbit"
			 * the same as "orbit-arc-a" and throw an error if their
			 * pointing is different.  No!  Right now it looks like it's
			 * anyone's guess what the pointing of the no-arc orbit
			 * prior to a named arc is -- between 130 and 131 it's a or
			 * b, but not quite.  Safest simply to drop the unnamed part
			 * since it really can't apply to anything once there are
			 * arcs.
			 *
			 * Also, allow gaps, since (at least for some period)
			 * inertial_pointing is lacking orbit 0129 information.
			 * It doesn't affect the search, the way things are set up.
			 */
			if (nipoint > 0 &&
			    (ipoint[nipoint].orbit-ipoint[nipoint-1].orbit) != 1) {
				if ((ipoint[nipoint].orbit-ipoint[nipoint-1].orbit) == 0
				    && ipoint[nipoint-1].arc == -1
				    && ipoint[nipoint].arc == 0) {
					/* we have an orbit, followed by the first orbit arc */
#if 0
					if (ipoint[nipoint-1].ra != ipoint[nipoint].ra ||
					    ipoint[nipoint-1].dec != ipoint[nipoint].dec) {
						fclose(fp);
						return(l);
					}
#endif
					/* delete the (duplicate) point and rename prior arc */
					ipoint[nipoint-1].arc = 0;
					ipoint[nipoint-1].ra = ipoint[nipoint].ra;
					ipoint[nipoint-1].dec = ipoint[nipoint].dec;
					ipoint[nipoint-1].burntime = ipoint[nipoint].burntime;
					nipoint--;
				} else if (ipoint[nipoint].orbit == ipoint[nipoint-1].orbit
				    && ipoint[nipoint-1].arc < 0 &&
				    ipoint[nipoint].arc == 1) {
					/* Dropped an arc a but had an "overall orbit" entry;
					 * fill it in.  Needed for ISOC orbit 155.
					 */
					ipoint[nipoint-1].arc = 0;
				} else if ((ipoint[nipoint].orbit-ipoint[nipoint-1].orbit)
				    != 0 || ipoint[nipoint-1].arc < 0 ||
				    ipoint[nipoint].arc < 0 ||
				    ipoint[nipoint].arc - ipoint[nipoint-1].arc != 1) {
					/* Allow skipped orbits */
					if ((ipoint[nipoint].orbit-ipoint[nipoint-1].orbit)
					    < 1) {
						fclose(fp);
						return(l);
					}
				}
			}
			nipoint++;
			/* Keep orbits which don't have real pointing info. */
		}
		l++;
	}
	fclose(fp);
	return(0);
}

char *
str_orbit_at_met(uint32_t met, int witharc)
{
	int i, j;

	if ((j = get_orbit_at_met(met, &i)) == -1)
		strlcpy(orbitbuffer, "???", sizeof(orbitbuffer));
	else if (witharc && i >= 0 && i < 256 - 'a')
		snprintf(orbitbuffer, sizeof(orbitbuffer), "%04d%c", abs(j), 'a' + i);
	else
		snprintf(orbitbuffer, sizeof(orbitbuffer), "%04d", abs(j));
	/* Possibly irritating, but we need to worry if there's no following
	 * burn time.
	 */
	if (j < 0)
		strlcat(orbitbuffer, "?", sizeof(orbitbuffer));
	return(orbitbuffer);
}

/* -1 on no match.  The idea is that an orbit goes between its planned burn
 * time and the burn time following.  If there is no burn time following,
 * well, return the negative of the last orbit, I guess.  It might still be
 * useful for the "current" orbit.
 */
int
get_orbit_at_met(uint32_t met, int *arc)
{
	int i;

	if (nipoint == 0)
		return(-1);
	i = 0;
	/* Few enough elements to just do a linear search */
	while (i < nipoint && ipoint[i].burntime <= met)
		i++;
	if (i == 0)
		return(-1);
	if (i == nipoint) {
		if (arc)
			*arc = ipoint[nipoint-1].arc;
		return(-ipoint[nipoint-1].orbit);
	}
	if (arc)
		*arc = ipoint[i-1].arc;
	return(ipoint[i-1].orbit);
}

int
get_ibex_dir(int orbit, int arc, double *ra, double *dec)
{
	int i;

	if (nipoint == 0)
		return(-1);
	i = findorbitn_(orbit, arc);
	if (i == nipoint)
		return(-2);
	if (fabs(ipoint[i].ra) < 1e-10 && fabs(ipoint[i].dec) < 1e-10)
		return(-3);
	*ra = ipoint[i].ra;
	*dec  = ipoint[i].dec;
	return(0);
}

/* Might be useful.  Just return the burn time (i.e. start) of a given
 * orbit.  Returns 0 on success.
 */
int
get_burn_MET_of_orbit(int orbit, int arc, uint32_t *met)
{
	int i;

	if (nipoint == 0)
		return(-1);
	i = findorbitn_(orbit, arc);
	if (i == nipoint)
		return(-2);
	*met = ipoint[i].burntime;
	return(0);
}

/* Might be useful.  Just return the burn time after (i.e. end) of a given
 * orbit.  Returns 0 on success.
 */
int
get_burn_MET_after_orbit(int orbit, int arc, uint32_t *met)
{
	int i;

	if (nipoint == 0)
		return(-1);
	i = findorbitn_(orbit, arc);
	i++;
	if (i >= nipoint)
		return(-2);
	*met = ipoint[i].burntime;
	return(0);
}

/* Might want to find out how many useful arcs exist, should I need to
 * handle arcs independently
 */
int
get_arcs_per_orbit(int orbit)
{
	int arc;

	arc = 0;
	if (nipoint == 0 || findorbitn_(orbit, arc) >= nipoint)
		return(0);
	arc++;
	while (findorbitn_(orbit, arc) < nipoint)
		arc++;
	return(arc);
}

/* Return 0 on success.  We're not after IBEX's spin direction here but
 * rather the look direction of IBEX-Hi for a given angle (0-360).  Angle
 * bin 0 is at 0 degrees -- i.e., from -3 to 3 degrees, where 0 is the
 * angle closest in the spin to NEP.
 */
int
get_la_lng_from_orb_ang(int orbit, int arc, double angle,
    double *la, double *lng)
{
	int i;
	double tlong, tlat;
	double tmp[3], tmp2[3];

	i = get_ibex_dir(orbit, arc, &tlong, &tlat);
	if (i != 0)
		return(i);
	/* Everything runs in ecliptic J2000 except this file.  Go to lat/long. */
	equat_to_eclip(&tlong, &tlat);
	/* Get local z to rotate from. */
	rd2vec(tmp, tlong, tlat);	/* it's normalized */
	tmp2[0] = tmp2[1] = 0.; tmp2[2] = 1.;
	for (i = 0; i < 3; i++)
		tmp2[i] -= tmp[i] * tmp[2];

	rotaroundaxis(tmp2, angle, tmp);
	vec2latlong(tmp2, la, lng);
	return(0);
}

/* Convenience - look for the default inertial pointing file and errx out
 * if it doesn't read.  Can pass an error message template; must pass an
 * nonzero error number with which to exit.  If errret is zero, warn rather
 * than err, in which case return values do matter; similarly, if errret is
 * less than zero, just return status, don't print anything.  Return zero on
 * success.
 */
int
simple_init_inertialpointing(char *errmsg, int errret)
{
	char *p, frob[2048];
	int i;

	i = -1;
	p = getenv("IBEX_MISCDIR");
	if (p) {
		i = strlcpy(frob, p, sizeof(frob));
		if (i > 0 && frob[strlen(frob) - 1] != '/')
			strlcat(frob, "/", sizeof(frob));
		strlcat(frob, "inertial_pointing", sizeof(frob));
		if ((i = init_inertialpointing(frob))) {
			if (errmsg) {
				if (errret > 0)
					errx(errret, "%s (%d)", errmsg, i);
				else if (errret == 0)
					warnx("%s (%d)", errmsg, i);
			} else {
				if (errret > 0)
					errx(errret, "couldn't find inertial_pointing (%d)", i);
				else if (errret == 0)
					warnx("couldn't find inertial_pointing (%d)", i);
			}
		}
	} else {
		if (errret > 0) {
			if (errmsg)
				errx(errret, "%s: $IBEX_MISCDIR not set", errmsg);
			else
				errx(errret, "$IBEX_MISCDIR not set");
		} else if (errret == 0) {
			if (errmsg)
				warnx("%s: $IBEX_MISCDIR not set", errmsg?errmsg:"");
			else
				warnx("$IBEX_MISCDIR not set");
		}
	}
	return(i);
}

int
is_pointing_inited()
{
	return(nipoint > 0);
}

#ifdef TESTING
int
main(int argc, char **argv)
{
	char foo[1024];
	int i, k, l;
	uint32_t j;
	double d, r1, r2;

	printf("Supply pointing file:  ");
	fgets(foo, sizeof(foo), stdin);
	foo[strcspn(foo, "\n")] = '\0';
	i = init_inertialpointing(foo);
	printf("init returned %d\n", i);
	i = 0;
	while (i == 0) {
		printf("Give a MET, zero to move on:  ");
		k = scanf("%u", &j);
		i = get_orbit_at_met(j, &k);
		printf("Orbit returned %d (arc %d).\n", i, k);
		if (j && k == 2)
			i = 0;
		else
			i = 1;
	}
	l = 2;
	while (i != 0 && l == 2) {
		printf("Give orbit (arc 0) and angle, zero orbit to quit:  ");
		l = scanf("%d%lf", &i, &d);
		k = get_la_lng_from_orb_ang(i, 0, d, &r1, &r2);
		printf("returned %d with angles %lf %lf\n", k, r1, r2);
		k = get_burn_MET_of_orbit(i, 0, &j);
		if (k == 0)
			printf("Orbit %d start was %u\n", i, j);
	}
	exit(0);
}
#endif
