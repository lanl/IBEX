/*	$Id: readewind.c,v 1.8 2016/05/22 23:55:41 pjanzen Exp $	*/
/* It looks like we may be using WIND 103 eV electron data frequently
 * regarding ion gun effect.  We may also want other energies of WIND
 * electron data, too.
 *
 * WIND data comes either as daily CDF files or via omniweb as an ugly text
 * file.  Since the latter can extend over a longer time period, and
 * doesn't require the CDF library, that's what I'll take (I already have
 * conversion routines to mangle CDF to this format).
 *
 * The basic request is for WIND data at some energy from time1 to time2.
 * Multiple files can be read in consecutively without resetting, so that
 * orbits that extend over a file boundary (i.e., typically a year boundary)
 * can be covered easily.  However, each read-in request will purge
 * existing data outside the last time1 - time2 range.
 *
 * At least for now, only ONE energy channel gets read in at a time.
 */
static const char rcsid[] = "@(#) $Id: readewind.c,v 1.8 2016/05/22 23:55:41 pjanzen Exp $";

#include <ctype.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <zlib.h>

#include "ibexhi.h"

#define WINDBLOCK (10000)

struct IBEXwind {
	uint32_t met;
	double   flux;
};

static struct IBEXwind *ibw;
static int wchan = 6;
static int nibw = 0;
static int nibwmax = 0;


static uint32_t
timestr_to_MET(char *foo)
{
	struct tm bar;
	time_t x;

	if (sscanf(foo, "%d-%d-%d %d:%d:%d.", &bar.tm_mday, &bar.tm_mon,
	    &bar.tm_year, &bar.tm_hour, &bar.tm_min, &bar.tm_sec) != 6)
		return(0);
	bar.tm_year -= 1900;

	/* Don't forget months are zero - offset */
	bar.tm_mon -= 1;

	bar.tm_isdst = 0;
	x = timegm(&bar) - EPOCHDIFF;
	if (x > 0)
		return((uint32_t)(x));
	return(0);
}


/* Clear out any extant data before t1, after t2, or not requested channel.
 * Assume time sorting has happened.
 */
static void
clear_wind(uint32_t t1, uint32_t t2, int windchan)
{
	int i;

	if (windchan != wchan) {
		if (nibwmax > 0)
			free(ibw);
		nibw = 0;
		nibwmax = 0;
	} else {
		while (nibw > 0 && ibw[nibw - 1].met > t2)
			nibw--;
		i = 0;
		while (i < nibw && ibw[i].met < t1)
			i++;
		if (i > 0) {
			nibw -= i;
			/* XXX some platforms may not like copying overlapping
			 * buffers!  Better to avoid memcpy()! XXX
			 */
			memcpy(ibw, ibw + i, nibw * sizeof(struct IBEXwind));
		}
		/* Don't bother freeing here. */
	}
}


static int
_wndcmp(const void *a, const void *b)
{
	struct IBEXwind *aa, *bb;

	aa = (struct IBEXwind *)a;
	bb = (struct IBEXwind *)b;
	if (aa->met < bb->met)
		return(-1);
	if (aa->met > bb->met)
		return(1);
	return(0);
}

/* returns:  -1 failure
 *            0 full success: entire time range requested was read in,
 *              either from this file or previously.
 *            1 partial success: time range END not covered in data.
 *            2 partial success: time range START not covered in data.
 *            3 partial success, as 1 | 2.
 * Times are MET (of course).
 * Wind channel, according to my numbering:
 *   1: 1113 eV     2: 669 eV         3: 427 eV       4: 265 eV
 *   5:  165 eV     6: 103 eV ***     7:  65 eV       8:  42 eV etc.
 * If channel is negative, it's set to 6.
 */
