/*	$Id: bursts.c,v 1.9 2014/07/25 04:01:28 pjanzen Exp $	*/
/* Look for and report on "bursts".
 * My simple definition of a burst is that some combination of long single
 * histogram types needs to be unusually high for one or two consecutive
 * angle bins, just for one ESA setting, and otherwise things must remain
 * quiet.  It's too complicated to go looking at overly high doubles,
 * although the framework is there to allow it.
 *
 * So go through lA, lB, and lC, all of which are at high cadence.  Per
 * ESA, flag all angle bins for which:
 *   there are at least <n> counts
 *   counts are fractionally <x> more than in the avg/max? of the 2 hbs
 * before or the 2 after
 *   counts are NOT fractionally <x> more than in the avg/max? of the 2 hbs
 * before/after in the other ESAs.
 *
 * For any such where B and A or C are correlated, print out a summary:
 * MET, ESA, angle bin, lA, lB, lC, lAB, lBC, qABC vs nearby.
 *
 * Don't do anything about short packets; assume that it's only really
 * sensible if we did a -c -c, but that if we do so we haven't checked
 * everywhere for bursting.
 *
 * Entry point is print_bursts().  Zero verbosity means simply a count of
 * bursts is returned; positive prints singles (1+), doubles (2+), and
 * triples(3+).  Negative verbosity prints summary lines, one per burst,
 * for analysis (MET, ESA, angle bin, excess lA lB lC lAB lAC lBC qABC).
 */

#include <stdio.h>
#include <stdlib.h>
#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: bursts.c,v 1.9 2014/07/25 04:01:28 pjanzen Exp $";

static void
freefound(garray **clearit, int n)
{
	int j;

	for (j = n - 1; j >= 0; j--)
		free(clearit[j]);
	free(clearit);
}

/* Obtain info for first packet created at or after given met (using slop).
 * The count floor is obtained by averaging the counts
 * before/after/above/below as per findthebursts().
 */
/* internal:  doesn't do any limit checking. */
static void
grabcounts_internal(int i, int esa, int angbin, int *counts, int *flr,
    timelog_c *t, int domax)
{
	double sum;
	int n;

	*counts = (*(t->data[i]))[esa][angbin];
	sum = 0.;
	if (domax) {
		if (i >= 2) {
			sum = (*(t->data[i-1]))[esa][angbin];
			if ((*(t->data[i-2]))[esa][angbin] > sum)
				sum = (*(t->data[i-2]))[esa][angbin];
		} else if (i == 1) {
			sum = (*(t->data[0]))[esa][angbin];
		}
		if (i < t->n - 2) {
			if (sum < (*(t->data[i+1]))[esa][angbin])
				sum = (*(t->data[i+1]))[esa][angbin];
			if (sum < (*(t->data[i+2]))[esa][angbin])
				sum = (*(t->data[i+2]))[esa][angbin];
		} else if (i == t->n - 2) {
			if (sum < (*(t->data[t->n - 1]))[esa][angbin])
				sum = (*(t->data[t->n - 1]))[esa][angbin];
		}
		if (sum < (*(t->data[i]))[esa][(angbin+2) % HI_AZ_BINS])
			sum = (*(t->data[i]))[esa][(angbin+2) % HI_AZ_BINS];
		if (sum < (*(t->data[i]))[esa][(angbin+3) % HI_AZ_BINS])
			sum = (*(t->data[i]))[esa][(angbin+3) % HI_AZ_BINS];
		if (sum < (*(t->data[i]))[esa][(HI_AZ_BINS+angbin-2) % HI_AZ_BINS])
			sum = (*(t->data[i]))[esa][(HI_AZ_BINS+angbin-2) % HI_AZ_BINS];
		if (sum < (*(t->data[i]))[esa][(HI_AZ_BINS+angbin-3) % HI_AZ_BINS])
			sum = (*(t->data[i]))[esa][(HI_AZ_BINS+angbin-3) % HI_AZ_BINS];
		*flr = (int)(sum);
	} else {
		n = 0;
		if (i >= 2) {
			sum += ((*(t->data[i-1]))[esa][angbin] +
			    (*(t->data[i-2]))[esa][angbin]) / 2.;
			n++;
		} else if (i == 1) {
			sum += (*(t->data[0]))[esa][angbin];
			n++;
		}
		if (i < t->n - 2) {
			sum += ((*(t->data[i+1]))[esa][angbin] +
			    (*(t->data[i+2]))[esa][angbin]) / 2.;
			n++;
		} else if (i == t->n - 2) {
			sum += (*(t->data[t->n - 1]))[esa][angbin];
			n++;
		}
		sum += ((*(t->data[i]))[esa][(angbin+2) % HI_AZ_BINS] +
		    (*(t->data[i]))[esa][(angbin+3) % HI_AZ_BINS]) / 2.;
		n++;
		sum += ((*(t->data[i]))[esa][(HI_AZ_BINS+angbin-2) % HI_AZ_BINS] +
		    (*(t->data[i]))[esa][(HI_AZ_BINS+angbin-3) % HI_AZ_BINS]) / 2.;
		n++;
		*flr = (int)(sum / n);
	}
}

