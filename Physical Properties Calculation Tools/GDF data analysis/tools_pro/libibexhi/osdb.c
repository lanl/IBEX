/*	$Id: osdb.c,v 1.35 2020/02/20 04:12:34 pjanzen Exp $	*/
/* Handle ISOC ASCII orbital spin bin database:  goal is to be able to
 * process DEs locally.  Copy over a bunch of Geoff's code, but don't
 * exactly duplicate:  I don't want OSB stuff spilling globally, and I
 * think he's possibly limited the number of spins possible per orbit
 * enough to cause grief.
 */
#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: osdb.c,v 1.35 2020/02/20 04:12:34 pjanzen Exp $";

static int n_osd = 0;
static double *osdb = NULL;
static int n_osd2 = 0;
static double *osdb2 = NULL;

/* Next sequence is defined in ISOC's me_util.h.
 * Format is
 * # comment
 * pulse orbit spin period [# comment]
 *
 * There are (nominally) no more than 8 * 24 * 60 * 4 = 46080
 * spin pulses per orbit, and the spin index is at most 16 bits.
 */
/* #define OSB_DB_SCAN_FMT      "%lf %hu %hu %f" */
/* sigh, just ints here. */
#define OSB_DB_SCAN_FMT      "%lf %d %d %lf"
#define OSB_DB_PRINT_FMT     "%.4f %5u %5u %.6f\n"

/* From me_misc.h */
/* basic osb/gps stuff */
#define ME_TIME_ORBIT_BYTE_GPS  0x41
#define ME_TIME_ORBIT_INVALID   0xF800
#define ME_TIME_STAMP_INVALID   0xF000
#if 0
#define ME_TIME_SPIN_INVALID  0xFE0F
#endif
#define ME_TIME_SPIN_INVALID    0x0000
#define ME_TIME_BIN_INVALID     0x40
#define ME_TIME_GPS_INVALID     (-1.0565900069394103e+270)/*F8000000F0004080*/
#if 0
#define ME_TIME_GPS_INVALID   (-6.5536018392e+268)/*F800FE0FF0004080*/
#endif
#define ME_TIME_DAWN_OF_TIME     850000000.0
#define ME_TIME_END_OF_TIME     1500000000.0


/* A bit different from Geoff's setup.  Return 0 on success, line number on
 * failure, negative if malloc pooched or file couldn't be opened.  Check
 * for ordering as we go, and confirm that pulse + period = next pulse
 * (within error), that stuff is monotonic with a proper single orbit step.
 *
 * I just populate an array of double for the pulses, where
 * array element == spin, because everything else can calculate off that.
 *
 * Fascinatingly, the osbd2a files seem to be buggy in that the period they
 * give actually applies to the PRECEDING pulses's period.  That is, for a
 * given line <n>, pulse <n-1> happened at t_n - period_n.  The first
 * period listed is copied from the otdba.  For the otdba, pulse <n+1>
 * happens at t_n + period_n.  Perhaps this is for some reason intentional.
 *    For the time being I turn off checking on the osbd2a file via prec.
 * It's a sanity check - I calculated my periods by comparing pulse times.
 */
static int
internal_init_OSdb(char *file, double **arr, int *arrn, double prec)
{
	gzFile fp;
	double pulse, period;
	double lastperiod;
	int spin, orbit, nmax, linn;
	int i;
	char lin[128];
	double *newp;

	if ((fp = gzopen(file, "r")) == NULL)
		return(-1);
	if (*arr)
		free(*arr);
	*arrn = 0;
	linn = 0;
	nmax = 50000;
	lastperiod = 0.0;	/* shush compiler */
	if ((*arr = calloc(nmax, sizeof(double))) == NULL) {
		gzclose(fp);
		return(-2);
	}
	/* copy gbc code */
	while (gzgets(fp, lin, sizeof(lin))) {
		linn++;
		/* skip # comment lines */
		if (lin[0] == '#' || lin[0] == '\n')
			continue;
		/* pulse orbit spin period [# comment] */
		if (4 != sscanf(lin, OSB_DB_SCAN_FMT, &pulse, &orbit, &spin,
		    &period) || pulse <= ME_TIME_DAWN_OF_TIME ||
		    pulse >= ME_TIME_END_OF_TIME ||
			/* spins start at 0 and go up by one each line, except
			 * for gaps or duplicates.
			 */
		    spin < *arrn - 1 || period < 0.0) {
			gzclose(fp);
			return(linn);
		}
		/* If the sequencing is right but the period is wrong, life
 		 * sucks, but not enough to return. */
		if ((*arrn > 0) && (spin == *arrn) &&
		    fabs((*arr)[*arrn - 1] + lastperiod - pulse) > prec) {
			errpprintf(0, "OSBdb %s:  bad period spin preceding %d.\n",
			    file, spin);
		}
		lastperiod = period;
		if (spin >= nmax) {
			nmax += ((10000 < spin - nmax) ? (spin - nmax + 1):10000);
			/* sigh... if only recalloc() were common.. */
			if ((newp = realloc(*arr, nmax * sizeof(double))) == NULL) {
				free(*arr);
				*arrn = 0;
				gzclose(fp);
				return(-2);
			}
			*arr = newp;
		}
		/* Duplicates can be an issue.  If we find them, complain,
		 * ignore, and don't return.
		 */
		if (spin == *arrn - 1) {
			errpprintf(0, "OSBdb %s:  ignoring duplicate spin %d.\n",
			    file, spin);
			lastperiod += pulse - (*arr)[*arrn-1];
		} else {
			/* make a spin gap less than a failure. */
			if (spin != *arrn) {
				errpprintf(0, "OSBdb %s:  filled gap in spins %d - %d.\n",
				    file, *arrn, spin - 1);
				if (*arrn == 0) {
					(*arr)[*arrn] = ME_TIME_DAWN_OF_TIME + 10.;
					(*arrn)++;
				}
				period = (pulse - (*arr)[*arrn - 1])/(spin - *arrn + 1);
				for (i = *arrn; i < spin; i++) {
					(*arr)[*arrn] = (*arr)[*arrn - 1] + period;
					(*arrn)++;
				}
			}
			(*arr)[*arrn] = pulse;
			(*arrn)++;
		}
	}
	gzclose(fp);
	return(0);
}


/* For despinning, we need two of these.  1 is the original, 2 is despun. */
int
initialize_OSBdb(char *file)
{
	return(internal_init_OSdb(file, &osdb, &n_osd, 0.0002));
}

int
initialize_OSBdb2(char *file)
{
	return(internal_init_OSdb(file, &osdb2, &n_osd2, 50.));
}

void
clear_OSBdbs()
{
	if (osdb)
		free(osdb);
	if (osdb2)
		free(osdb2);
	osdb = osdb2 = NULL;
	n_osd = n_osd2 = 0;
}

int
is_OSBdb_initialized()
{
	int i;

	i = 0;
	if (n_osd > 0) {
		i++;
		if (n_osd2 > 0)
			i++;
	}
	return(i);
}