int
reap_wind(char *fname, uint32_t t1, uint32_t t2, int windchan)
{
	gzFile fp;
	struct IBEXwind *tmp;
	char line[8192], *p;
	uint32_t mt;
	int i;
	double v;

	if (windchan < 1)
		windchan = 6;
	clear_wind(t1, t2, windchan);
	/* Don't clear stuff if it's already there -- let us read numerous
	 * files and just concatenate.
	 */
	if (nibwmax == 0) {
		if ((ibw = (struct IBEXwind *) calloc(WINDBLOCK,
		    sizeof(struct IBEXwind))) == NULL)
		    err(1, "reap_wind()");
		nibwmax = WINDBLOCK;
		nibw = 0;
	}

	if ((fp = gzopen(fname, "r")) == NULL)
		return(-1);
	while (gzgets(fp, line, sizeof(line))) {
		/* poor man's check of valid data line: look for -20 in the
		 * century field
		 */
		if (strlen(line) > 10 && line[5] == '-' && line[6] == '2' &&
		    line[7] == '0') {
			mt = timestr_to_MET(line);
			/* to use dblcolval need to make different delimiter because
			 * lines of spaces muck things up
			 */
			p = line;
			i = 0;
			while (*p) {
				if (isblank(*p) && !i) {
					i = 1;
					*p = ',';
				} else if (!isblank(*p) && i)
					i = 0;
				p++;
			}
			if (mt >= t1 && mt <= t2 &&
			    dblcolval(line, windchan + 2, ',', &v) == 0) {
				/* Add at end, sort later. */
				if (nibw + 1 > nibwmax) {
					nibwmax += WINDBLOCK;
					/* really want recalloc() */
					if ((tmp = realloc(ibw, nibwmax *
					    sizeof(struct IBEXwind))) == NULL)
						err(1, "reapwind() realloc");
					ibw = tmp;
				}
				ibw[nibw].met = mt;
				ibw[nibw].flux = v;
				nibw++;
			}
		}
	}
	gzclose(fp);
	wchan = windchan;
	/* Count it a failure if there wasn't data in the time zone, even if
	 * there was a file.
	 */
	if (nibw < 2)
		return(-1);
	/* Probably in order, but qsort() it anyhow.  qsort may not be the
	 * optimal choice here.
	 */
	qsort(ibw, nibw, sizeof(struct IBEXwind), _wndcmp);
	/* XXX no removal of duplicate entries! */
	/* Hah, since we include only times WITHIN, it's hard to say if we got
	 * right to the edges.  Assume we did if we're within about 90
	 * seconds, since that's the actual cadence...
	 */
	i = 0;
	if (ibw[0].met > t1 + 90 + 45)
		i += 1;
	if (ibw[nibw-1].met + 90 + 45 < t2)
		i += 2;
	return(i);
}


/* Clear from memory, since it can get huge. */
void
break_wind()
{
	if (nibwmax > 0)
		free(ibw);
	nibw = 0;
	nibwmax = 0;
}


double
get_avgwindeflux(double t1, double t2)
{
	int i, j;
	double foo;

	if (t2 < t1) {
		foo = t2; t2 = t1; t1 = foo;
	}
	foo = 0.;
	j = 0;
	for (i = 0; i < nibw; i++) {
		if (ibw[i].met >= t1 && ibw[i].met <= t2) {
			foo += ibw[i].flux;
			j++;
		}
	}
	if (j == 0.)
		return(-1.);
	else
		return(foo/j);
}


/* For finding dropouts:  just return the number of data points in a time
 * range.
 */
int
get_navgwindeflux(double t1, double t2)
{
	int i, j;
	double foo;

	if (t2 < t1) {
		foo = t2; t2 = t1; t1 = foo;
	}
	j = 0;
	for (i = 0; i < nibw; i++)
		if (ibw[i].met >= t1 && ibw[i].met <= t2)
			j++;
	return(j);
}


static int _bsew_range = 10;

static int
_bsearchewind(const void *a, const void *b)
{
	struct IBEXwind *aa, *bb;

	aa = (struct IBEXwind *)a;
	bb = (struct IBEXwind *)b;
	if (aa->met + _bsew_range < bb->met)
		return(-1);
	if (aa->met > bb->met + _bsew_range)
		return(1);
	return(0);
}

/* XXX Kind of ugly use of bsearch().  If data cadence is nominally about
 * 90s, there should be SOMETHING within that time.  But start wider and
 * just narrow down.
 */
