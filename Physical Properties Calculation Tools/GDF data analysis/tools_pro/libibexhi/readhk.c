/*	$Id: readhk.c,v 1.3 2020/01/02 05:44:27 pjanzen Exp $	*/
/* Might want to correlate housekeeping to good times counts or some kind
 * of science data.  This is a first crack assuming pktsoh has already been
 * processed; right now all the cleverness is hidden away in hk_print.
 * It's basically just library calls to process each packet, but things are
 * a touch trickier than that since (a) there remains translation to useful
 * units in some cases and (b) some h/k points exist in multiple packets,
 * and I want to treat them the same.
 *
 * Therefore, since hi_hk_isoc produces files of the points I care about,
 * and I always run hi_hk_isoc, the easiest thing to do is simply to parse
 * a hi_hk_isoc output file, and the easiest thing to specify is the
 * filename and column to care about.
 *
 * Start with an ugly assumption that we will only ever care about one h/k
 * point at a time, that being the last one read in by readhousekeep() and
 * put in a local static struct.  Can get fancier later if needed.
 */
static const char rcsid[] = "@(#) $Id: readhk.c,v 1.3 2020/01/02 05:44:27 pjanzen Exp $";

#include <sys/types.h>
#include <dirent.h>
#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "ibexhi.h"

typedef struct {
	int nmax;
	int n;
	uint32_t *met;
	double *data;
} hkpoint;

static hkpoint hk = {0, 0, NULL, NULL};
static hkpoint hk_cems[3] = {{0, 0, NULL, NULL}, {0, 0, NULL, NULL},
    {0, 0, NULL, NULL}};

static void
addtohk(hkpoint *h, uint32_t met, double d)
{
	uint32_t *tmp1;
	double *tmp2;

	if (h->n >= h->nmax) {
		if (h->nmax <= 0) {
			tmp1 = calloc(sizeof(uint32_t), 10000);
			tmp2 = calloc(sizeof(double), 10000);
			h->nmax = 10000;
		} else {
			/* recalloc() is nonportable */
			tmp1 = realloc(h->met, sizeof(uint32_t) * (h->nmax + 10000));
			tmp2 = realloc(h->data, sizeof(double) * (h->nmax + 10000));
			h->nmax += 10000;
		}
		if ((!tmp1) || (!tmp2))
			errx(100, "FATAL:  addtohk out of mem");
		h->met = tmp1;
		h->data = tmp2;
	}
	*(h->met + h->n) = met;
	*(h->data + h->n) = d;
	h->n++;
}

/* 0 on success.  Ignore '^#' lines or "null" fields, assume it's floating
 * point, and get MET from column 2.
 */
int
read_housekeep(char *fname, int colno)
{
	FILE *fp;
	char fline[2048], str[20];
	uint32_t tmet;
	double td;

	if ((fp = fopen(fname, "r")) == NULL)
		return(1);
	if (hk.nmax > 0) {
		free(hk.met);
		free(hk.data);
	}
	hk.n = 0;
	hk.nmax = 0;
	while (fgets(fline, sizeof(fline), fp)) {
		if (fline[0] != '#') {
			if (uint32colval(fline, 2, ' ', &tmet)) {
				fclose(fp);
				return(2);
			}
			/* value might be "null", so no dblcolval() */
			if (strcolval(fline, colno, str, sizeof(str), ' ')) {
				fclose(fp);
				return(3);
			}
			if (strcmp(str, "null")) {
				if (sscanf(str, "%lf", &td) != 1) {
					fclose(fp);
					return(4);
				}
				addtohk(&hk, tmet, td);
			}
		}
	}
	fclose(fp);
	return(0);
}

/* One thing we need for map 11 in particular is a framework to see what
 * voltage the CEMs were at.  Set up to read all of them in.  Leave out the
 * cleverness of figuring out the name of the file to read, but assume it's
 * our standard hi_v1.hk_plot.
 */