/* Basic lookup:  get spin number and period at a given MET.  -1 means
 * outside current database range.
 */
static int32_t
get_OSdbint(double smet, double *period, double *arr, int arrn)
{
	int i, l, r;
	double t;

	if (arrn == 0 || smet < arr[0] || smet > arr[arrn - 1])
		return(-1);
	/* Want first element smaller than or equal to smet; binary search. */
	l = 0;
	r = arrn;
	while (l <= r) {
		i = (l + r) / 2;
		t = smet - arr[i];
		if (t < 0.)
			r = i - 1;
		else
			l = i + 1;
	}
	*period = arr[l] - arr[r];
	return(r);
}

int32_t
get_OSBdbstuff(double smet, double *period)
{
	return(get_OSdbint(smet, period, osdb, n_osd));
}

int32_t
get_OSBdb2stuff(double smet, double *period)
{
	return(get_OSdbint(smet, period, osdb2, n_osd2));
}

double
get_metfromspin(int spin)
{
	if (spin >= 0 && spin < n_osd)
		return(osdb[spin]);
	else
		return(-1.);
}

double
get_metfromspin2(int spin)
{
	if (spin >= 0 && spin < n_osd2)
		return(osdb2[spin]);
	else
		return(-1.);
}

double
get_perfromspin(int spin)
{
	if (spin >= 0 && spin + 1 < n_osd)
		return(osdb[spin + 1] - osdb[spin]);
	else
		return(-1.);
}

double
get_perfromspin2(int spin)
{
	if (spin >= 0 && spin + 1 < n_osd2)
		return(osdb2[spin + 1] - osdb2[spin]);
	else
		return(-1.);
}

int
get_lastspin()
{
	return(n_osd - 1);
}

int
get_lastspin2()
{
	return(n_osd2 - 1);
}

/* Basically, phase is simple.  It's 0 - 1 (or -1. if things don't make
 * sense) and you get it by taking the timestamp, multiplying by 4.2 ms
 * (the clock tick), and dividing by the relevant period.
 *
 * It's more complicated if you need to despin.  Then you have to convert
 * spin + timestamp into a MET using the first OSB database, and then
 * convert the MET into a phase using the second database.
 */
double
get_OSBdbphase(int spin, int timestamp)
{
	double phase;
	double period;

	if (spin < 0 || spin >= n_osd - 1)
		return(-1.);
	period = osdb[spin+1] - osdb[spin];
	phase = (timestamp * ME_TIME_SEC_PER_TICK) / period;
	if (phase > 1.002)
		return(-1.);
	/* Next line is a gbc-ism */
	if (phase > 0.99994) phase = 0.99994;
	return(phase);
}


double
get_OSBdbphase2(int spin, int timestamp, int *spin2)
{
	double phase, metc, period;

	if (spin < 0 || spin >= n_osd - 1)
		return(-1.);
	metc = osdb[spin] + timestamp * ME_TIME_SEC_PER_TICK;
	*spin2 = get_OSBdb2stuff(metc, &period);
	if (*spin2 < 0)
		return(-1);
	phase = (metc - osdb2[*spin2])/period;
	if (phase < 0.00000) phase = 0.00000;
	if (phase > 0.99994) phase = 0.99994;
	return(phase);
}


/* 0 on success (i.e., stuff is initialized).  For a given time range,
 * return two numbers from 0 to 1 indicating the angle range over which the
 * data was spun.  The point is to be able to "anti-spin up" culls to allow
 * removal of bright Earth signal from spun histogram good time data in
 * products other than direct events.  For this purpose, assume monotonic
 * behaviour so we need only check the two endpoints.
 *
 * goesthroughzero is set to nonzero if spin phase 0 is included in the
 * range; otherwise, you don't know on which side of minphase-maxphase the
 * data actually sits.
 *
 * This may fail on washing-machined stuff which rotates by more than a
 * full turn during a histogram bin collection, although I try to spot that.
 */
int
get_OSBhowspun(uint32_t met1, uint32_t met2, double *minphase, double *maxphase,
    int *goesthroughzero)
{
	double p1, p2;
	int s1, s2;
	int n1, n2;
	double ph1, ph2, tmp;

	s1 = get_OSBdbstuff((double)met1, &p1);
	s2 = get_OSBdb2stuff((double)met1, &p2);
	n1 = s1 - s2;
	if (s1 >= 0 && s2 >= 0) {
		tmp = osdb[s1];
		while (tmp < osdb2[s2]) {
			tmp += p1;
			n1++;
		}
		ph1 = (tmp - osdb2[s2]) / p2;
		/* ph1 can (barely) exceed 1 if the two timings don't really match. */
		while (ph1 > 1.) {
			ph1 -= 1.;
			n1--;
		}
	} else {
		if (s1 >= 0) {	/* Not spun; we did read an osdba, so we are
					 * initialized to some degree.
					 */
			*maxphase = *minphase = 0.;
			*goesthroughzero = 0;
			return(0);
		}
		return(1);
	}
	s1 = get_OSBdbstuff((double)met2, &p1);
	s2 = get_OSBdb2stuff((double)met2, &p2);
	n2 = s1 - s2;
	if (s1 >= 0 && s2 >= 0) {
		tmp = osdb[s1];
		while (tmp < osdb2[s2]) {
			tmp += p1;
			n2++;
		}
		ph2 = (tmp - osdb2[s2]) / p2;
		/* ph2 can (barely) exceed 1 if the two timings don't really match. */
		while (ph2 > 1.) {
			ph2 -= 1.;
			n2--;
		}
	} else
		return(2);
	*goesthroughzero = (n1 != n2);
	if (ph2 < ph1) {
		*minphase = ph2;
		*maxphase = ph1;
	} else {
		*minphase = ph1;
		*maxphase = ph2;
	}
	/* Catch washing machines */
	if (abs(n1 - n2) > 1) {
		*minphase = 0.;
		*maxphase = 1.;
		*goesthroughzero = 0;
	}

	return(0);
}


