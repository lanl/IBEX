/*	$Id: mappage.c,v 1.10 2022/09/03 03:53:12 pjanzen Exp $	*/
/* Map projections */

static const char rcsid[] = "@(#) $Id: mappage.c,v 1.10 2022/09/03 03:53:12 pjanzen Exp $";

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "extern.h"

typedef double Qvec_d[3];
typedef double Qmtx_d[3][3];

static Qmtx_d currotm = {{1., 0., 0.}, {0., 1., 0.}, {0., 0., 1.}};

/* Undo mouse clicks */
static int mclix = 0;
static double ctrss[11][3];
void
pushctr()
{
	int i, j;

	ctrss[mclix][0] = ctrlat;
	ctrss[mclix][1] = ctrlng;
	ctrss[mclix][2] = ctrrot;
	mclix++;
	if (mclix >= 11) {
		mclix--;
		for (i = 1; i < 11; i++)
			for (j = 0; j < 3; j++)
				ctrss[i-1][j] = ctrss[i][j];
	}
}
int
popctr()
{
	if (mclix == 0)
		return(0);
	mclix--;
	ctrlat = ctrss[mclix][0];
	ctrlng = ctrss[mclix][1];
	ctrrot = ctrss[mclix][2];
	return(1);
}

void
print_currot()
{
printf("[[ %.2lf %.2lf %.2lf ]\n", currotm[0][0],currotm[0][1],currotm[0][2]);
printf(" [ %.2lf %.2lf %.2lf ]\n", currotm[1][0],currotm[1][1],currotm[1][2]);
printf(" [ %.2lf %.2lf %.2lf ]]\n", currotm[2][0],currotm[2][1],currotm[2][2]);
}

double
max_arr(double *arr, int n)
{
	int i;
	double x;
	
	x = arr[0];
	for (i = 1; i < n; i++)
		if (arr[i] > x)
			x = arr[i];
	return(x);
}

double
min_arr(double *arr, int n)
{
	int i;
	double x;
	
	x = arr[0];
	for (i = 1; i < n; i++)
		if (arr[i] < x)
			x = arr[i];
	return(x);
}

/* return zero if maps can be divided/subtracted. */
int
maps_compatible(int i, int j)
{
	int k, l;

	if (dsets[i].healn != dsets[j].healn ||
	    dsets[i].nbinlat != dsets[j].nbinlat ||
	    dsets[i].nbinlng != dsets[j].nbinlng)
		return(1);
	for (k = 0; k < HI_ENERGIES; k++)
		if (dsets[i].filled[k] != dsets[j].filled[k])
			break;
	if (k < HI_ENERGIES)
		return(2);
	for (k = 0; k < 3; k++)
		for (l = 0; l < 3; l++)
			if (fabs(dsets[i].initrot[k][l] - dsets[j].initrot[k][l]) > 1e-9)
				return(3);
	return(0);
}


/* Now some general rotation goo (without quaternions, sigh) */
/* r3 = r1 r2 */
static void
matmult(Qmtx_d r1, Qmtx_d r2, Qmtx_d r3)
{
	int i, j, k;
	double sum;

	sum = 0.;
	for (i = 0; i < 3; i++) {
		for (j = 0; j < 3; j++) {
			for (k = 0; k < 3; k++)
				sum += r1[i][k] * r2[k][j];
			r3[i][j] = sum;
			sum = 0.;
		}
	}
}

/* v3 = r1 v2 */
static void
matvecmult(Qmtx_d r1, Qvec_d v2, Qvec_d v3)
{
	int i, j;

	for (i = 0; i < 3; i++) {
		v3[i] = 0.;
		for (j = 0; j < 3; j++)
			v3[i] += r1[i][j] * v2[j];
	}
}

/* v3 = r1^-1 v2, using that the inverse of a rot matrix is its transpose. */
static void
invrotmatvecmult(Qmtx_d r1, Qvec_d v2, Qvec_d v3)
{
	int i, j;

	for (i = 0; i < 3; i++) {
		v3[i] = 0.;
		for (j = 0; j < 3; j++)
			v3[i] += r1[j][i] * v2[j];
	}
}

/* Silly. */
void
copy_currotm(double a[3][3])
{
	memcpy(a, currotm, 3 * 3 * sizeof(double));
}

