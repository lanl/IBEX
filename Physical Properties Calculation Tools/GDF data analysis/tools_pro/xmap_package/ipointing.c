/*	$Id: ipointing.c,v 1.3 2022/09/29 03:04:58 pjanzen Exp $	*/
/* This is a subset of libibexhi/readpointing, so that we don't have to
 * link the whole library.
 *
 * Read in ISOC inertial_pointing file, and be ready to print out which
 * orbits might be within <x> angle of a given ECLIPJ2000 direction (ram or
 * wake).
 */
static const char rcsid[] = "@(#) $Id: ipointing.c,v 1.3 2022/09/29 03:04:58 pjanzen Exp $";

#include <sys/types.h>
#include <ctype.h>
#include <err.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "xmap.h"

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
#define MAX_ORBITS (2048)
typedef struct {
	int orbit;
	int arc;
	uint32_t burntime;
	/* This is different from libibexhi.  I'm going to be dotting a
	 * lot of vectors in ECLIPJ2000, so rather than storing RA and dec,
	 * store an ECLIPJ2000 unit vector.
	 */
	double spinax[3];
} ip_struct;
static ip_struct ipoint[MAX_ORBITS];
static int  nipoint = 0;

#define EPOCHDIFF (315964819)

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
			equat_to_eclip(&tmpra, &tmpdec);
			rd2vec(ipoint[nipoint].spinax, tmpra, tmpdec);
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
					/* delete the (duplicate) point and rename prior arc */
					ipoint[nipoint-1].arc = 0;
					ipoint[nipoint-1].spinax[0]= ipoint[nipoint].spinax[0];
					ipoint[nipoint-1].spinax[1]= ipoint[nipoint].spinax[1];
					ipoint[nipoint-1].spinax[2]= ipoint[nipoint].spinax[2];
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


/* ram:  0:  print ram and wake;  1: print ram only; -1: print wake only.
 * Note that this will do basically all the orbits if you click near the
 * poles.
 */
void
print_nearby_arcs(double lat, double lng, int firstorb, int lastorb,
    double maxdegofs, int ram)
{
	int i;
	double x[3], zz[3], tmp, tmp2;

	tmp = cos(d2r(90. - maxdegofs));
	rd2vec(x, lng, lat);
	/* For ram test, look at (z-axis cross lookdir) dot spinax.
	 * It's positive for ram and negative for wake.
	 */
	zz[0] = -x[1];
	zz[1] = x[0];
	zz[2] = 0.;
	if (firstorb < 0 || lastorb < 0) {
		firstorb = 0;
		lastorb = 2 * nipoint;
	}
	for (i = 0; i < nipoint; i++)
		if (ipoint[i].orbit >= firstorb && ipoint[i].orbit <= lastorb) {
			tmp2 = dotp(ipoint[i].spinax, x);
			if (fabs(tmp2) <= tmp &&
			    (ram == 0 || dotp(ipoint[i].spinax, zz) * ram > 0))
				printf(" %04d%c [%.1lf](%s)", ipoint[i].orbit,
				    (ipoint[i].arc >= 0) ? 'a'+ipoint[i].arc : ' ',
				    r2d(acos(tmp2)) - 90.,
				    dotp(ipoint[i].spinax, zz) > 0 ? " ram" : "wake");
		}
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

/* basically pasting from libibexhi/readpointing.c */
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