/* 0.5 - 1 if valid, negative on error */
double
get_flyback_correction_bybin(int hbtype, int n, int esa, int angb)
{
	double mn, mx;
	int tz, status, firstbin, lastbin;
	double fbedge1, fbedge2, tmp1, tmp2;
	double nonflybackfraction;

	if (esa > 0)
		return(1.);
	if (esa < 0 || hbtype < 0 || hbtype >= BIN_TYPES ||
	    n < 0 || hbs[hbtype].n <= n || angb < 0 || angb >= HI_AZ_BINS)
		return(-2.);
	if (n == 0)
		n = 1;
	status = get_OSBhowspun(hbs[hbtype].met[n-1], hbs[hbtype].met[n],
	    &mn, &mx, &tz);
	if (status != 0)
		return(-1.);
	if (tz)
		if (mx > mn) {	/* as expected */
			tmp1 = mn;
			mn = mx;
			mx = 1. + tmp1;
		}
	/* Exposure time correction will happen for anything now in the
	 * phase range [-1/(2*HI_AZ_BINS) to 1/(2*HI_AZ_BINS)].
	 * This is copied from get_spun_flyback_correction() below.
	 */
	firstbin = (int)(-0.5 + mn * HI_AZ_BINS + HI_AZ_BINS) % HI_AZ_BINS;
	lastbin = (int)(0.5 + mx * HI_AZ_BINS + HI_AZ_BINS + 0.49999) %
	    HI_AZ_BINS;
	while (lastbin < firstbin)
		lastbin += HI_AZ_BINS;
	fbedge1 = -0.5 + mn * HI_AZ_BINS;
	while (fbedge1 + 1. < firstbin)
		fbedge1 += HI_AZ_BINS;
	fbedge2 = mx * HI_AZ_BINS + 0.5;
	while (fbedge2 + 1. < lastbin)
		fbedge2 += HI_AZ_BINS;
	while (angb + 0.5 < fbedge1)
		angb += HI_AZ_BINS;
	tmp1 = fbedge1 - (-0.5 + angb);
	if (tmp1 < 0.) /* i.e., flyback bin starts first */
		tmp1 = 0.;
	tmp2 = -fbedge2 + ( 0.5 + angb);
	if (tmp2 < 0.)
		tmp2 = 0.;
	nonflybackfraction = tmp1 + tmp2;
	if (nonflybackfraction > 1.)
		nonflybackfraction = 1.;
	return(nonflybackfraction + 0.5 * (1. - nonflybackfraction));
}


/* Allocate and return a 60-spinbin exposure time correction factor for
 * ESA 1's flyback bin.  That angle gets only half the exposure time of
 * everywhere else.  Assuming spun data, that "half" walks around a bit.
 */
int
get_spun_flyback_correction(double **fbfac, int hbtype, int whichcull)
{
	int i, j, tz, status;
	int firstbin, lastbin;
	double fbedge1, fbedge2;
	double mn, mx, tmp1, tmp2, nonflybackfraction;
	int ngts[HI_AZ_BINS];

	if ((*fbfac = calloc(HI_AZ_BINS, sizeof(double))) == NULL)
		return(-1);
	for (i = 0; i < HI_AZ_BINS; i++) {
		ngts[i] = 0;
		(*fbfac)[i] = 0.;
	}
	/* We care only about ESA 1 and only for good times and angles. */
	status = 0;
	for (i = 1; i < hbs[hbtype].n; i++) {
		status = get_OSBhowspun(hbs[hbtype].met[i-1], hbs[hbtype].met[i],
		    &mn, &mx, &tz);
		if (status != 0) {
			free(*fbfac);
			*fbfac = NULL;
			return(status);
		}
		if (tz)
			if (mx > mn) {	/* as expected */
				tmp1 = mn;
				mn = mx;
				mx = 1. + tmp1;
			}
		/* Exposure time correction will happen for anything now in the
		 * phase range [-1/(2*HI_AZ_BINS) to 1/(2*HI_AZ_BINS)].
		 */
		firstbin = (int)(-0.5 + mn * HI_AZ_BINS + HI_AZ_BINS) % HI_AZ_BINS;
		lastbin = (int)(0.5 + mx * HI_AZ_BINS + HI_AZ_BINS + 0.49999) %
		    HI_AZ_BINS;
		while (lastbin < firstbin)
			lastbin += HI_AZ_BINS;
		fbedge1 = -0.5 + mn * HI_AZ_BINS;
		while (fbedge1 + 1. < firstbin)
			fbedge1 += HI_AZ_BINS;
		fbedge2 = mx * HI_AZ_BINS + 0.5;
		while (fbedge2 + 1. < lastbin)
			fbedge2 += HI_AZ_BINS;
		for (j = firstbin; j <= lastbin; j++) {
			if (safe_isincull(whichcull, hbs[hbtype].met[i], 0,
			    j % HI_AZ_BINS)) {
				/* What fraction of the flyback bin is in this bin? */
				/* compare first edge of actual bin to first edge of
				 * where flyback bin lives; also compare other edge.
				 */
				tmp1 = fbedge1 - (-0.5 + j);
				if (tmp1 < 0.) /* i.e., actual bin starts first */
					tmp1 = 0.;
				/* if (tmp1 >= 1.), then there's no overlap */
				tmp2 = -fbedge2 + ( 0.5 + j);
				if (tmp2 < 0.) /* i.e., actual bin extends past end of
							 * actual bin */
					tmp2 = 0.;
				/* if (tmp2 > 1.), then there's no overlap */
				nonflybackfraction = tmp1 + tmp2;
				if (nonflybackfraction > 1.)
					nonflybackfraction = 1.;
				(*fbfac)[j % HI_AZ_BINS] += nonflybackfraction +
				    0.5 * (1. - nonflybackfraction);
				ngts[j % HI_AZ_BINS]++;
			}
		}
		/* And include the time we're NOT in flyback but are good */
		for (j = lastbin + 1; j < firstbin + HI_AZ_BINS; j++) {
			if (safe_isincull(whichcull, hbs[hbtype].met[i], 0,
			    j % HI_AZ_BINS)) {
				(*fbfac)[j % HI_AZ_BINS] += 1.;
				ngts[j % HI_AZ_BINS]++;
			}
		}
	}
	for (i = 0; i < HI_AZ_BINS; i++) {
		if (ngts[i] == 0)
			(*fbfac)[i] = 1.;
		else
			(*fbfac)[i] /= (double)(ngts[i]);
	}
	return(status);
}


/* Take a proper cull in origcull and convert it into one in spun coordinates
 * in newcull, which is zeroed first.  Returns 0 on success.
 * Maximally open gaps.
 * Assumed that cull has been butchered to match timing with histograms
 * (no need here for safe_isincull() since we're using alltimes[] times, but
 * note that safe_isincull() will be needed to compare histogram data to
 * the spun cull if the timing actually matches the despun data instead,
 * which it inevitably will).
 */
int
spinup_cull(int origcull, int newcull)
{
	int i, j, k, l;
	int ii, jj, kk;
	int n;
	double m1, m2, tmp;
	char c;
	int status;

	status = 0;
	memset(mculls[newcull], 0, HI_AZ_BINS * nallt);
	for (i = 0; i < nallt; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
			l = 0;
			c = 0xFF ^ (1 << j);
			for (k = 0; k < HI_AZ_BINS; k++)
				if (isincull(origcull, alltimes[i], j, k)) {
					l++;
					k = HI_AZ_BINS;
				}
			if (l) {
				for (k = 0; k < HI_AZ_BINS; k++)
					mculls[newcull][i * HI_AZ_BINS + k] |= (1<<j);
				for (k = 0; k < HI_AZ_BINS; k++)
					if (!isincull(origcull, alltimes[i], j, k)) {
						l = get_OSBhowspun(
						    (i == 0?alltimes[0]:alltimes[i-1]),
						    alltimes[i], &m1, &m2, &n);
						if (l)
							status = 1;
						else {
							if (n) {
								tmp = m1;
								m1 = m2;
								m2 = tmp;
							}
							jj = (int)(k - (m2*HI_AZ_BINS) + HI_AZ_BINS)
							    % HI_AZ_BINS;
							kk = (int)(k+1 - (m1*HI_AZ_BINS)+HI_AZ_BINS)
							    % HI_AZ_BINS;
							if (kk < jj)
								kk += HI_AZ_BINS;
							for (ii = jj; ii <= kk; ii++)
mculls[newcull][i * HI_AZ_BINS + (ii % HI_AZ_BINS)] &= c;
						}
					}
			}
		}
	}
	return(status);
}