static void
grabcounts(uint32_t tmet, int esa, int angbin, int *counts, int *flr,
    int hbt)
{
	int i;

	*counts = *flr = 0;
	i = 0;
	while (i < hbs[hbt].n && tmet - HBtimeSlop > hbs[hbt].met[i])
		i++;
	if (i == hbs[hbt].n)
		return;
	grabcounts_internal(i, esa, angbin, counts, flr, hbs + hbt, 0);
}

/* Given an array of data, malloc and return an array of 0 or 1, as per
 * where bursts are likely.
 *
 * domax:  choose max of two nearest neighbours, rather than avg.
 * XXX not enabled at present
 */
static garray **
findthebursts(int mincnts, double fracthresh, int domax, timelog_c *targ)
{
	garray **bst, *tmp;
	int i, j, k, l;
	int blip[HI_ENERGIES];
	int counts, flr;

	if ((bst = calloc(sizeof(garray *), targ->n)) == NULL)
		return(NULL);
	for (i = 0; i < targ->n; i++) {
		if ((tmp = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL) {
			freefound(bst, i - 1 > 0 ? i - 1 : 0);
			return(NULL);
		}
		bst[i] = tmp;
	}
	/* Do the checking, then */
	for (i = 0; i < targ->n; i++) {
		for (j = 0; j < HI_AZ_BINS; j++) {
			for (k = 0; k < HI_ENERGIES; k++) {
				blip[k] = 0;
				if ((*(targ->data[i]))[k][j] >= mincnts) {
					grabcounts_internal(i, k, j, &counts, &flr,
					    targ, 1);
					if ((flr <= 0 ||
					    (double)counts/ (double)flr > fracthresh) &&
					    (counts - flr) > mincnts)
						blip[k] = 1;
				}
			}
			/* At this point we've flagged everything we think might be
			 * a blip, at all ESAs for one angle.  Stop flagging it as
			 * such if it shows up at multiple ESAs, because that would
			 * be a signal, not a burst.
			 */
			l = 0;
			for (k = 0; k < HI_ENERGIES; k++)
				if (blip[k])
					l++;
			if (l == 1)	/* Keep this one! */
				for (k = 0; k < HI_ENERGIES; k++)
					(*(bst[i]))[k][j] = blip[k];
		}
	}
	/* Return, don't free, so it can get used further */
	return(bst);
}

burst_rec *
return_bursts(int mincnts, double fracthresh, int verbosity, int *nb)
{
	garray **la, **lb, **lc;
	int i, j, k, n;
	int cts, ctfloor;
	burst_rec *p;
	int bnp;

	*nb = 0;
	bnp = 0;
	lb = lc = NULL;
	if ((la = findthebursts(mincnts, fracthresh, 1, hbs + HB_LA)) == NULL ||
	    (lb = findthebursts(mincnts, fracthresh, 1, hbs + HB_LB)) == NULL ||
	    (lc = findthebursts(mincnts, fracthresh, 1, hbs + HB_LC)) == NULL) {
		if (lb)
			freefound(lb, hbs[HB_LB].n);
		if (la)
			freefound(la, hbs[HB_LA].n);
		if (verbosity != 0)
			printf("Whoops!  Out of memory in return_bursts()\n");
		return(NULL);
	}
	bnp = 8;
	if ((p = (burst_rec *)calloc(bnp, sizeof(burst_rec))) == NULL) {
		freefound(lc, hbs[HB_LC].n);
		freefound(lb, hbs[HB_LB].n);
		freefound(la, hbs[HB_LA].n);
		if (verbosity != 0)
			printf("Whoops!  Out of memory in return_bursts()\n");
		return(NULL);
	}
	/* Compare:  we need to see something in at least 2 CEMs to care.
	 * It's actually pretty bizarre if we don't have the same number of
	 * hbs for LA, LB, and LC, but in such a case assume they line up on
	 * the left and just truncate.
	 */
	n = hbs[HB_LA].n;
	if (hbs[HB_LB].n != n) {
		if (verbosity > 0)
			printf("Warning:  return_bursts(): number of lA and lB do not line up.  (?!)\n");
		if (hbs[HB_LB].n < n)
			n = hbs[HB_LB].n;
	}
	if (hbs[HB_LC].n != n) {
		if (verbosity > 0)
			printf("Warning:  return_bursts(): number of lA/lB and lC do not line up.  (?!)\n");
		if (hbs[HB_LC].n < n)
			n = hbs[HB_LC].n;
	}
	for (i = 0; i < n; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
			for (k = 0; k < HI_AZ_BINS; k++) {
				if ((*(la[i]))[j][k] + (*(lb[i]))[j][k] +
				    (*(lc[i]))[j][k] >= 2) {
					if (*nb == bnp) {
						burst_rec *tmpbp;

						bnp += 8;
						/* Too bad recalloc() isn't portable */
						if ((tmpbp = (burst_rec *)realloc(p,
						    bnp * sizeof(burst_rec))) == NULL) {
							free(p);
							freefound(lc, hbs[HB_LC].n);
							freefound(lb, hbs[HB_LB].n);
							freefound(la, hbs[HB_LA].n);
							if (verbosity != 0)
			printf("Whoops!  Out of memory in return_bursts()\n");
							return(NULL);
						}
						p = tmpbp;
					}
					p[*nb].met = hbs[HB_LA].met[i];
					p[*nb].ESA = j;
					p[*nb].angbin = k;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_QABC);
					p[*nb].qABC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LABC);
					p[*nb].lABC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_QAB);
					p[*nb].qAB = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LAB);
					p[*nb].lAB = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_QAC);
					p[*nb].qAC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LAC);
					p[*nb].lAC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_QBC);
					p[*nb].qBC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LBC);
					p[*nb].lBC = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LA);
					p[*nb].lA = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LB);
					p[*nb].lB = cts - ctfloor;
					grabcounts(hbs[HB_LA].met[i], j, k, &cts,
					    &ctfloor, HB_LC);
					p[*nb].lC = cts - ctfloor;
					(*nb)++;
				}
			}
		}
	}
	freefound(lc, hbs[HB_LC].n);
	freefound(lb, hbs[HB_LB].n);
	freefound(la, hbs[HB_LA].n);
	return(p);
}

