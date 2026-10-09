/*	$Id: sepsearch.c,v 1.5 2014/07/09 04:53:30 pjanzen Exp $	*/
/* Under the assumption that LVSCI periods have been removed and hbs have
 * been culled and further_culled, look for SEP events.
 * If verbosity is positive, print.  If *sepl is not NULL, allocate and
 * return a NULL-terminated list of SEP events.  Return number of events
 * found.
 *
 * XXX some day might also want to make sure there are no bursts in the
 * analysis...
 *
 * If interval is negative, everything is (silently) initialized to defaults.
 *
 * arguments:
 * interval:  time in seconds (useful default, set if it's input as
 *       negative or silly: 8 * APPROX_HBTIME)
 * minhztocare: 0.02 is default:  it's minimum additional counts needed to
 *       identify a SEP event.
 * sigmasneeded: 4.0 is default:  it's how many sigma an event must be to
 *       identify a SEP event.
 * sigmahyst: 1.25 is default:  it's used to avoid double-triggering on a
 *       single SEP event.
 */
static const char rcsid[] = "@(#) $Id: sepsearch.c,v 1.5 2014/07/09 04:53:30 pjanzen Exp $";

#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ibexhi.h"

#define NO_SEP (0)
#define IN_SEP (1)

static int
_dubcmp(const void *a, const void *b)
{
	double x;

	x = *((double *)a) - *((double *)b);
	if (x < 0.)
		return(-1);
	else if (x > 0.)
		return(1);
	return(0);
}


int
find_seps(int interval, double minhztocare, double sigmasneeded,
    double sigmahyst, SEPlist **sepl, int verbosity)
{
	int nmax, n, i;
	double *rate, *unc, *rs;
	double thresh, peak, tmp;
	uint32_t starttime, *ts;
	int status, seps, peaki;
	SEPlist *foo, *bar;

	if (interval < 0) {
		interval = 8 * APPROX_HBTIME;
		minhztocare = 0.02;
		sigmasneeded = 4.0;
		sigmahyst = 1.25;
	}
	if (interval >= APPROX_HBTIME * 200 || interval < APPROX_HBTIME / 2) {
		interval = 8 * APPROX_HBTIME;
		if (verbosity > 0)
			printf("find_seps(): setting interval to default %d\n",
			    interval);
	}
	nmax = (hbs[HB_QABC].met[hbs[HB_QABC].n - 1] - hbs[HB_QABC].met[0]) /
	    interval + 3;
	if (nmax < 1 ||
	    (rate = calloc(nmax, sizeof(double))) == NULL ||
	    (rs = calloc(nmax, sizeof(double))) == NULL ||
	    (ts = calloc(nmax, sizeof(uint32_t))) == NULL ||
	    (unc = calloc(nmax, sizeof(double))) == NULL)
		errx(1, "mem");
	n = 0;
	starttime = hbs[HB_QABC].met[0] - APPROX_HBTIME;
	while (starttime < hbs[HB_LABC].met[hbs[HB_LABC].n - 1]) {
		get_bgs_time(rate + n, unc + n, starttime, starttime + interval, 0);
		if (verbosity > 1)
			printf("%lu\t%lf\t%lf\n", (unsigned long)starttime + interval/2,
			    rate[n], unc[n]);
		ts[n] = starttime + interval/2;
		starttime += interval;
		n++;
		/* Can't ever happen */
		if (n > nmax)
			errx(1, "impossibly large n");
	}
	/* Report SEP existance.  Strategy is to call baseline for the orbit
	 * the n/10th lowest value (unless it's above 80 mHz) and consider a
	 * SEP anything that gets 3 sigma above it.  Then we report start MET,
	 * peak (and peak MET), and finish MET for any that we find.
	 */
	memcpy(rs, rate, n * sizeof(double));
	qsort(rs, n, sizeof(double), _dubcmp);
	/* Skip gaps in data, if there were any */
	i = 0;
	while (i < n && rs[i] < 0.)
		i++;
	if (i == n) {
		if (verbosity > 0)
			warnx("no decent data to work with");
		free(unc);
		free(ts);
		free(rs);
		free(rate);
		return(0);
	}
	thresh = rs[i + (n - i) / 10];
	free(rs);
	if (thresh > 0.08) {
		if (verbosity > 0)
			printf("Discarding calculated threshold of %lf as too high!\n",
			    thresh);
		thresh = 0.08;
	}
	if (verbosity > 0)
		printf("Threshold:  %lf Hz\n", thresh);
	i = 0;
	status = NO_SEP;
	seps = 0;
	peaki = 0;
	peak = 0.0;
	foo = bar = NULL;
	if (sepl != NULL)
		*sepl = NULL;
	while (i < n) {
		if (unc[i] > 0.) {
			tmp = (rate[i] - thresh) / unc[i];
			switch(status) {
			case NO_SEP:
				if (tmp > sigmasneeded && rate[i] - thresh > minhztocare) {
					if (verbosity >= 0) {
						printf("SEP start approx MET %lu\n",
						    (unsigned long)(ts[i]));
					}
					seps++;
					peak = rate[i];
					peaki = i;
					status = IN_SEP;
					if (sepl != NULL) {
						if ((foo = (SEPlist *)calloc(sizeof(SEPlist), 1))
						    == NULL)
							err(1, NULL);
						if (*sepl == NULL) {
							*sepl = foo;
							bar = foo;
						} else {
							bar->nextsep = foo;
							bar = foo;
						}
						foo->startmet = ts[i];
						foo->peakmet = ts[i];
						foo->endmet = ts[i];
						foo->peakrate = 0.;
						foo->nextsep = NULL;
					}
				}
				break;
			case IN_SEP:
				/* Try to avoid bouncing by putting in some hysteresis */
				if (tmp < sigmasneeded - sigmahyst) {
					if (verbosity >= 0) {
						printf("SEP peak rate %lf Hz approx MET %lu\n",
						    peak, (unsigned long)(ts[peaki]));
						printf("SEP end approx MET %lu\n",
						    (unsigned long)(ts[i]));
					}
					if (sepl != NULL) {
						foo->peakrate = peak;
						foo->peakmet = ts[peaki];
						foo->endmet = ts[i];
					}
					status = NO_SEP;
				} else if (rate[i] > peak) {
					peak = rate[i];
					peaki = i;
				}
				break;
			}
		}
		i++;
	}
	if (status == IN_SEP) {
		if (verbosity >= 0) {
			printf("SEP peak rate %lf Hz approx MET %lu\n",
			    peak, (unsigned long)(ts[peaki]));
			printf("SEP end past end of data (MET %lu)\n",
			    (unsigned long)(ts[n-1]));
		}
		if (sepl != NULL) {
			foo->peakrate = peak;
			foo->peakmet = ts[peaki];
			foo->endmet = ts[n-1];
		}
	}

	free(unc);
	free(ts);
	free(rate);
	return(seps);
}


/* Convenience:  says whether a given MET is in the SEP list (i.e. during a
 * SEP event.  0 if not.  Can't predict that the list is sorted, though it
 * always is; can predict that it's not a long linked list ever.
 */
int
in_SEP(uint32_t m, SEPlist *sp)
{
	SEPlist *p;

	p = sp;
	while (p) {
		if (p->startmet <= m && p->endmet >= m)
			return(1);
		p = p->nextsep;
	}
	return(0);
}
