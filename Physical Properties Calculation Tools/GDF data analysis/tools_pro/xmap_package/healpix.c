/*	$Id: healpix.c,v 1.1 2018/03/12 08:56:58 pjanzen Exp $	*/
/* Quick convertor from lat/long to pixel number, doing the consecutive
 * (not nested) counting method.
 */
static const char rcsid[] = "@(#) $Id: healpix.c,v 1.1 2018/03/12 08:56:58 pjanzen Exp $";

#include <math.h>

/* n is "nside"; there are 12 * n * n array elements.
 * lat and lng are in radians.
 */
int
healpix_ndx(double lat, double lng, int n)
{
	double z, nlng;
	double tmp1, tmp2;
	int j1, j2;
	int ring, j, ndx;

	z = cos(M_PI_2 - lat);
	while (lng < 0.)
		lng += 2 * M_PI;
	nlng = fmod(lng, 2 * M_PI) * M_2_PI;
	if (fabs(z) < 2./3.) { /* equatorial */
		tmp1 = n * (nlng + 0.5);
		tmp2 = n * z * 0.75;
		j1 = tmp1 - tmp2;
		j2 = tmp1 + tmp2;
		ring = n + j1 - j2;
		j = (j1 + j2 - n + (ring % 2) + 1)/2;
		if (j >= (n << 2))
			j = 0;
		ndx = 2 * n * (n - 1) + 4 * n * ring + j;
	} else { /* polar */
		tmp1 = fmod(nlng, 1.);
		tmp2 = n * sqrt(3. * (1 - fabs(z)));
		j1 = tmp1 * tmp2;
		j2 = (1 - tmp1) * tmp2;
		ring = j1 + j2 + 1;
		j = nlng * ring;
		if (j >= (ring << 2))
			j = 0;
		if (z > 0)
			ndx = 2 * ring * (ring - 1) + j;
		else /* match with equatorial pixels that poke over */
			ndx = 12 * n * n - 2 * ring * (ring + 1) + j;
	}
	return(ndx);
}


#ifdef TESTING
#include <stdio.h>

double
d2r(double x)
{
	return(x * M_PI/180.);
}

int
main(int argc, char **argv)
{
	double t1, t2;

	for (t1 = 90; t1 > -90; t1 -= 4.)
		for (t2 = 0; t2 < 360; t2 += 4.) {
			printf("lng %.1f lat %.1f:  ", t2, t1);
			printf("%d\n", healpix_ndx(d2r(t1), d2r(t2), 4));
		}
	return(0);
}
#endif
