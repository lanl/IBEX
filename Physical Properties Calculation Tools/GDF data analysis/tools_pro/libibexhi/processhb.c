/*	$Id: processhb.c,v 1.44 2018/04/06 01:20:34 pjanzen Exp $	*/
/* Logical stuff to do with histogram bins other than plotting them.
 */

#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "compression.h"

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: processhb.c,v 1.44 2018/04/06 01:20:34 pjanzen Exp $";


int
get_max_E(int flagger)
{
	int i;

	i = 1;
	switch (flagger) {
	case TLC_HIHB:
	case TLC_HIDE:
		i = HI_ENERGIES;
		break;
	case TLC_BM:
		i = HI_BG_SWEEPS;
		break;
	case TLC_LOH:
		i = LO_ENERGIES;
		break;
	default:
		warnx("get_max_E() called with unknown data type");
		break;
	}
	return(i);
}

/* Convenience for elsewhere */
int
get_max_bmcounts()
{
	return(bm_uncomp(0xFF));
}

/* Return and possibly print number of overflows.  If printhow is negative,
 * don't print.  If printing, merely report number of overflows (as opposed
 * to each one individually) if printhow is zero.  If printhow is 1,
 * summarize energies and angles at a given time.  If it's 2, summarize by
 * angles, not by E.
 * XXX might want to test somewhere that pd_uncomp(0xFF) in fact returns
 * PD_SATURATED_IN as it's supposed to, and bm_uncomp(0xFF) in fact returns
 * BM_SATURATED_IN.
 */
int
print_hb_overflows(timelog_c thang, int print_how)
{
	int i, j, k;
	int ntot, nthist, nthisE;

	ntot = 0;
	for (i = 0; i < thang.n; i++) {
		nthist = 0;
		for (j = 0; j < HI_ENERGIES; j++) {
			nthisE = 0;
			for (k = 0; k < HI_AZ_BINS; k++) {
				if ((*thang.data[i])[j][k] == PD_SATURATED_IN) {
					ntot++;
					nthist++;
					nthisE++;
					if (print_how > 2)
						printf("%s: overflow at E %d az %d MET %u\n",
						    thang.name, j, k, thang.met[i]);
				}
			}
			if (print_how == 2 && nthisE)
				printf("%s: %d overflows at E %d MET %u\n",
				    thang.name, nthisE, j, thang.met[i]);
		}
		if (print_how == 1 && nthist)
			printf("%s: %d overflows at MET %u\n",
			    thang.name, nthist, thang.met[i]);
	}
	if (print_how == 0)
		printf("%s: total overflows seen: %d\n", thang.name, ntot);
	return(ntot);
}
int
print_bm_overflows(timelog_c thang, int print_how)
{
	int i, j, k;
	int ntot, nthist, nthisE;
	int bmunc;

	/* XXX It appears that for whatever default compression scheme is in
	 * place, we don't get the defined saturated value.  So uncompress
	 * 0xFF and use it.
	 */
	bmunc = get_max_bmcounts();
	ntot = 0;
	for (i = 0; i < thang.n; i++) {
		nthist = 0;
		for (j = 0; j < HI_BG_SWEEPS; j++) {
			nthisE = 0;
			for (k = 0; k < HI_AZ_BINS; k++) {
				if ((*thang.data[i])[j][k] == bmunc /*BM_SATURATED_IN*/ ) {
					ntot++;
					nthist++;
					nthisE++;
					if (print_how > 2)
						printf("%s: overflow at E %d az %d MET %u\n",
						    thang.name, j, k, thang.met[i]);
				}
			}
			if (print_how == 2 && nthisE)
				printf("%s: %d overflows at E %d MET %u\n",
				    thang.name, nthisE, j, thang.met[i]);
		}
		if (print_how == 1 && nthist)
			printf("%s: %d overflows at MET %u\n",
			    thang.name, nthist, thang.met[i]);
	}
	if (print_how == 0)
		printf("%s: total overflows seen: %d\n", thang.name, ntot);
	return(ntot);
}

/* Return and possibly print number of compressions.  If printhow is negative,
 * don't print.  If printing, merely report number of overflows (as opposed
 * to each one individually) if printhow is zero.  If printhow is 1,
 * summarize energies and angles at a given time.  If it's 2, summarize by
 * angles, not by E.
 * Can't do this for background monitor as it's always compressed.
 */
int
print_hb_comps(timelog_c thang, int print_how)
{
	int i, j, k;
	int ntot, nthist, nthisE;

	ntot = 0;
	for (i = 0; i < thang.n; i++) {
		nthist = 0;
		for (j = 0; j < HI_ENERGIES; j++) {
			nthisE = 0;
			for (k = 0; k < HI_AZ_BINS; k++) {
				if ((*thang.data[i])[j][k] > PD_COMPRESS_L) {
					ntot++;
					nthist++;
					nthisE++;
					if (print_how > 2)
						printf("%s: compressed at E %d az %d MET %u\n",
						    thang.name, j, k, thang.met[i]);
				}
			}
			if (print_how == 2 && nthisE)
				printf("%s: %d compressed at E %d MET %u\n",
				    thang.name, nthisE, j, thang.met[i]);
		}
		if (print_how == 1 && nthist)
			printf("%s: %d compressed at MET %u\n",
			    thang.name, nthist, thang.met[i]);
	}
	if (print_how == 0)
		printf("%s: total compressed seen: %d\n", thang.name, ntot);
	return(ntot);
}

int
print_tce(int print_how)
{
	int i, n, w;

	for (i = 0; i < tce.n; i++) {
		n = (*tce.data[i])[0][0];
		w = (*tce.data[i])[0][1];
		if (print_how > 0)
			printf("TOT-LONG %c fails:  %d times, worst %d\n",
			    (char)(*tce.data[i])[0][2], n, w);
	}
	if (print_how == 0 || (print_how < 0 && i))
		printf("TOT-LONG excesses seen:  %d\n", i);
	return(i);
}

static void
drop_hb(int i1, int i2, int i3, int ofs)
{
	int j;

	free(hbs[i1].data[ofs]);
	free(hbs[i2].data[ofs]);
	free(hbs[i3].data[ofs]);
	for (j = ofs+1; j < hbs[i1].n; j++) {
		hbs[i1].met[j-1] = hbs[i1].met[j];
		hbs[i1].spincount[j-1] = hbs[i1].spincount[j];
		hbs[i1].data[j-1] = hbs[i1].data[j];
		hbs[i2].met[j-1] = hbs[i2].met[j];
		hbs[i2].spincount[j-1] = hbs[i2].spincount[j];
		hbs[i2].data[j-1] = hbs[i2].data[j];
		hbs[i3].met[j-1] = hbs[i3].met[j];
		hbs[i3].spincount[j-1] = hbs[i3].spincount[j];
		hbs[i3].data[j-1] = hbs[i3].data[j];
	}
	hbs[i1].n--;
	hbs[i2].n--;
	hbs[i3].n--;
}

