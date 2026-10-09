/*	$Id: vectors.c,v 1.14 2020/01/02 05:45:03 pjanzen Exp $	*/
/* General math functions.  Maybe should have a library for these.  You see
 * them in findthemoon.c and elsewhere.  But they're so simple.
 */

static const char rcsid[] = "@(#) $Id: vectors.c,v 1.14 2020/01/02 05:45:03 pjanzen Exp $";

#include <err.h>
#include <math.h>

double
d2r(double x)
{
	return(x * M_PI / 180.);
}

double
r2d(double x)
{
	return(x * 180. / M_PI);
}

double
dotp(double a[3], double b[3])
{
	return(a[0]*b[0] + a[1] * b[1] + a[2] * b[2]);
}

/* a = b x c */
void
crosv(double a[3], double b[3], double c[3])
{
	a[0] = b[1] * c[2] - c[1] * b[2];
	a[1] = b[2] * c[0] - c[2] * b[0];
	a[2] = b[0] * c[1] - c[0] * b[1];
}

/* (a x b) . c */
double
acrosv(double a[3], double b[3], double c[3])
{
	return((a[1] * b[2] - b[1] * a[2]) * c[0] +
	    (a[2] * b[0] - b[2] * a[0]) * c[1] +
	    (a[0] * b[1] - b[0] * a[1]) * c[2]);
}

void
subv(double a[3], double b[3])
{
	a[0] -= b[0];
	a[1] -= b[1];
	a[2] -= b[2];
}

void
scalm(double f, double a[3])
{
	int i;
	for (i = 0; i < 3; i++)
		a[i] *= f;
}

void
renorm(double x[3])
{
	double tmp;
	tmp = dotp(x, x);
	if (tmp > 0.)
		scalm(1./sqrt(tmp), x);
}

/* There's no obvious reason why I should call it RA & Dec --> unit vector
 * and then unit vector --> lat and long, except that the first use of
 * these was to convert a J2000 RA & Dec to a unit vector, and a unit
 * vector to an ECLIPJ2000 direction.  The functions are in fact inverses.
 */
void
rd2vec(double x[3], double ra, double dec)
{
	x[0] = cos(d2r(dec)) * cos(d2r(ra));
	x[1] = cos(d2r(dec)) * sin(d2r(ra));
	x[2] = sin(d2r(dec));
}

void
vec2latlong(double x[3], double *lat, double *lng)
{
	double t[3];

	t[0] = x[0];  t[1] = x[1];  t[2] = x[2];
	renorm(t);
	if (fabs(t[2]) < 1e-10)
		*lat = 0.;
	else
		*lat = r2d(asin(t[2]));
	*lng = r2d(atan2(x[1], x[0]));
	/* map 0 - 360 from -180 to 180 */
	while (*lng < 0.)
		*lng += 360.;
}

/* Everything's in ECLIPJ2000 except the inertial pointing numbers for the
 * spin axis, which are in J2000.  This converts them so everything else
 * actually works right.  Methodology is that suggested by wikipedia.
 */
#define AXTILT (23.4392911)
void
equat_to_eclip(double *lng, double *lat)
{
	double eq1, eq2, eq3;

	eq1 = cos(d2r(AXTILT)) * sin(d2r(*lat)) -
	    sin(d2r(*lng)) * cos(d2r(*lat)) * sin(d2r(AXTILT));
	eq2 = cos(d2r(*lng)) * cos(d2r(*lat));
	eq3 = sin(d2r(AXTILT)) * sin(d2r(*lat)) +
	    sin(d2r(*lng)) * cos(d2r(*lat)) * cos(d2r(AXTILT));
	*lng = r2d(atan2(eq3, eq2));
	/* [-180, 180] to [0, 360] */
	if (*lng < 0.)
		*lng += 360.;
	/* This is automatically in [-90,90] because second term >= 0 */
	*lat = r2d(atan2(eq1, sqrt(eq3*eq3 + eq2*eq2)));
}
void
eclip_to_equat(double *lng, double *lat)
{
	double eq1, eq2, eq3;

	eq1 = sin(d2r(AXTILT)) * sin(d2r(*lng)) * cos(d2r(*lat)) +
	    cos(d2r(AXTILT)) * sin(d2r(*lat));
	eq2 = cos(d2r(*lng)) * cos(d2r(*lat));
	eq3 = cos(d2r(AXTILT)) * sin(d2r(*lng)) * cos(d2r(*lat)) -
	    sin(d2r(AXTILT)) * sin(d2r(*lat));
	/* RA */
	*lng = r2d(atan2(eq3, eq2));
	/* [-180, 180] to [0, 360] */
	if (*lng < 0.)
		*lng += 360.;
	/* dec */
	/* This is automatically in [-90,90] because second term >= 0 */
	*lat = r2d(atan2(eq1, sqrt(eq3*eq3 + eq2*eq2)));
}