/* This is similar to the above function, but more horrible.  For ion-gun
 * effects, we need to use histograms and translate what we find into a
 * cull in "despun" coordinates.  Ion-gun signal is nominally isotropic, so
 * we want to use all "good" (despun) angles for all times when a given
 * angle is "good" to determine its cull.
 *
 * To this end, allocate and return an array of hbtype.n x 60 x 2 doubles,
 * indicating what minimum and maximum despun angle bins are present in
 * each histogram bin.  The first number is always the min, and increments
 * (mod 60) to the max.
 *
 * This is for the CENTRE of the bin. For example, a nondespun bin goes
 * from 0.0 to 0.0, not from -0.5 to +0.5.
 *
 * I guess this is a blanket invocation of get_OSBhowspun(), of sorts.
 *
 * Note that it makes the most sense to run this at the cadence of the
 * histogram you care about--not for alltimes[], which may or may not line
 * up.
 *
 * Returns zero on success.
 */
int
get_spinup_ranges(double **icky, int hbtype)
{
	int i, j, l, n;
	double m1, m2, tmp;
	int f, status;

	if (hbtype < 0 || hbtype >= BIN_TYPES)
		return(-1);
	n = hbs[hbtype].n * HI_AZ_BINS * 2;
	if ((*icky = calloc(n, sizeof(double))) == NULL)
		return(1);
	status = 0;
	for (i = 0; i < n; i++)
		(*icky)[i] = -1.;
	for (i = 0; i < hbs[hbtype].n; i++) {
		l = get_OSBhowspun((i == 0?hbs[hbtype].met[0]:hbs[hbtype].met[i-1]),
		    hbs[hbtype].met[i], &m1, &m2, &f);
		if (l)
			status = 1;
		else {
			if (f) {
				tmp = m1;
				m1 = m2;
				m2 = tmp;
			}
			for (j = 0; j < HI_AZ_BINS; j++) {
				tmp = j + m1 * HI_AZ_BINS;
				while (tmp > (double)HI_AZ_BINS)
					tmp -= (double)HI_AZ_BINS;
				(*icky)[(i * HI_AZ_BINS * 2) + j * 2] = tmp;
				tmp = j + m2 * HI_AZ_BINS;
				while (tmp > (double)HI_AZ_BINS)
					tmp -= (double)HI_AZ_BINS;
				(*icky)[(i * HI_AZ_BINS * 2) + j * 2 + 1] = tmp;
			}
		}
	}
	if (status) {
		free(*icky);
		*icky = NULL;
	}
	return(status);
}

/* A convenience function.
 * Returns 0 if it found nothing, 1 if it loaded an osbdba, and 2 if it
 * found and loaded both an osbdba and an osbd2a.
 * Looks in SPINDIR, then cwd.
 * Supplied arc is only added in if the orbit has more than one arc and the
 * arc number is >= 0 (the first arc is arc 0, inkeeping with how
 * inertial_pointing is handled).
 *
 * Also look for .gz variants.
 */
int
getdefault_osbdba(int orbit, int arc)
{
	char argone[1024], argtwo[24];
	char *q;
	int i;

	if (orbit < 0 || orbit > 9999 || arc > 20)
		return(0);
	if (get_arcs_per_orbit(orbit) > 1 && arc >= 0)
		snprintf(argtwo, sizeof(argtwo), "%c.osbdba", 'a' + arc);
	else
		snprintf(argtwo, sizeof(argtwo), ".osbdba");
	q = getenv("IBEX_SPINDIR");
	i = 1;
	if (q != NULL) {
		snprintf(argone, sizeof(argone), "%s/o%04d%s", q, orbit, argtwo);
		i = initialize_OSBdb(argone);
		if (i) {
			snprintf(argone, sizeof(argone), "%s/o%04d%s.gz", q, orbit, argtwo);
			i = initialize_OSBdb(argone);
		}
	}
	if (i) {	/* look in cwd */
		snprintf(argone, sizeof(argone), "./o%04d%s", orbit, argtwo);
		i = initialize_OSBdb(argone);
		if (i) {
			snprintf(argone, sizeof(argone), "./o%04d%s.gz", orbit, argtwo);
			i = initialize_OSBdb(argone);
		}
	}
	if (i)
		return(0);
	/* Look for osbd2a only in same place (and type) as we found osbdba */
	i = strlen(argone) - 2;
	if (i < 1 || argone[i] != 'b') {
		/* .gz */
		i = strlen(argone) - 5;
		if (i < 1 || argone[i] != 'b')
			errx(1, "getdefault_osbdba(): not possible!");
	}
	argone[i] = '2';
	i = initialize_OSBdb2(argone);
	if (i)
		return(1);
	return(2);
}

/* A possibly even more convenient function - supplied MET should define
 * exactly one arc.  Requires inertial_pointing to have been read, to work.
 */
int
getdefault_osbdba_MET(uint32_t gmet)
{
	int arc, orb;

	if ((orb = get_orbit_at_met(gmet, &arc)) == -1)
		return(0);
	return(getdefault_osbdba(orb, arc));
}


/* See if the osbdba data matches some other set:  get a checksum of the
 * data.  Returns 0, 1, or 2 as per getdefault_osbdba(), and 0-2 checksums.
 */
int
get_osbdba_cksums(uint32_t *ck1, uint32_t *ck2)
{
	CKSUM_CTX foo;

	*ck1 = *ck2 = 0;
	if (n_osd == 0)
		return(0);
	CKSUM_Init(&foo);
	CKSUM_Update(&foo, (unsigned char *)osdb, n_osd * sizeof(double));
	CKSUM_Final(&foo);
	*ck1 = foo.crc;
	if (n_osd2 == 0)
		return(1);
	CKSUM_Init(&foo);
	CKSUM_Update(&foo, (unsigned char *)osdb2, n_osd2 * sizeof(double));
	CKSUM_Final(&foo);
	*ck2 = foo.crc;
	return(2);
}


/* Assuming osbdba and osbd2a have been read in, produce a cull that is
 * true (for all ESAs and all angles) for all periods which do NOT require
 * despinning - that is, for which the spun spin bin 0 is within some
 * tolerance (nominally 1 degree, if tolerance is zero or negative) of
 * where it should be.  Take as a hint the hbtype to which (one hopes)
 * alltimes has been synced.
 *
 * Returns zero on success.
 */