/* As a general monitor, it's good to show all histogram data that we have.
 * However, for analysis purposes, it's difficult with non-full-count bins
 * to figure out exactly how much time was spent at a given energy.
 * Exiting HVSCI is done on a spin boundary, but the valid-spin-counts
 * field is common for all energies stored in a histogram, and won't
 * necessarily be accurate for all energies if the packet was made early.
 * In nominal ops, we don't go in and out of HVSCI, so it's not an issue,
 * but for the early orbits either Hi or Lo is always popping in and out of
 * HVSCI.
 *
 * This function removes all/most partially filled histogram bins (defined
 * as spin-count neither 48 nor 96), and returns how many it killed.  It
 * should be called prior to any fancy X-work.
 *
 * Operates only on Hi packets, and knows which histograms share a packet.
 */
int
cull_partial_hbs(int verbosity)
{
	int i, nq, nm, nl, nb;

	nq = nm = nl = nb = 0;
	/* HistQ */
	for (i = 0; i < hbs[HB_QABC].n; i++) {
		if (hbs[HB_QABC].spincount[i] != 48) {
			nq++;
			drop_hb(HB_QABC, HB_QAB, HB_QBC, i);
			i--;
		}
	}
	/* HistM */
	for (i = 0; i < hbs[HB_LAB].n; i++) {
		if (hbs[HB_LAB].spincount[i] != 48) {
			nm++;
			drop_hb(HB_LAB, HB_QAC, HB_LB, i);
			i--;
		}
	}
	/* HistL */
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		if (hbs[HB_LABC].spincount[i] != 96) {
			nl++;
			drop_hb(HB_LABC, HB_LAC, HB_LBC, i);
			i--;
		}
	}
	/* Background */
	for (i = 0; i < hbs[HB_LA].n; i++) {
		if (hbs[HB_LA].spincount[i] != 48) {
			nb++;
			drop_hb(HB_LA, HB_LC, HB_BM, i);
			i--;
		}
	}
	if (verbosity > 0)
		printf("Culled %d Q, %d M, %d L, %d BM non-full spins\n",
		    nq, nm, nl, nb);
	return(nq + nm + nl + nb);
}

static uint32_t
min4w(uint32_t a, uint32_t b, uint32_t c, uint32_t d, int *whch)
{
	uint32_t tmp;

	tmp = (a < b ? a:b);
	tmp = (tmp < c ? tmp : c);
	tmp = (tmp < d ? tmp : d);
	if (tmp == a)
		*whch = 0;
	else if (tmp == b)
		*whch = 1;
	else if (tmp == c)
		*whch = 2;
	else
		*whch = 3;
	return(tmp);
}

/* If we've already done the above culling, we can cull further to remove
 * high-cadence packets that have no low-cadence analog.  In other words,
 * keep no more than the two most recent high-cadence packets up to a
 * slow-cadence one.
 * First, though, make sure we have one of each kind of packet when we
 * should.
 */
int
further_cull_hbs(int verbosity)
{
	int i, nq, nm, nl, nb;
	int i1, i2, i4;
	uint32_t c;

	nq = nm = nl = nb = 0;
	if (hbs[HB_QABC].n == 0 || hbs[HB_LAB].n == 0 || hbs[HB_LABC].n == 0 ||
	    hbs[HB_LA].n == 0)
		errx(1, "No packets after culling.");
	i1 = i2 = i4 = 0;
	do {
		/* Misusing min4w for 3 variables since we don't want low cadence */
		c = min4w(hbs[HB_QABC].met[i1], hbs[HB_LAB].met[i2],
		    hbs[HB_QABC].met[i1], hbs[HB_LA].met[i4], &i);
		if (hbs[HB_QABC].met[i1] - HBtimeSlop > c ||
		    hbs[HB_LAB].met[i2] - HBtimeSlop > c ||
		    hbs[HB_LA].met[i4] - HBtimeSlop > c) {
			/* Cull */
			if (hbs[HB_QABC].met[i1] - HBtimeSlop <= c) {
				drop_hb(HB_QABC, HB_QAB, HB_QBC, i1);
				nq++;
			}
			if (hbs[HB_LAB].met[i2] - HBtimeSlop <= c) {
				drop_hb(HB_LAB, HB_QAC, HB_LB, i2);
				nm++;
			}
			if (hbs[HB_LA].met[i4] - HBtimeSlop <= c) {
				drop_hb(HB_LA, HB_LC, HB_BM, i4);
				nb++;
			}
		} else {
			i1++;
			i2++;
			i4++;
		}
	} while (i1 < hbs[HB_QABC].n && i2 < hbs[HB_LAB].n && i4 < hbs[HB_LA].n);
	while (i1 < hbs[HB_QABC].n) {
		drop_hb(HB_QABC, HB_QAB, HB_QBC, i1);
		nq++;
	}
	while (i2 < hbs[HB_LAB].n) {
		drop_hb(HB_LAB, HB_QAC, HB_LB, i2);
		nm++;
	}
	while (i4 < hbs[HB_LA].n) {
		drop_hb(HB_LA, HB_LC, HB_BM, i4);
		nb++;
	}
	if (verbosity > 0)
		printf("Culling to match high cadence times:  %d Q, %d M, %d BM\n",
		    nq, nm, nb);

	nb = 0;
	i1 = 0;
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		while (i1 < hbs[HB_QABC].n &&
		    hbs[HB_QABC].met[i1] + HBtimeSlop < hbs[HB_LABC].met[i])
			i1++;
		if (i1 >= hbs[HB_QABC].n ||
		    hbs[HB_LABC].met[i] + HBtimeSlop < hbs[HB_QABC].met[i1]) {
			drop_hb(HB_LABC, HB_LBC, HB_LAC, i);
			i--;
			nb++;
		}
	}
	if (verbosity > 0)
		printf("Culling to match low cadence times to missing high cadence times:  %d L\n", nb);
	nm = nb = nq = 0;
	i1 = i2 = i = 0;
	do {
		/* printf("hi %u  lo %u  ", hbs[HB_QABC].met[i1],
		    hbs[HB_LABC].met[i2]); */
		if (hbs[HB_QABC].met[i1] - HBtimeSlop <= hbs[HB_LABC].met[i2]) {
			if (i == 2) {
				/* printf("-->TRIMMING HI (%d %d)\n", i1, i2); */
				/* Trim oldest */
				drop_hb(HB_QABC, HB_QAB, HB_QBC, i1 - i);
				drop_hb(HB_LAB, HB_QAC, HB_LB, i1 - i);
				drop_hb(HB_LA, HB_LC, HB_BM, i1 - i);
				nq++;
				nm++;
				nb++;
			} else {
				/* printf("ok, incing hi\n"); */
				i++;
				i1++;
			}
		} else {
			if (i != 2) {
				/* Not enough high cadence!  Should never happen */
				if (i) {
					/* printf("--> TRIMMING HI (%u)",
					    hbs[HB_QABC].met[i1-i]); */
					drop_hb(HB_QABC, HB_QAB, HB_QBC, i1 - i);
					drop_hb(HB_LAB, HB_QAC, HB_LB, i1 - i);
					drop_hb(HB_LA, HB_LC, HB_BM, i1 - i);
					nq++;
					nm++;
					nb++;
					i1--;
				}
				/* printf("---> TRIMMING LO (%u)\n",
				    hbs[HB_LABC].met[i2]); */
				drop_hb(HB_LABC, HB_LBC, HB_LAC, i2);
				nl++;
			} else {
				/* printf("ok, incing lo\n"); */
				i2++;
			}
			i = 0;
		}
	} while (i1 < hbs[HB_QABC].n && i2 < hbs[HB_LABC].n);
	while (i1 < hbs[HB_QABC].n) {
		drop_hb(HB_QABC, HB_QAB, HB_QBC, i1);
		drop_hb(HB_LAB, HB_QAC, HB_LB, i1);
		drop_hb(HB_LA, HB_LC, HB_BM, i1);
		nq++;
		nm++;
		nb++;
	}
	i2++;
	while (i2 < hbs[HB_LABC].n) {
		drop_hb(HB_LABC, HB_LBC, HB_LAC, i2);
		nl++;
	}
	if (verbosity > 0)
		printf("Culling to match high and low cadence:  %d Q,M,BM; %d L\n",
		    nq, nl);
	return(nq + nm + nl + nb);
}