/* Make a rotation matrix.
 *
 * The process is:
 * (1) rotate around z axis to bring longitude to middle of screen (0).
 * (2) rotate around y axis to bring latitude requested to middle (0).
 *     (it's rotating to bring lat to 0, so the fact that it's not 90-lat
 *      is irrelevant.)
 * (3) if required, rotate about x axis by ctrrot.
 *
 * When we build, we either have lat/long relative to current rotation (if
 * we got a mouse click) or relative to nonrotated (command line options),
 * so flag for that.
 *
 * Tricky bit, though:  we use this to map on-screen to actual, so it's
 * the REVERSE rotation that we truly want.  That means we have to do it in
 * the other order, which amounts either to taking a transpose or to
 * flipping the order in which we multiply the matrices.
 *
 * The other tricky bit is if the original map was already rotated.
 * In that case, pass another matrix along to get multiplied, and make sure
 * keepold is zero.
 */
void
build_rotation(double lng, double lat, double rot, int keepold,
    double foo[3][3])
{
	Qmtx_d rot1, rot2, rot3, tmp;

	rot1[0][0] = rot1[1][1] = cos(d2r(-lng));
	rot1[0][1] = sin(d2r(-lng));
	rot1[1][0] = -rot1[0][1];
	rot1[2][0] = rot1[2][1] = rot1[0][2] = rot1[1][2] = 0.;
	rot1[2][2] = 1.;

	rot2[0][0] = rot2[2][2] = cos(d2r(lat));
	rot2[0][2] = -sin(d2r(lat));
	rot2[2][0] = -rot2[0][2];
	rot2[1][0] = rot2[0][1] = rot2[2][1] = rot2[1][2] = 0.;
	rot2[1][1] = 1.;

	matmult(rot1, rot2, tmp);	/* reverse order */
	if (rot != 0.) {
		rot3[1][1] = rot3[2][2] = cos(d2r(rot));
		rot3[1][2] = sin(d2r(rot));
		rot3[2][1] = -rot3[1][2];
		rot3[2][0] = rot3[1][0] = rot3[0][1] = rot3[0][2] = 0.;
		rot3[0][0] = 1.;
		matmult(tmp, rot3, rot1);	/* reverse order */
		memcpy(tmp, rot1, 3 * 3 * sizeof(double));
	}

	if (keepold) {
		matmult(currotm, tmp, rot1);	/* reverse order */
		memcpy(currotm, rot1, 3 * 3 * sizeof(double));
	} else {
#if 0
		if (foo)
			matmult(foo, tmp, currotm); /* XXX ? */
		else
#endif
			memcpy(currotm, tmp, 3 * 3 * sizeof(double));
	}
}

void
apply_rotation(double *x, double *y)
{
	Qvec_d tmp, tmp2;

	rd2vec(tmp, *x, *y);
	matvecmult(currotm, tmp, tmp2);
	vec2latlong(tmp2, y, x);
}

void
apply_inv_rotation(double *x, double *y)
{
	Qvec_d tmp, tmp2;

	rd2vec(tmp, *x, *y);
	invrotmatvecmult(currotm, tmp, tmp2);
	vec2latlong(tmp2, y, x);
}

/* Latitude and longitude are in degrees. Longitude has to run -180 to
 * +180. Latitude has to be +90 to -90.
 * I'd like this to be wicked fast, but it HAS to tolerate lat/long out of
 * range because that's what vec2latlong does.  Faster would mean
 * rebuilding to accommodate that.
 *
 * As an aside, note that we're actually INVERTING latitude here.  That's
 * because the imagemaps that we draw have y increasing down.
 * hist2d.c:build_hist() flips non-HEALpix data so that latitude increases
 *    DOWN (ngle is 0 to 180 from a dot product, so 0 is "north"; that
 *    corresponds to an index starting at nhlat - 1.
 * mapread.c:isoc_ingest() reads in a data file that appears to start with
 *    latitude -90 increasing to latitude 90, so we store it "upside down"
 *    too.
 */
double
get_pixel_value(double lat, double lng, char *foo)
{
	int i, j;

	while (lng >= 180.)
		lng -= 360.;
	while (lng < -180.)
		lng += 360.;
	if (healzn > 0)
		return(pltdata[healpix_ndx(d2r(-lat), d2r(lng + 180.), healzn)]);
	else if (healzn < 0)
		return(pltdata[abrate_ndx(d2r(-lat), d2r(lng + 180.), -healzn)]);
	else {
		/* XXX PJ rounding? */
		i = (180. + lng) / 360. * pltnlng;
		j = (90. - lat) / 180. * pltnlat;
		return(pltdata[j * pltnlng + i]);
	}
}


/* Build up an array to display.  It's 1-D, mapX * mapY elements long,
 * where element (x, y) is mapY * x + y [XXX TBD], on a 0-255 scale from
 * minval to maxval (set to -1 for not-plottable).  This array is
 * allocated by this function (it must be freed elsewhere).
 *
 * Data is taken from a map.  I want to be able to take HEALpix eventually,
 * which is why I'm going to compartmentalize how we get it.
 * I'll specify a map of nbinlat and nbinlng (as per hist2d), lined up in
 * lat * nbinlng + lng.
 *
 * We may wish to draw equators, etc. on this yet. XXX
 */