void
print_bursts(int mincnts, double fracthresh, int verbosity)
{
	int i, sum;
	int cts, ctfloor;
	burst_rec *p;

	p = return_bursts(mincnts, fracthresh, verbosity, &sum);
	if (!p)
		sum = -1;
	for (i = 0; i < sum; i++) {
		if (verbosity > 0) {
			printf("Burst detected:");
			printf("\tMET %u  ESA %d  angle bin %d\n",
			    p[i].met, p[i].ESA + 1, p[i].angbin);
		} else if (verbosity < 0) {
			if (i == 0)
				printf("#\tMET\tESA\tang\tlA\tlB\tlC\tlAB\tlAC\tlBC\tqABC\n");
			printf("%u\t%d\t%d\t", p[i].met, p[i].ESA + 1, p[i].angbin);
			grabcounts(hbs[HB_LA].met[i], p[i].ESA, p[i].angbin, &cts,
			    &ctfloor, HB_LA);
			printf("%d\t%d\t%d\t", p[i].lA, p[i].lB, p[i].lC);
			printf("%d\t%d\t%d\t", p[i].lAB, p[i].lAC, p[i].lBC);
			printf("%d\n", p[i].qABC);
		}
		if (verbosity > 3) {
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_QABC);
			printf("\tqABC %d (floor approx %d)\n", cts, ctfloor);
/*
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LABC);
			printf("\tlABC %d (floor approx %d)\n", cts, ctfloor);
*/
		}
		if (verbosity > 2) {
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LAB);
			printf("\tlAB %d (floor %d)  ", cts, ctfloor);
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LAC);
			printf("\tlAC %d (floor %d)  ", cts, ctfloor);
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LBC);
			printf("\tlBC %d (floor %d)\n", cts, ctfloor);
		}
		if (verbosity > 1) {
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LA);
			printf("\tlA  %d (floor %d)  ", cts, ctfloor);
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LB);
			printf("\tlB  %d (floor %d)  ", cts, ctfloor);
			grabcounts(p[i].met, p[i].ESA, p[i].angbin, &cts, &ctfloor,
			    HB_LC);
			printf("\tlC  %d (floor %d)\n", cts, ctfloor);
			printf("\n");
		}
	}
	if (verbosity >= 0)
		printf("Total possible bursts seen: %d\n", sum);
	if (p)
		free(p);
}
