/*	$Id: hist2d.c,v 1.16 2022/09/03 03:53:12 pjanzen Exp $	*/
/* Framework pulled from hi_iso_ofs/utils/hist2d */
/* not rcsid[] since we include libibexhi/vectors.c */
static const char rcsidm[] = "@(#) $Id: hist2d.c,v 1.16 2022/09/03 03:53:12 pjanzen Exp $";

#include <ctype.h>
#include <err.h>
#include <libgen.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/* from libibexhi */
#include "vectors.c" 

#include "extern.h"
#include "xmap.h"

static char *fnamebasedef = "/Users/nwalia/IDLWorkspace/tools_pro/qABC_qBC_6-deg_bins/qABC/";
static char *fnameextdef = ".qABC";
static char *fnamebase = NULL;
static char *fnameext = NULL;

/* antiram only (-1); ram only (1); both (0) */
/* XXX assuming 60 entries in file.  Works for now... */
static int ramm = 0;
/* stat weighting: none(0); arithmetic (1); geometric-unweighted(-1) */
static int statsum = 1;
/* drop negatives if nonzero */
static int noneg = 0;
/* do HEALpix instead (if nonzero).  It's a little hinky since it's done on
 * 6-deg binned data, but still.
 * Do Abrate pixels if negative.
 */
static int healn = 0;

/* binning: put the N pole of the map here */
static double nplong = 0.;
static double nplat = 90.;
/* binning: put the centre of the map here.  For our purposes it'll be
 * either the same as nplong or 180 degrees off, if we're doing the
 * simplest alignment. */
/* static double binctrlong = -104.6;	/* nose */
static double binctrlong = 0.;	/* nose */
/* degrees in lat and long per bin; better to set nhlat and nhlng */
static double latwid = 6.;
static double longwid = 6.;
static int nhlat = 30;
static int nhlng = 60;
static double bloat = -1.;
/* nonzero is something TBD with nearest neighbours.
 * 1 is an attempt to match ISOC smearing as per bdm's description.
 */
static int interp = 0;

int crappy = 0;	/* nonzero:  toss points with too lousy uncertainty */

void
clear_hist(int wch)
{
	int i;

	if (wch < 0 || wch >= N_DATASETS)
		return;
	free(dsets[wch].name);
	free(dsets[wch].fnamebase);
	free(dsets[wch].fnameext);
	dsets[wch].name = NULL;
	dsets[wch].fnamebase = NULL;
	dsets[wch].fnameext = NULL;
	for (i = 0; i < HI_ENERGIES; i++)
		if (dsets[wch].filled[i]) {
			free(dsets[wch].esa[i]);
			dsets[wch].esa[i] = NULL;
			dsets[wch].filled[i] = 0;
		}
	dsets[wch].firstorbit = dsets[wch].lastorbit = 0;
	dsets[wch].healn = 0;
	dsets[wch].datatype = 0;
}

void
print_histspecs(int i)
{
	printf("histogramming:  %d lng x %d lat, %s\n", nhlng, nhlat,
	    (ramm == 0 ? "ram & wake": (ramm > 0 ?  "ram only":"wake only")));
	printf("\tstat weighting:  %s\n", statsum == 1 ? "arithmetic":
	    (statsum == 0 ? "none":"unwted geometric"));
	if (interp == 1)
		printf("\tBut we are doing ISOC smearing at %.1lf degrees instead.\n",
		    bloat);
	printf("\t%s negative data points\n", noneg ? "DROP":"keep");
	printf("\tN pole in map coords at (%.1lf, %.1lf) ecliptic long/lat\n",
	    nplong, nplat);
	if (healn > 0)
		printf("\tHEALpix enabled! (n_side = %d)\n", healn);
	else if (healn < 0)
		printf("\tAbratepix enabled! (n_wanted = %d)\n", -healn);
	printf("\tmap bin centre is at longitude %.1lf\n", binctrlong);
	if (i < 0 || i >= nds) {
		printf("\tfile names are %s[ORBIT]%s\n", fnamebase, fnameext);
		printf("\t\texpecting %d-degree data files\n", defdattype == 0?6:1);
	} else {
		printf("\tfile names are %s[ORBIT]%s\n", dsets[i].fnamebase,
		    dsets[i].fnameext);
		printf("\t\texpecting %d-degree data files\n",
		    dsets[i].datatype == 0?6:1);
	}
}

char *
getfext()
{
	return(fnameext);
}