int
get_nonspuntimes(double tol, int whchcull, int hbtype)
{
	int i, j, k, ii;
	double *su;

	if (hbtype < 0 || hbtype >= BIN_TYPES || whchcull < 0 || whchcull >= 8)
		return(1);
	/* If there's no osbdba, return a fail.  If there's an osbdba but no
	 * osbd2a, assume it's all good.
	 */
	if (n_osd == 0 || nallt <= 0)
		return(2);
	if (n_osd2 == 0) {
		for (i = 0; i < nallt * HI_AZ_BINS; i++)
			mculls[whchcull][i] = 0xFF;
		return(0);
	}
	if (get_spinup_ranges(&su, hbtype) != 0)
		return(3);
	if (tol <= 0.)
		tol = 1./6.;
	memset(mculls[whchcull], 0, HI_AZ_BINS * nallt);
	/* Don't blindly assume we're synced to hbtype... */
	j = -1;
	for (i = 0; i < hbs[hbtype].n; i++) {
		j++;
		/* This odd case can happen on despun orbits. */
		if (j >= nallt && i + 1 == hbs[hbtype].n)
			break;
		k = j;
		while (j < nallt && alltimes[j] + HBtimeSlop < hbs[hbtype].met[i])
			j++;
		if (j == nallt) {
			free(su);
			return(4);
		}
		if ((fabs(su[i * HI_AZ_BINS * 2]) < tol ||
		    fabs(su[i * HI_AZ_BINS * 2] - 60.) < tol) &&
		    (fabs(su[i * HI_AZ_BINS * 2 + 1]) < tol ||
		    fabs(su[i * HI_AZ_BINS * 2 + 1] - 60.) < tol)) {
			for (; k <= j; k++) {
				for (ii = 0; ii < HI_AZ_BINS; ii++)
					mculls[whchcull][k * HI_AZ_BINS + ii] = 0xFF;
			}
		}
	}
	free(su);
	return(0);
}

/* HB_TIME as a global define of 690.5s is a kludge.  We can do better once
 * the osdb files are read in, as long as we drop silly things like where a
 * spin was lost.
 *
 * If we loaded across a repoint, which shouldn't actually be easy given
 * typical filenames, we might have more than one spin.  This will also
 * happen if we use an osdba file (not a d2a file) on a spun orbit.  Look
 * for and return an error if that's the case.
 *
 * Also allow for a cull to limit the times to use, as opposed to using
 * every time we have loaded.  If whichcull is invalid (e.g., negative),
 * don't use a cull, just use all times.  However, as a special case, use a
 * whichcull of -1 as a signal to use just times within alltimes (if nallt
 * is nonzero).  This is a bit dangerous XXX as it assumes, mightily, that
 * you've explicitly loaded exactly one arc.
 *
 * Note that if we didn't have to go looking for gaps and mistakes, this
 * would be a lot quicker:  (end time - start time) / number of spins.
 *
 * Return 0 on success.
 */
int
get_hbtime(int use_d2a, int whichcull, char whichesas, double *hbtime)
{
	int i, n, nfoo;
	double *arr;
	double foo, foo2, tmp;
	int retval;

	if (use_d2a) {
		arr = osdb2;
		n = n_osd2;
	} else {
		arr = osdb;
		n = n_osd;
	}
	if (arr == NULL || n < 2)
		return(-1);
	foo = foo2 = 0.;
	nfoo = 0;
	retval = 0;
	for (i = 1; i < n; i++) {
		if (whichcull < -1 || whichcull >= 8 ||
		    (whichcull == -1 && nallt > 0 &&
		    arr[i] >= alltimes[0] && arr[i] <= alltimes[nallt - 1]) ||
		    (whichcull >= 0 && whichcull <= 8 &&
		    is_any_goodcull(whichcull, (uint32_t)(arr[i]), whichesas))) {
			tmp = arr[i] - arr[i-1];
			/* Simply discard if the timing is bad and we didn't ask for
			 * good cullage.  Set an error flag and discard if we did
			 * ask for good cullage.
			 *
			 * It's painful to try to do multiple fits, but at least
			 * track standard deviation on what we keep to see if time
			 * is switchy.
			 */
			/* XXX hard wired limits!  Much tighter than
			 * get_spininfo_hbtime().
			 */
			if (tmp <= 14.1 || tmp > 14.5) {
				if (whichcull >= 0 && whichcull < 8)
					retval++;
			} else {
				nfoo++;
				foo += tmp;
				foo2 += tmp * tmp;
			}
		}
	}

	if (nfoo < 3)
		retval = -500;
	else {
		/* 48 spins per hb */
		*hbtime = foo / nfoo * 48;
		/* Sanity check the spread in times.  Expect standard deviation
		 * below .001s per spin; for now hardwire that and see how it goes.
		 * Well, make that a little looser.  It really only possibly
		 * figures into calculations if it's off by a hundredth of a
		 * second or more...
		 */
		tmp = sqrt((foo2 - foo * foo / nfoo)/(nfoo - 1.));
		/* XXX hardwired */
		if (tmp > 0.009)
			retval = -100;
	}
	return(retval);
}


/* Since we read SPIN_INFO, perhaps our best guess for hb timing WHEN NOT
 * SPUN during HVSCI comes simply from it.  To start with we don't expect
 * that we've set up consecutive spins (and backfilled) as the ISOC does,
 * so we just count it as a valid spin interval if the delta between two
 * HVSCI spin pulses is greater than 13.5 and less than 15.5.
 *
 * XXX Be nice to have some verbosity optional here and some checks if it's
 * really Gaussian or if it shifts vs time.  In other words, this currently
 * provides valid timing only if there is no despinning needed.
 */
double
get_spininfo_hbtime(double tmin, double tmax, double *std)
{
	int i;
	double s, s2, t;
	int n;

	n = 0;
	s = s2 = 0.;
	for (i = 1; i < nspin_times; i++) {
		t = spin_times[i].met - spin_times[i-1].met;
		if (spin_times[i].met <= tmax &&
		    spin_times[i-1].met >= tmin &&
		    t > 13.5 && t < 15.5) {
			n++;
			s += t;
			s2 += t*t;
		}
	}
	if (std != NULL) {
		if (n > 1)
			*std = 48. * sqrt((s2 - s * s / n)/(n-1));
		else
			*std = 0.;
	}
	return(48. * s/n);
}


/* Since we read SPIN_INFO, theoretically I do not need the osdba data any
 * more.  Fake up an osbdba array.  Although the ISOC does care about how
 * many spins really happened in an orbit, I don't.  The packet gives spin
 * number mod 256, so start at packet 1024 plus offset, and make stuff up
 * for previous spins.
 */
