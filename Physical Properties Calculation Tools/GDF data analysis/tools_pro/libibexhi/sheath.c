/*	$Id: sheath.c,v 1.3 2013/06/18 18:19:43 pjanzen Exp $	*/
/* General routines to guess if IBEX is in the sheath/bow shock/wherever.
 * The idea is to use these routines when studying possible solar
 * wind-related contamination. 
 *
 */
static const char rcsid[] = "@(#) $Id: sheath.c,v 1.3 2013/06/18 18:19:43 pjanzen Exp $";

#include <math.h>
#include <string.h>
#include "ibexhi.h"
#include "mpfit.h"

/* Are we behind the bow shock, or in the solar wind?
 * The exact edge depends on solar wind conditions, but we can do a general
 * check for "average" solar wind.  I take the fit and functional form Sofia 
 * Tanberg used in her 2011 AGU poster, and just assume nominal solar wind.
 * I assume once aberration angle is handled, it's entirely symmetric
 * around sw direction.
 *
 * Input is coordinates in GSE in km.
 * Output is 1 if you are (likely) BEHIND the bow shock, 0 if you are
 * (likely) in clean solar wind.
 */
int
in_nominal_BS(double x[3])
{
	double r, costhet, y[2], tmp, tmp2;

	/* R_o = 15.0 R_E */
	r = sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]) / EARTH_RAD / 15.0;
	/* Solar wind aberration:  rotate in xy by 4.2 degrees (on average),
	 * leaving z alone.
	 */
	y[0] = x[0] * cos(d2r(4.2)) - x[1] * sin(d2r(4.2));
	y[1] = x[1] * cos(d2r(4.2)) + x[0] * sin(d2r(4.2));
	/* I want cos(theta) and
	 * theta = atan2(sqrt(x[2] * x[2] + y[1] * y[1]), y[0]);
	 */
	costhet = y[0] / sqrt(x[2] * x[2] + y[1] * y[1] + y[0] * y[0]);
	/* Epsilon is 1.01, alpha is 0.793 */
	tmp = 1 + 1.01 * costhet;
	if (tmp <= 0.)
		return(1);
	tmp2 = (1 + 1.01) / tmp;
	tmp = pow(tmp2, 0.793);
	if (r <= tmp)
		return(1);
	return(0);
}

/* Set up a cull for one ESA (0-5) that's 1 for times when IBEX is (likely)
 * in clean solar wind, and zero otherwise.  Obviously SPICE must be loaded
 * and hb_makealltimesnculls() has to have run.  Returns 0 on success.  On
 * failure, it's possible to have a partially modified cull returned.
 *
 * XXX really should have some more conservative check for in solar wind.
 * This is NOMINAL bow shock location, which may not be enough.
 * Perhaps setting up three energies with bounds would make sense...
 */
int
make_cull_in_nominal_SW(int whichcull, int esa)
{
	int i, j;
	char k;
	double x[3];

	if (esa < 0 || esa >= HI_ENERGIES || whichcull < 0 || whichcull >= 8)
		return(-1);
	k = (1 << esa);
	for (i = 0; i < nallt; i++) {
		if (getIBEXlocGSE((double)alltimes[i], x, x+1, x+2, &j, -100))
			return(-1 - i);
		if (in_nominal_BS(x) == 0) {
			for (j = 0; j < HI_AZ_BINS; j++)
				mculls[whichcull][i * HI_AZ_BINS + j] |= k;
		} else {
			for (j = 0; j < HI_AZ_BINS; j++)
				mculls[whichcull][i * HI_AZ_BINS + j] &= ~k;
		}
	}
	return(0);
}


/* this duplicates noisemap code to some degree -- it's for fitting
 * deflected solar wind type signals.
 */
/* For now I get the canonical deflected solar wind shape from
 * part of orbit 47, simply summing ESAs 1, 2, and 3, and then
 * normalizing.  I took
 * # time range:  938010954 - 938120486 HVSCI packets
 * # 159 individual times of packet creation
 */
static const double swshape[HI_AZ_BINS] = {
  0.129434,  0.199664,  0.24976,   0.295542,  0.354027, 0.404842,
  0.478188,  0.529482,  0.604506,  0.683845,  0.763782, 0.836889,
  0.861577,  0.930968,  0.954698,  0.987536,  1,        0.993648,
  0.985618,  0.943672,  0.89849,   0.844799,  0.78092,  0.700623,
  0.623202,  0.543864,  0.477948,  0.409276,  0.348274, 0.294343,
  0.246045,  0.207095,  0.185403,  0.157598,  0.13255,  0.120566,
  0.112057,  0.096117,  0.091443,  0.0873682, 0.0884468,0.0784995,
  0.0817354, 0.0783797, 0.0761026, 0.0829338, 0.0707095,0.0704698,
  0.0629195, 0.0739453, 0.0743049, 0.0761026, 0.075743, 0.0792186,
  0.0824545, 0.0975551, 0.0918025, 0.110618,  0.130753, 0.143337
};
/* We fit on ESAs 1 -- 3.  I get the ratios by taking the max value
 * from this period of orbit 47.  Note that it does extend at least to
 * ESA 4 but not in a manner worth fitting for.
 */
