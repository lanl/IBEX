/*
 * $Id: readhb.c,v 1.46 2020/02/13 23:06:09 pjanzen Exp $
 *
 * Take HBs unpacked from the telemetry and ingest them.
 *
 * This file is hugely based on hi_hb_* and associated gbc code.
 *
 * This version pretty much assumes the qualified select register is b1011
 * and that the coincidences present have the default values.
 */
#include <assert.h>
#include <ctype.h>
#include <err.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include "ccsds_msg.h"
#include "compression.h"
#include "edac_list.h"
#include "edac_sum.h"
#include "err_log.h"
#include "hi_de_flt.h"
#include "hi_hist_q.h"
#include "hi_hist_m.h"
#include "hi_hist_l.h"
#include "background.h"
#include "lo_hist_h.h"
#include "lo_hist_o.h"
#include "spin_info.h"
#include "star_sensor.h"

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: readhb.c,v 1.46 2020/02/13 23:06:09 pjanzen Exp $";

#define BUFSZ (8192)

#define DATASTEPSZ (2000)

static void
addtolog_c(timelog_c *a, uint32_t met, int spincount,
    garray *coinc)
{
	uint32_t *tmp1;
	int *tmp2;
	garray **tmp3;

	if (a->n >= a->nmax) {
		if (a->nmax <= 0) {
			tmp1 = calloc(sizeof(uint32_t), DATASTEPSZ);
			tmp2 = calloc(sizeof(int), DATASTEPSZ);
			tmp3 = calloc(sizeof(garray *), DATASTEPSZ);
			a->nmax = DATASTEPSZ;
		} else {
			/* recalloc() is nonportable */
			tmp1 = realloc(a->met, sizeof(uint32_t) * (a->nmax + DATASTEPSZ));
			tmp2 = realloc(a->spincount, sizeof(int) * (a->nmax + DATASTEPSZ));
			tmp3 = realloc(a->data, sizeof(int *) * (a->nmax + DATASTEPSZ));
			a->nmax += DATASTEPSZ;
		}
		if ((!tmp1) || (!tmp2) || (!tmp3))
			errx(100, "FATAL:  addtolog out of mem");
		a->met = tmp1;
		a->spincount = tmp2;
		a->data = tmp3;
	}
	*(a->met + a->n) = met;
	*(a->spincount + a->n) = spincount;
	*(a->data + a->n) = coinc;
	a->n++;
}

static void
add_spin_pulse(double x, Byte firstspin, uint32_t met)
{
	spind *tmp;

	if (nspin_times >= nmaxspin_times) {
		if (nmaxspin_times <= 0) {
			tmp = calloc(sizeof(spind), DATASTEPSZ * 25);
			nmaxspin_times = DATASTEPSZ * 25;
		} else {
			tmp = realloc(spin_times,
			    sizeof(spind) * (nmaxspin_times + DATASTEPSZ * 10));
			nmaxspin_times += DATASTEPSZ * 10;
		}
		if (!tmp)
			errx(100, "FATAL: add_spin_pulse out of mem");
		spin_times = tmp;
	}
	/* XXX need spin numbers to increment in order, not just keep the low
	 * bits
	 */
	(spin_times[nspin_times]).spin = firstspin;
	(spin_times[nspin_times]).met = x;
	(spin_times[nspin_times]).pktmet = met;
	nspin_times++;
}

/* I believe this is Geoff's (total - sum of longs) field.  He presently
 * assumes everything is 48 spins.  ex[0] through ex[5] have one bit each
 * as a pass/fail for each spin.  Excessive is the worst offset.
 *
 * So as a rough guide we can give a minimum number of misses by summing
 * up all the bits that are on, and we can report what the worst miss was.
 * It all goes in its own woefully underfilled timelog_c, but initial
 * checking indicates none of this has ever been set for at least orbits
 * 8-11.
 */