void
set_histfile(char *fbase, char *fext)
{
	char *p;

	free(fnamebase);
	if (fbase)
		fnamebase = strdup(fbase);
	else {
		if ((p = getenv("XMAP_FNAMEBASE")))
			fnamebase = strdup(p);
		else
			fnamebase = strdup(fnamebasedef);
	}
	free(fnameext);
	if (fext)
		fnameext = strdup(fext);
	else {
		if ((p = getenv("XMAP_FNAMEEXT")))
			fnameext = strdup(p);
		else
			fnameext = strdup(fnameextdef);
	}
}

void
set_histbins(int nlong, int nlat, double wnplong, double wnplat /* ,
    double wctrlong */)
{
	if (nlong > 1)
		nhlng = nlong;
	if (nlat > 1)
		nhlat = nlat;
	nplong = wnplong;
	nplat = wnplat;
	/* set binctrlong to keep N pole centred on display. */
	/* XXX huh? To fix. */
	if (nplat > 0. && nplat < 90.) {
		binctrlong = nplong - 180.;
		while (binctrlong < 0.)
			binctrlong += 360.;
	} else
		binctrlong = nplong;
#if 0
	binctrlong = wctrlong;
#endif
	longwid = 360./nhlng;;
	latwid = 180./nhlat;
}

void
set_histflags(int ramwake, int wstatsum, int dropneg, int winterp,
    double wbloat)
{
	ramm = ramwake;
	statsum = wstatsum;
	noneg = dropneg;
	interp = winterp;
	bloat = wbloat;
	/* Minor sanity checking */
	if (interp == 1)
		statsum = 1;
}

void
get_histflags(int *ramwake, int *wstatsum, int *dropneg, int *winterp,
    double *wbloat)
{
	*ramwake = ramm;
	*wstatsum = statsum;
	*dropneg = noneg;
	*winterp = interp;
	*wbloat = bloat;
}

void
set_histheal(int nside)
{
	if (nside > 0)
		healn = nside;
	else
		healn = 0;
}

/* I can use + vs - to piggyback Abrate on healpix, but I'll need to
 * rewrite this properly if we get one more silly mapping.
 */
void
set_histabrate(int n)
{
	if (n > 0)
		healn = -n;
	else
		healn = 0;
}

static void
populate_one_bin(int idx, double *binsig, double *bindat, int statsum,
    double datapoint, double sigmpoint)
{
	if (binsig[idx] < 0.) {
		bindat[idx] = datapoint;
		if (statsum == 0 || statsum == -1)
			binsig[idx] = 1.;
		else
			binsig[idx] = sigmpoint;
	} else {
		if (statsum == -1) {
			bindat[idx] *= datapoint;
			binsig[idx] += 1.;
		} else if (statsum == 0) {
			bindat[idx] += datapoint;
			binsig[idx] += 1.;
		} else { /* stat wt add */
			bindat[idx] = (bindat[idx] / (binsig[idx] * binsig[idx]) +
				  datapoint /  (sigmpoint  * sigmpoint)) /
				 (1. / (binsig[idx] * binsig[idx]) +
				  1. / (sigmpoint   * sigmpoint));
			binsig[idx] = sqrt(1. /
				 (1. / (binsig[idx] * binsig[idx]) +
				  1. / (sigmpoint   * sigmpoint)));
		}
	}
}


/* build_hist() is the standard place to begin, assuming you have 6-degree
 * (or other) spin-plane arc data of rate & unc.
 *
 * We can also start from the "1-degree" files I provide for better stats
 * maps, but in this case, a bunch of the options no longer make sense.
 * These files have total counts, exposure, and average background to
 * subtract. Weighting is ONLY by exposure in a pixel, since we assume that
 * whatever's in a map pixel is a constant.
 *
 * build_hist_1deg() and build_hist_6deg() have considerable duplicated
 * code.  This is possibly suboptimal, but they are totally different input
 * files.
 */