/* In theory we expect Q, M, and BM every 48 spins and L every 96.  This is
 * LUT-adjustable.  What we theoretically do NOT expect to see are packets
 * that are slightly offset in time.  They should all get created at once.
 * Yet they don't.  I'll try to quantify this by looking for packets that
 * are created within 100 seconds of each other, but not at the same time.
 * It takes 6 minutes, give or take, to complete one full energy sweep, so
 * 100s is reasonable.
 *
 * There is a bunch of similar code in xhihb.c:main().
 *
 * print_how is a little different than usual:  it prints data if the
 * summed offsets are greater than print_how if print_how > 0, a summary
 * if print_how == 0, and a summary if it's interesting if print_how < 0.
 */
int
print_timing(int print_how)
{
	int i1, i2, i3, i4;
	uint32_t mt, a, b, c, d;
	int i, j, k;
	int sum;
	const char *packname[] = {"histQ", "histM", "histL", "bgnd"};

	i1 = i2 = i3 = i4 = 0;
	mt = min4w(hbs[HB_QABC].met[0], hbs[HB_LAB].met[0], hbs[HB_LABC].met[0],
	    hbs[HB_LA].met[0], &j);
	i = k = 0;
	do {
		while (i1 < hbs[HB_QABC].n && hbs[HB_QABC].met[i1] <= mt)
			i1++;
		if (i1 == hbs[HB_QABC].n)
			a = 0xFFFFFFFF;
		else
			a = hbs[HB_QABC].met[i1];
		while (i2 < hbs[HB_LAB].n && hbs[HB_LAB].met[i2] <= mt)
			i2++;
		if (i2 == hbs[HB_LAB].n)
			b = 0xFFFFFFFF;
		else
			b = hbs[HB_LAB].met[i2];
		while (i3 < hbs[HB_LABC].n && hbs[HB_LABC].met[i3] <= mt)
			i3++;
		if (i3 == hbs[HB_LABC].n)
			c = 0xFFFFFFFF;
		else
			c = hbs[HB_LABC].met[i3];
		while (i4 < hbs[HB_LA].n && hbs[HB_LA].met[i4] <= mt)
			i4++;
		if (i4 == hbs[HB_LA].n)
			d = 0xFFFFFFFF;
		else
			d = hbs[HB_LA].met[i4];
		if (k) {
			k = 0;
			mt = min4w(a, b, c, d, &j);
		} else if (((a - mt <= 100) && (a - mt > 0)) ||
		    ((b - mt <= 100) && (b - mt > 0)) ||
		    ((c - mt <= 100) && (c - mt > 0)) ||
		    ((d - mt <= 100) && (d - mt > 0))) {
			i++;
			if (print_how > 0) {
				sum = (a-mt < 100 ? a-mt:0) + (b-mt < 100 ? b-mt:0) +
				    (c-mt < 100 ? c-mt:0) + (d-mt < 100 ? d-mt:0);
				if (sum >= print_how)
	printf("Hist mistiming at %u: %s  offsets(Q,L,M,bg) %d %d %d %d\n",
					    mt, packname[j], (a-mt < 100 ? a-mt:0),
					    b-mt < 100 ? b-mt:0, c-mt < 100 ? c-mt:0,
					    d-mt < 100 ? d-mt:0);
			}
			mt += 100;
			k = 1;
		} else
			mt = min4w(a, b, c, d, &j);
	} while (0xFFFFFFFF > mt);
	if (print_how == 0 || (print_how < 0 && i))
		printf("Total sloppy histogram timings:  %d\n", i);
	return(i);
}

static int
comp_hb_de_cmp(const void *a, const void *b)
{
	return(*((int *)a) - *((int *)b));
}
int
get_cadence(timelog_c *p, int *nomspins)
{
	int *dt, *dts;
	int i, n;
	int dtmed;

	n = p->n - 1;
	if (n < 3)
		return(-1);
	if ((dt = (int *)malloc(n * sizeof(int))) == NULL ||
	    (dts = (int *)malloc(n * sizeof(int))) == NULL) {
		if (dt)
			free(dt);
		printf("get_cadence:  no malloc space.\n");
		return(-1);
	}
	for (i = 0; i < n; i++) {
		dt[i] =  (p->met)[i+1] - (p->met)[i];
		dts[i] = (p->spincount)[i];
	}
	qsort(dt, n, sizeof(int), comp_hb_de_cmp);
	qsort(dts, n, sizeof(int), comp_hb_de_cmp);
	dtmed = dt[n/2 + 1];
	*nomspins = dts[n/2 + 1];
	free(dt);
	free(dts);
	return(dtmed);
}

static void
compare_hbde_gotone(int i, int j, int slop)
{
	int k, l, az;
	long sumtrip[HI_ENERGIES], sumdub[HI_ENERGIES];
	long sd, st;

	/* Note we start officially a second after the first
	 * packet creation time.  We don't use the first packet.
	 * Because we expect to have half-cadence data, we
	 * don't use the second packet either.
	 * We also don't use the last packet, but it's at
	 * location i+1 anyhow.  Make sure we do an even number
	 * of packets.
	 */
	if ((i - (j + 3)) % 2)
		i--;
	printf("HVSCI interval %u to %u (lAB+qAC+lBC, qABC): %d qABC histograms\n",
	    hbs[HB_QABC].met[j+1] + 1, hbs[HB_QABC].met[i], i - j - 1);
	j++;
	j++;
	for (l = 0; l < HI_ENERGIES; l++)
		sumtrip[l] = sumdub[l] = 0;
	for (k = j; k <= i; k++)
		for (l = 0; l < HI_ENERGIES; l++)
			for (az = 0; az < HI_AZ_BINS; az++)
				sumtrip[l] += (*hbs[HB_QABC].data[k])[l][az];
	/* A bit trickier for summed doubles as none of them
	 * live in the same packet as qABC.
	 */
	k = 0;
	while (k < hbs[HB_LAB].n &&
	    hbs[HB_LAB].met[k] + slop < hbs[HB_QABC].met[j])
		k++;
	while (k < hbs[HB_LAB].n &&
	    hbs[HB_LAB].met[k] < slop + hbs[HB_QABC].met[i]) {
		for (l = 0; l < HI_ENERGIES; l++)
			for (az = 0; az < HI_AZ_BINS; az++) {
				sumdub[l] += (*hbs[HB_LAB].data[k])[l][az];
				/* qAC is in same packet */
				sumdub[l] += (*hbs[HB_QAC].data[k])[l][az];
			}
		k++;
	}
	k = 0;
	while (k < hbs[HB_LBC].n &&
	    hbs[HB_LBC].met[k] + slop < hbs[HB_QABC].met[j])
		k++;
	while (k < hbs[HB_LBC].n &&
	    hbs[HB_LBC].met[k] < slop + hbs[HB_QABC].met[i]) {
		for (l = 0; l < HI_ENERGIES; l++)
			for (az = 0; az < HI_AZ_BINS; az++)
				sumdub[l] += (*hbs[HB_LBC].data[k])[l][az];
		k++;
	}
	sd = st = 0;
	for (l = 0; l < HI_ENERGIES; l++) {
		printf("ESA %d:\t%ld\t%ld\n", l + 1,
		    sumdub[l], sumtrip[l]);
		sd += sumdub[l];
		st += sumtrip[l];
	}
	printf("All E:\t%ld\t%ld\n\n", sd, st);
}
/* We'd like to check if DEs drop counts noticeably.  Complications to this
 * task include (1) from what I can tell, reading DEs is a royal pain, so
 * much so that I think I want to use Geoff's meta-event output  and
 * (2) timing of histogram bins is only good to a second.
 *
 * So what this function does is spit out time ranges that it thinks should
 * be good for comparisons to DEs, plus summed qABCs and summed-doubles in
 * total and for each energy.  Eventually it'll spit out a script to
 * run to compare.  Longer time ranges are better than shorter to even out
 * the 1s resolution...
 *
 * Time ranges that it likes:  it sorts qABCs (if there are more than
 * 2 * mingroup) and gets the median time delta.  It then looks for
 * sequences of packets of length at least mingroup + 2 (or mingroup + 3 if
 * mingroup is odd) where the deltas are always within slop s of median.  This
 * is assumed to be a solid HVSCI time block - without SOH packets we have
 * no other measure.
 * We drop the first packet (when HVSCI starts) and the last packet (when
 * HVSCI ends), leaving an even number of consecutive packets (since some
 * packets come at half cadence).  That's what we sum.
 *
 * suggest slop = 5.
 */
