/*	$Id: abrate.c,v 1.1 2021/01/09 05:02:36 pjanzen Exp $	*/
/* Quick convertor from lat/long to pixel number for Abrate tiling -
 * Abrate & Pollastri, IJAM 42,3,01 (2012)
 */
static const char rcsid[] = "@(#) $Id: abrate.c,v 1.1 2021/01/09 05:02:36 pjanzen Exp $";

#include <math.h>
#include <stdio.h>
#include "xmap.h"

static int a_n, a_m;
static int a_wanted = 0;
static double a_atile, a_apol, a_err;

/* Set up an Abrate map.  You say how many pixels you want and it tells you
 * how many you get.
 */
void
abrate_init(int nw)
{
	double atarg0;

	if (nw <= 0) {
		a_n = a_m = 0;
		return;
	}
	a_wanted = nw;
	atarg0 = 4. * M_PI / nw;
	a_n = round(M_PI / sqrt(atarg0));
	a_m = round(4. * M_PI * sin(sqrt(atarg0))/atarg0/sqrt(atarg0));
	a_atile = 4. * a_n * sin(M_PI/a_n)/a_m;
	a_apol = 2. * M_PI * (sqrt(atarg0) - sin(sqrt(atarg0)))/sqrt(atarg0);
	a_err = (a_atile * a_m + 2. * a_apol)/(4. * M_PI) - 1.;
#if 0
	printf(">>> a_n %d a_m %d\n>>> a_atile %.5lf a_apol %.5lf\n>>> a_err %.5lf\n",
	    a_n, a_m, a_atile, a_apol, a_err);
#endif
}

int
n_abrate(int n)
{
	if (n > 0 && n != a_wanted) {
		abrate_init(n);
	} else if (n <= 0) {
		a_n = a_m = 0;
		return(0);
	}
	return(a_m + 2);	/* need to add two polar pixels */
}

/* Angles are in radians.  lat is already actually polar angle (not lat). */
int
abrate_ndx(double lat, double lng, int n)
{
	int k, i;
	double t, tt;

	if (n > 0 && n != a_wanted) {
		abrate_init(n);
	} else if (n <= 0) {
		a_n = a_m = 0;
		return(0);
	}
	k = (a_n * M_PI - lng - 2. * a_n * lat) / (2. * M_PI);
	t = lng / (2. * a_n) + M_PI/a_n * k - M_PI/2.;
	tt = cos(M_PI/(2. * a_n));
	i = a_m * (tt - cos(t + (a_n + 1.)*M_PI/2./a_n)) / (2. * tt);
	/* don't offset by 1 */
	return(i);
}