double
get_closestwindeflux(double t1)
{
	struct IBEXwind x, *y, *z;

	if (nibw < 1)
		return(-1.);
	x.met = (uint32_t)t1;
	/* Start by accepting anything within standard IBEX cadence. */
	_bsew_range = (int)APPROX_HBTIME / 2;
	z = NULL;
	do {
		y = (struct IBEXwind *)bsearch(&x, ibw, nibw,
		    sizeof(struct IBEXwind), _bsearchewind);
		if (y)
			z = y;
		_bsew_range /= 2;
	} while (y != NULL && _bsew_range > 1);
	if (!z)
		return(-1);
	return(z->flux);
}

/* For speed, make a couple simple functions do binary dump and binary
 * load, with no error checking at all.  Obviously not portable across
 * architectures.
 * Both return 0 on success.
 */
int
dump_bwind(char *fname)
{
	int fp, i;
	long j;
	void *p;

	if ((fp = open(fname, O_WRONLY|O_CREAT|O_TRUNC, 0444)) == -1)
	    return(fp);
	i =  write(fp, &nibw, sizeof(int));
	i += write(fp, &wchan, sizeof(int));
	if (i != 2 * sizeof(int)) {
		close(fp);
		return(1);
	}
	/* Don't expect the writes of integers to happen partially, but the
	 * next write might.
	 */
	p = (void *)ibw;
	j = nibw * sizeof(struct IBEXwind);
	while ((i = write(fp, p, j)) != -1 && i != 0) {
		p += i;
		j -= i;
	}
	close(fp);
	if (i == -1)
		return(-2);
	return(0);
}

int
load_bwind(char *fname)
{
	int fp, i;
	long j;
	void *p;

	if ((fp = open(fname, O_RDONLY, 0)) == -1)
	    return(fp);
	break_wind();
	i =  read(fp, &nibw, sizeof(int));
	i += read(fp, &wchan, sizeof(int));
	if (i != 2 * sizeof(int)) {
		close(fp);
		return(1);
	}
	nibwmax = nibw;
	if ((ibw = (struct IBEXwind *) calloc(nibwmax, sizeof(struct IBEXwind)))
	    == NULL) {
		nibwmax = nibw = 0;
		return(2);
	}
	p = (void *)ibw;
	j = nibwmax * sizeof(struct IBEXwind);
	while ((i = read(fp, p, j)) != -1 && i != 0) {
		p += i;
		j -= i;
	}
	close(fp);
	if (i == -1) {
		break_wind();
		return(-2);
	}
	return(0);
}


#ifdef TESTING
int
main(int argc, char **argv)
{
	unsigned long t1, t2;

	if (argc != 3)
		errx(1, "usage: testprog one-wind-file second-wind-file");

	printf("Enter t1 and t2, 0 and 0 to quit:  ");
	if (scanf("%lu%lu", &t1, &t2) != 2 || (t1 == 0 && t2 == 0))
		exit(0);
	printf("First file returned %d\n", reap_wind(argv[1], t1, t2, 6));
	printf("testdumping first:  %d\n", dump_bwind("Wind-bin.dat"));
#if 0
	printf("Second file returned %d\n", reap_wind(argv[2], t1, t2, 6));
#endif
	while (1) {
		printf("Enter t1 and t2, 0 and 0 to quit:  ");
		if (scanf("%lu%lu", &t1, &t2) != 2 || (t1 == 0 && t2 == 0))
			break;
		printf("avg eflux in chosen channel is %lf\n\n",
		    get_avgwindeflux((double)t1, (double)t2));
		printf("closest to t1 flux is %lf\n", 
		    get_closestwindeflux((double)t1));
	}
	printf("reloading first from bin:  %d\n", load_bwind("Wind-bin.dat"));
	while (1) {
		printf("Enter t1 and t2, 0 and 0 to quit:  ");
		if (scanf("%lu%lu", &t1, &t2) != 2 || (t1 == 0 && t2 == 0))
			exit(0);
		printf("avg eflux in chosen channel is %lf\n\n",
		    get_avgwindeflux((double)t1, (double)t2));
		printf("closest to t1 flux is %lf\n", 
		    get_closestwindeflux((double)t1));
	}
	exit(0);
}
#endif