void
compare_hb_to_de(int mingroup, int slop)
{
	int *dt, *dts;
	int i, j, n;
	int dtmed;

	if (mingroup < 20) {
		printf("compare_hb_to_de:  mingroup is silly short.\n");
		return;
	}
	if (mingroup % 2)
		mingroup++;
	n = hbs[HB_QABC].n - 1;
	if (n < 2 * mingroup) {
		printf("compare_hb_to_de:  not enough HVSCI data to work with.\n");
		return;
	}
	if ((dt = (int *)malloc(n * sizeof(int))) == NULL ||
	    (dts = (int *)malloc(n * sizeof(int))) == NULL) {
		if (dt)
			free(dt);
		printf("compare_hb_to_de:  no malloc space.\n");
		return;
	}
	for (i = 0; i < n; i++) {
		dt[i] = dts[i] = hbs[HB_QABC].met[i+1] - hbs[HB_QABC].met[i];
	}
	qsort(dt, n, sizeof(int), comp_hb_de_cmp);
	dtmed = dt[n/2];
	printf("qABC cadence median: %ds (implies %.3lf rpm)\n", dtmed,
	    (double)48. * 60./dtmed);
	j = -1;
	for (i = 0; i < n; i++) {
		if (abs(dtmed - dts[i]) < slop) {
			/* We're in a "good bunch" - start if not yet initialized */
			if (j < 0)
				j = i;
		} else {
			/* We might be exiting a "good bunch" - see if it's long
			 * enough and if it is, go to.
			 */
			if ((j >= 0) && (i - j >= mingroup + 1))
				compare_hbde_gotone(i, j, slop);
			j = -1;
		}
	}
	if ((j >= 0) && (i - j >= mingroup + 1))
		compare_hbde_gotone(i, j, slop);
	free(dt);
	free(dts);
}

/* Get the qABC cosmic BG rate from unqABC rate, qABC rate, and a factor
 * related to ESA setting correlating "signal" qABC to "signal" unqABC.
 */
static double
bgs_calc(double x, double y, double z, double ratio)
{
	return((x - z * y) / (1 - z * ratio));
}
static double _bgcrrate;
static double _bgcrunc;
/* Assuming we've done a vigorous culling, it will be useful to see what
 * the unqualified ABC and AC rates are, as a measure of background; we
 * could plot it orbit to orbit (if we want higher resolution, we'll need
 * to use -a and -z options on the command line).  People may want to
 * confirm that it's the same at all ESA settings, as well.
 *
 * Because our unqualified rate depends slightly on our signal, and our
 * signal can be high in the magnetosphere, this function takes as an
 * argument the maximum qABC counts allowed before that histogram bin
 * is discarded as being too contaminated with signal to allow a decent
 * background measurement.  This is the counts over TWO qABCs - it has to
 * line up with the lower-cadence packets.
 *
 * An additional feature:  the ESA 1, zero-degree bin always undercounts;
 * the theory is that this is a design feature because that's ESA ramping
 * time.  It means though that that one angle bin has to be discarded to
 * get true bg rates.  We do this, just for ESA 1 for now.
 *
 * XXX based on the orbit 13 data, there could possibly be something else
 * going on with ESA 1.  Maybe this function can help settle that.
 *
 * Because histogram bin timing can be jumpy if the star tracker is
 * pooching, timing is done based on MET timestamps.
 * Note:  as a result, this function does NOT use HB_TIME, nor does it take
 * a hb_time calculated from the osbd[2b]a files.  It will never get the
 * time perfectly accurately, but for a typical orbit it's averaging over a
 * few hundred hb packets, so it'll get close -- well inside 1 second on a
 * 690s base.  For the time being, the uncertainty will be dominated by
 * Poisson stats and by the unqABC/qABC ratio determined from background
 * tests, which is, as of orbit 189, about 3%.  So IGNORE this timing
 * uncertainty for now.  Note to do exactly right is very annoying, since I
 * nominally calculate backgrounds per orbit, not per orbit arc, and hbtime
 * is arc-dependent.  Note also the approximation that penetrating
 * background doesn't change over an orbit.  XXX to revisit.
 *
 * You may theoretically want to study penetrating background vs angle.
 * If so, set ang1 and ang2 sanely; this will not wrap.  The angle range
 * is ang1 to (ang2 - 1).  Note that using globals to store values becomes
 * pretty silly here.
 *
 * NOTE:  if you want SEP events removed, you need to include a non-NULL
 * SEP list -- times within the range will not be included.
 */