static void
handle_tce(char *CEM, Byte ex[], Sint wexcessive, int spincount, uint32_t mt)
{
	Byte tmp;
	int i, c, n;

	n = 0;
	for (i = 0; i < 6; i++) {
		tmp = ex[i];
		/* Use Wegner (1960) bit summer, aka exercise 2-9 in K&R's C book */
		for (c = 0; tmp; c++)
			tmp &= tmp - 1;	/* clear LSB set */
		n += c;
	}
	if (n || wexcessive) {
		garray *ar1;

		if ((ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
			errx(100, "FATAL:  handle_tce out of mem");
		(*ar1)[0][0] = n;
		(*ar1)[0][1] = wexcessive;
		(*ar1)[0][2] = (int)CEM[0];
		addtolog_c(&tce, mt, spincount, ar1);
	}
}


/*
 * Packet handlers: to start, build everything up in memory.
 * Return 1 if the packet was completely processed.
 */
static int
handle_hist_q(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	HI_HIST_Q_msg	*hiq = (HI_HIST_Q_msg *)(msg->msg);
	garray *ar1, *ar2, *ar3;

	assert(hiq->coinc_present == HI_HIST_Q_COINC_PRESENT);
	assert(hiq->single_present == HI_HIST_Q_SINGLE_PRESENT);
	if (hiq->met < stm || hiq->met > endm)
		return(1);

	if ((ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar2 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar3 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL:  handle_hist_q out of mem");

	for (az = 0; az < HI_AZ_BINS; az++)
		for (en = 0; en < HI_ENERGIES; en++) {
			(*ar1)[en][az] = pd_uncomp(hiq->qual_ABC[en][az]);
			(*ar2)[en][az] = pd_uncomp(hiq->qual_AB_[en][az]);
			(*ar3)[en][az] = pd_uncomp(hiq->qual__BC[en][az]);
	}

	/* Had msg->met.ui as the time; I'm taking hiq->met instead.
	 * It's packet creation == end of collection time.
	 */
	addtolog_c(hbs + HB_QABC, hiq->met, hiq->count, ar1);
	addtolog_c(hbs + HB_QAB, hiq->met, hiq->count, ar2);
	addtolog_c(hbs + HB_QBC, hiq->met, hiq->count, ar3);

	handle_tce("A", hiq->excess_A, hiq->excessive_A, hiq->count, hiq->met);
	return(1);
}

static int
handle_hist_m(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	HI_HIST_M_msg	*him = (HI_HIST_M_msg *)(msg->msg);
	garray *ar1, *ar2, *ar3;

	assert(him->coinc_present == HI_HIST_M_COINC_PRESENT);
	assert(him->single_present == HI_HIST_M_SINGLE_PRESENT);
	if (him->met < stm || him->met > endm)
		return(1);

	if ((ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar2 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar3 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL:  handle_hist_m out of mem");

	for (az = 0; az < HI_AZ_BINS; az++)
		for (en = 0; en < HI_ENERGIES; en++) {
			(*ar1)[en][az] = pd_uncomp(him->qual_A_C[en][az]);
			(*ar2)[en][az] = pd_uncomp(him->long_AB_[en][az]);
			(*ar3)[en][az] = pd_uncomp(him->single_B[en][az]);
	}

	/* Had msg->met.ui as the time; I'm taking him->met instead.
	 * It's packet creation == end of collection time.
	 */
	addtolog_c(hbs + HB_QAC, him->met, him->count, ar1);
	addtolog_c(hbs + HB_LAB, him->met, him->count, ar2);
	addtolog_c(hbs + HB_LB,  him->met, him->count, ar3);

	handle_tce("B", him->excess_B, him->excessive_B, him->count, him->met);
	return(1);
}
static int
handle_hist_l(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	HI_HIST_L_msg	*hil = (HI_HIST_L_msg *)(msg->msg);
	garray *ar1, *ar2, *ar3;

	assert(hil->coinc_present == HI_HIST_L_COINC_PRESENT);
	assert(hil->single_present == HI_HIST_L_SINGLE_PRESENT);
	if (hil->met < stm || hil->met > endm)
		return(1);

	if ((ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar2 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar3 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL:  handle_hist_l out of mem");

	for (az = 0; az < HI_AZ_BINS; az++)
		for (en = 0; en < HI_ENERGIES; en++) {
			(*ar1)[en][az] = pd_uncomp(hil->long_ABC[en][az]);
			(*ar2)[en][az] = pd_uncomp(hil->long__BC[en][az]);
			(*ar3)[en][az] = pd_uncomp(hil->long_A_C[en][az]);
	}

	/* Had msg->met.ui as the time; I'm taking hil->met instead.
	 * It's packet creation == end of collection time.
	 */
	addtolog_c(hbs + HB_LABC, hil->met, hil->count, ar1);
	addtolog_c(hbs + HB_LBC, hil->met, hil->count, ar2);
	addtolog_c(hbs + HB_LAC,  hil->met, hil->count, ar3);

	handle_tce("C", hil->excess_C, hil->excessive_C, hil->count, hil->met);
	return(1);
}
static int
handle_hi_bm(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	BACKGROUND_msg	*bm = (BACKGROUND_msg *)(msg->msg);
	garray *ar1, *ar2, *ar3;

	assert(bm->single_present == BACKGROUND_SINGLE_PRESENT);
	if (bm->met < stm || bm->met > endm)
		return(1);

	if ((ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar2 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar3 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL:  handle_hi_bm out of mem");

	for (az = 0; az < HI_AZ_BINS; az++)
		for (en = 0; en < HI_ENERGIES; en++) {
			(*ar1)[en][az] = pd_uncomp(bm->single_A[en][az]);
			(*ar2)[en][az] = pd_uncomp(bm->single_C[en][az]);
	}
	/* next bit only works because HI_ENERGIES > HI_BG_SWEEPS */
	for (az = 0; az < HI_AZ_BINS; az++)
		for (en = 0; en < HI_BG_SWEEPS; en++) {
			(*ar3)[en][az] = bm_uncomp(bm->bg[en][az]);
	}

	/* Had msg->met.ui as the time; I'm taking hil->met instead.
	 * It's packet creation == end of collection time.
	 */
	addtolog_c(hbs + HB_LA, bm->met, bm->count, ar1);
	addtolog_c(hbs + HB_LC, bm->met, bm->count, ar2);
	addtolog_c(hbs + HB_BM, bm->met, bm->count, ar3);

	return(1);
}

/* Lo handling is based on lo_hb_raw.c but for now includes only a small
 * subset of what's in there, basically the part that has 6 degree angle
 * bins.
 */
static int
handle_lo_hh(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	LO_HIST_H_msg	*loh = (LO_HIST_H_msg *)(msg->msg);
	garray *ar1, *ar2, *ar3, *ar4, *ar5;
	int i, j, k, l, m;

#if 0
	if (fails_count_checks(msg)) return(0);
#endif
	if (loh->met < stm || loh->met > endm)
		return(1);
	if ((ar1 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar2 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar3 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar4 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL ||
	    (ar5 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL: handle_lo_hh out of mem");
	for (az = 0; az < HI_AZ_BINS; az++)
	    for (en = 0; en < LO_ENERGIES; en++)
			/* Flip it 180 degrees to line up with Hi */
			(*ar1)[en][(az + HI_AZ_BINS / 2) % HI_AZ_BINS] =
			    pd_uncomp(loh->h_hist[en][az]);
		/* FIXME: o-mode  -- or just let slide...*/
	/* Some crazy other stuff we might want.   Sectors are 60 degrees,
	 * so simply make them 10 wide so we don't have to change anything.
	 * Electrons are predominantly in tof_ac_2, but we could keep the
	 * others too.
	 */
	/* LO_SECTORS has to be 6 */
	for (az = 0; az < LO_SECTORS; az++)
	    for (en = 0; en < LO_ENERGIES; en++) {
		    j = pd_uncomp(loh->tof_ab_0[en][az]);
		    k = pd_uncomp(loh->tof_cb_1[en][az]);
		    l = pd_uncomp(loh->tof_ac_2[en][az]);
		    m = pd_uncomp(loh->tof_pos_b0b3_3[en][az]);
		    /* XXX not sure where angles line up. */
		    for (i = 0; i < 10 ; i++) {
			    (*ar2)[en][(az * 10 + HI_AZ_BINS / 2 + i) % HI_AZ_BINS] = j;
			    (*ar3)[en][(az * 10 + HI_AZ_BINS / 2 + i) % HI_AZ_BINS] = k;
			    (*ar4)[en][(az * 10 + HI_AZ_BINS / 2 + i) % HI_AZ_BINS] = l;
			    (*ar5)[en][(az * 10 + HI_AZ_BINS / 2 + i) % HI_AZ_BINS] = m;
		    }
	    }
	addtolog_c(hbs + HB_LOH, loh->met, loh->count, ar1);
	addtolog_c(hbs + HB_TOF0, loh->met, loh->count, ar2);
	addtolog_c(hbs + HB_TOF1, loh->met, loh->count, ar3);
	addtolog_c(hbs + HB_TOF2, loh->met, loh->count, ar4);
	addtolog_c(hbs + HB_TOF3, loh->met, loh->count, ar5);

	return(1);
}
static int
handle_lo_ho(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int		en, az;
	LO_HIST_O_msg	*loo = (LO_HIST_O_msg *)(msg->msg);
	garray *ar1;

#if 0
	if (fails_count_checks(msg)) return(0);
#endif
	if (loo->met < stm || loo->met > endm)
		return(1);
	if ((ar1 = calloc(LO_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
		errx(100, "FATAL: handle_lo_ho out of mem");
	for (az = 0; az < HI_AZ_BINS; az++)
	    for (en = 0; en < LO_ENERGIES; en++)
			/* Flip it 180 degrees to line up with Hi */
			(*ar1)[en][(az + HI_AZ_BINS / 2) % HI_AZ_BINS] =
			    pd_uncomp(loo->o_hist[en][az]);
		/* FIXME: o-mode  -- or just let slide...*/
	addtolog_c(hbs + HB_LOO, loo->met, loo->count, ar1);

	return(1);
}
static int
handle_spin_info(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int i, n;
	SPIN_INFO_msg	*si = (SPIN_INFO_msg *)(msg->msg);
	double x;
	uint32_t t, u, v;

	if (si->met < stm || si->met > endm || si->count == 0)
		return(1);
	n = si->count;
	if (n > N_SPIN_INFO_SPINS) {
		n = N_SPIN_INFO_SPINS;
		warnx("handle_spin_info:  bogus count");
	}
	/* Need the part of MET that's not the low 22 bits.
	 * Beware of edges:  we expect packet creation time to be after any of
	 * the spins included.
	 */
	t = (si->met & ~(SPIN_INFO_SEC_MASK >> SPIN_INFO_SEC_SHIFT));
	u = (si->met & (SPIN_INFO_SEC_MASK >> SPIN_INFO_SEC_SHIFT));

	for (i = 0; i < n; i++) {
		x = 0.001 * (double)SPIN_INFO_MSEC(si->pulse[i]);
		if (x >= 1.)
			warnx("handle_spin_info():  bogus ms (%lf)", x);
		v = SPIN_INFO_SEC(si->pulse[i]);
		x += v;
		/* That's still just the low part of MET. */
		x += t;
		if (v > u) /* We wrapped */
			x -= (SPIN_INFO_SEC_MASK >> SPIN_INFO_SEC_SHIFT) + 1;
		add_spin_pulse(x, si->first, si->met);
	}
	return(1);
}
static int
handle_ss_info(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	int n;
	STAR_SENSOR_msg *ss = (STAR_SENSOR_msg *)(msg->msg);
	starsensord *ssd, **tmp;

	if (ss->met < stm || ss->met > endm || ss->count == 0)
		return(1);
	n = ss->count;
	if (n > 64 || n < 1) {
		if (n > 64)
			warnx("handle_spin_info:  bogus count");
		n = 64;
	}
	/* This should really be based on verbosity.  I have to disable it in
	 * general.  Note that any future program can go look at star_adj and
	 * say the same thing -- it's not like we do anything different if
	 * this is found.
	 */
#if 0
	if (ss->star_adj == 0xFF)
		warnx("Star Sensor out of sync at MET %u.", ss->met);
#endif
	/* The appropriate methodology to linearize the counts is something like
	 * for (bin = 0; bin < 720; bin++) {
	 *	raw = ss_uncompress(ss->bright[bin]);
	 *	raw /= n;
	 *	raw += ss->sky;
	 *	fprintf(fo, "%03X\n", raw);
	 * }
	 * However, for initial purposes we might as well just keep the raw
	 * data in its one-byte form, since we'll probably just be displaying
	 * it on a 128-colour colourmap.
	 */
	if ((ssd = calloc(1, sizeof(starsensord))) == NULL ||
	    (ssd->brightness = calloc(SS_AZ_BINS, 1)) == NULL)
		errx(100, "FATAL: handle_ss_info out of mem");
	ssd->met = ss->met;
	ssd->star_adj = ss->star_adj;
	ssd->spincount = ss->count;
	ssd->pmt_gain = ss->pmt_gain;
	ssd->sky = ss->sky;
	memcpy(ssd->brightness, ss->bright, SS_AZ_BINS);
	if (nss_times >= nmaxss_times) {
		if (nss_times == 0)
			tmp = calloc(256, sizeof(starsensord *));
		else
			tmp = realloc(ss_data, sizeof(starsensord *) *
			    (256 + nmaxss_times));
		if (!tmp)
			errx(100, "FATAL: handle_ss_info out of mem");
		ss_data = tmp;
		nmaxss_times += 256;
	}
	ss_data[nss_times] = ssd;
	nss_times++;
	return(1);
}
static int
handle_err_log(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	ERR_LOG_msg *el = (ERR_LOG_msg *)(msg->msg);
	errlogd *ed, **tmp;

	if (el->met < stm || el->met > endm)
		return(1);
	if ((ed = (errlogd *)calloc(1, sizeof(errlogd))) == NULL)
		errx(100, "FATAL: handle_err_log out of mem");
	ed->met = el->met;
	ed->errmet = (el->met & 0xFFFF0000) | el->errmet;
	ed->errcode = el->errcode;
	memcpy(ed->params, el->params, 4);
	if (nerr_log >= nmaxerr_log) {
		if (nerr_log == 0)
			tmp = calloc(64, sizeof(errlogd *));
		else
			tmp = realloc(err_log, sizeof(errlogd *) *
			    (64 + nmaxerr_log));
		if (!tmp)
			errx(100, "FATAL: handle_err_log out of mem");
		err_log = tmp;
		nmaxerr_log += 64;
	}
	err_log[nerr_log] = ed;
	nerr_log++;
	return(1);
}
/* So don't really despin them, but DO keep track of total DEs seen, for
 * comparison purposes.  It's right at the start of the packet.
 */
static int
handle_hide(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	HI_DE_FLT_msg *hde = (HI_DE_FLT_msg *)(msg->msg);
	int i, n;
	hided *ded, **tmp;

	if (hde->met < stm || hde->met > endm)
		return(1);
	/* sanity check; cannot be less than zero (unsigned) */
	if (hde->count > 1091) {
		warnx("handle_hide:  bogus count MET %u", hde->met);
		return(0);
	}
	/* If it's not got the header, we don't do anything here */
	if (msg->grup == PKT_GRP_MIDDLE || msg->grup == PKT_GRP_FINISH)
		return(1);
	if ((ded = (hided *)calloc(1, sizeof(hided))) == NULL)
		errx(100, "FATAL: handle_hide out of mem");
	ded->met = hde->met;
	/* Guaranteed to be big enough if this isn't a "continuation" packet */
	n = 0;
	for (i = 0; i < 24; i++) {
		switch(i % 3) {
		case 0:  /* we have ONE byte, with which we can do nothing */
			break;
		case 1:  /* we can now read the first 12-bit quantity */
			ded->des[n] = (hde->packed[i-1] << 4) | (hde->packed[i] >> 4);
			n++;
			break;
		case 2:	/* we can read the other quantity */
			ded->des[n] = ((hde->packed[i-1] & 0x0F) << 8) | (hde->packed[i]);
			n++;
			break;
		}
	}
	if (nhidetotlist >= nmaxhidetotlist) {
		if (nhidetotlist == 0)
			tmp = calloc(8192, sizeof(hided *));
		else
			tmp = realloc(hidetotlist, sizeof(hided *) *
			    (8192 + nmaxhidetotlist));
		if (!tmp)
			errx(100, "FATAL: handle_hide out of mem");
		hidetotlist = tmp;
		nmaxhidetotlist += 8192;
	}
	hidetotlist[nhidetotlist] = ded;
	nhidetotlist++;
	return(1);
}
static int
handle_edac_sum(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	EDAC_SUMMARY_msg *eds = (EDAC_SUMMARY_msg *)(msg->msg);
	edacsumd *ed, **tmp;

	if (eds->met < stm || eds->met > endm)
		return(1);
	if ((ed = (edacsumd *)calloc(1, sizeof(edacsumd))) == NULL)
		errx(100, "FATAL: handle_edac_sum out of mem");
	ed->met = eds->met;
	ed->sram_single  = eds->sram_single_errct;
	if (ed->sram_single) {
		ed->srams[0] = eds->sram_single_diags[5];
		ed->srams[1] = eds->sram_single_diags[7];
		ed->srams[2] = eds->sram_single_diags[0];
		ed->srams[3] = eds->sram_single_diags[2];
	}
	ed->sram_multi   = eds->sram_multi_errct;
	if (ed->sram_multi) { /* unlikely - I think this forces a reboot! */
		ed->sramm[0] = eds->sram_multi_diags[5];
		ed->sramm[1] = eds->sram_multi_diags[7];
		ed->sramm[2] = eds->sram_multi_diags[0];
		ed->sramm[3] = eds->sram_multi_diags[2];
	}
	ed->eeprom_single = eds->eepro_single_errct;
	if (ed->eeprom_single) {
		ed->eeps[0] = eds->eepro_single_diags[5];
		ed->eeps[1] = eds->eepro_single_diags[7];
		ed->eeps[2] = eds->eepro_single_diags[0];
		ed->eeps[3] = eds->eepro_single_diags[2];
	}
	ed->eeprom_multi  = eds->eepro_multi_errct;
	if (ed->eeprom_multi) {
		ed->eepm[0] = eds->eepro_multi_diags[5];
		ed->eepm[1] = eds->eepro_multi_diags[7];
		ed->eepm[2] = eds->eepro_multi_diags[0];
		ed->eepm[3] = eds->eepro_multi_diags[2];
	}
	ed->sdwr_single = eds->sd_fsw_single_errct;
	ed->sdwr_multi  = eds->sd_fsw_multi_errct;
	if (ed->sdwr_single || ed->sdwr_multi) {
		ed->sdwr[0] = eds->sd_fsw_diags[5];
		ed->sdwr[1] = eds->sd_fsw_diags[7];
		ed->sdwr[2] = eds->sd_fsw_diags[0];
		ed->sdwr[3] = eds->sd_fsw_diags[2];
	}
	ed->sdpb_single   = eds->sdpbk_single_errct;
	ed->sdpb_multi    = eds->sdpbk_multi_errct;
	if (ed->sdpb_single) {
		ed->sdpb[0] = eds->sdpbk_diags[5];
		ed->sdpb[1] = eds->sdpbk_diags[7];
		ed->sdpb[2] = eds->sdpbk_diags[0];
		ed->sdpb[3] = eds->sdpbk_diags[2];
	}
	if (nedacsum >= nmaxedacsum) {
		if (nedacsum == 0)
			tmp = calloc(64, sizeof(edacsumd *));
		else
			tmp = realloc(edac_sum, sizeof(edacsumd *) *
			    (64 + nmaxedacsum));
		if (!tmp)
			errx(100, "FATAL: handle_edac_sum out of mem");
		edac_sum = tmp;
		nmaxedacsum += 64;
	}
	edac_sum[nedacsum] = ed;
	nedacsum++;
	return(1);
}
static int
handle_edac_list(IBEXmsg *msg, uint32_t stm, uint32_t endm)
{
	EDAC_LIST_msg *edl = (EDAC_LIST_msg *)(msg->msg);
	edaclistd *ed, **tmp;
	int i;

	if (edl->met < stm || edl->met > endm)
		return(1);
	if ((ed = (edaclistd *)calloc(1, sizeof(edaclistd))) == NULL)
		errx(100, "FATAL: handle_edac_sum out of mem");
	ed->met = edl->met;
	for (i = 0; i < 128; i++) {
		ed->eventmet[i] = edl->event_list[i].met;
		/* 28 bits of event address */
		ed->eventaddr[i] = edl->event_list[i].diag & 0x0FFFFFFF;
		/* top 4 bits are event type: 2bits 0-2 are single/multi/unknown
		 * and next 2 bits are SRAM/EEPROM/SDRAM_ACCESS/SDRAM_PLAYBACK
		 */
		ed->eventtype[i] = (edl->event_list[i].diag & 0xF0000000) >> 28;
	}
	if (nedaclist >= nmaxedaclist) {
		if (nedaclist == 0)
			tmp = calloc(64, sizeof(edaclistd *));
		else
			tmp = realloc(edac_list, sizeof(edaclistd *) *
			    (64 + nmaxedaclist));
		if (!tmp)
			errx(100, "FATAL: handle_edac_list out of mem");
		edac_list = tmp;
		nmaxedaclist += 64;
	}
	edac_list[nedaclist] = ed;
	nedaclist++;
	return(1);
}

/*
 * Read packets from the file, passing along histogram and background
 * packets to their respective handlers as appropriate.
 */
int
process_tlm(char *file, uint32_t stmet, uint32_t endmet, int verbos)
{
	static IBEXpkt	pkt;
	static IBEXmsg	msg;
	int	fd;
	int	err = 0;
	int	pq = 0, pm = 0, pl = 0, pb = 0, px = 0, pde = 0;
	int	ph = 0, po = 0, plde = 0, psi = 0, pss = 0, pce = 0;
	int	pedl = 0, peds = 0;
	int  i, j, jj, k;

	fd = open(file, O_RDONLY);
	if (fd < 0) {
		warnx("process_tlm");
		return(1);
	}

	/* loop through file gathering msgs */
	while (1) {
		err = Read_IBEXpkt(pkt, fd, 0);
		if (err < 0) {
		    if (err != IBEX_PKT_ERR_EOF)
			warnx("%s", report_IBEXpkt_error(err, 1));
		    else
		    	err = 0;
		    break;	/* eof, typically */
		}
		IBEX_pkt2msg(pkt, &msg);
		switch (msg.apid) {
		case HI_HIST_Q:
			if (handle_hist_q(&msg, stmet, endmet) != 1)
				warnx("read error histq");
			else
				pq++;
			break;
		case HI_HIST_M:
			if (handle_hist_m(&msg, stmet, endmet) != 1)
				warnx("read error histm");
			else
				pm++;
			break;
		case HI_HIST_L:
			if (handle_hist_l(&msg, stmet, endmet) != 1)
				warnx("read error histl");
			else
				pl++;
			break;
		case BACKGROUND:
			if (handle_hi_bm(&msg, stmet, endmet) != 1)
				warnx("read error background");
			else
				pb++;
			break;
		case HI_DE_FLT:
			if (handle_hide(&msg, stmet, endmet) != 1)
				warnx("read error Hi DE");
			else
				pde++;	/* Note in hi_de_gather that we get fragments,
						 * so this isn't going to be easily useful.
						 */
			break;
		case LO_HIST_H:
			if (handle_lo_hh(&msg, stmet, endmet) != 1)
				warnx("read error Lo Hist H");
			else
				ph++;
			break;
		case LO_HIST_O:
			if (handle_lo_ho(&msg, stmet, endmet) != 1)
				warnx("read error Lo Hist O");
			else
				po++;
			break;
		case LO_DE_FLT:
			plde++;
			break;
		case SPIN_INFO:
			if (handle_spin_info(&msg, stmet, endmet) != 1)
				warnx("read error Spin Info");
			else
				psi++;
			break;
		case STAR_SENSOR:
			if (handle_ss_info(&msg, stmet, endmet) != 1)
				warnx("read error Star Sensor");
			else
				pss++;
			break;
		case ERR_LOG:
			if (handle_err_log(&msg, stmet, endmet) != 1)
				warnx("read error CEU Error Log");
			else
				pce++;
			break;
		case EDAC_SUMMARY:
			if (handle_edac_sum(&msg, stmet, endmet) != 1)
				warnx("read error EDAC Summary");
			else
				peds++;
			break;
		case EDAC_LIST:
			if (handle_edac_list(&msg, stmet, endmet) != 1)
				warnx("read error EDAC List");
			else
				pedl++;
			break;
		case EDAC_RPT:
			warnx("EDAC_RPT packets exist!");
			break;
		default:
			/* just dispose of allocated space */
			px++;
			break;
		}
		free(msg.msg);
	}
	if (verbos >= 0)
		printf("Processed %s with\n\
\t%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d\n\
\tQ/M/L/B/HiDE/LoH/LoO/LoDE/spin/SS/errlog/EDAC/EDAClist/other packets\n",
			file, pq, pm, pl, pb, pde, ph, po, plde, psi, pss, pce,
			peds, pedl, px);
	/* Stuff breaks if times are out of order.  Sort by deletion, but probably
	 * there's worse problems are out there if this triggers... XXX
	 */
	for (i = 0; i < BIN_TYPES; i++) {
		k = 0;
		for (j = hbs[i].n-1; j > 0; j--)
			if (hbs[i].met[j] < hbs[i].met[j-1]) {
				k++;
				/* Probably we have good data pasted in after
				 * bad, so simply delete earlier packets in sequence at
				 * later time until this is no longer true.
				 */
				free(*(hbs[i].data[j-1]));
				for (jj = j; jj < hbs[i].n; jj++) {
					hbs[i].data[jj-1] = hbs[i].data[jj];
					hbs[i].met[jj-1]  = hbs[i].met[jj];
					hbs[i].spincount[jj-1] = hbs[i].spincount[jj];
				}
				hbs[i].n--;
				hbs[i].nmax--;
			}
		if (verbos >= -1 && k)
			printf("Deleted %d %s packets to force packets into order!\n",
			    k, hbs[i].name);
	}
	/* Always do some fixing */
	nst_256 = fix_256_issue();
	if ((verbos > 0 && nst_256 > 0) || verbos > 1)
		printf("%d SPIN_INFO '256' glitch(es) fixed\n", nst_256);
	/* Next issue must be fixed PER ARC, which requires inordinate
	 * processing.  256_issue() is simply a clear logic glitch that's
	 * quick to fix.
	 */
	nst_pps = 0;	/* reset on reread */
	/* nst_pps = fix_PPS_issue_as_per_ISOC(); */
	return(0);
}

#if 0
/* Used with Python-created fake data files.  Kept for further testing. */
int
process_faketlm(char *file)
{
	FILE *fp;
	char foo[8192];
	int mode, l, lin;
	int i, tag;
	unsigned long met;
	garray *ar1, *ar2, *ar3;
	char *p;

	if ((fp = fopen(file, "r")) == NULL) {
		warn("%s", file);
		return(1);
	}
	mode = l = 0;
	lin = 0;
	tag = 0;
	while (fgets(foo, sizeof(foo), fp)) {
		lin++;
		switch(mode) {
		case 0:	/* time */
		   	if (sscanf(foo, "%lu", &met) != 1)
				errx(1, "mode 0 error line %d", lin);
			mode = 1;
			tag++;
			l = 0;
			if ((ar1=calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL
			    || (tag % 2 == 1 && 
			    (ar2=calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
			    ||
			    (ar3=calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int))) == NULL)
				err(100, NULL);
			break;
		case 1:	/* line of qABC */
			p = strtok(foo, " ");
			for (i = 0; i < 60; i++) {
			    (*ar1)[l][i] = atoi(p);
				p = strtok(NULL, " ");
			}
			l++;
			if (l == 6) {
				mode = 2;
				l = 0;
			}
			break;
		case 2:	/* line of lABC */
			p = strtok(foo, " ");
			for (i = 0; i < 60; i++) {
			    (*ar2)[l][i] += atoi(p);
				p = strtok(NULL, " ");
			}
			l++;
			if (l == 6) {
				mode = 3;
				l = 0;
			}
			break;
		case 3:	/* line of lAB */
			p = strtok(foo, " ");
			for (i = 0; i < 60; i++) {
			    (*ar3)[l][i] = atoi(p);
				p = strtok(NULL, " ");
			}
			l++;
			if (l == 6) {
				mode = 0;
				l = 0;
				/* And now actually shove data into arrays */
				/* Note that lABC has to be half cadence. */
				addtolog_c(hbs + HB_QABC, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_QAB, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_QBC, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_QAC, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_LB,  met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_LA, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_LC, met, 48, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_BM, met, 48, ar1);
				addtolog_c(hbs + HB_LAB, met, 48, ar3);
				if (tag % 2 == 0) {
				addtolog_c(hbs + HB_LABC,  met, 96, ar2);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_LBC, met, 96, ar1);
	ar1 = calloc(HI_ENERGIES * HI_AZ_BINS, sizeof(int));
	addtolog_c(hbs + HB_LAC, met, 96, ar1);
				}
			}
			break;
		}
	}
	fclose(fp);
	return(0);
}
#endif