int
build_hist_1deg(int startorb, int startarc, int endorb, int endarc,
    int verbos, int returnuncs, int whch)
{
	double *bindat[6], *binsig[6], *binbg[6], *binbgu[6];
	long *bincts[6], *binexp[6];
	double x[3], y[3], z[3], ngle, ngle2;
	FILE *fp;
	char frob[2048], bozz[20], bazz[2048];
	int i, j, k, rwcut, jlim;
	int bn, bn2, idx, lin, extraconds;
	double linlong, linlat, linbg[HI_ENERGIES], linbgunc[HI_ENERGIES];
	long lincts[HI_ENERGIES], linexp[HI_ENERGIES];
	int bign;

	if (get_arcs_per_orbit(startorb) < 1 || get_arcs_per_orbit(endorb) < 1) {
		printf("Can't build orbits without inertial_pointing.\n");
		return(-1);
	}
	/* Success is guaranteed below here, so we can free some data. */
	free(dsets[whch].name);
	dsets[whch].name = NULL;
	for (i = 0; i < HI_ENERGIES; i++)
		if (dsets[whch].filled[i]) {
			free(dsets[whch].esa[i]);
			dsets[whch].esa[i] = NULL;
			dsets[whch].filled[i] = 0;
		}
	dsets[whch].firstorbit = dsets[whch].lastorbit = 0;
	dsets[whch].healn = 0;
	if (verbos > 5) {
		print_histspecs(whch);
		/* Corrections */
printf("For 1-deg data, averaging is BY EXPOSURE regardless of flags.\n");
	}
	if (healn == 0)
		bign = nhlat * nhlng;
	else if (healn > 0)
		bign = 12 * healn * healn;
	else
		bign = n_abrate(-healn);
	for (i = 0; i < HI_ENERGIES; i++)
		if (!(bindat[i] = (double *)calloc(bign, sizeof(double))) ||
		    !(binsig[i] = (double *)calloc(bign, sizeof(double))) ||
		    !(bincts[i] = (long *)calloc(bign, sizeof(long))) ||
		    !(binexp[i] = (long *)calloc(bign, sizeof(long))) ||
		    !(binbg[i] = (double *)calloc(bign, sizeof(double))) ||
		    !(binbgu[i] = (double *)calloc(bign, sizeof(double))))
			err(1, "calloc()");
	for (j = 0; j < HI_ENERGIES; j++)
		for (i = 0; i < bign; i++) {
			bindat[j][i] = 0.;
			binsig[j][i] = -1.;
			binexp[j][i] = 0;
		}
	rd2vec(x, nplong, nplat);
	rd2vec(z, binctrlong, 0.);

	for (i = startorb; i <= endorb; i++) {
		for (j = (i == startorb ? startarc:0);
		    j <= (i == endorb ? endarc:(get_arcs_per_orbit(i) - 1));
		    j++) {
			strlcpy(frob, dsets[whch].fnamebase, sizeof(frob));
			if (get_arcs_per_orbit(i) == 1)
				snprintf(bozz, sizeof(bozz), "%04d", i);
			else
				snprintf(bozz, sizeof(bozz), "%04d%c", i, 'a' + j);
			strlcat(frob, bozz, sizeof(frob));
			strlcat(frob, dsets[whch].fnameext, sizeof(frob));
			if ((fp = fopen(frob, "r")) == NULL) {
				if (verbos > 1)
					printf("\n");
				if (verbos >= 0)
					printf("no %s found; skipping\n", frob);
				continue;
			}
			if (verbos > 1)
				printf("%s ", bozz);
			lin = 0;
			/* By default cut ram/wake after 180th entry.  This is
			 * slightly incorrect because (usually) data starts 3
			 * degrees short of NEP.
			 */
			rwcut = 180;
			while (fgets(bazz, sizeof(bazz), fp)) {
				if (bazz[0] != '#') {
					lin++;
					/* XXX Here, sscanf() requires HI_ENERGIES to be 6 */
					if (sscanf(bazz,
"%lf%lf%ld%ld%lf%lf%ld%ld%lf%lf%ld%ld%lf%lf%ld%ld%lf%lf%ld%ld%lf%lf%ld%ld%lf%lf",
    &linlat, &linlong,
    lincts, linexp, linbg, linbgunc,
    lincts+1, linexp+1, linbg+1, linbgunc+1,
    lincts+2, linexp+2, linbg+2, linbgunc+2,
    lincts+3, linexp+3, linbg+3, linbgunc+3,
    lincts+4, linexp+4, linbg+4, linbgunc+4,
    lincts+5, linexp+5, linbg+5, linbgunc+5) != 26)
						warnx("sscanf %s line %d", bozz, lin);
                         else {
						rd2vec(y, linlong, linlat);
						/* acos() returns [0, pi] */
						ngle = r2d(acos(dotp(x, y)));
						/* spin bin -> degrees, centred as required */
						/* Ha- not off NEP so we need a static function */
						ngle2 = getspinbin_internal(x, y, z) * 6.;
				    		/* - binctrlong; NOT needed since z in ngle calc
						 * takes care of it.
						 */
						while (ngle2 < 0.)
							ngle2 += 360.;
						while (ngle2 > 360.)
							ngle2 -= 360.;
						if (healn == 0) {
							bn = ngle / latwid;
							/* Flip so we are counting UP (biggest dot
							 * product ==> index zero)
							 */
							bn = nhlat - 1 - bn;
							if (bn < 0) /* exactly 180 deg off N pole */
								bn = 0;
							bn2 = ngle2 / longwid;
							idx = bn * nhlng + bn2;
						} else if (healn > 0)
							idx = healpix_ndx(d2r(90 - ngle),
							    d2r(ngle2), healn);
						else
							idx = abrate_ndx(d2r(90 - ngle),
							    d2r(ngle2), -healn);

						for (k = 0; k < HI_ENERGIES; k++) {
							/* noneg has to be interpreted much later */
							extraconds = (ramm == 0 ||
							     (ramm == 1 && lin <= rwcut + 1) ||
							     (ramm == -1 && lin >= rwcut) ||
							     lin == 1) &&
							    (crappy == 0 || linexp[k] > 400);
							if (extraconds && linexp[k] > 0) {
								if (bloat < 0.) {
									/* populate one bin; easy
									 * enough to do here.
									 */
	if (binexp[k][idx] <= 0) {
		bincts[k][idx] = lincts[k];
		binexp[k][idx] = linexp[k];
		binbg[k][idx]  = linbg[k] * linexp[k];
		// binbgu[k][idx] = linbgunc[k] * linbgunc[k] * linexp[k] * linexp[k];
	} else {
		bincts[k][idx] += lincts[k];
		binexp[k][idx] += linexp[k];
		binbg[k][idx]  += linbg[k] * linexp[k];
		// binbgu[k][idx] += linbgunc[k] * linbgunc[k] * linexp[k] * linexp[k];
	}
								} else {
	if (interp == 1) {
		/*  "ISOC" smoothing!
		 * Not gonna do it yet.  This is too silly.
		 */
		     }
     /* Fill in other options here once they exit, for
      * interpolating/bloating
      */
                                        }
                                   }
                              }
                         }
				} /* Not '#' */
			}
			fclose(fp);
		}
	} /* End of reading in data */
	if (verbos > 1)
		printf("\n");
	/* Time to convert to binsig and bindat, from bincts, binexps, binbg */
	/* Beware ms vs seconds */
	for (k = 0; k < HI_ENERGIES; k++)
		for (idx = 0; idx < bign ; idx++)
			if (binexp[k][idx] > 0.) {
				bindat[k][idx] = (1000. * bincts[k][idx] - binbg[k][idx]) /
				    (1.0 * binexp[k][idx]);
				/* binsig is doable, but we need to treat the bg unc as
				 * SYSTEMATIC along each arc.  Hmm.
				 */
#if 0
				/* XXX FIX based on above comment */
				binsig[k][idx] = sqrt(bincts[k][idx]*1e6 + binbgu[k][idx]) /
				    (1.0 * binexp[k][idx]);
#endif
				if (noneg && bindat[k][idx] < 0.)
					bindat[k][idx] = 0.;
			} else {
				bindat[k][idx] = 0.;
				binsig[k][idx] = -1.;
			}
	for (k = 0; k < HI_ENERGIES; k++) {
		free(binbg[k]);
		free(binexp[k]);
		free(bincts[k]);
		if (returnuncs) {
			dsets[whch].esa[k] = binsig[k];
			free(bindat[k]);
		} else {
			dsets[whch].esa[k] = bindat[k];
			free(binsig[k]);
		}
	}
	/* Fill up some of the fields that are hard to do elsewhere */
	dsets[whch].nbinlat = nhlat;
	dsets[whch].nbinlng = nhlng;
	dsets[whch].firstorbit = startorb;
	dsets[whch].firstarc = startarc;
	dsets[whch].lastorbit = endorb;
	dsets[whch].lastarc = endarc;
	dsets[whch].healn = healn;
	if (dsets[whch].healn > 0)
		jlim = 12 * dsets[whch].healn * dsets[whch].healn;
	else if (dsets[whch].healn < 0)
		jlim = n_abrate(-healn);
	else
		jlim = dsets[whch].nbinlat * dsets[whch].nbinlng;
	for (j = 0; j < HI_ENERGIES; j++) {
		dsets[whch].filled[j] = 1;
		dsets[whch].min[j] = 0.;
		dsets[whch].max[j] = max_arr(dsets[whch].esa[j], jlim);
	}
	/* Rotation matrix; use standard routine, meaning we have to redo
	 * what we had to begin with, just in case.  Bleah.
	 * Our framework here is "where to put the N pole" (nplat, nplong)
	 * and then where to plunk the centre longitude.  That's equivalent (?)
	 * to rotating by nplong around z and then rotating by (nplat - 90)
	 * around y.
	 */
	build_rotation(nplong, 90. - nplat, 0., 0, NULL);
	copy_currotm(dsets[whch].initrot);
	/* We really want the inverse matrix though; it's the transpose. */
	/* XXX ?  First thing is that we fail the N pole straight up bit. */
	for (i = 0; i < 3; i++)
		for (j = i+1; j < 3; j++) {
			ngle = dsets[whch].initrot[i][j];
			dsets[whch].initrot[i][j] = dsets[whch].initrot[j][i];
			dsets[whch].initrot[j][i] = ngle;
		}
	build_rotation(ctrlng, ctrlat, ctrrot, 0, dsets[whch].initrot);

	return(0);
}