static void
print_bgs_t(int qualthresh, int verbosity, uint32_t met1, uint32_t met2,
    int ang1, int ang2, SEPlist *sepl, int limit_v)
{
	long unqABC[HI_ENERGIES], unqAC[HI_ENERGIES];
	long qqABC[HI_ENERGIES];
	int nunq[HI_ENERGIES], ndrop[HI_ENERGIES];
	long nt[HI_ENERGIES];
	int ntg[HI_ENERGIES], ntb[HI_ENERGIES];
#ifdef DO_SINGLES
	long llA[HI_ENERGIES], llB[HI_ENERGIES], llC[HI_ENERGIES];
#endif
	long temp1, temp2, temp3, temp4;
	int i, j, k, l;
	int mi;
	double ubest, umin, umax;
	double t1, t2, t3, t4;
	int nesas;
	double sbgs, slowbgs, shibgs, pseudopoiss;
	double angconvfactor;
	double ratiolq, ratiolqunc, ratioqu, ratioquunc;
	uint32_t rmet1, rmet2, usemet;

	if (ang1 < 0)
		ang1 = 0;
	if (ang2 < 0)
		ang2 = 0;
	if (ang1 >= HI_AZ_BINS)
		ang1 = HI_AZ_BINS - 1;
	if (ang2 > HI_AZ_BINS)
		ang2 = HI_AZ_BINS;
	rmet1 = rmet2 = 0;
	angconvfactor = HI_AZ_BINS/(double)(ang2 - ang1);
	nesas = 0;
	sbgs = slowbgs = shibgs = pseudopoiss = 0.0;
	for (i = 0; i < HI_ENERGIES; i++) {
		unqABC[i] = unqAC[i] = qqABC[i] = nt[i] = 0;
		nunq[i] = ndrop[i] = ntg[i] = ntb[i] = 0;
#ifdef DO_SINGLES
		llA[i] = llB[i] = llC[i] = 0;
#endif
	}
	/* If we culled, things have to line up:  there are twice as many qABC
	 * histograms as lABC histograms.  Check anyhow and warn, then assume
	 * (in a safe manner) it's the case.
	 */
	if (hbs[HB_LABC].n * 2 != hbs[HB_QABC].n ||
	    hbs[HB_QAC].n != 2 * hbs[HB_LAC].n) {
		if (verbosity > -100000) {
			printf("Warning: print_bgs_t() called on non-culled data!\n");
			printf("         Proceeding cautiously nonetheless...\n");
		}
	}
	mi = hbs[HB_LABC].n;
	if (hbs[HB_LAC].n < mi)
		mi = hbs[HB_LAC].n;
	if (hbs[HB_QABC].n < 2 * mi)
		mi = hbs[HB_QABC].n / 2;
	if (hbs[HB_QAC].n < 2 * mi)
		mi = hbs[HB_QAC].n / 2;
	for (i = 0; i < mi; i++) {
		if (hbs[HB_LABC].met[i] >= met1 && hbs[HB_LABC].met[i] <= met2 &&
		    !in_SEP(hbs[HB_LABC].met[i], sepl) &&
		    (limit_v == 0 || get_CEMsetting(hbs[HB_LABC].met[i]) == limit_v)) {
			/* rmets bracket ACTUAL data collected, in case we want to
			 * find out the ESA settings.
			 */
			if (rmet1 == 0)
				rmet1 = hbs[HB_LABC].met[i];
			if (hbs[HB_LABC].met[i] > rmet2)
				rmet2 = hbs[HB_LABC].met[i];
			for (j = 0; j < HI_ENERGIES; j++) {
				temp1 = temp2 = temp3 = temp4 = 0;
				for (k = ang1; k < ang2; k++) {
					temp1 += (*(hbs[HB_QABC].data[2 * i]))[j][k];
					temp1 += (*(hbs[HB_QABC].data[2 * i + 1]))[j][k];
					temp2 += (*(hbs[HB_LABC].data[i]))[j][k];
					temp3 += (*(hbs[HB_QAC].data[2 * i]))[j][k];
					temp3 += (*(hbs[HB_QAC].data[2 * i + 1]))[j][k];
					temp4 += (*(hbs[HB_LAC].data[i]))[j][k];
				}
				if (temp1 < qualthresh) {
#ifdef DO_SINGLES
				for (k = ang1; k < ang2; k++) {
					/* lB are in hist_m at 48 spin cadence.
					 * lA and lC are in background at 48 spin cadence.
					 * XXX I should really check that neither of these
					 * packets are missing; it's not likely that we've
					 * checked.  But we also don't really care too
					 * much about this, precisely, I guess.  Let's
					 * hope we don't run off the end...
					 */
					llA[j] += (*(hbs[HB_LA].data[2 * i]))[j][k];
					llA[j] += (*(hbs[HB_LA].data[2 * i + 1]))[j][k];
					llB[j] += (*(hbs[HB_LB].data[2 * i]))[j][k];
					llB[j] += (*(hbs[HB_LB].data[2 * i + 1]))[j][k];
					llC[j] += (*(hbs[HB_LC].data[2 * i]))[j][k];
					llC[j] += (*(hbs[HB_LC].data[2 * i + 1]))[j][k];
				}
#endif
/* How long an interval is this?  In most cases we can just pull the time
 * since the last L packet, but that won't work for the first packet or in
 * cases with gaps.  The longest time that makes sense for a packet is
 * perhaps a bit over 15s per spin, or 96 spins * (15s/spin) = 1440s + 60s
 * of slop == 1500s.  Anything shorter that's survived a cull is good; we
 * may sneak in something if we drop to HVENG for a period shorter than
 * 2 minutes, but that's not likely given that we've culled.
 *
 * So what I do is keep track of total "properly timed" hbs collected, plus
 * the number that didn't get good timing, and I just scale.  It really
 * shouldn't be an issue unless the star tracker is pooching.
 */
					if (i > 0 &&
					    (l = hbs[HB_LABC].met[i] - hbs[HB_LABC].met[i-1]) <=
					    1500) {
						ntg[j]++;
						nt[j] += l;
					} else
						ntb[j]++;
					nunq[j]++;
					unqABC[j] += temp2 - temp1;
					qqABC[j] += temp1;
					unqAC[j]  += temp4 - temp3;
					/* No zero bin for ESA 1 */
					if (j == 0 && ang1 == 0) {
						unqABC[0] -= (*(hbs[HB_LABC].data[i]))[0][0];
						unqABC[0] += (*(hbs[HB_QABC].data[2 * i + 1]))[0][0];
						unqABC[0] += (*(hbs[HB_QABC].data[2 * i]))[0][0];
						qqABC[0] -= (*(hbs[HB_QABC].data[2 * i + 1]))[0][0];
						qqABC[0] -= (*(hbs[HB_QABC].data[2 * i]))[0][0];
						unqAC[0] -= (*(hbs[HB_LAC].data[i]))[0][0];
						unqAC[0] += (*(hbs[HB_QAC].data[2 * i]))[0][0];
						unqAC[0] += (*(hbs[HB_QAC].data[2 * i + 1]))[0][0];
#ifdef DO_SINGLES
						llA[0] -= (*(hbs[HB_LA].data[2 * i + 1]))[0][0];
						llA[0] -= (*(hbs[HB_LA].data[2 * i]))[0][0];
						llB[0] -= (*(hbs[HB_LB].data[2 * i + 1]))[0][0];
						llB[0] -= (*(hbs[HB_LB].data[2 * i]))[0][0];
						llC[0] -= (*(hbs[HB_LC].data[2 * i + 1]))[0][0];
						llC[0] -= (*(hbs[HB_LC].data[2 * i]))[0][0];
#endif
					}
				} else
					ndrop[j]++;
			}
		}
	}
	/* Used to have hardwired qABC/unqABC ratio of 57.6 / 51.7.
	 * De-hardwire, or at least move the hardwiring to penbg.c
	 */
	ratiolq = get_penbg_ratio(rmet1 / 2  + rmet2 / 2, HB_LABC, &ratiolqunc);
	ratioqu = 1./(ratiolq - 1.);
	/* XXX ratioquunc not yet incorporated */
	ratioquunc = ratioqu * ratioqu * ratiolqunc;
	t1 = t2 = 0.0;
	if (verbosity > 0)
		printf("BACKGROUNDS:\n");
#ifdef DO_SINGLES
	/* Can make things snazzy if I ever care to.  This is not usually run. */
	/* Note assumption that basically all we see in singles is penetrating
	 * background.  This is not true when moon is there or Earth is there.
	 * Let's hope it still is sensible.
	 */
	printf("lA ");
	for (i = 0; i < HI_ENERGIES; i++) {
		t3 = 1. / (1. + ntb[i]/(double)ntg[i]) / (double)nt[i];
		t3 *= HI_ENERGIES;
		if (i == 0 && ang1 == 0) {
			if (ang2 - ang1 == 1)
				t3 = -1;
			else
				t3 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
		}
		t3 *= angconvfactor;
		printf(" %.3lf", llA[i] * t3);
	}
	printf("\nlB ");
	/* Grotesque copy'n'paste of above (and below) */
	for (i = 0; i < HI_ENERGIES; i++) {
		t3 = 1. / (1. + ntb[i]/(double)ntg[i]) / (double)nt[i];
		t3 *= HI_ENERGIES;
		if (i == 0 && ang1 == 0) {
			if (ang2 - ang1 == 1)
				t3 = -1;
			else
				t3 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
		}
		t3 *= angconvfactor;
		printf(" %.3lf", llB[i] * t3);
	}
	printf("\nlC ");
	/* Grotesque copy'n'paste of above (and below) */
	for (i = 0; i < HI_ENERGIES; i++) {
		t3 = 1. / (1. + ntb[i]/(double)ntg[i]) / (double)nt[i];
		t3 *= HI_ENERGIES;
		if (i == 0 && ang1 == 0) {
			if (ang2 - ang1 == 1)
				t3 = -1;
			else
				t3 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
		}
		t3 *= angconvfactor;
		printf(" %.3lf", llC[i] * t3);
	}
	printf("\n");
#endif
	for (i = 0; i < HI_ENERGIES; i++) {
		if (ntg[i] > 0 && nt[i] > 0) {
			pseudopoiss += unqABC[i];
			t3 = unqABC[i] / (1. + ntb[i]/(double)ntg[i]) / (double)nt[i];
			t3 *= HI_ENERGIES;
			t4 = qqABC[i] / (1. + ntb[i]/(double)ntg[i]) / (double)nt[i];
			t4 *= HI_ENERGIES;
			if (i == 0 && ang1 == 0) {
				if (ang2 - ang1 == 1)
					t3 = t4 = -1;
				else {
					t3 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
					t4 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
				}
			}
			t3 *= angconvfactor;
			t4 *= angconvfactor;
		} else {
			t3 = t4 = -1.;
		}
		if (verbosity > 0) {
			printf("ESA %d:  unqABC %ld in %d L hbs (%d dropped) is %lf Hz\n",
			    i + 1, unqABC[i], nunq[i], ndrop[i], t3);
			printf("ESA %d:    qABC %ld in %d L hbs (%d dropped) is %lf Hz\n",
			    i + 1, qqABC[i], nunq[i], ndrop[i], t4);
		} else {
			/* Less verbose, fits into my plotting better */
			if (verbosity > -10)
				printf("## %d %d %lf %lf\n", i + 1, nunq[i], t3, t4);
			if (t3 > 0. && t4 > 0.) {
				nesas++;
				/* Do a mildly bogus averaging for qABC rates,
				 * using estimates based on cal as to how much unqABC
				 * comes from real signal.  (That any does at all is
				 * why there's a threshold on total qABCs).
				 */
				usemet = rmet1;
				if (!is_sweep_same(rmet1, rmet2, 1<<i)) {
					if (verbosity > -100000)
printf("Warning: print_bgs_t() called on data with multiple sweep tables (ESA %d)!\n", i+1);
					/* In this case we probably want to figure out
					 * which is the MOST APPROPRIATE sweep table to
					 * use and go from there.  Oh lord. XXX
					 */
					usemet = MET_for_most_appropriate_sweep_table(rmet1,
					    rmet2, i);
					if (verbosity > -100000)
printf("         Proceeding with sweep table >%s< (at %ld)...\n",
					    ESAstr_at_met(usemet, i), (long)usemet);
	}
				if (get_sweep_unq_ratio(usemet, i+1, &umin, &ubest, &umax))
					errx(1, "background calculation failed on sweep table load");
				sbgs    += bgs_calc(t3, t4, ubest, ratioqu);
				slowbgs += bgs_calc(t3, t4, umin, ratioqu);
				shibgs  += bgs_calc(t3, t4, umax, ratioqu);
			}
		}
		t1 += t3;
		/* Reuse t3 */
		if (ntg[i] > 0 && nt[i] > 0) {
			t3 = (unqAC[i] / (1. + ntb[i] / ntg[i]) / (double)nt[i]);
			t3 *= HI_ENERGIES;
			if (i == 0 && ang1 == 0) {
				if (ang2 - ang1 == 1)
					t3 = t4 = -1;
				else {
					t3 *= ((double)(ang2-ang1)/(double)(ang2-ang1 - 1));
				}
			}
			t3 *= angconvfactor;
		} else
			t3 = -1.;
		t2 += t3;
		if (verbosity > 1)
			printf("        unqAC  %ld in %d (%lf Hz)\n",
			    unqAC[i], nunq[i], t3);
	}
	if (verbosity > 0) {
		printf("\nTotal unqABC:  avg rate of %lf\n", t1 / HI_ENERGIES);
		if (verbosity > 1)
			printf("\nTotal unqAC:   avg rate of %lf\n", t2 / HI_ENERGIES);
	} else if (verbosity > -10) {
		/* printf("%lf Hz unqABC bg\n", (nesas > 0) ? (sbgs/nesas):(-1.)); */
		printf("%lf Hz qABC bg\n", (nesas > 0) ?
		    (ratioqu * sbgs/nesas):(-1.));
	} else {	/* shortest response, for ISOC use */
		t2 = ((nesas > 0) ? (ratioqu * sbgs/nesas):(-1.));
		if (verbosity > -100000)
			/* XXX this is potentially WRONG depending on MET limits set */
			printf("####  %.1lf %.1lf  0 59 Hi  %lf %lf %lf %lf %lf %lf  rate\n",
			    (double)(hbs[HB_QABC].met[0] - 1.01 * APPROX_HBTIME),
			    (double)(hbs[HB_QABC].met[hbs[HB_QABC].n - 1]),
		    t2, t2, t2, t2, t2, t2);
		/* XXX For sigma, get the difference by assuming maximally
		 * different offsets in sbgs, and add in quadrature with stat
		 * uncertainty.  That's safe, I think.  Hardwired guesses!
		 * Also, incorporate uncertainty in bg unqABC:qABC ratio.
		 */
		t3 = ((nesas > 0) ? (ratioqu * slowbgs/nesas):(-1.));
		t4 = ((nesas > 0) ? (ratioqu * shibgs/nesas):(-1.));
		/* XXX Really too bad that stat unc isn't separated from
		 * systematic for later processors.
		 */
		if (pseudopoiss > 0.)
			t1 = t2 * sqrt(((t4 - t3) / 2. / t2) * ((t4 - t3)/2. / t2) +
			    ratioquunc / ratioqu * ratioquunc / ratioqu +
			    1./pseudopoiss);
		else
			t1 = -1.;
		if (verbosity > -100000)
			/* XXX this is potentially WRONG depending on MET limits set */
			printf("####  %.1lf %.1lf  0 59 Hi  %lf %lf %lf %lf %lf %lf  sigma\n",
			    (double)(hbs[HB_QABC].met[0] - 1.01 * APPROX_HBTIME),
			    (double)(hbs[HB_QABC].met[hbs[HB_QABC].n - 1]),
			    t1, t1, t1, t1, t1, t1);
		_bgcrrate = t2;
		_bgcrunc  = t1;
#ifdef DEBUG
printf("t3 %lf t4 %lf pseudosqrt %lf\n", t3, t4, sqrt(pseudopoiss));
#endif
	}
}