int *
plot_mercator(int mapX, int mapY, double minval, double maxval)
{
	int i, j, k;
	int *retarr;
	double tmp, tmpdnm;
	double lng, lat;

	tmpdnm = maxval - minval;
	if (tmpdnm == 0.)
		tmpdnm = 1.;
	if ((retarr = (int *)calloc(mapX * mapY, sizeof(int))) == NULL)
		return(NULL);
	for (i = 0; i < mapX; i++) {
		for (j = 0; j < mapY; j++) {
			/* Does it run positive right or left, or should that be
			 * adjustable?
			 */
			lng = 360. - (i+0.5)/(double)mapX * 360.;
			lat = 180. * (0.5 - (j+0.5)/(double)mapY);
			if (appResources.Flip)
				lng = -lng;
			apply_rotation(&lng, &lat);
			tmp = get_pixel_value(lat, lng, "mercator");
			k = (tmp - minval)/tmpdnm * 256;
			if (k < 0)
				k = 0;
			if (k >= 256)
				k = 255;
			retarr[j * mapX + i] = k;
		}
	}
	return(retarr);
}


int *
plot_globe(int isfront, int mapX, int mapY, double minval, double maxval)
{
	int i, j, k;
	double lng, lat, r, rtmp1, rtmp;
	double tmp, tmpdnm;
	int *retarr;

	if ((retarr = (int *)calloc(mapX * mapY, sizeof(int))) == NULL)
		return(NULL);
	if (mapX < mapY)
		r = mapX / 2.;
	else
		r = mapY / 2.;
	tmpdnm = maxval - minval;
	if (tmpdnm == 0.)
		tmpdnm = 1.;
	for (i = 0; i < mapX; i++) {
		rtmp1 = ((i+0.5) - mapX/2.) * ((i+0.5) - mapX/2.);
		for (j = 0; j < mapY; j++) {
			rtmp = sqrt(rtmp1 + ((j+0.5) - mapY/2.) * ((j+0.5) - mapY/2.));
			if (rtmp > r)
				retarr[j * mapX + i] = 0; /* -1; */
				/* XXX yow, -1 is not a valid place to access. */
			else {
				lat = asin((mapY/2. - (j+0.5))/(mapY/2.));
				/* Does it run positive right or left, or should that be
				 * adjustable?
				 */
				lng = r2d(asin((mapX/2. - (i+0.5))/(mapX/2.)/cos(lat)));
				if (isfront)
					lng += 180.;
				if (appResources.Flip)
					lng = -lng;
				lat = r2d(lat);

				apply_rotation(&lng, &lat);
				tmp = get_pixel_value(lat, lng, "globe");
				k = (tmp - minval)/tmpdnm * 256;
				if (k < 0)
					k = 0;
				if (k >= 256)
					k = 255;
				retarr[j * mapX + i] = k;
			}
		}
	}
	return(retarr);
}


int *
plot_mollweide(int mapX, int mapY, double minval, double maxval)
{
	int i, j, k;
	double lng, lat;
	double th, tmp, tmp2, tmpdnm;
	int *retarr;

	if ((retarr = (int *)calloc(mapX * mapY, sizeof(int))) == NULL)
		return(NULL);
	tmpdnm = maxval - minval;
	if (tmpdnm == 0.)
		tmpdnm = 1.;
	for (j = 0; j < mapY; j++) {
		/* Fit vertically. */
		th = asin(1. - 2. * (j+0.5)/(double)mapY);
		tmp = (2 * th + sin(2. * th))/M_PI;
		for (i = 0; i < mapX; i++) {
		/* Yes it zeroes at the right place for (i = -2; i < mapX + 2; i++) { */
			lat = r2d(asin(tmp));
			/* Does it run positive right or left, or should that be
			 * adjustable?
			 */
			if (cos(th) == 0.) {
				retarr[j * mapX + i] = 0; /* -1; */
				/* Yow, -1 is invalid when we draw this. */
			} else {
				lng = -360./cos(th) * ((i+0.5)/(double)mapX - 0.5);
				if (appResources.Flip)
					lng = -lng;
				if (fabs(lng) > 180.)
					retarr[j * mapX + i] = 0; /* -1; */
				else {
					lng += 180.;
					apply_rotation(&lng, &lat);
					tmp2 = get_pixel_value(lat, lng, "mollweide");
					k = (tmp2 - minval)/tmpdnm * 256;
					if (k < 0)
						k = 0;
					if (k >= 256)
						k = 255;
					retarr[j * mapX + i] = k;
				}
			}
		}
	}
	return(retarr);
}