int
build_hist_6deg(int startorb, int startarc, int endorb, int endarc, int verbos,
    int returnuncs, int whch)
{
	double *bindat[6], *binsig[6];
	double x[3], y[3], z[3], ngle, ngle2;
	FILE *fp;
	char frob[2048], bozz[20], bazz[2048], *p;
	int i, j, k, rwcut, jlim;
	int ii, jj;
	int bn, bn2, idx, lin, extraconds;
	double linlong, linlat, lindat[HI_ENERGIES], linsig[HI_ENERGIES];
	double latcn, lngcn, wtlat, wtlng, foo;
	int bign;

	if (get_arcs_per_orbit(startorb) < 1 || get_arcs_per_orbit(endorb) < 1) {
		printf("Can't build orbits without inertial_pointing.\n");
		return(-1);
	}
	/* Success is guaranteed below here, so we can free some data. */
	free(dsets[whch].name);
	dsets[whch].name = NULL;
	for (i = 0; i < HI_ENERGIES; i++)
		if (dsets[whch].filled[i]) {
			free(dsets[whch].esa[i]);
			dsets[whch].esa[i] = NULL;
			dsets[whch].filled[i] = 0;
		}
	dsets[whch].firstorbit = dsets[whch].lastorbit = 0;
	dsets[whch].healn = 0;
	if (verbos > 5)
		print_histspecs(whch);
	if (healn == 0)
		bign = nhlat * nhlng;
	else if (healn > 0)
		bign = 12 * healn * healn;
	else
		bign = n_abrate(-healn);
	for (i = 0; i < HI_ENERGIES; i++)
		if (!(bindat[i] = (double *)calloc(bign, sizeof(double))) ||
		    !(binsig[i] = (double *)calloc(bign, sizeof(double))))
			err(1, "calloc()");
	for (j = 0; j < HI_ENERGIES; j++)
		for (i = 0; i < bign; i++) {
			bindat[j][i] = 0.;
			binsig[j][i] = -1.;
		}
	rd2vec(x, nplong, nplat);
	rd2vec(z, binctrlong, 0.);

	for (i = startorb; i <= endorb; i++) {
		for (j = (i == startorb ? startarc:0);
		    j <= (i == endorb ? endarc:(get_arcs_per_orbit(i) - 1));
		    j++) {
			strlcpy(frob, dsets[whch].fnamebase, sizeof(frob));
			if (get_arcs_per_orbit(i) == 1)
				snprintf(bozz, sizeof(bozz), "%04d", i);
			else
				snprintf(bozz, sizeof(bozz), "%04d%c", i, 'a' + j);
			strlcat(frob, bozz, sizeof(frob));
			strlcat(frob, dsets[whch].fnameext, sizeof(frob));
			if ((fp = fopen(frob, "r")) == NULL) {
				if (verbos > 1)
					printf("\n");
				if (verbos >= 0)
					printf("no %s found; skipping\n", frob);
				continue;
			}
			if (verbos > 1)
				printf("%s ", bozz);
			lin = 0;
			/* By default cut ram/wake after 30th entry */
			rwcut = 30;
			while (fgets(bazz, sizeof(bazz), fp)) {
				if (bazz[0] != '#') {
					lin++;
					/* XXX Here, sscanf() requires HI_ENERGIES to be 6 */
					if (sscanf(bazz,
					    "%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf",
					    &linlat, &linlong, lindat, linsig, lindat+1,
					    linsig+1, lindat+2, linsig+2, lindat+3, linsig+3,
					    lindat+4, linsig+4, lindat+5, linsig+5) != 14)
						warnx("sscanf %s line %d", bozz, lin);
					else {
						rd2vec(y, linlong, linlat);
						/* acos() returns [0, pi] */
						ngle = r2d(acos(dotp(x, y)));
						/* spin bin -> degrees, centred as required */
						/* Ha- not off NEP so we need a static function */
						ngle2 = getspinbin_internal(x, y, z) * 6.;
				    		/* - binctrlong; NOT needed since z in ngle calc
						 * takes care of it.
						 */
						while (ngle2 < 0.)
							ngle2 += 360.;
						while (ngle2 > 360.)
							ngle2 -= 360.;
						if (healn == 0) {
							bn = ngle / latwid;
							/* Flip so we are counting UP (biggest dot
							 * product ==> index zero)
							 */
							bn = nhlat - 1 - bn;
							if (bn < 0) /* exactly 180 deg off N pole */
								bn = 0;
							bn2 = ngle2 / longwid;
							idx = bn * nhlng + bn2;
						} else if (healn > 0)
							idx = healpix_ndx(d2r(90 - ngle),
							    d2r(ngle2), healn);
						else
							idx = abrate_ndx(d2r(90 - ngle),
							    d2r(ngle2), -healn);

						for (k = 0; k < HI_ENERGIES; k++) {
							extraconds = (noneg || lindat[k] > 0.) &&
							    (ramm == 0 ||
							     (ramm == 1 && lin <= rwcut + 1) ||
							     (ramm == -1 && lin >= rwcut) ||
							     lin == 1) &&
							    (crappy == 0 || linsig[k] > 0.004);
							if (extraconds && linsig[k] > 0.) {
								if (bloat < 0.) {
populate_one_bin(idx, binsig[k], bindat[k], statsum, lindat[k], linsig[k]);
								} else {
	if (interp == 1) {
		/*  "ISOC" smoothing!
		 * We want to funny-weight everything whose bin centre is
		 * within bloat degrees of lat and long of our particular
		 * piece of data.  Follow Bob DeMajistre's belief of what
		 * the ISOC does, although we utterly lose the uncertainties
		 * when we do this and the ISOC somehow does not.
		 *
		 * We're in long/lat angles relative to our map coords here.
		 * Note that this smoothing is spatially inhomogeneous and
		 * depends on where you put the "N pole" of your map.  Truly
		 * this is an awful and wrong kludge that I'm ashamed to put
		 * into my code, except it ought to make things look like
		 * ISOC maps.
		 */
		if (healn == 0) {
			/* Not the most efficient way to do it, but the easiest to
			 * code.  Note that our bins have to end at the poles, not
			 * sweep across them.  This would be trivial except the
			 * closest bin may be across the pole or the 0 longitude
			 * line, and by ISOC standards we can't simply measure the
			 * angle between them, we need separate lat & long
			 * differences.
			 */
			for (ii = 0; ii < nhlat; ii++) {
				latcn = (nhlat - ii - 0.5) / nhlat * 180.;
				for (jj = 0; jj < nhlng; jj++) {
					lngcn = (jj + 0.5) / nhlng * 360.;
					if (ngle >= bloat && ngle + bloat <= 180.)
						wtlat = 1. - fabs(latcn - ngle) / bloat;
					else {
						/* which side are we on?  If longitude
						 * doesn't approximately line up, we really
						 * don't care about the answer.
						 */
						foo = fabs(lngcn - ngle2);
						if (foo < 90. || foo > 270.)
							wtlat = 1. - fabs(latcn - ngle) / bloat;
						else {
							if (ngle < bloat)
								wtlat = 1. - (latcn + ngle) / bloat;
							else
								wtlat = 1. - (360. - (latcn + ngle))
								    / bloat;
							lngcn += 180.;
							while (lngcn > 360.)
								lngcn -= 360.;
						}
					}
					if (wtlat > 0.) {
						foo = lngcn - ngle2 + 360.;
						while (foo > 180.)
							foo -= 360.;
						wtlng = 1. - fabs(foo) / bloat;
						if (wtlng > 0.)
populate_one_bin(ii * nhlng + jj, binsig[k], bindat[k], statsum, lindat[k],
    linsig[k]/sqrt(wtlng * wtlat));
					}
				}
			}
		} else {
			/* XXX TODO:  nearest neighbour healpix/Abrate is to be done when
			 * it's actually needed, not before.
			 */
			/* XXX populate_one_bin() above used to have
			 * 1./sqrt(wtlng * wtlat), not linsig[k]/sqrt().
			 * To some degree we want to weight on TIME observed, not
			 * Poisson of counts.
			 */
		}
	}
	/* Fill in other options here once they exit, for
	 * interpolating/bloating
	 */
								}
							}
						}
					}
				} else { /* one header comment is worth parsing */
					if ((p = strstr(bazz, " bins in spin plane"))) {
						p--;
						while (p > bazz && isdigit(*p))
							p--;
						if (sscanf(p, "%d", &rwcut) == 1 &&
						    rwcut % 2 == 0)
							rwcut /= 2;
					}
				}
			}
			fclose(fp);
		}
	} /* End of reading in data */
	if (verbos > 1)
		printf("\n");
	if (statsum == -1) {
		for (k = 0; k < HI_ENERGIES; k++)
			for (i = 0; i < nhlat * nhlng; i++)
				if (binsig[k][i] > 0.)
					bindat[k][i] = pow(bindat[k][i], 1./binsig[k][i]);
	} else if (statsum == 0) {
		for (k = 0; k < HI_ENERGIES; k++)
			for (i = 0; i < nhlat * nhlng; i++)
				if (binsig[k][i] > 0.)
					bindat[k][i] /= binsig[k][i];
	}
#ifdef BS_COUNTS
	else if (statsum == 1) {
		/* XXX hack for Jamey - how many counts with Poisson stats is
		 * this equal to?  So we have bindat and binsig and we just
		 * say if unc is sqrt n then n must be (bindat/binsig) squared.
		 * And it's just for dumping files.
		 */
		for (k = 0; k < HI_ENERGIES; k++)
			for (i = 0; i < nhlat * nhlng; i++)
				if (binsig[k][i] > 0.)
					bindat[k][i] = bindat[k][i] * bindat[k][i] /
					    binsig[k][i] / binsig[k][i];
		printf("gark.\n");
	}
#endif
	if (returnuncs) {
		for (k = 0; k < HI_ENERGIES; k++) {
			free(bindat[k]);
			dsets[whch].esa[k] = binsig[k];
		}
	} else {
		for (k = 0; k < HI_ENERGIES; k++) {
			free(binsig[k]);
			dsets[whch].esa[k] = bindat[k];
		}
	}
	/* Fill up some of the fields that are hard to do elsewhere */
	dsets[whch].nbinlat = nhlat;
	dsets[whch].nbinlng = nhlng;
	dsets[whch].firstorbit = startorb;
	dsets[whch].firstarc = startarc;
	dsets[whch].lastorbit = endorb;
	dsets[whch].lastarc = endarc;
	dsets[whch].healn = healn;
	if (dsets[whch].healn > 0)
		jlim = 12 * dsets[whch].healn * dsets[whch].healn;
	else if (dsets[whch].healn < 0)
		jlim = n_abrate(-healn);
	else
		jlim = dsets[whch].nbinlat * dsets[whch].nbinlng;
	for (j = 0; j < HI_ENERGIES; j++) {
		dsets[whch].filled[j] = 1;
		dsets[whch].min[j] = 0.;
		dsets[whch].max[j] = max_arr(dsets[whch].esa[j], jlim);
	}
	/* Rotation matrix; use standard routine, meaning we have to redo
	 * what we had to begin with, just in case.  Bleah.
	 * Our framework here is "where to put the N pole" (nplat, nplong)
	 * and then where to plunk the centre longitude.  That's equivalent (?)
	 * to rotating by nplong around z and then rotating by (nplat - 90)
	 * around y.
	 */
	build_rotation(nplong, 90. - nplat, 0., 0, NULL);
	copy_currotm(dsets[whch].initrot);
	/* We really want the inverse matrix though; it's the transpose. */
	/* XXX ?  First thing is that we fail the N pole straight up bit. */
	for (i = 0; i < 3; i++)
		for (j = i+1; j < 3; j++) {
			ngle = dsets[whch].initrot[i][j];
			dsets[whch].initrot[i][j] = dsets[whch].initrot[j][i];
			dsets[whch].initrot[j][i] = ngle;
		}
	build_rotation(ctrlng, ctrlat, ctrrot, 0, dsets[whch].initrot);

	return(0);
}