/* Does NOT remove SEP events without an event list... */
void
print_bgs(int qualthresh, int verbosity, SEPlist *sp, int limit_v)
{
	print_bgs_t(qualthresh, verbosity, 0x0, 0xFFFFFFFF, 0, HI_AZ_BINS, sp,
	    limit_v);
}

/* Sometimes we don't want a printout, we just want the background and
 * uncertainty, as per ISOC use.  So as not to interfere too much with
 * print_bgs, sneak in a couple local variables and set verbosity heinously
 * negative.
 *
 * NULL SEPlist means no SEPs removed.
 */
void
get_bgs(int qualthresh, double *rate, double *unc, SEPlist *sp, int limit_v)
{
	print_bgs(qualthresh, -100001, sp, limit_v);
	*rate = _bgcrrate;
	*unc  = _bgcrunc;
}

/* Well, wouldn't you know it, there's ALSO call sometimes to get the
 * penetrating background rate for just a PART of the orbit.  Don't assume
 * anyone's done a running average, because that's just funny with 2
 * different cadence packets.  Give the first time and the last time (of
 * lABC info) and match qABCs to that, and return the background rate
 * just for then.  There IS NO qualthresh!  Overall default bg rates are
 * still reset, which is kind of lousy.
 */
void
get_bgs_time(double *rate, double *unc, uint32_t met1, uint32_t met2,
    int limit_v)
{
	print_bgs_t(pd_uncomp(0xFF), -100001, met1, met2, 0, HI_AZ_BINS, NULL,
	    limit_v);
	*rate = _bgcrrate;
	*unc  = _bgcrunc;
}