int
populate_osb_from_spininfo(int verbosity)
{
	int i, j, k, n, nmax;
	uint32_t lastpktmet;
	double lastmet, *newp;

	i = is_OSBdb_initialized();
	if (i && verbosity > 2)
		printf("populate_osb_from_spininfo: clearing %d osbdba(s)\n", i);
	clear_OSBdbs();
	n_osd = 0;
	nmax = 50000;
	if ((osdb = calloc(nmax, sizeof(double))) == NULL) {
		warn("populate_osb_from_spininfo");
		return(-2);
	}
	/* Fix the spininfos if they haven't been yet; assume one arc! */
	if (nst_pps == 0) {
		nst_pps = fix_PPS_issue_as_per_ISOC(0, 0xFFFFFFFF);
		fix_gaps_in_spins();
	}
	n_osd = 1024 + spin_times[0].spin;
	n = 0;
	j = 0;
	lastpktmet = spin_times[0].pktmet;
	lastmet = 0.;
	while (n < nspin_times) {
		if (spin_times[n].pktmet != lastpktmet) {
			/* Could be a gap; it's definitely consecutive in one packet */
			/* XXX 32. is a strange hardwired number of seconds! */
			if (spin_times[n].met - lastmet >= 32.) {
				/* guess gap */
				j = ((int)((spin_times[n].met - lastmet) /
				    (APPROX_HBTIME/48.)) + 2) / 256;
				i = spin_times[n].spin - n_osd % 256;
				if (i >= 0)
					n_osd += j * 256 + i;
				else
					n_osd += (j + 1) * 256 + i;
			}
		}
		/* Grow array if need be */
		if (n_osd >= nmax) {
			nmax += ((10000 < n_osd - nmax) ? (n_osd - nmax + 1):10000);
			/* sigh... if only recalloc() were common.. */
			if ((newp = realloc(osdb, nmax * sizeof(double))) == NULL) {
				free(osdb);
				n_osd = 0;
				warn("populate_osb_from_spininfo");
				return(-2);
			}
			osdb = newp;
			/* Zero it since it wasn't calloc()ed */
			for (i = n_osd + 1; i < nmax; i++)
				osdb[i] = 0.;
		}
		osdb[n_osd] = spin_times[n].met;
		n_osd++;
		lastmet = spin_times[n].met;
		n++;
	}
	/* Interpolate gaps */
	i = 0;
	j = 0;
	while (i < n_osd) {
		while (i < n_osd && osdb[i] >= 1e-5)
			i++;
		j = i;
		while (i < n_osd && osdb[i] < 1e-5)
			i++;
		if (j < n_osd) {
			if (verbosity > 2)
				printf("populate_osb: gap spins %d - %d (%d)\n",
				    j, i, n_osd);
			if (j == 0) {
				if (i >= n_osd) {
					warnx("populate_osb:  serious flaw!\n");
					free(osdb);
					n_osd = 0;
					return(-2);
				}
				/* APPROX_HBTIME / 48. is not a great guess, but who
				 * cares?
				 */
				for (; j < i; j++)
					osdb[j] = osdb[i] + (APPROX_HBTIME / 48.) * (j - i);
			} else if (i >= n_osd) {
				k = j - 1;
				for (; j < i; j++)
					osdb[j] = osdb[k] + (APPROX_HBTIME / 48.) * (j - k);
			} else {
				k = j - 1;
				/* repurpose lastmet */
				lastmet = (osdb[i] - osdb[k])/(i - k);
				for (; j < i; j++)
					osdb[j] = osdb[k] + lastmet * (j - k);
			}
		}
	}
	/* Add another 512 on end for good measure. */
	if (nmax < n_osd + 512) {
		if ((newp = realloc(osdb, (n_osd + 512) * sizeof(double))) == NULL) {
			free(osdb);
			n_osd = 0;
			warn("populate_osb_from_spininfo");
			return(-2);
		}
		osdb = newp;
	}
	for (i = 0; i < 512; i++)
		osdb[n_osd + i] = osdb[n_osd - 1] + i * (APPROX_HBTIME / 48.);
	n_osd += 512;
#if 0
{
	FILE *fp;

	if ((fp = fopen("testfakeosbdba.txt", "w")) != NULL) {
		for (i = 0; i < n_osd; i++)
			fprintf(fp, "%d\t%lf\n", i, osdb[i]);
		fclose(fp);
	}
}
#endif
	return(0);
}

/* NULL inputs mean not to do that array.  Arrays are allocated; number of
 * elements is returned in n.  n == 0 basically means a failure of some
 * sort.
 */
void
make_spintime_array(double **met, double **period, int *n, double minper,
    double maxper)
{
	int i;
	double tt;

	*n = 0;
	/* Save thought and simply allocate nspin_times-1 worth, which will be
	 * too much, but only by a little bit.
	 */
	if (met != NULL)
		if ((*met = calloc(nspin_times - 1, sizeof(double))) == NULL)
			return;
	if (period != NULL)
		if ((*period = calloc(nspin_times - 1, sizeof(double))) == NULL) {
			free(*met);
			return;
		}
	/* "Time" of a period corresponds to the time ENDING that period. */
	for (i = 1; i < nspin_times; i++) {
		tt = spin_times[i].met - spin_times[i-1].met;
		if (tt >= minper && tt <= maxper) {
			if (*met)
				(*met)[*n] = spin_times[i].met;
			if (*period)
				(*period)[*n] = tt;
			(*n)++;
		}
	}
}

/* Framework is the same as for finding SEP events.  The SEPlist startmet
 * and endmet fields constitute start and end of spun interval.  peakrate
 * becomes the best-guess average spin in the interval -- note that a
 * SINGLE best guess may not be useful if there are temperature effects.
 * peakmet is 0 if it's based on correctly spinning times before and after,
 *            1 if it's based on correctly spun times before only,
 *         or 2 if it's based on correctly spun times after only.
 *            3 means pretty bogus...
 * No SEPlist is allocated if sepl is NULL.
 *
 * Negative periods are set to defaults of 14.1 and 15.0 seconds.
 * hbtype is set to qABC if it's out of range.
 *
 * Note that this function will return in getbesthbtime the best estimate
 * we have for spin period based on non-spun portion of arc (inside minmet
 * to maxmet).  There will of course be issues if there's more than one arc
 * or the spin-period-finding algorithm borks.
 *
 * If fp is not NULL, dump average periods at hbtype cadence to that file.
 *
 * Return value is negative on error and >= 0 for number of spun intervals
 * found.
 */
