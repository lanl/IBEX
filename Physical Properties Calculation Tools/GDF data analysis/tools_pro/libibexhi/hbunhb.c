/*	$Id: hbunhb.c,v 1.11 2016/06/03 02:16:24 pjanzen Exp $	*/
/* Routines to start up or clear all the global hb stuff.  Needed if a
 * program reads more than a single orbit.  Convenient otherwise.
 */
#include <err.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: hbunhb.c,v 1.11 2016/06/03 02:16:24 pjanzen Exp $";

static uint32_t
min4(uint32_t a, uint32_t b, uint32_t c, uint32_t d)
{
	uint32_t tmp;

	tmp = (a < b ? a:b);
	tmp = (tmp < c ? tmp : c);
	tmp = (tmp < d ? tmp : d);
	return(tmp);
}

void
hb_massinit()
{
	int i;

	for (i = 0; i < BIN_TYPES; i++) {
		hbs[i].n = hbs[i].nmax = 0;
	}
	hbs[HB_QABC].name = strdup("qABC");
	hbs[HB_QABC].flag = TLC_HIHB;
	hbs[HB_LABC].name = strdup("lABC");
	hbs[HB_LABC].flag = TLC_HIHB;
	hbs[HB_QAB].name = strdup("qAB");
	hbs[HB_QAB].flag = TLC_HIHB;
	hbs[HB_LAB].name = strdup("lAB");
	hbs[HB_LAB].flag = TLC_HIHB;
	hbs[HB_QAC].name = strdup("qAC");
	hbs[HB_QAC].flag = TLC_HIHB;
	hbs[HB_LAC].name = strdup("lAC");
	hbs[HB_LAC].flag = TLC_HIHB;
	hbs[HB_QBC].name = strdup("qBC");
	hbs[HB_QBC].flag = TLC_HIHB;
	hbs[HB_LBC].name = strdup("lBC");
	hbs[HB_LBC].flag = TLC_HIHB;
	hbs[HB_LA].name = strdup("lA");
	hbs[HB_LA].flag = TLC_HIHB;
	hbs[HB_LB].name = strdup("lB");
	hbs[HB_LB].flag = TLC_HIHB;
	hbs[HB_LC].name = strdup("lC");
	hbs[HB_LC].flag = TLC_HIHB;
	hbs[HB_BM].name = strdup("BM");
	hbs[HB_BM].flag = TLC_BM;
	hbs[HB_LOH].name = strdup("LoH");
	hbs[HB_LOH].flag = TLC_LOH;
	hbs[HB_LOO].name = strdup("LoO");
	hbs[HB_LOO].flag = TLC_LOH;
	hbs[HB_TOF0].name = strdup("LoTOF0");
	hbs[HB_TOF0].flag = TLC_LOH;
	hbs[HB_TOF1].name = strdup("LoTOF1");
	hbs[HB_TOF1].flag = TLC_LOH;
	hbs[HB_TOF2].name = strdup("LoTOF2");
	hbs[HB_TOF2].flag = TLC_LOH;
	hbs[HB_TOF3].name = strdup("LoTOF3");
	hbs[HB_TOF3].flag = TLC_LOH;
	tce.n = tce.nmax = 0;
}

void
hb_massfree()
{
	int i, j;

	for (i = 0; i < BIN_TYPES; i++) {
		free(hbs[i].name);
		for (j = hbs[i].n - 1; j >= 0; j--)
			free(*(hbs[i].data[j]));
		if (hbs[i].n) {
			free(hbs[i].met);
			free(hbs[i].spincount);
			free(hbs[i].data);
		}
	}
	for (j = tce.n - 1; j >= 0; j--)
		free(*(tce.data[j]));
	if (tce.n) {
		free(tce.data);
		free(tce.met);
		free(tce.spincount);
	}
	if (nmaxspin_times > 0) {
		free(spin_times);
		nmaxspin_times = 0;
		nspin_times = 0;
	}
	if (nmaxss_times > 0) {
		for (i = 0; i < nss_times; i++) {
			free(ss_data[i]->brightness);
			free(ss_data[i]);
		}
		free(ss_data);
		nmaxss_times = 0;
		nss_times = 0;
	}
	if (nmaxerr_log > 0) {
		for (i = 0; i < nerr_log; i++)
			free(err_log[i]);
		free(err_log);
		nmaxerr_log = 0;
		nerr_log = 0;
	}
}


/* Make a matrix of every unique MET time, in order, for binning
 * purposes.  Assume that qABC is it with up to 5% dropouts.
 * Anything more than that probably means slop has to go up.
 * There are a total of 4 packet types; test qABC, lAB, lABC, lA.
 */