/* getspinbin() comes straight from findthemoon.c */
/* x is ibex, y is vector to moon.  We want for that part of y that's
 * in the plane perpendicular to x, the angle it makes wrt local z.
 * x is normalized....
 *
 * Since z is ECLIPTIC J2000, getspinbin() works only if everything passed
 * in is in ECLIPJ2000.  Hence the internal bit and a kludge to get things
 * to work in J2000.
 */
static double
getspinbin_internal(double x[3], double y[3], double zax[3])
{
	double t[3], t2[3], t3[3];
	double s1, s2;

	t[0] = x[0];  t[1] = x[1];  t[2] = x[2];
	t2[0] = y[0]; t2[1] = y[1]; t2[2] = y[2];
	renorm(t);
	s1 = dotp(y, t);
	scalm(s1, t);
	subv(t2, t);
	renorm(t2);
	t[0] = x[0];  t[1] = x[1];  t[2] = x[2];
	t3[0] = zax[0]; t3[1] = zax[1]; t3[2] = zax[2];
	renorm(t);
	s1 = dotp(zax, t);
	scalm(s1, t);
	subv(t3, t);
	renorm(t3);
	t[0] = x[0];  t[1] = x[1];  t[2] = x[2];
	renorm(t);

	/* should be exactly zero; they're perpendicular */
	if (fabs(dotp(x, t2)) > 1e-8 || fabs(dotp(x, t3)) > 1e-8)
		warnx("XXX %lf %lf", dotp(x, t2), dotp(x, t3));

	s2 = r2d(atan2(acrosv(t3, t2, t), dotp(t3, t2)));
	if (s2 < 0.)
		s2 += 360.;
	if (s2 > 360.)
		s2 -= 360.;
	/* convert to bins; bin 0 is indeed centred on 0 degrees, so there's
	 * no need to play around with offsetting. */
	s2 /= 6.0;
	return(s2);
}

double
getspinbin(double x[3], double y[3])
{
	double zax[3];

	zax[0] = zax[1] = 0.; zax[2] = 1.;
	return(getspinbin_internal(x, y, zax));
}

double
getspinbinj2000(double x[3], double y[3])
{
	double zax[3];
	double ra, dec;

	/* At least we can hardwire what ECLIPJ2000 z axis is in J2000. */
	ra = 270.;
	dec = 90. - AXTILT;
	rd2vec(zax, ra, dec);
#ifdef DEBUG
	equat_to_eclip(&ra, &dec);
	printf("getspinbinj2000 thinks the z axis has RA & dec %lf & %lf\n",
	    ra, dec);
#endif
	return(getspinbin_internal(x, y, zax));
}


/* Rotate x around y by theta (in degrees).  Rotated x is returned in x.
 * Theta is positive counterclockwise as is usual in math.
 */
void
rotaroundaxis(double x[3], double theta, double y[3])
{
	double t[3], t2[3];
	double s1, s2;

	t[0] = x[0];  t[1] = x[1];  t[2] = x[2];
	t2[0] = y[0]; t2[1] = y[1]; t2[2] = y[2];
	renorm(t2);
	s1 = cos(d2r(theta));
	s2 = sin(d2r(theta));
	x[0] = (s1 + (1.-s1) * t2[0] * t2[0]) * t[0] +
	    ((1.-s1) * t2[0] * t2[1] - s2 * t2[2]) * t[1] +
	    ((1.-s1) * t2[0] * t2[2] + s2 * t2[1]) * t[2];
	x[1] = (s1 + (1.-s1) * t2[1] * t2[1]) * t[1] +
	    ((1.-s1) * t2[0] * t2[1] + s2 * t2[2]) * t[0] +
	    ((1.-s1) * t2[1] * t2[2] - s2 * t2[0]) * t[2];
	x[2] = (s1 + (1.-s1) * t2[2] * t2[2]) * t[2] +
	    ((1.-s1) * t2[0] * t2[2] - s2 * t2[1]) * t[0] +
	    ((1.-s1) * t2[1] * t2[2] + s2 * t2[0]) * t[1];
}

#ifdef TESTING
#include <stdio.h>

int
main(int argc, char **argv)
{
	double l1, l2;

	/* New "nose direction", J2000 */
	l1 = 258.47;
	l2 = -18.;
	equat_to_eclip(&l1, &l2);
	printf("%lf\t%lf\n", l1, l2);
	/* Original "nose direction", J2000 */
	l1 = 254.73;
	l2 = -17.57;
	equat_to_eclip(&l1, &l2);
	printf("Old %lf\t%lf\n", l1, l2);
	return(0);
}
#endif