int
find_spun_spininfo(double minper, double maxper, double minmet, double maxmet,
    int hbtype, SEPlist **sepl, FILE *fp, double *getbesthbtime, int verbosity)
{
	double *spinmet, *spinper;
	int i, j, k, nn, ndelta, nspin;
	int nseplist;
	double *delta, *avpr;
	double s, ss, lastsn;
	uint32_t *avmet;
	char *badsp;
	SEPlist *foo, *bar;
	int istart, iend;

	istart = iend = 0;
	/* Set defaults */
	if (hbtype < 0 || hbtype >= BIN_TYPES) {
		if (verbosity > 3)
			printf("find_spun:  setting hbtype to HB_QABC\n");
		hbtype = HB_QABC;
	}
	if (minper < 0. || maxper < 0.) {
		minper = 14.1;
		maxper = 15.0;
		if (verbosity > 3)
			printf("find_spun:  setting period range to %.2lf - %.2lf s\n",
			    minper, maxper);
	}
	make_spintime_array(&spinmet, &spinper, &nspin, minper, maxper);
	if (nspin <= 0)
		return(-1);
	delta = calloc(nspin, sizeof(double));
	avpr = calloc(nspin, sizeof(double));
	avmet = calloc(nspin, sizeof(uint32_t));
	badsp = calloc(nspin, sizeof(char));
	if (delta == NULL || avpr == NULL || avmet == NULL || badsp == NULL) {
		/* it's safe to free(NULL) */
		free(badsp);
		free(avmet);
		free(avpr);
		free(delta);
		free(spinper);
		free(spinmet);
		return(-2);
	}
	if (fp)
		fprintf(fp,
"# Average recorded HVSCI spin periods at %s cadence\n\
# Columns are packet MET, average spin period, number of periods used,\n\
#   and 0 == not spun, 1 == spun?, 2 == too early/late\n\
# Filter:  periods are between %.3lf and %.3lf\n",
hbs[hbtype].name, minper, maxper);

	j = 0;
	nseplist = 0;
	ndelta = 0;
	lastsn = -1;
	/* Bin up at packet cadence */
	for (i = 0; i < hbs[hbtype].n; i++) {
		nn = 0;
		s = 0.;
		ss = 0.;
		/* Packet creation time as an int can be 0.999 seconds "early" */
		while (j < nspin && spinmet[j] <= (double) hbs[hbtype].met[i] + 1.) {
			if (spinmet[j] <= maxmet && spinmet[j] >= minmet) {
				s += spinper[j];
				nn++;
			}
			j++;
		}
		/* We want to disregard statistically less-relevant data, but it
		 * doesn't really matter if the packet is "full" or not.
		 */
		if (nn > 40) {
			if (lastsn > 0.) {
				avmet[ndelta] = hbs[hbtype].met[i];
				avpr[ndelta] = s / nn;
				delta[ndelta] = s / nn - lastsn;
				ndelta++;
			}
			lastsn = s / nn;
		}
	}
	/* Now go looking for quirks.  Those would be large jumps and
	 * unusually steady periods.  We expect "spun" intervals to have a
	 * longer-than-average period and a jump at the end (maybe one at the
	 * start).
	 *
	 * A quick check indicates that nonspun orbit arcs don't seem to have
	 * absolute deltas bigger than .00047.  Put in a hardwired limit a
	 * touch bigger...
	 * SPUN intervals, at least once the star tracker has failed us, have
	 * a constant spin interval within 4e-5 per interval, with no
	 * long-term drift.
	 */
	for (i = 0; i < ndelta; i++) {
		if (fabs(delta[i]) > 0.0005) {
			if (verbosity > 1)
				printf("Suspicious delta %d (MET %lu) %.2lg\n", i,
				    (unsigned long)avmet[i], delta[i]);
			badsp[i] = 1;
			/* Mark either side bad and look 2 over */
			if (i > 0)
				badsp[i-1] = 1;
			j = i - 2;
			while (j > 0 && fabs(delta[j]) <= 8e-5 &&
			    fabs(avpr[i-1] - avpr[j]) <= 6e-5) {
				badsp[j] = 1;
				j--;
			}
			if (i + 1 < ndelta)
				badsp[i+1] = 1;
			j = i + 2;
			while (j < ndelta && fabs(delta[j]) <= 8e-5 &&
			    fabs(avpr[i+1] - avpr[j]) <= 6e-5) {
				badsp[j] = 1;
				j++;
			}
			j = i + 1;
		}
	}
	/* Get rid of stupidly short "nonspun" intervals because probably they
	 * are bogus.  This should be an adjustable parameter.
	 */
	i = 0;
	while (i < ndelta) {
		j = 0;
		while (i < ndelta && badsp[i] != 0)
			i++;
		while (i < ndelta && badsp[i] == 0) {
			i++;
			j++;
		}
		if (j > 0 && j < 4) {	/* Clear; 4 should be a parameter */
			if (verbosity > 1)
				printf("negating %d elements before %d\n", j, i);
			for ( ; j > 0; j--)
				badsp[i - j] = 1;
		}
	}
	/* Get averages of remaining intervals.  Probably there's just one,
	 * but if there are more than one, then we should check that we get
	 * the same number for both, and also then we can improve our guess on
	 * spin rate by requiring an integer number of spins between.
	 */
	i = 0;
	nn = 0;
	ss = 0.;
	foo = bar = NULL; /* shush the compiler */
	if (sepl)
		*sepl = NULL;
	while (i < ndelta) {
		j = 0;
		s = 0.;
		if (badsp[i]) {
			j = i;
			if (verbosity > 0)
				printf("SPUN interval from %lu - ",
				    (unsigned long) avmet[i]);
			if (sepl != NULL) {
				if ((foo = calloc(sizeof(SEPlist), 1)) == NULL)
					err(1, NULL);
				if (*sepl == NULL) {
					*sepl = foo;
					bar = foo;
				} else {
					bar->nextsep = foo;
					bar = foo;
				}
				foo->startmet = avmet[i];
				istart = i;
				foo->nextsep = NULL;	/* redundant */
			}
			nseplist++;
		}
		while (i < ndelta && badsp[i] != 0)
			i++;
		if (i > 0 && badsp[i - 1]) {
			if (verbosity > 0)
				printf("%lu (%.1lf hrs)\n", (unsigned long) avmet[i - 1],
				    (avmet[i-1] - avmet[j])/3600.);
			if (sepl != NULL) {
				foo->endmet = avmet[i-1];
				iend = i-1;
			}
		}
		j = 0;
		while (i < ndelta && badsp[i] == 0) {
			s += avpr[i];
			i++;
			j++;
		}
		if (nn > 0 && j > 0) { /* We have a second block of nonspun times */
			/* XXX really ought to track std dev of mean, not an
			 * absolute difference.
			 */
			if (fabs(s/j - ss/nn) > 0.0005) {
				if (verbosity > -1) {
printf("Bleah!  Intervals don't have the same spin (%lf and %lf)\n",
			    s/j, ss/nn);
printf("Bleah!  %d of %d (%lf / %d)\n", i, ndelta, s, j);
				}
			/* XXX do something */
			}
			if (verbosity > 0)
printf("\tbased on surrounding times, spin period should have been %.5lf\n",
			    (ss + s)/(nn + j));
			if (sepl != NULL) {
				foo->peakrate = (ss + s)/(nn + j);
				foo->peakmet = 0;
			}
			if (verbosity > 0)
printf("\tforcing spun interval to an integer number of periods -> %.5lf\n",
			    (avmet[iend] - avmet[istart]) /
			    round((avmet[iend] - avmet[istart])/((ss + s)/(nn + j))));
			if (sepl != NULL) {
				foo->peakrate = (avmet[iend] - avmet[istart]) /
				    round((avmet[iend] - avmet[istart])/((ss + s)/(nn + j)));
			}
		} else if (nn > 0) {
			/* We have correctly spun preceding times but none following */
			if (verbosity > 0)
printf("\tbased on preceding times, spin period should have been %.5lf\n",
			    ss / nn);
			if (sepl != NULL) {
				foo->peakrate = ss / nn;
				foo->peakmet = 1;
			}
		} else if (j > 0) {
			/* We have correctly spun following times but none
			 * preceding, or there were no spun intervals at all.
			 */
			if (nseplist > 0) {
				if (verbosity > 0)
printf("\tbased on following times, spin period should have been %.5lf\n", s/j);
				if (sepl != NULL) {
					foo->peakrate = s / j;
					foo->peakmet = 2;
				}
			}
		} else {
			/* should never happen */
			if (verbosity > 0)
printf("\tNo surrounding decent times by which to guess spin!\n");
			if (sepl != NULL) {
				foo->peakrate = APPROX_HBTIME/48.;
				foo->peakmet = 3;
			}
		}
		nn += j;
		ss += s;
	}
	if (verbosity > 1)
		printf("Average good spin was %lf\n", ss / nn);
	if (getbesthbtime != NULL)
		*getbesthbtime = ss / nn * 48.;
	if (fp) {
		/* XXX significant duplication of earlier effort; it's slightly
		 * different because we want to keep all the stuff we didn't put
		 * into ndelta, whether it's good or not.
		 */
		lastsn = -1;
		k = -1;
		j = 0;
		for (i = 0; i < hbs[hbtype].n; i++) {
			nn = 0;
			s = 0.;
			ss = 0.;
			/* Packet creation time as an int can be 0.999 seconds "early" */
			while (j < nspin &&
			    spinmet[j] <= (double) hbs[hbtype].met[i] + 1.) {
				if (spinmet[j] <= maxmet && spinmet[j] >= minmet) {
					s += spinper[j];
					nn++;
				}
				j++;
			}
			/* XXX this 40 must match the 40 from earlier version. */
			if (nn > 40) {
				if (lastsn > 0.)
					k++;
				lastsn = 1.0;
			}
			if (nn > 0) {
				fprintf(fp, "%lu\t%.5lf\t%d\t",
				    (unsigned long) hbs[hbtype].met[i], s / nn, nn);
				/* give shortened packets the same value as last preceding
				 * fuller packet.
				 */
				if (k < 0 || k >= ndelta)
					fprintf(fp, "2\n");
				else	
					fprintf(fp, "%d\n", (badsp[k] != 0));
			}
		}
	}
	free(badsp);
	free(avmet);
	free(avpr);
	free(delta);
	free(spinper);
	free(spinmet);
	return(nseplist);
}