void
hb_makealltimesnculls()
{
	int i, i1, i2, i3, i4;
	uint32_t a, b, c, d;

	nallt = 1.05 * hbs[HB_QABC].n + 2;
	if ((alltimes = (uint32_t *)calloc(nallt, sizeof(uint32_t)))
	    == NULL)
		err(1, NULL);
	for (i = 0; i < 8; i++)
		if ((mculls[i] = (char *)calloc(HI_AZ_BINS, nallt)) == NULL)
			err(1, NULL);
	i1 = i2 = i3 = i4 = 0;
	alltimes[0] = min4(hbs[HB_QABC].met[0], hbs[HB_LAB].met[0],
	    hbs[HB_LABC].met[0], hbs[HB_LA].met[0]);
	i = 1;
	do {
		if (i >= nallt)
			errx(1, "too many dropped Q histograms!  (or try -s)");
		while (i1 < hbs[HB_QABC].n &&
		    hbs[HB_QABC].met[i1] - HBtimeSlop <= alltimes[i - 1])
			i1++;
		if (i1 == hbs[HB_QABC].n)
			a = 0xFFFFFFFF;
		else
			a = hbs[HB_QABC].met[i1];
		while (i2 < hbs[HB_LAB].n &&
		    hbs[HB_LAB].met[i2] - HBtimeSlop <= alltimes[i - 1])
			i2++;
		if (i2 == hbs[HB_LAB].n)
			b = 0xFFFFFFFF;
		else
			b = hbs[HB_LAB].met[i2];
		while (i3 < hbs[HB_LABC].n &&
		    hbs[HB_LABC].met[i3] - HBtimeSlop <= alltimes[i - 1])
			i3++;
		if (i3 == hbs[HB_LABC].n)
			c = 0xFFFFFFFF;
		else
			c = hbs[HB_LABC].met[i3];
		while (i4 < hbs[HB_LA].n &&
		    hbs[HB_LA].met[i4] - HBtimeSlop <= alltimes[i - 1])
			i4++;
		if (i4 == hbs[HB_LA].n)
			d = 0xFFFFFFFF;
		else
			d = hbs[HB_LA].met[i4];
		alltimes[i] = min4(a, b, c, d);
		i++;
	} while (alltimes[i - 1] - alltimes[i - 2] > (uint32_t) HBtimeSlop);
			/* alltimes is monotonic so LHS is always >= 0 */
	i--;
	i--;
	nallt = i;
}

void
hb_freealltimesnculls()
{
	int i;

	for (i = 0; i < 8; i++)
		free(mculls[i]);
	free(alltimes);
	nallt = 0;
}


/* Sometimes you want to force cadence to something else (e.g., despun).
 * Do so in this kludgey way, AFTER you've done it once the regular way.
 *
 * To return to the ORIGINAL timing, which doesn't sync on a single hbtype,
 * use -1 as hbtype.
 */
void
remake_alltimesnculls(int hbtype)
{
	int i, i1;
	uint32_t a;

	if (hbtype < -1 || hbtype >= BIN_TYPES)
		return;
	hb_freealltimesnculls();
	if (hbtype == -1) {
		hb_makealltimesnculls();
		return;
	}
	nallt = hbs[hbtype].n + 5;
	if ((alltimes = (uint32_t *)calloc(nallt, sizeof(uint32_t)))
	    == NULL)
		err(1, NULL);
	for (i = 0; i < 8; i++)
		if ((mculls[i] = (char *)calloc(HI_AZ_BINS, nallt)) == NULL)
			err(1, NULL);
	i1 = 0;
	alltimes[0] = hbs[HB_QABC].met[0];
	if (hbs[HB_LAB].met[0] < alltimes[0])
		alltimes[0] = hbs[HB_LAB].met[0];
	if (hbs[HB_LABC].met[0] < alltimes[0])
		alltimes[0] = hbs[HB_LABC].met[0];
	if (hbs[hbtype].met[0] < alltimes[0])
		alltimes[0] = hbs[hbtype].met[0];
	i = 1;
	do {
		if (i >= nallt)
			errx(1, "too many unsyncable histograms on remade resync!");
		while (i1 < hbs[hbtype].n &&
		    hbs[hbtype].met[i1] - HBtimeSlop <= alltimes[i - 1])
			i1++;
		if (i1 == hbs[hbtype].n)
			a = 0xFFFFFFFF;
		else
			a = hbs[hbtype].met[i1];
		alltimes[i] = a;
		i++;
	} while (alltimes[i - 1] - alltimes[i - 2] > (uint32_t) HBtimeSlop);
			/* alltimes is monotonic so LHS is always >= 0 */
	i--;
	i--;
	nallt = i;
}