void
get_bgs_time_ang(double *rate, double *unc, uint32_t met1, uint32_t met2,
    int ang1, int ang2, int limit_v)
{
	print_bgs_t(pd_uncomp(0xFF), -100001, met1, met2, ang1, ang2, NULL,
	    limit_v);
	*rate = _bgcrrate;
	*unc  = _bgcrunc;
}

/* Noted from an old orbit-8 BM plot of Geoff's:  we may occasionally wish
 * to check that nothing's gone weird in the compression or storage
 * routines, by plotting the frequency of various count rates seen.
 * Naturally, we want this in the 0-255 range of raw data; sadly, I'm not
 * set up to store that info, so we have to unconvert the converted data
 * instead.  Probably we'll eventually want to plot with a log y axis.
 *
 * This is set to histogram only from t1 to t2 in angle range ang1 to ang2
 * for data of type histtype (if you want to look at multiple histogram
 * types together, you need to ask for each one and sum on your own), for
 * ESA settings/BM range given by esas (bits set as per 1<<i, i = 0-5 for
 * Hi settings 1-6).
 *
 * This function allocates but does not free a long array[256], which it
 * populates and returns.  NULL will be returned on error; caller has to
 * check.
 */
long *
bin_raw_counts(uint32_t t1, uint32_t t2, int ang1, int ang2, int histtype,
    char esas)
{
	long *binz;
	int i, j, k, n;
	int s;

	if (histtype < 0 || histtype >= BIN_TYPES)
		return(NULL);
	if (ang1 < 0)
		ang1 = 0;
	if (ang1 >= HI_AZ_BINS)
		ang1 = HI_AZ_BINS - 1;
	if (ang2 < 0)
		ang2 = 0;
	if (ang2 >= HI_AZ_BINS)
		ang2 = HI_AZ_BINS - 1;
	if ((binz = (long *)calloc(256, sizeof(long))) == NULL)
		return(NULL);
	/* calloc() initializes to zero */
	switch (hbs[histtype].flag) {
	case TLC_HIHB:
	case TLC_HIDE:
		n = HI_ENERGIES;
		break;
	case TLC_BM:
		n = HI_BG_SWEEPS;
		break;
	case TLC_LOH:
		n = LO_ENERGIES;
		break;
	default:
		free(binz);
		return(NULL);
	}
	for (i = 0; i < hbs[histtype].n; i++) {
		if (hbs[histtype].met[i] >= t1 && hbs[histtype].met[i] <= t2) {
			for (j = 0; j < n; j++) {
				if (esas & (1 << j)) {
					for (k = ang1; k <= ang2; k++) {
						if (hbs[histtype].flag == TLC_BM)
							s = bm_comp((*hbs[histtype].data[i])[j][k]);
						else
							s = pd_comp((*hbs[histtype].data[i])[j][k]);
						if (s >= 0 && s <= 255)
							binz[s]++;
					}
				}
			}
		}
	}
	return(binz);
}

/* We occasionally want to look at the difference between nondespun DEs and
 * histograms.  One thing that frequently dominates over everything else
 * are situations where the CEU and the ground disagree slightly over where
 * the 6-degree boundary sits.  This function removes these differences by
 * MODIFYING one of the sets of data whenever it sees a characteristic
 * n-too-many/n-too-few in consecutive angle bins.  Max value for <n> can
 * be set.
 *
 * Verbosity level controls what gets printed to supplied FILE * (if
 * non-NULL).  You always get a summary of how many things were modified.
 * verbosity > 0 gets a breakdown by angle and by ESA.
 *
 * For safety there's a check that the two data sets line up (within slop)
 * on timing.  If they don't, nothing gets done and the return is nonzero.
 *
 * hbs[hb2] is the one that gets modified.
 */
int
fix_hb_de_off_by_ones(int hb1, int hb2, int nmax, int verbosity, FILE *fp)
{
	int i, j, k, n1, n2;
	int scoring[HI_ENERGIES][HI_AZ_BINS];

	if (hbs[hb2].n != hbs[hb1].n)
		return(1);
	for (i = 0; i < hbs[hb1].n; i++)
		/* How about that casting */
		if (llabs((long long)(hbs[hb1].met[i]) -
		    (long long)(hbs[hb2].met[i])) > HBtimeSlop)
			return(-1);
	/* Okay, so we can modify in relative safety. */
	for (i = 0; i < HI_ENERGIES; i++)
		for (j = 0; j < HI_AZ_BINS; j++)
			scoring[i][j] = 0;
	for (i = 0; i < hbs[hb1].n; i++) {
		for (j = 0; j < HI_ENERGIES; j++) {
			for (k = 0; k < HI_AZ_BINS; k++) {
				n1 = (*(hbs[hb1].data[i]))[j][k] -
				    (*(hbs[hb2].data[i]))[j][k];
				n2 = (*(hbs[hb1].data[i]))[j][(k+1) % HI_AZ_BINS] -
				    (*(hbs[hb2].data[i]))[j][(k+1) % HI_AZ_BINS];
				/* Note this fails if there's anything else, like a
				 * bonus DE, going on here.  I think I want it that way.
				 */
				if (n1 != 0 && abs(n1) <= nmax && n1 + n2 == 0) {
					(*(hbs[hb2].data[i]))[j][k] += n1;
					(*(hbs[hb2].data[i]))[j][(k+1) % HI_AZ_BINS] -= n1;
					scoring[j][k]++;
				}
			}
		}
	}
	if (fp) {
		n1 = 0;
		for (i = 0; i < HI_ENERGIES; i++)
			for (j = 0; j < HI_AZ_BINS; j++)
				n1 += scoring[i][j];
		fprintf(fp,
	"Resetting off-by-one in angles, altering %s to match %s:  %d mods\n",
		    hbs[hb2].name, hbs[hb1].name, n1);
		if (verbosity > 0) {
			fprintf(fp, "\nBreakdown, ESA by ang bin:\n");
			for (j = 0; j < HI_AZ_BINS; j++) {
				fprintf(fp, "%d", scoring[0][j]);
				for (i = 1; i < HI_ENERGIES; i++)
					fprintf(fp, "\t%d", scoring[i][j]);
				fprintf(fp, "\n");
			}
		}
	}
	return(0);
}