static const double swratios[3] = { 1.0, 0.741, 0.322 };

/* Adjust this to shift where the peak lies. */
static int swBINofs = 0;
/* XXX Ideally you'd FIT this! */


static int
_sheath_swfitfuncb(int m, int n, double *p, double *deviates, double **derivs,
    void *prv)
{
	int i;
	double tmp;

	if (m != HI_AZ_BINS || n != 2)
		return(-1);
	for (i = 0; i < m; i++) {
		/* XXX simple "Earth view" removal; also remove the chunk that
		 * pooches in ESA 1 of Lo.
		 */
		if ((i < 12 || (i > 18 && i < 42) || i > 48) && (i == 0 || i > 3)) {
			tmp = ((long *)prv)[i] -
			    p[0] * swshape[(i + swBINofs) % HI_AZ_BINS] - p[1];
			deviates[i] = tmp;
		} else
			deviates[i] = 0.;
	}

	return 0;
}


/* This variant just sums the energies asked in the char (it'll go up to
 * ESA 8, so this works for Lo!) and fits against the shape, not the
 * dependence ESA to ESA.
 *
 * Fit is now 2 parameters - height and offset.  Only the height gets
 * reported, along with height uncertainty and fit reduced chisquared.
 * Note that mpfit will be assuming input uncertainties that probably
 * aren't the right order of magnitude.  If you were risky you could
 * claim reduced chisq should be one, so its actual value is the square
 * of the true uncertainty, and use this as a multiplicative factor on
 * htunc...   XXX XXX ???
 */
void
get_dswcontam(garray data, char esas, double *height, double *htunc,
    double *chisq)
{
	int j, k, giv;
	struct mp_result_struct res;
	double fparams[2];
	double fpunc[2];
	/* Only really want to keep the param related to sw contam right now */
	double bestparam, bestpunc;	
	double bestchisq;
	long fdat[HI_AZ_BINS + 1];

	for (j = 0; j < HI_AZ_BINS; j++)
		fdat[j] = 0;
	for (j = 0; j < 8; j++)
		if (1 << j & esas)
			for (k = 0; k < HI_AZ_BINS; k++)
				fdat[k] += data[j][k];
	/* Guess some initial values for mpfit, and guess which side to work on. */
	giv = fdat[0];
	for (k = 1; k < HI_AZ_BINS; k++)
		if (giv > fdat[k])
			giv = fdat[k];
	fparams[1] = (double)giv;
	bestchisq = -1.;
	bestpunc = -1.;
	bestparam = 0.;
	swBINofs = 0;
	for (k = 0; k < HI_AZ_BINS; k++) {
		bzero(&res, sizeof(res));
		res.xerror = fpunc;
		j = mpfit(_sheath_swfitfuncb, HI_AZ_BINS, 2, fparams, NULL, NULL,
		    fdat, &res);
		if (j > 0) {	/* Generally, success */
			if (bestchisq < 0. || res.bestnorm < bestchisq) {
				bestchisq = res.bestnorm;
				bestparam = fparams[0];
				bestpunc = fpunc[0];
			}
		}
		swBINofs = (swBINofs + 1) % HI_AZ_BINS;
	}
	if (bestchisq >= 0.) {
		*height = bestparam;
		*htunc = bestpunc;
		/* reduce it */
		*chisq = bestchisq / (HI_AZ_BINS - 2);
	} else {
		*height = *htunc = *chisq = -1.;
	}
}


#ifdef TESTING
#include <stdio.h>

int
main(int argc, char **argv)
{
	double x[3];

	x[2] = 0.;
	for (x[1] = -60. * EARTH_RAD; x[1] <= 60. * EARTH_RAD;
	    x[1] += 0.5 * EARTH_RAD) {
		for (x[0] = -60. * EARTH_RAD; x[0] <= 60. * EARTH_RAD;
		    x[0] += 0.5 * EARTH_RAD)
			printf("%d ", in_nominal_BS(x));
		printf("\n");
	}
	return(0);
}
#endif