/* Just the ISOCfu version from histogram2d, unless HEALpix. */
int
dump_currentdata(char *ofbase, int whch)
{
	int i, j, k, jlim;
	char frob[2048];
	time_t isoct;
	double minner, maxxer;
	FILE *fp;

	for (i = 0; i < HI_ENERGIES; i++) {
		if (dsets[whch].filled[i] == 0)
			continue;
		if (ofbase == NULL)
			fp = stdout;
		else {
			if (snprintf(frob, sizeof(frob), "%s%d", ofbase, i + 1) >=
			    (int) sizeof(frob) || (fp = fopen(frob, "w")) == NULL)
				fp = stdout;
		}
		minner = dsets[whch].esa[i][0];
		maxxer = 0.;
		if (dsets[whch].healn > 0)
			jlim = 12 * dsets[whch].healn * dsets[whch].healn;
		else if (dsets[whch].healn < 0)
			jlim = n_abrate(-healn);
		else
			jlim = dsets[whch].nbinlat * dsets[whch].nbinlng;
		for (j = 0; j < jlim; j++) {
			if (minner > dsets[whch].esa[i][j])
				minner = dsets[whch].esa[i][j];
			if (maxxer < dsets[whch].esa[i][j])
				maxxer = dsets[whch].esa[i][j];
		}
		isoct = time(NULL);
		/* Will lie if ramm has changed since we built this array. */
		fprintf(fp, "# 27:%dx%d:-5.0x-5.0:7x6:0:7\n\
#\n# %s#\n# xmap\n#\n# Simulated flux_translate header\n#\n\
#  -0 dec (addresses incr. downwards)\n\
#  -1 ra (addresses incr. left->right)\n#\n\
#  h_min=%.4lf h_max=%.4lf h_title='%s'\n\
#  min_0=-90 max_0=90 num_0=%d title_0='Dec (deg)'\n\
#  min_1=0 max_1=360 num_1=%d title_1='R.A. (deg)'\n\
#  desc=\"'possibly count rate (/s)'\"\n#  e_nominal='ESA %d'\n\
# skyframe=ECLIPJ2000 posframe=J2000\n#\n# noram='%d' nowake='%d'\n\
# non-ISOC notes: initrot TBD XXX; %s\n\
# orbits %04d%c - %04d%c\n\
###\n",
dsets[whch].healn?dsets[whch].healn:dsets[whch].nbinlat,
dsets[whch].healn?dsets[whch].healn:dsets[whch].nbinlng,
ctime(&isoct), minner, maxxer,
dsets[whch].name, dsets[whch].nbinlat, dsets[whch].nbinlng, i+1,
(ramm == -1), (ramm == 1),
(dsets[whch].healn > 0)?"HEALpix!":((dsets[whch].healn < 0)?"Abratepix!":""),
dsets[whch].firstorbit, dsets[whch].firstarc >= 0? 'a'+dsets[whch].firstarc:'.',
dsets[whch].lastorbit, dsets[whch].lastarc >= 0? 'a'+dsets[whch].lastarc:'.');
		if (dsets[whch].healn == 0) {
			for (j = 0; j < dsets[whch].nbinlat; j++) {
				for (k = 0; k < dsets[whch].nbinlng; k++)
					fprintf(fp, "\t%lf",
					    dsets[whch].esa[i][j*dsets[whch].nbinlng + k]);
				fprintf(fp, "\n");
			}
		} else if (dsets[whch].healn > 0) {
			for (j = 0; j < 12 * dsets[whch].healn * dsets[whch].healn; j++)
				fprintf(fp, "\t%lf", dsets[whch].esa[i][j]);
			fprintf(fp, "\n");
		} else {
			for (j = 0; j < n_abrate(-healn); j++)
				fprintf(fp, "\t%lf", dsets[whch].esa[i][j]);
			fprintf(fp, "\n");
		}
		if (fp != stdout)
			fclose(fp);
		else
			fprintf(fp, "\n");
	}
	return(0);
}


/* We need whch's datatype already set.  0 is a fine default... */
int
build_hist(int startorb, int startarc, int endorb, int endarc,
    int verbos, int returnuncs, int whch)
{
	int rv;

	if (dsets[whch].fnamebase == NULL)
		dsets[whch].fnamebase = strdup(fnamebase);
	if (dsets[whch].fnameext == NULL)
		dsets[whch].fnameext = strdup(fnameext);
	if (!(dsets[whch].fnameext) || !(dsets[whch].fnamebase))
		err(1, NULL);
	switch(dsets[whch].datatype) {
	case 1: /* unc maps, 6_deg */
		rv = -1;
		break;
	case 2: /* 1_deg files! */
		rv = build_hist_1deg(startorb, startarc, endorb, endarc,
		    verbos, returnuncs, whch);
		break;
	case 3: /* exp maps, 1_deg */
		rv = -1;
		break;
	case 4: /* unc maps, 1_deg */
		rv = -1;
		break;
	case 0:
	default:
		rv = build_hist_6deg(startorb, startarc, endorb, endarc,
		    verbos, returnuncs, whch);
		break;
	}
	return(rv);
}
