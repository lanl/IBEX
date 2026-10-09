/*	$Id: penbg.c,v 1.17 2020/01/21 05:42:13 pjanzen Exp $	*/
/* Routines to figure out what the penetrating background ratios are, based
 * on the background tests.
 *
 * Really, this should probably read in a data file, and should NOT have
 * hard-coded values.  Consider that a XXX to fix.  For now, interpolate
 * linearly between tests, in time -- except for the qABC:lABC ratio, which
 * appears constant, in which case the uncertainty drops like crazy.
 * Linear is probably a poor call.  Note that the orbit 77 background test
 * didn't seem to make sense, although in hindsight it's between what we
 * got in orbit 189 and in orbit 13.
 */

static const char rcsid[] = "@(#) $Id: penbg.c,v 1.17 2020/01/21 05:42:13 pjanzen Exp $";

#include <math.h>
#include "ibexhi.h"

#define NPENBGTESTS (14)

typedef struct {
	double val;
	double unc;
} datapoint;

/* Numbers copied from the "IBEX-Hi Testing, orbits 186-189" memo, Feb 4
 * 2013 for orbits 13, 77, 189.  (tests186-189/testsreport.tex)
 * For orbit 243, data is in 0243/bg/safe/Notes.
 */
static datapoint penbgtestrates[NPENBGTESTS][BIN_TYPES] = {
/* Orbit 13 test */
/* It's Poisson and 1756 counts for qABC */
{ { 57.59, 1.4 }, { 109.3, 1.9 },
  { 187.2, 2.5 }, { 269.8, 3.0 }, { 41.2, 1.2 }, { 104.5, 1.9 },
  { 189.8, 2.5 }, { 565.7, 4.3 },
  { 2817, 9.6 }, { 4667, 12 }, { 6044, 14 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 77 test */
{ { 56.8, 1.5 }, { 107.8, 2.0 },
  { 174.5, 2.6 }, { 257.4, 3.2 }, { 40.1, 1.2 }, { 101.1, 2.0 },
  { 198.0, 2.8 }, { 531.6, 4.5 },
  { 2688, 10 }, { 4390, 13 }, { 5711, 15 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 189 test */
{ { 39.4, 0.8 }, { 74.9, 1.2 },
  { 110.7, 1.4 }, { 163.8, 1.7 }, { 24.1, 0.7 }, { 64.8, 1.1 },
  { 122.7, 1.5 }, { 342.1, 2.5 },
  { 1652, 6. }, { 2677, 7. }, { 3478, 8. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 243 test, merging the two CEM voltages */
{ { 36.38, 0.87 }, { 67.53, 1.19 },
  { 102.46, 1.46}, { 150.68, 1.78}, { 21.82, 0.68 }, { 57.37, 1.10 },
  { 112.33, 1.53}, { 314.2,  2.6 },
  { 1483.2, 5.6 }, { 2344.6, 7.0 }, { 3036.3, 8.0 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* orbit 307 test */
{ { 43.97, 0.73 }, { 83.11, 1.00 },
  { 127.4, 1.23 }, { 188.4, 1.50 }, { 27.03, 0.57 }, { 70.97, 0.92},
  { 144.6, 1.32 }, { 392.0, 2.2 },
  { 1878., 5. }, { 3022., 6. }, { 3973., 7. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* orbit 349 test */
{ { 57.77, 0.81 }, { 106.9, 1.10 },
  { 174.5, 1.40 }, { 254.4, 1.70 }, { 37.56, 0.65 }, { 98.82, 1.06},
  { 196.7, 1.49 }, { 531.0, 2.4 },
  { 2568., 5. }, { 4181., 7. }, { 5508., 8. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* orbit 391 test */
{ { 59.74, 0.92 }, { 113.6, 1.26 },
  { 183.8, 1.61 }, { 270.0, 1.95 }, { 36.46, 0.72 }, { 102.83, 1.20},
  { 208.1, 1.71 }, { 564.6, 2.8 },
  { 2804., 6. }, { 4561., 8. }, { 6005., 9. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 411 test */
{ { 63.09, 0.90 }, { 118.6, 1.24 },
  { 190.2, 1.56 }, { 279.9, 1.90 }, { 39.25, 0.71 }, { 106.73, 1.17},
  { 214.7, 1.67 }, { 579.1, 2.7 },
  { 2919., 6. }, { 4728., 8. }, { 6213., 9. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 420 test */
{ { 62.77, 0.89 }, { 117.6, 1.22 },
  { 196.5, 1.57 }, { 290.2, 1.91 }, { 39.17, 0.70 }, { 107.70, 1.16},
  { 219.4, 1.66 }, { 593.5, 2.7 },
  { 3012., 6. }, { 4881., 8. }, { 6424., 9. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 430 test */
{ { 61.50, 0.85 }, { 118.5, 1.19 },
  { 195.4, 1.52 }, { 288.8, 1.85 }, { 40.60, 0.69 }, { 108.98, 1.14},
  { 221.2, 1.62 }, { 597.7, 2.7 },
  { 2990., 6. }, { 4860., 8. }, { 6406., 9. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 441 test */
{ { 63.92, 0.84 }, { 121.2, 1.16 },
  { 204.2, 1.50 }, { 302.8, 1.83 }, { 41.29, 0.67 }, { 114.88, 1.13},
  { 230.0, 1.59 }, { 626.9, 2.6 },
  { 3164., 7. }, { 5159., 8. }, { 6749., 10. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 451 test, with lots of times removed */
{ { 65.10, 1.31 }, { 122.6, 1.80 },
  { 201.0, 2.3  }, { 295.6, 2.8 }, { 43.08, 1.07 }, { 116.7, 1.8 },
  { 227.5, 2.5  }, { 618.9, 4.0 },
  { 3152., 9. }, { 5156., 12. }, { 6751., 13. },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 461 test */
{ { 62.85, 0.82 }, { 121.6, 1.14 },
  { 204.6, 1.47 }, { 303.4, 1.80 }, { 42.63, 0.67 }, { 115.99, 1.11 },
  { 233.6, 1.58 }, { 631.7, 2.6 },
  { 3192.5, 5.8 }, { 5183.1, 7.4 }, { 6826.8, 8.5 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
  /* orbit 471 test */
{ { 62.39, 0.88 }, { 121.3, 1.22 },
  { 202.8, 1.58 }, { 299.8, 1.93 }, { 40.68, 0.71 }, { 111.95, 1.18 },
  { 228.9, 1.68 }, { 625.3, 2.8 },
  { 3151.2, 6.2 }, { 5159.6, 8.0 }, { 6793.9, 9.2 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} }
};

/* And the ratios are really what we're after.  There's no new data, but I
 * might as well do the error analysis only the once.
 */
static datapoint penbgtestratios[NPENBGTESTS][BIN_TYPES] = {
/* Orbit 13 */
{ { 1, 0. }, { 1.898, 0.031 },
  { 3.25, 0.09 }, { 4.68, 0.13 }, { 0.72, 0.03 }, { 1.81, 0.06 },
  { 3.30, 0.09 }, { 9.82, 0.25 },
  { 48.9,  1.2 }, { 81.0, 2.0 }, { 104.9, 2.6 }, 
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 77 */
{ { 1, 0. }, { 1.897, 0.034 },
  { 3.07, 0.09 }, { 4.53, 0.13 }, { 0.71, 0.03 }, { 1.78, 0.06 },
  { 3.49, 0.10 }, { 9.36, 0.26 },
  { 47.3, 1.3 }, { 77.3, 2.1 }, { 100.6, 2.7 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 189 */
{ { 1, 0. }, { 1.902, 0.028 },
  { 2.81, 0.07 }, { 4.16, 0.10 }, { 0.61, 0.02 }, { 1.65, 0.04 },
  { 3.11, 0.07 }, { 8.68, 0.2 },
  { 41.9, 0.9 }, { 67.9, 1.4 }, { 88.3, 1.8 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 243 */
{ { 1., 0. }, { 1.856, 0.030 },
  { 2.82, 0.12 }, { 4.14, 0.17 }, { 0.60, 0.03 }, { 1.58, 0.07 },
  { 3.09, 0.13 }, { 8.64, 0.35 },
  { 40.8, 1.6  }, { 64.4, 2.6  }, { 83.5, 3.3 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 307 */
{ { 1., 0. }, { 1.890, 0.021 },
  { 2.90, 0.06 }, { 4.29, 0.08 }, { 0.61, 0.02 }, { 1.61, 0.03 },
  { 3.29, 0.06 }, { 8.92, 0.16 },
  { 42.7, 0.7 }, { 68.7, 1.1 }, { 90.3, 1.5 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 349 */
{ { 1., 0. }, { 1.850, 0.018 },  /* lABC ratio...can't find raw docs */
  { 3.02, 0.05 }, { 4.44, 0.07 }, { 0.65, 0.01 }, { 1.71, 0.03 },
  { 3.41, 0.05 }, { 9.19, 0.14 },
  { 44.4, 0.6 }, { 72.4, 1.0 }, { 95.3, 1.3 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 391 */
{ { 1., 0. }, { 1.902, 0.020 },
  { 3.08, 0.05 }, { 4.52, 0.07 }, { 0.61, 0.01 }, { 1.72, 0.03 },
  { 3.48, 0.05 }, { 9.45, 0.14 },
  { 46.9, 0.7 }, { 76.4, 1.2 }, { 100.5, 1.5 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 411 */
{ { 1., 0. }, { 1.879, 0.018 },
  { 3.01, 0.05 }, { 4.44, 0.07 }, { 0.62, 0.01 }, { 1.69, 0.03 },
  { 3.40, 0.06 }, { 9.18, 0.14 },
  { 46.3, 0.7 }, { 74.9, 1.1 }, { 98.5, 1.4 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 420 */
{ { 1., 0. }, { 1.874, 0.018 },
  { 3.13, 0.05 }, { 4.62, 0.07 }, { 0.62, 0.01 }, { 1.72, 0.03 },
  { 3.50, 0.06 }, { 9.46, 0.14 },
  { 48.0, 0.7 }, { 77.8, 1.1 }, { 102.3, 1.5 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 430 */
{ { 1., 0. }, { 1.926, 0.019 },
  { 3.18, 0.05 }, { 4.70, 0.07 }, { 0.66, 0.01 }, { 1.77, 0.03 },
  { 3.60, 0.06 }, { 9.72, 0.14 },
  { 48.6, 0.7 }, { 79.0, 1.1 }, { 104.2, 1.5 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 441 */
{ { 1., 0. }, { 1.896, 0.017 },
  { 3.19, 0.05 }, { 4.74, 0.07 }, { 0.65, 0.01 }, { 1.80, 0.03 },
  { 3.60, 0.05 }, { 9.81, 0.14 },
  /* XXX next 3 are wrong */
  { 49.5, 0.7 }, { 80.7, 1.1 }, { 105.6, 1.4 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 451 */
{ { 1., 0. }, { 1.883, 0.026 },
  { 3.09, 0.07 }, { 4.54, 0.10 }, { 0.66, 0.02 }, { 1.79, 0.05 },
  { 3.50, 0.08 }, { 9.51, 0.20 },
  { 48.4, 1.0 }, { 79.2, 1.6 }, { 103.7, 2.1 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 461 */
{ { 1, 0. }, { 1.935, 0.017 },
  { 3.25, 0.05 }, { 4.83, 0.07 }, { 0.68, 0.01 }, { 1.85, 0.03 },
  { 3.72, 0.05 }, { 10.05, 0.14 },
  { 50.8, 0.67 }, { 82.5, 1.1 }, { 108.6, 1.42 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} },
/* Orbit 471 */
{ { 1, 0. }, { 1.945, 0.019 },
  { 3.25, 0.05 }, { 4.81, 0.07 }, { 0.65, 0.01 }, { 1.79, 0.03 },
  { 3.67, 0.06 }, { 10.02, 0.15 },
  { 50.5, 0.72 }, { 82.7, 1.2 }, { 108.9, 1.54 },
  { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.}, { -1., -1.},
  { -1., -1.}, { -1., -1.} }
};


/* A central MET per test wouldn't hurt any either.  Picked by eye --
 * precision is not vital.
 */
static uint32_t testmets[NPENBGTESTS] = {
  916048181, 957794744, 1039270688, 1081835457, 1132247509, 1165126926,
  1198324610, 1213882468, 1221025698, 1228770109, 1237469098, 1245299207,
  1253098096, 1260648595
};



/* Penetrating background, as a ratio, changes over time, as observed by
 * penetrating background tests in orbits 13, 77, and 189.  We could use
 * the numbers from the test closest in time, or we could do some form of
 * interpolation, noting that the orbit 77 test was a touch questionable
 * for other reasons, and noting that there are uncertainties with each
 * ratio anyhow.  With three tests, one could imagine a best-fit line, for
 * instance...
 *
 * Anyhow, this function is where all the magic has to reside.  We can
 * determine penetrating background quite well from the qABC/lABC ratio,
 * which doesn't seem to change over time.  If we are to subtract
 * background from other hb types, though, we need to translate.
 *
 * I'm worried about extrapolating, so for now, anything before the first
 * test matches the first test.  Anything after the last test... well...
 * XXX.  Intermediate gets interpolated linearly.
 */
double
get_penbg_ratio(uint32_t met, int hbtype, double *unc)
{
	int i;
	double d, x;

	*unc = -1.;
	if (hbtype < 0 || hbtype > BIN_TYPES)
		return(-1.);
	/* Handle the special cases.  Penbg_ratio for qABC stays at 1 by
	 * definition.  At present we believe the qABC/lABC ratio never
	 * changes, so we want to simply average the tests and return a number
	 * with a sweet tiny uncertainty.
	 */
	if (hbtype == HB_QABC) {
		*unc = 0.;
		return(1.);
	}
	if (hbtype == HB_LABC) {
		/* XXX XXX at present (end 2019/start 2020) there is some
		 * suggestion that this ratio is changing over time.
		 * It's not absolutely certain that it is, but right now the last
		 * 2 bg tests (461, 471) are over 2 sigma above the long-term
		 * average (1.89723 if weighted).  If it IS changing, it would
		 * explain (probably) the divergence of IBEX-Hi calc bg compared
		 * to ground-based neutron monitors, and align the bg calc with
		 * the last 2 bg tests.  But Dan figures it's too soon to pull
		 * that trigger - there has been one 2 sigma low earlier.
		 * The thing is, I can't really justify using the stat weighted
		 * unc (currently .0056) now, because it is likely NOT behaving
		 * statistically like something that's constant.
		 * For now hardwire XXX XXX in the standard deviation of the
		 * measurements -- NOT the standard deviation of the mean --
		 * assuming generally equal uncs.  This at least safely handles
		 * the actual unc.  This value may go down once I figure out
		 * what's going on.
		 */
		/* XXX this assumption could perhaps use more documentation */
		d = x = 0.;
		for (i = 0; i < NPENBGTESTS; i++) {
			d += penbgtestratios[i][hbtype].val /
	    penbgtestratios[i][hbtype].unc / penbgtestratios[i][hbtype].unc;
			x += 1.0 /
	    penbgtestratios[i][hbtype].unc / penbgtestratios[i][hbtype].unc;
		}
		*unc = sqrt(1./x);
		*unc = 0.027;	/* XXX */
		return(d/x);
	}
	if (met <= testmets[0]) {
		*unc = penbgtestratios[0][hbtype].unc;
		return(penbgtestratios[0][hbtype].val);
	}
	if (met >= testmets[NPENBGTESTS - 1]) {
#ifdef DO_NOT_EXTRAPOLATE
		*unc = penbgtestratios[NPENBGTESTS - 1][hbtype].unc;
		return(penbgtestratios[NPENBGTESTS - 1][hbtype].val);
#else
		/* This is the same as the case below, except now d will be
		 * negative, not between 0 and 1.
		 */
		/* Linear.  Assume no uncertainty in the assumption of linear... */
		d = ((double)(testmets[NPENBGTESTS-1]) - (double)met) /
		    ((double)(testmets[NPENBGTESTS-1]) -
		    (double)(testmets[NPENBGTESTS-2]));
		*unc = sqrt(d * d *
		    penbgtestratios[NPENBGTESTS-2][hbtype].unc *
		    penbgtestratios[NPENBGTESTS-2][hbtype].unc
		    + (1. - d) * (1. - d) *
		    penbgtestratios[NPENBGTESTS - 1][hbtype].unc *
		    penbgtestratios[NPENBGTESTS - 1][hbtype].unc);
		return(penbgtestratios[NPENBGTESTS-1][hbtype].val * (1.-d) +
		    penbgtestratios[NPENBGTESTS-2][hbtype].val * d);
#endif
	}
	i = 1;
	while (testmets[i] < met)
		i++;
	/* Linear.  Assume no uncertainty in the assumption of linear... */
	d = ((double)(testmets[i]) - (double)met) /
	    ((double)(testmets[i]) - (double)(testmets[i-1]));
	*unc = sqrt(d * d *
	    penbgtestratios[i-1][hbtype].unc * penbgtestratios[i-1][hbtype].unc
	    + (1. - d) * (1. - d) *
	    penbgtestratios[i][hbtype].unc * penbgtestratios[i][hbtype].unc);
	return(penbgtestratios[i][hbtype].val * (1.-d) +
	    penbgtestratios[i-1][hbtype].val * d);
}


/* Probably nice to be able to get the raw numbers per test, too.  I mean,
 * right now they're hardcoded everywhere.
 *
 * Return 0 on success.
 */
int
get_test_results(int whichtest, int hbtype, double *rate, double *rateunc)
{
	if (whichtest >= 0 && whichtest < NPENBGTESTS &&
	    hbtype >= 0 && hbtype < BIN_TYPES) {
		*rate = penbgtestrates[whichtest][hbtype].val;
		*rateunc = penbgtestrates[whichtest][hbtype].unc;
		return(0);
	} /* else */
	return (-1);
}


#ifdef TESTING
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
	uint32_t m;
	double r, u;
	int hbt;

	hbt = HB_LAB;
	if (argc > 1)
		hbt = atoi(argv[1]);
	for (m = 910000000 ; m < 1200000000; m += 1000000) {
		r = get_penbg_ratio(m, hbt, &u);
		printf("%lu  %lf %lf\n", (unsigned long)m, r, u);
	}
	return(0);
}
#endif