int
read_CEMV_housekeep(char *fname)
{
	FILE *fp;
	char fline[2048], str[20];
	uint32_t tmet;
	int i;
	double td;

	if ((fp = fopen(fname, "r")) == NULL)
		return(1);
	for (i = 0; i < 3; i++) {
		if (hk_cems[i].nmax > 0) {
			free(hk_cems[i].met);
			free(hk_cems[i].data);
		}
		hk_cems[i].n = 0;
		hk_cems[i].nmax = 0;
	}
	while (fgets(fline, sizeof(fline), fp)) {
		if (fline[0] != '#') {
			if (uint32colval(fline, 2, ' ', &tmet)) {
				fclose(fp);
				return(2);
			}
			for (i = 0; i < 3; i++) {
				/* value might be "null", so no dblcolval() */
				if (strcolval(fline, 3+i, str, sizeof(str), ' ')) {
					fclose(fp);
					return(3+i);
				}
				if (strcmp(str, "null")) {
					if (sscanf(str, "%lf", &td) != 1) {
						fclose(fp);
						return(6);
					}
					addtohk(hk_cems + i, tmet, td);
				}
			}
		}
	}
	fclose(fp);
	return(0);
}


/* See ibexhi.h for defines.  This will need rewriting every time we turn
 * up the the voltage on the CEMs.
 */
#define _CEM_SLOP  (20.)
static int
get_CEMstatus(double v1, double v2, double v3)
{
	if (fabs(v1 + 1700.) <= _CEM_SLOP &&
	    fabs(v2 + 1700.) <= _CEM_SLOP &&
	    fabs(v3 + 1700.) <= _CEM_SLOP)
		return(CEM_1700);
	if (fabs(v1 + 1780.) <= _CEM_SLOP &&
	    fabs(v2 + 1780.) <= _CEM_SLOP &&
	    fabs(v3 + 1780.) <= _CEM_SLOP)
		return(CEM_1780);
	return(CEM_OTHER);
}

/* Return an integer indicating how we were running the CEMs, or one of two
 * error codes if we don't have enough data or if the CEMs changed between
 * housekeeping points.
 *
 * Search is just like that in get_hkinfo().
 */
int
get_CEMsetting(uint32_t tmet)
{
	int mid, lo, hi;
	
	if (hk_cems[0].n <= 0)
		return(CEM_NODATA);
	lo = 0;
	hi = hk_cems[0].n -1;
	if (tmet < hk_cems[0].met[lo] || tmet > hk_cems[0].met[hi])
		return(CEM_NODATA);
	while (lo < hi) {
		mid = lo + (hi - lo)/2;
		if (hk_cems[0].met[mid] < tmet)
			lo = mid + 1;
		else
			hi = mid;
	}
	if (lo >= hk_cems[0].n || lo == 0)
		return(CEM_NODATA);	/* should never execute */
	/* lo is now the first element where met >= met asked for.
	 * So we want the linear interpolation between lo and lo-1.
	 * Repurpose mid and hi.
	 */
	mid = get_CEMstatus(hk_cems[0].data[lo], hk_cems[1].data[lo],
	    hk_cems[2].data[lo]);
	lo--;
	hi = get_CEMstatus(hk_cems[0].data[lo], hk_cems[1].data[lo],
	    hk_cems[2].data[lo]);
	if (mid == hi)
		return(mid);
	return(CEM_CHANGING);
}

/* Give interpolated value at given time, plus time of closest point
 * Binary search since cadence can change; can't use bsearch() because
 * we don't need an exact MET match.
 * 0 on success.
 */
int
get_hkinfo(uint32_t tmet, double *val, uint32_t *closemet)
{
	int mid, lo, hi;
	double scalef;

	if (hk.n <= 0)
		return(-1);
	lo = 0;
	hi = hk.n -1;
	if (tmet < hk.met[lo] || tmet > hk.met[hi])
		return(-1);
	while (lo < hi) {
		mid = lo + (hi - lo)/2;
		if (hk.met[mid] < tmet)
			lo = mid + 1;
		else
			hi = mid;
	}
	if (lo >= hk.n || lo == 0)
		return(-1);	/* should never execute */
	/* lo is now the first element where met >= met asked for.
	 * So we want the linear interpolation between lo and lo-1.
	 */
	scalef = ((double)tmet - (double)hk.met[lo]) /
	    ((double)hk.met[lo-1] - (double)hk.met[lo]);
	*val = hk.data[lo] + (hk.data[lo-1] - hk.data[lo]) * scalef;
	if (hk.met[lo] - tmet < tmet - hk.met[lo-1])
		*closemet = hk.met[lo];
	else
		*closemet = hk.met[lo-1];
	return(0);
}