static void
_growit(double **arr, int *nm)
{
	double *newp;

	*nm += 10000;
	if ((newp = realloc(*arr, *nm * sizeof(double))) == NULL)
		err(1, "_growit");
	*arr = newp;
}

/* Yow.  Given an osbdba, which may have been generated from SPIN_INFO
 * data, and a list of spun times, presumably from find_spun_spininfo,
 * fake up an osbd2a list so that we can despin.
 * Note that the SEPlist format allows for only one spin value during a
 * spun interval, so this whole framework is insufficient if, say,
 * temperature effects mean that an interval has a changing spin rate.
 *
 * Assumed that SEPlist is in chronological order.
 */
void
fake_osbd2a(SEPlist *sepl)
{
	SEPlist *foo;
	int i, j, k, l;
	double tmet;
	int nmax;

	foo = sepl;
	if (osdb2)
		free(osdb2);
	osdb2 = NULL;
	n_osd2 = 0;
	i = j = k = 0;
	nmax = 50000;
	if ((osdb2 = calloc(nmax, sizeof(double))) == NULL) {
		warn("fake_osbd2a");
		return;
	}
	while (i < n_osd && foo != NULL) {
		while (i < n_osd && osdb[i] < foo->startmet) {
			osdb2[j] = osdb[i];
			k = i;
			i++;
			j++;
			if (j >= nmax)
				_growit(&osdb2, &nmax);
		}
		while (i < n_osd && osdb[i] <= foo->endmet)
			i++;
		if (foo->peakmet < 2) { /* sync off prior */
			l = 1;
			while ((tmet = osdb[k] + l * foo->peakrate) <= foo->endmet) {
				osdb2[j] = tmet;
				l++;
				j++;
				if (j >= nmax)
					_growit(&osdb2, &nmax);
			}
		} else { /* sync off following */
			l = (osdb[i] - osdb[k]) / foo->peakrate - 0.5;
			while ((tmet = osdb[i] - l * foo->peakrate) <= foo->endmet) {
				osdb2[j] = tmet;
				l--;
				j++;
				if (j >= nmax)
					_growit(&osdb2, &nmax);
			}
		}
		foo = foo->nextsep;
	}
	while (i < n_osd) {
		osdb2[j] = osdb[i];
		i++;
		j++;
		if (j >= nmax)
			_growit(&osdb2, &nmax);
	}
	n_osd2 = j;
}


#ifdef TESTING
int
main(int argc, char **argv)
{
	char foo[1024];
	int i, j, k, tstamp;
	uint32_t ck1, ck2;
	double met, per;

	printf("Supply OSBDBA: ");
	fgets(foo, sizeof(foo), stdin);
	foo[strcspn(foo, "\n")] = '\0';
	i = initialize_OSBdb(foo);
	printf("init: %d\nSupply OSBD2A: ", i);
	fgets(foo, sizeof(foo), stdin);
	foo[strcspn(foo, "\n")] = '\0';
	i = initialize_OSBdb2(foo);
	printf("init: %d\n", i);
	j = get_osbdba_cksums(&ck1, &ck2);
	printf("checksumming: %u, %u (%d)\n", ck1, ck2, j);
	met = 100.;
	while (met >= 0 && !feof(stdin)) {
		printf("Supply MET (<0 to quit) and DE timestamp: ");
		scanf("%lf", &met);
		scanf("%d", &tstamp);
		k = get_OSBdbstuff(met, &per);
		printf("OSDB:  spin %d with period %lf\n", k, per);
		j = get_OSBdb2stuff(met, &per);
		printf("OSDB2:  spin %d with period %lf\n", j, per);
		printf("phase OSDB: %lf\n", get_OSBdbphase(k, tstamp));
		printf("phase OS2DB: %lf\n", get_OSBdbphase2(k, tstamp, &j));
		printf("\n");
	}
	exit(0);
}
#endif