/* Look for and null out periods of LVSCI.  This is difficult to do without
 * looking at housekeeping, but I'll give it a try.  There are many
 * giveaways, but the one I'm looking for is any period where ESAs 4-6 have
 * no qABCs but ESA 6 has qABs.  Locate in the qABCs and zero out anything
 * contemporaneous in other packets; note that I can slop around a LOT
 * timewise because there is no quick way to transition from LVSCI to HVSCI.
 * (qAB and qABC are in the same packet.)
 *
 * If we're despun, this is less relevant as LVSCI shouldn't populate DEs.
 */
void
findnzeroLVSCI(int verbosity)
{
	int i, ii, j, k, l, delta;
	long tot1, tot2, tot3, tot4;
	int inlvsci;

	inlvsci = 0;
	for (i = 0; i < hbs[HB_QABC].n; i++) {
		tot1 = tot2 = tot3 = tot4 = 0;
		for (k = 0; k < HI_AZ_BINS; k++) {
			tot1 += (*(hbs[HB_QABC].data[i]))[3][k];
			tot2 += (*(hbs[HB_QABC].data[i]))[4][k];
			tot3 += (*(hbs[HB_QABC].data[i]))[5][k];
			tot4 += (*(hbs[HB_QAB].data[i]))[5][k];
		}
		if (tot4 > 1 && tot1 <= 1 && tot2 <= 1 && tot3 <= 1) {
			if (!inlvsci && verbosity > 0)
				printf("LVSCI starts %u\n", hbs[HB_QABC].met[i]);
			inlvsci = 1;
			/* Zero stuff out. */
			/* Do a 500-second window; up it to 1100s for low-cadence
			 * stuff, identified by having <n> data that's less than 3/4
			 * that of the QABCs.  A bit of a hack.
			 */
			for (l = 0; l < BIN_TYPES; l++) {
				if ((hbs[HB_QABC].n / 4) * 3 > hbs[l].n)
					delta = 1100;
				else
					delta = 500;
				for (ii = 0; ii < hbs[l].n; ii++)
					if (abs((long)hbs[l].met[ii] -
					    (long)hbs[HB_QABC].met[i]) <= delta) {
						for (j = 0; j < get_max_E(hbs[l].flag); j++)
							for (k = 0; k < HI_AZ_BINS; k++)
								(*(hbs[l].data[ii]))[j][k] = 0;
					}
			}
		} else {
			if (inlvsci && verbosity > 0)
				printf("LVSCI ended before %u\n", hbs[HB_QABC].met[i]);
			inlvsci = 0;
		}
	}
}


static int
_is_hb_null(int hh, int jj)
{
	int m, k, l;

	m = 1;
	for (k = 0; k < m * get_max_E(hbs[hh].flag); k++)
		for (l = 0; l < m * HI_AZ_BINS; l++)
			if ((*(hbs[hh].data[jj]))[k][l])
				m = 0;
	return(m);
}
static void
_move_down_hbs(int hh, int j)
{
	int jj, k, l;

	for (jj = j+1; jj < hbs[hh].n; jj++) {
		for (k = 0; k < get_max_E(hbs[hh].flag); k++)
			for (l = 0; l < HI_AZ_BINS; l++)
				(*(hbs[hh].data[jj - 1]))[k][l] =
				    (*(hbs[hh].data[jj]))[k][l];
		hbs[hh].met[jj-1] = hbs[hh].met[jj];
		hbs[hh].spincount[jj-1] = hbs[hh].spincount[jj];
	}
	hbs[hh].n--;
	free(*(hbs[hh].data[hbs[hh].n]));
}
/* Kind of as a followup to findnzeroLVSCI(), and possibly for more general
 * purposes, simply remove all-zero histograms from the data entirely.
 *
 * Note this could break further_cull_hbs(), but it probably won't.
 * If nastiness is nonzero, it will potentially do terrible, terrible
 * things to anything that assumes that the number of histograms is the
 * same for all data types of a given packet.  Many things assume this.  In
 * particular, best to run cull_partial_hbs() and further_cull_hbs() BEFORE
 * this and not after!
 *    A reason one might want a nonzero nastiness is if, for instance, you
 * aren't going to cull further, or you've already munged up your data
 * types from their defaults.
 */
void
drop_null_hbs(int nastiness)
{
	int i, j;

	for (i = 0; i < BIN_TYPES; i++) {
		if (nastiness || (i > HB_BM)) {
			for (j = 0; j < hbs[i].n; j++)
				if (_is_hb_null(i, j))
					_move_down_hbs(i, j);
		}
	}
	if (nastiness == 0) {
		/* histq */
		for (j = 0; j < hbs[HB_QABC].n; j++)
			if (_is_hb_null(HB_QABC, j) &&
			    _is_hb_null(HB_QAB, j) &&
			    _is_hb_null(HB_QBC, j)) {
					_move_down_hbs(HB_QABC, j);
					_move_down_hbs(HB_QAB, j);
					_move_down_hbs(HB_QBC, j);
			}
		/* histl */
		for (j = 0; j < hbs[HB_LABC].n; j++)
			if (_is_hb_null(HB_LABC, j) &&
			    _is_hb_null(HB_LAC, j) &&
			    _is_hb_null(HB_LBC, j)) {
					_move_down_hbs(HB_LABC, j);
					_move_down_hbs(HB_LAC, j);
					_move_down_hbs(HB_LBC, j);
			}
		/* histm */
		for (j = 0; j < hbs[HB_QAC].n; j++)
			if (_is_hb_null(HB_QAC, j) &&
			    _is_hb_null(HB_LAB, j) &&
			    _is_hb_null(HB_LB, j)) {
					_move_down_hbs(HB_QAC, j);
					_move_down_hbs(HB_LAB, j);
					_move_down_hbs(HB_LB, j);
			}
		/* BM */
		for (j = 0; j < hbs[HB_LA].n; j++)
			if (_is_hb_null(HB_LA, j) &&
			    _is_hb_null(HB_LC, j) &&
			    _is_hb_null(HB_BM, j)) {
					_move_down_hbs(HB_LA, j);
					_move_down_hbs(HB_LC, j);
					_move_down_hbs(HB_BM, j);
			}
	}
}