char _cem_v_name[PATH_MAX];

/* Return nonzero if you find at least one .hi_v1.hk_plot, and copy the best
 * choice filename into _cem_v_name.  Note assumption that housekeeping
 * starts before HVSCI, which may not be true always.
 */
static int
_look_for_cemhk(DIR *dirp, uint32_t tmet)
{
	struct dirent *dp;
	unsigned long ff, gg;

	gg = 0;
	while ((dp = readdir(dirp)) != NULL) {
		if (dp->d_fileno != 0 && dp->d_namlen > 14 && 
		    (dp->d_type == DT_REG || dp->d_type == DT_LNK) &&
		    !strcmp(dp->d_name + dp->d_namlen - 14, ".hi_v1.hk_plot") &&
		    sscanf(dp->d_name, "%lu", &ff) == 1 &&
		    ff <= tmet && ff > gg) {
			gg = ff;
			strlcpy(_cem_v_name, dp->d_name, PATH_MAX);
		}
	}
	if (gg)
		return(1);
	return(0);
}

/* Convenience:  try to load up the CEM voltage housekeeping given a time
 * in the orbit.  Idea is to look for a filename starting with a uint32_t
 * and ending in .hi_v1.hk_plot, first in $IBEX_MISCDIR/%04d(orbit)/, then
 * if necessary in the cwd, and settling on the highest-numbered version
 * preceding firstmet.
 *
 * Filename is returned in the buffer _cem_v_name.  NULL is the return if
 * nothing was found.
 */
char *
guess_cem_hkname(uint32_t firstmet)
{
	DIR *dirp;
	char *p, bestf[PATH_MAX];
	int i, j;

	if (!is_pointing_inited())
		if (simple_init_inertialpointing("guess_cem_hkname: init_inertial",
		    0))
			return(NULL);
	i = get_orbit_at_met(firstmet, &j);
	if (i > 0 && (p = getenv("IBEX_MISCDIR"))) {
		snprintf(bestf, PATH_MAX, "%s/%04d", p, i);
		dirp = opendir(bestf);
		if (dirp != NULL) {
			if (_look_for_cemhk(dirp, firstmet)) {
				closedir(dirp);
				strlcat(bestf, "/", PATH_MAX);
				strlcat(bestf, _cem_v_name, PATH_MAX);
				strlcpy(_cem_v_name, bestf, PATH_MAX);
				return(_cem_v_name);
			}
			closedir(dirp);
		}
	}
	dirp = opendir(".");
	if (dirp != NULL) {
		if (_look_for_cemhk(dirp, firstmet)) {
			closedir(dirp);
			return(_cem_v_name);
		}
		closedir(dirp);
	}
	return(NULL);
}


#ifdef TESTING
int
main(int argc, char **argv)
{
	int i, j;
	unsigned long m;
	uint32_t x;
	double d;

#if 0
	if (argc < 3 || (j = atoi(argv[2])) <= 2)
		errx(1, "usage:  progname filenametoread columntoread");
	i = read_housekeep(argv[1], j);
	printf("read_housekeep() returned %d.\nEnter MET, 0 to quit\n", i);
	while (scanf("%lu", &m) == 1 && m != 0) {
		i = get_hkinfo(m, &d, &x);
		printf("get_hkinfo() returned %d with value %lf at closest %lu\n",
		    i, d, (long)x);
	}
#else
	if (argc < 2 || (m = strtoul(argv[1], NULL, 10)) < 10)
		errx(1, "usage: progname MET");
	printf("%s\n", guess_cem_hkname(m));
#endif
	return(0);
}
#endif
