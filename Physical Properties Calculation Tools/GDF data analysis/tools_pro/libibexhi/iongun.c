/*	$Id: iongun.c,v 1.33 2019/10/22 22:54:01 pjanzen Exp $	*/
/* This is similar to isoofs.c in that it deals with an isotropic offset:
 * "ion gun" contamination, predominantly in ESAs 1, 2, 5, and 6.
 * We ignore it in ESAs 3 and 4 since it's quite small there.
 *
 * The source is hot (> 100 eV) isotropic solar wind electron density.
 * In the solar wind, we can correlate to fluxes measured by solar wind
 * instruments; we use WIND electron data because ACE has efficiency
 * variations over time.  (We could "fake" up locally-calibrated ACE data
 * to fill in holes in the WIND data.)
 *
 * There is a function here which correlates WIND (103-eV) electron flux to
 * IBEX-Hi count rates, over time.  It's based on a linear fit over a long
 * period of time.  ESA 1 and 2 signal is from H from H2O.
 * ESA 5 and 6 is H from H2.  Both appear basically to differ over time at
 * about the same rate (surprise); their relation to WIND data does change
 * (less sensitive) after the first year.
 *
 * Because WIND is not always available, we correlate instead to "excess"
 * lAB signal in ESAs 3 and 4, which we attribute to oxygen from ion-gun
 * water.  There are numerous diagnostic functions in this file for minimum
 * isotropic background, excess lABs, etc.
 *
 * With luck, this correction will end up zero with the newer higher
 * negative collimator potential.
 *
 * Functions here return a 60-element arrays per ESA of offset and
 * uncertainty in offset, for a given cull number.  Part of the cleverness
 * is that the correction only applies for that portion of the good times
 * in the solar wind, but the calculated offset applies to the good times
 * as a whole.
 *
 * Additionally, if there are good and "loose" culls, there's more work.
 * The offset between the good and loose cull gets calculated over in
 * isoofs.c and will obliterate some amount of the ion gun correction, if
 * you don't account for it.
 *
 * To start with, this applies ONLY to qABC.  Additional functions would be
 * necessary to correct ion gun for any other coincidence type.
 */
#include <err.h>
#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: iongun.c,v 1.33 2019/10/22 22:54:01 pjanzen Exp $";

/* This really belongs in ../response/Hi_cal.c, or in a new file
 * ../response/Hi_cal-orbit.c
 * or some such.
 * The point is to obtain an interpolated expected efficiency of detector
 * section C, versus time in the mission.  This is based on analysis of
 * on-orbit data, by assuming hot electrons form the bulk of the "ion gun"
 * signal, and interpolating what section C efficiency is required for zero
 * WIND- or ACE- based hot electron signal to match to zero ion gun.
 * The result of this analysis, which incorporates CEM voltage shifts as
 * they occur, is a file to be read in, where intermediate points are
 * interpolated.
 *
 * How this correlates to the original efficiency numbers from ground cal
 * is nontrivial.
 *
 * There should also be functions for detector sections A and B, done the
 * same way.  However, the immediate reason for this function is to
 * calculate an ion gun correction, and that needs only detector section C.
 *
 * Input a time; return an efficiency (0-1; negative if out of useful time
 * range) and an uncertainty in effunc.
 */
double
expected_detC_efficiency(uint32_t met, double *effunc)
{
	/* With severe caveats for map 1 and possibly more of year 1, we do
	 * not think we see section C change meaningfully yet (end of year 5).
	 */
	/* will become XXX in the future */
	*effunc = 0.015;
	return(0.465);
}

/* For now put this here -- at least it's factored out in one place.
 * We do not see time effects; it seems for now that the only thing varying
 * in time is penetrating background ratios.  Return 0 for lAB ESA that's
 * not 3 or 4 (i.e., 2 or 3 on the 0..5 scale), or qABC ESA that's not
 * 1,2,5,6.
 *
 * This is returned in Hz, not in /hb, although the factor assumes lAB is
 * in /hb.  Note this implies a base uncertainty of (a few seconds)/690.5s
 * or about .4% simply by having determined the coefficients assuming
 * HB_TIME was completely constant.
 *
 * The uncertainties are from the fitting and almost assuredly are
 * underestimates.  Certainly the estimation of excess lAB from count rates
 * and a guess at epsilon_C is fraught with serious issues.
 */
double
conversionfactor_lAB_qABC(uint32_t met, int esalab, int esaqabc,
    double *convunc)
{
	double retval;

	*convunc = -1.;
	retval = 0.;
	if (esalab < 2 || esalab > 3 || esaqabc < 0 || esaqabc > 5 ||
	    esaqabc == 2 || esaqabc == 3)
		return(retval);
	/* uncs no longer are from fit uncertainty but from variation in fits
	 * over time.
	 */
	switch(esaqabc) {
	case 0:
		if (esalab == 2) {
			*convunc = 0.012;
			retval = 0.2876;
		} else {
			*convunc = 0.0082;
			retval = 0.1886;
		}
		break;
	case 1:
		if (esalab == 2) {
			*convunc = 0.007;
			retval = 0.1120;
		} else {
			*convunc = 0.005;
			retval = 0.0729;
		}
		break;
	case 4:	/* XXX this one is just scaled (badly) to ESA 6... */
		if (esalab == 2) {
			*convunc = 0.016;
			retval = 0.0611;
		} else {
			*convunc = 0.010;
			retval = 0.0398;
		}
		break;
	case 5:
		if (esalab == 2) {
			*convunc = 0.011;
			retval = 0.1071;
		} else {
			*convunc = 0.007;
			retval = 0.0699;
		}
		break;
	}
	return(retval);
}


/* Do this in relation to the qABC correction; why not?
 * Run unc in quadrature with qABC correction?  That does overestimate
 * it a little.
 */
double
conversionfactor_lAB_qBC_relqABC(uint32_t met, int esaqbc, double *convunc)
{
	double retval;

	*convunc = -1.;
	retval = 0.;
	if (esaqbc < 0 || esaqbc > 5 || esaqbc == 2 || esaqbc == 3)
		return(retval);
	switch(esaqbc) {
	case 0:
		retval = 2.06;
		*convunc = (0.024 * retval);
		break;
	case 1:
		retval = 1.80;
		*convunc = (0.024 * retval);
		break;
	case 4:
		retval = 1.49;	/* XXX scaling; really a guess. */
		*convunc = (0.024 * retval);
		break;
	case 5:
		/* Here's where the conversion uncertainty is small, because
		 * relative to qABC, this ratio seems solid.
		 */
		retval = 1.49;
		*convunc = (0.004 * retval);
		break;
	default:
		retval = 0.;
		break;
	}
	return(retval);
}


/* Allocate and return an array of minimum isotropic backgrounds seen in hb
 * whichhb, over n consecutive angle bins and m consecutive histograms in
 * ESA whichesas (OR of 1<<(0..5)), for all times for which any angle at all
 * is good in whichcull's cullesa (0..5).  Set flag f to nonzero if the
 * histograms used don't have to be consecutive in time (i.e., if there can
 * be gaps).
 *
 * Failure means returning an array of length 0.
 */
void
get_min_iso_bgs(int n, int m, int whichhb, int whichesas, int whichcull,
    int cullesa, int f, double **bgs, int *nbgs)
{
	long w[HI_AZ_BINS], mn, tmp;
	int i, j, k;
	int flag, msofar;

	*nbgs = 0;
	if (n < 1 || n >= HI_AZ_BINS || m < 1 || m > 32 || whichhb < 0 ||
	    whichhb >= BIN_TYPES || whichcull < 0 || whichcull >= 8 ||
	    whichesas < 0 || whichesas >= (1 << (HI_ENERGIES+1)) ||
	    cullesa < 0 || cullesa >= HI_ENERGIES || m > hbs[whichhb].n)
		return;
	/* Simplest just to alloc once.  It can't be more than hbs[].n divided
	 * by m, and that's small enough not to fuss about it a lot.
	 */
	if ((*bgs = (double *)calloc(hbs[whichhb].n / m, sizeof(double))) == NULL)
		return;
	memset(w, 0, HI_AZ_BINS * sizeof(long));
	msofar = 0;
	for (i = 0; i < hbs[whichhb].n; i++) {
		flag = 0;
		for (j = 0; j < HI_AZ_BINS; j++)
			if (safe_isincull(whichcull, hbs[whichhb].met[i], cullesa, j)) {
				flag = 1;
				j = HI_AZ_BINS;
			}
		if (flag) {
			for (j = 0; j < HI_AZ_BINS; j++) {
				for (k = 0; k < get_max_E(hbs[whichhb].flag); k++)
					if (whichesas & (1 << k))
						w[j] += (*(hbs[whichhb].data[i]))[k][j];
			}
			/* Double-count ESA 1 spin bin zero if it's being used,
			 * at least if it's not despun data, which I check for
			 * by looking for a name that starts with "D".
			 * XXX
			 */
			if ((whichesas & (1 << 0)) && (hbs[whichhb].name[0] != 'D'))
				w[0] += (*(hbs[whichhb].data[i]))[0][0];
			msofar++;
			if (msofar == m) {
				msofar = 0;
				/* Find the min over angle range requested */
				mn = 0;
				for (k = 0; k < n; k++)
					mn += w[k];
				for (j = 1; j < HI_AZ_BINS; j++) {
					tmp = 0;
					for (k = 0; k < n; k++)
						tmp += w[(k + j) % HI_AZ_BINS];
					if (tmp < mn)
						mn = tmp;
				}
				(*bgs)[*nbgs] = (double)mn;
				(*nbgs)++;
				memset(w, 0, HI_AZ_BINS * sizeof(long));
			}
		} else if (f == 0 && msofar != 0) {
			/* Have to reset -- can't have temporal gaps */
			memset(w, 0, HI_AZ_BINS * sizeof(long));
			msofar = 0;
		}
	}
}

/* Same as get_min_iso_bgs() in terms of timing, but instead, get WIND
 * data.  Idea is to get matching arrays from these two functions and then
 * to do a fit on the comparison.  Requires WIND data to have been read in.
 * So that array sizes match, insert a -1. anywhere where we are lacking
 * WIND data.
 */
void
get_wind_e_bgs(int m, int whichhb, int whichcull, int cullesa, int f,
    double **bgs, int *nbgs)
{
	int i, j, k;
	int flag, msofar, mcur;
	double tmp, tmpt;
	double wflux, t;

	*nbgs = 0;
	if (m < 1 || m > 32 || whichhb < 0 || whichhb >= BIN_TYPES ||
	    whichcull < 0 || whichcull >= 8 ||
	    cullesa < 0 || cullesa >= HI_ENERGIES || m > hbs[whichhb].n)
		return;
	/* Simplest just to alloc once.  It can't be more than hbs[].n divided
	 * by m, and that's small enough not to fuss about it a lot.
	 */
	if ((*bgs = (double *)calloc(hbs[whichhb].n / m, sizeof(double))) == NULL)
		return;
	msofar = 0;
	mcur = 0;
	wflux = 0.;
	t = 0.;
	for (i = 0; i < hbs[whichhb].n; i++) {
		flag = 0;
		for (j = 0; j < HI_AZ_BINS; j++)
			if (safe_isincull(whichcull, hbs[whichhb].met[i], cullesa, j)) {
				flag = 1;
				j = HI_AZ_BINS;
			}
		if (flag) {
			msofar++;
			mcur++;
		} else if (f == 0) {
			/* Have to reset -- can't have temporal gaps */
			msofar = 0;
			mcur = 0;
			wflux = 0.;
			t = 0.;
		}
		if ((flag && msofar == m) || (!flag && f != 0 && mcur > 0)) {
			/* Have to get flux for the current time interval, to mix
			 * in with other intervals.  Assume timing starts a second
			 * after the packet prior to the start of things -- this
			 * assumes that any cull we want will NOT start on the first
			 * packet or the first packet after a data gap. XXX-ish
			 */
			k = i - mcur - 1;
			if (k < 0)
				k = 0;
			tmp = get_avgwindeflux((double)(hbs[whichhb].met[k]) + 1.,
			    (double)(hbs[whichhb].met[i-1]));
			tmpt = (double)(hbs[whichhb].met[i-1]) -
			    ((double)(hbs[whichhb].met[k]) + 1.);
			if (tmp < 0. || wflux < 0.)
				wflux = -1.;
			else if (t < 1.) {
				wflux = tmp;
				t = tmpt;
			} else {	/* weight'em by time */
				wflux = wflux * (t/(tmpt+t)) + tmp * (tmpt/(tmpt+t));
				t += tmpt;
			}
			mcur = 0;
			if (msofar == m) {
				msofar = 0;
				(*bgs)[*nbgs] = wflux;
				(*nbgs)++;
				wflux = 0.;
				t = 0.;
			}
		}
	}
}

/* Same idea as previous two functions, but for "excess" isotropic lAB
 * counts in a particular ESA setting.  Need to provide a CEM C efficiency
 * and a ratio of lAB to qABC, but no uncertainties.
 *
 * [Note that this is not strictly excess lAB.  Truthfully it's excess
 * (lAB + lABC); in other words, excess AB regardless of what C does.
 * This is how I set up the ion gun correction for qABC.  It's not
 * necessarily the ONLY or even the best way to do it.  An argument for
 * doing it this way is that it keeps effc as the fundamental quantity, not
 * the ratio of lAB to qABC.  A few arguments against it are (1) potential
 * greater uncertainty due to addition of lABC and subtraction of
 * penetrating background what with all the Poisson action; (2) resultant
 * confusing name of this function; (3) I end up having to do it
 * differently if and when I want a correction for the lABs themselves.]
 *
 * Note in comparison to get_basic_iongun, things are a lot simpler.  We do
 * assume cull_partial_hbs() and further_cull_hbs() have run, and that the
 * cull we have is appropriately spun for histogram analysis and needs no
 * further cleverness.  get_basic_iongun is way more complicated because it
 * has to translate all this back to despun direct events.
 *
 * m is taken to be over SLOW cadence, not fast.  That means to compare to
 * regular cadence data in above two functions, we need to make sure m is
 * even there.
 *
 * penb has to be in /hb, not in Hz.  XXX
 */
void
get_iso_excess_lAB(int m, int whichesa, int whichcull, int cullesa, int f,
    double effc, double penb, double **bgs, int *nbgs)
{
	int i, j;
	int flag, msofar;
	long sumlabc, sumlab, sumqabc;
	int nangbins;
	double mn, tmp, ratlab, ratlabc;

	*nbgs = 0;
	if (m < 1 || m > 32 || whichesa < 0 || whichesa >= HI_ENERGIES ||
	    whichcull < 0 || whichcull >= 8 ||
	    cullesa < 0 || cullesa >= HI_ENERGIES || m > hbs[HB_LABC].n)
		return;
	/* XXX could/should let these vary over the orbit.  TO FIX */
	ratlab = get_penbg_ratio(hbs[HB_QABC].met[hbs[HB_QABC].n / 2],
	    HB_LAB, &tmp);
	ratlabc = get_penbg_ratio(hbs[HB_QABC].met[hbs[HB_QABC].n / 2],
	    HB_LABC, &tmp);
	if (ratlab < 0. || ratlabc < 0.)
		return;
	/* It's kind of a check... don't run if we don't have the right
	 * relative number of packets.
	 */
	if (hbs[HB_LABC].n * 2 != hbs[HB_QABC].n ||
	    hbs[HB_LABC].n * 2 != hbs[HB_LAB].n)
		return;
#if 1
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		if (hbs[HB_LABC].met[i] - HBtimeSlop > hbs[HB_LAB].met[2 * i + 1] ||
		    hbs[HB_LAB].met[2 * i + 1] - HBtimeSlop > hbs[HB_LABC].met[i]) {
			warnx("get_iso_excess_lAB:  failure to find sufficiently matching\n\
times between LABC and LAB (packet %d)", i);
			return;
		}
	}
#endif
	/* Simplest just to alloc once.  It can't be more than hbs[].n divided
	 * by m, and that's small enough not to fuss about it a lot.
	 */
	if ((*bgs = (double *)calloc(hbs[HB_LABC].n / m, sizeof(double))) == NULL)
		return;
	msofar = 0;
	sumlabc = sumlab = sumqabc = 0;
	nangbins = 0;
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		flag = 0;
		for (j = 0; j < HI_AZ_BINS; j++)
			if (safe_isincull(whichcull, hbs[HB_LABC].met[i], cullesa, j)) {
				flag = 1;
				j = HI_AZ_BINS;
			}
		if (flag) {
			msofar++;
			for (j = 0; j < HI_AZ_BINS; j++) {
				 /* assume that half-cadence entry y corresponds to
				  * normal-cadence entries y * 2 and y * 2 + 1, so
				  * the time they share is in y * 2 + 1.
				  */
				if (safe_isincull(whichcull, hbs[HB_LABC].met[i],
				    cullesa, j) &&
				    safe_isincull(whichcull, hbs[HB_QABC].met[i * 2],
				    cullesa, j)) {
					sumlabc += (*(hbs[HB_LABC].data[i]))[whichesa][j];
					sumlab  += (*(hbs[HB_LAB].data[2*i]))[whichesa][j];
					sumlab  += (*(hbs[HB_LAB].data[2*i+1]))[whichesa][j];
					sumqabc += (*(hbs[HB_QABC].data[2*i]))[whichesa][j];
					sumqabc += (*(hbs[HB_QABC].data[2*i+1]))[whichesa][j];
					nangbins++;
					nangbins++;
				}
			}
			if (msofar == m) {
				msofar = 0;
				mn = (sumlab + sumlabc)/((double)(nangbins)) -
				    penb * (ratlab + ratlabc) -
				    (sumqabc / ((double)(nangbins)) - penb) / effc;
				/* 1/effc would be (1./effc - 1.) if it were truly
				 * excess lAB and not excess-any-AB
				 */
				(*bgs)[*nbgs] = mn;
				(*nbgs)++;
				sumlabc = sumlab = sumqabc = 0;
				nangbins = 0;
			}
		} else if (f == 0) {
			/* Have to reset -- can't have temporal gaps */
			msofar = 0;
			sumlabc = sumlab = sumqabc = 0;
			nangbins = 0;
		}
	}
}


/* Using the valid angle bins of ESA cullesa (0..5) in cull whichcull,
 * and provided a CEM C efficiency and unc (effc, effcunc) and a
 * penetrating background rate (Hz) for qABC (penb, penbunc),
 * allocate and return two arrays of HI_AZ_BINS of double indicating
 * the ion gun contamination rate (/hb) and uncertainty for ESAs included
 * in esa1.  Use a flag to determine whether there's despinning to do or not.
 *
 * cull_partial_hbs() and further_cull_hbs() MUST have been run:  we need
 * high-cadence and low-cadence histograms to be lined up.  We could save
 * some checks if trim_cull_to_slow_cadence() has run, but presumably the
 * cull periodicity (and alltimes[]) will match the despun data and not the
 * histogram data anyhow.
 *
 * (Note esa1 is a bitmap and cullesa is a single value.  This choice
 * follows from wanting corrections for "old" ESAs 1,2,5,6, but ESA 3 under
 * the new map happening in 2 consecutive "sweep entries".  If we sat at
 * ESA 2, for instance, for 2 sweep table entries, I'd make cullesa a
 * bitmap too.)
 *
 * This all would be SO much easier if we didn't have to despin.
 *
 * If hbtype is HB_LAB, this returns the excess lAB count rate (Hz)
 * and uncertainty rather than converting to qABC.  In this case, there are
 * a couple additional constraints:  warn if dodespin and wantlAB, because
 * it doesn't make a lot of sense; and make sure cullesa is in esa1.
 *
 * Return 0 on success.
 *
 * For HB_LAB, we do NOT subtract additional H signal related to
 * ion gun.  We subtract ONLY the oxygen component.  For ESAs 1,2,5,6,
 * then, for proper lAB numbers we'll probably need to get the qABC
 * correction as well and then to scale that to lAB counts based on
 * expected efficiencies.  That is the responsibility of the calling
 * function to implement.
 *
 * For hbtype HB_QBC, we get HB_QABC backgrounds and simply scale using
 * conversionfactor_lAB_qBC_relqABC() at the end.
 */
int
get_basic_iongun(char esa1, int cullesa, int whichcull, int dodespin,
    double effc, double effcunc, double penb, double penbunc,
    double **ionghz, double **ionghzunc, double hbtime,
    int hbtype, int verbosity)
{
	int i, ii, j, k, l, flag;
	int t1, t2;
	int whichangs[HI_AZ_BINS];
	double *spunarray;
	long sumlabc, sumlab, sumqabc;
	int nangbins;
	long slabc[HI_AZ_BINS], slab[HI_AZ_BINS], sqabc[HI_AZ_BINS];
	int sangb[HI_AZ_BINS];
	double ratlab, ratlabc, ratlabunc, ratlabcunc, tmp, qbcunc;
	int swptable[6], sESA;
	uint32_t nominalmet;

	if ((esa1 & 0x3F) == 0 ||
	    cullesa < 0 || cullesa >= HI_ENERGIES ||
	    whichcull < 0 || whichcull >= 8 ||
	    ((hbtype == HB_LAB) && (esa1 & (1 << cullesa)) == 0))
		return(1);
	if (hbtype != HB_LAB && hbtype != HB_QABC && hbtype != HB_QBC)
		return(1);
	if ((hbtype == HB_LAB) && dodespin) {
		if (verbosity >= 0)
			printf("get_basic_ion_gun(): want lAB, also despinning?\n");
		/* dodespin = 0; */
	}
	if ((hbtype == HB_LAB) && penb > 0.09) {	/* XXX hardwired, but just a warning */
		if (verbosity >= 0)
			printf("get_basic_ion_gun(): lAB pen bg supplied instead of qABC?\n");
	}
	/* Penbg and penbgunc are going to be in Hz.  Convert locally to /hb */
	/* XXX Note that hbtime must be supplied here; whatever value it was,
	 * it's probably not exactly what was used to calculate penetrating
	 * bg.
	 */
	penb *= hbtime/(double)(HI_AZ_BINS * HI_ENERGIES);
	penbunc *= hbtime/(double)(HI_AZ_BINS * HI_ENERGIES);
	/* Make sure sweep table doesn't change during interval we care about;
	 * also, choose the central time as representative of the interval.
	 */
	i = 0;
	while (i / HI_AZ_BINS < nallt && (mculls[whichcull][i] & (1<<cullesa)) == 0)
		i++;
	if ((t1 = i / HI_AZ_BINS) >= nallt) {
		/* No good times, so set the world's shortest interval. */
		t1 = 0;
		t2 = 0; /* nallt - 1; */
	} else {
		i = (nallt - 1) * HI_AZ_BINS;
		while (i > t1  && (mculls[whichcull][i] & (1<<cullesa)) == 0)
			i--;
		t2 = i / HI_AZ_BINS;
	}
	nominalmet = alltimes[(t1 + t2)/2];
	if (get_sweeptable(nominalmet, swptable))
		return(-1);
	if (is_sweep_same(alltimes[t1], alltimes[t2], (char)(1<<cullesa)) == 0)
		return(-100);
	/* Check to make sure all ESAs in esa1 are at the same sweep table
	 * entry.  Don't bother checking if the sweep is time constant, though.
	 */
	sESA = -1;
	for (i = 0; i < HI_ENERGIES; i++)
		if ((1 << i) & esa1) {
			if (sESA >= 0 && sESA != swptable[i])
				return(-200);
			sESA = swptable[i];
		}
	if (sESA < 0)
		return(-300);
	ratlab = get_penbg_ratio(nominalmet, HB_LAB, &ratlabunc);
	ratlabc = get_penbg_ratio(nominalmet, HB_LABC, &ratlabcunc);
	if (ratlab < 0. || ratlabc < 0.)
		return(2);
	/* It's kind of a check... don't run if we don't have the right
	 * relative number of packets.
	 */
	if (hbs[HB_LABC].n * 2 != hbs[HB_QABC].n ||
	    hbs[HB_LABC].n * 2 != hbs[HB_LAB].n) {
		if (verbosity > 1)
			printf("get_basic_iongun: number of packets don't match up.\n");
		return(2);
	}
#if 1
	for (i = 0; i < hbs[HB_LABC].n; i++) {
		if (hbs[HB_LABC].met[i] - HBtimeSlop > hbs[HB_LAB].met[2 * i + 1] ||
		    hbs[HB_LAB].met[2 * i + 1] - HBtimeSlop > hbs[HB_LABC].met[i]) {
			warnx("get_basic_iongun:  failure to find sufficiently matching\n\
times between LABC and LAB (packet %d)", i);
			return(-100);
		}
	}
#endif
	if (dodespin) {
		i = get_spinup_ranges(&spunarray, HB_LABC);
		if (i && verbosity > 1)
			printf("get_basic_iongun: failed on get_spinup_ranges (%d)\n",
			    i);
		if (i)
			return(i);
		/* Make life a bit easier by not modding by HI_AZ_BINS */
		for (i = 0; i < hbs[HB_LABC].n; i++)
			for (j = 0; j < HI_AZ_BINS; j++)
				if (spunarray[(i * HI_AZ_BINS + j)* 2] >
				    spunarray[(i * HI_AZ_BINS + j)* 2 + 1])
		    spunarray[(i * HI_AZ_BINS + j) * 2 + 1] += (double)HI_AZ_BINS;
	} else {
		/* Could make a quicker codepath, but why nearly duplicate
		 * things?  Fake a nice easy spunarray that's not spun.
		 */
		if ((spunarray = (double *)calloc(hbs[HB_LABC].n * HI_AZ_BINS * 2,
		    sizeof(double))) == NULL)
			return(-1);
		for (i = 0; i < hbs[HB_LABC].n; i++)
			for (j = 0; j < HI_AZ_BINS; j++) {
				spunarray[(i * HI_AZ_BINS + j) * 2] = (double)j;
				spunarray[(i * HI_AZ_BINS + j) * 2 + 1] = (double)j;
			}
	}
	if ((*ionghz = (double *)calloc(HI_AZ_BINS, sizeof(double))) == NULL) {
		free(spunarray);
		return(-1);
	}
	if ((*ionghzunc = (double *)calloc(HI_AZ_BINS, sizeof(double))) == NULL) {
		free(*ionghz);
		free(spunarray);
		return(-1);
	}
	/* Bail early if we asked for ESA 3 and 4, which have no correction
	 * (for now).  Note sweep table is 1..6 (not 0..5) and 0 is a bg test.
	 */
	if (((hbtype != HB_LAB) &&
	    (swptable[cullesa] == 3 || swptable[cullesa] == 4))
	    || swptable[cullesa] == 0) {
		free(spunarray);
		return(0);
	}

	t1 = t2 = 0;
	for (i = 0; i < HI_AZ_BINS; i++) {
		slabc[i] = slab[i] = sqabc[i] = 0;
		sangb[i] = 0;
	}
	/* End of prep.  Now, build up, time by time, angle bin by angle bin,
	 * the arrays of counts, from which we'll get ion gun offset and
	 * uncertainty.  At the end, we could look for matching elements.  This
	 * approach is sadly up to 6*60 times slower than a smarter algorithm,
	 * particularly for the situation where there's no angular dependence
	 * at all and all 60 angles will have the same correction, but at
	 * least this is not a terribly slow process to run.
	 * XXX could be improved.
	 */
	for (i = 0; i < hbs[HB_LABC].n; i++) {
for (ii = 0; ii < HI_ENERGIES; ii++) {
	if (esa1 & (1 << ii)) {
#if 0
/* Hey wow, I think I don't even need this since spunarray is already at
 * the right cadence.
 */
		/* Get range of alltimes[] and hence cull associated with this bin */
		t1 = t2;	/* not necessarily (t2 + 1) */
		while (nallt > t2 && alltimes[t2] < hbs[HB_LABC].met[i] - HBtimeSlop)
			t2++;
		if (t2 == nallt) {
			warnx("should never happen t2");
			t2 = nallt - 1;
		}
		if (i > 0) {
			while (t1 < t2 &&
			    alltimes[t1] < hbs[HB_LABC].met[i-1] - HBtimeSlop)
				t1++;
		}
#endif
		sumlabc = sumlab = sumqabc = 0;
		nangbins = 0;
		for (j = 0; j < HI_AZ_BINS; j++) {
			/* See if this angle at this time is in the cull.
			 * It's brutally long and involved simply because "this
			 * angle" could be spun over a wide range and "this time"
			 * means the duration of a half-cadence packet.
			 */
			memset(whichangs, 0, sizeof(int) * HI_AZ_BINS);
			for (l = lround(spunarray[(i * HI_AZ_BINS + j) * 2] - 0.45);
			    l <= lround(spunarray[(i * HI_AZ_BINS + j) * 2 + 1] + 0.45);
			    l++)
				whichangs[l % HI_AZ_BINS]++;
			flag = 0;
			for (k = 0; k < HI_AZ_BINS; k++) {
				 /* assume that half-cadence entry y corresponds to
				  * normal-cadence entries y * 2 and y * 2 + 1, so
				  * the time they share is in y * 2 + 1.
				  */
				if (whichangs[k] &&
				    (safe_isincull(whichcull, hbs[HB_LABC].met[i],
				    cullesa, k) == 0 ||
				    safe_isincull(whichcull, hbs[HB_QABC].met[i * 2],
				    cullesa, k) == 0)) {
					flag = 1;
					k = HI_AZ_BINS;
				}
			}
			if (flag == 0) {
				sumlabc += (*(hbs[HB_LABC].data[i]))[ii][j];
				sumlab  += (*(hbs[HB_LAB].data[2*i]))[ii][j];
				sumlab  += (*(hbs[HB_LAB].data[2*i+1]))[ii][j];
				sumqabc += (*(hbs[HB_QABC].data[2*i]))[ii][j];
				sumqabc += (*(hbs[HB_QABC].data[2*i+1]))[ii][j];
				nangbins++;
				nangbins++;
			}
		}
		/* Ion gun is isotropic, so add the sums from all good angles at
		 * this time to each angle range that's good.
		 */
		for (j = 0; j < HI_AZ_BINS; j++) {
			if (safe_isincull(whichcull, hbs[HB_LABC].met[i], cullesa, j) &&
			    safe_isincull(whichcull, hbs[HB_LABC].met[i], cullesa, j)) {
				slabc[j] += sumlabc;
				slab[j]  += sumlab;
				sqabc[j] += sumqabc;
				sangb[j] += nangbins;
			}
		}
	}
}
	}
	free(spunarray);
	/* First, convert from counts to ion gun for each angle. */
	/* We'll then look up the conversion factor. */
	/* penb and its unc have already been converted to /hb */
	for (j = 0; j < HI_AZ_BINS; j++) {
		if (sangb[j] == 0) {
			(*ionghz)[j] = 0.;
			(*ionghzunc)[j] = -1.;
		} else {
		(*ionghz)[j] = (slab[j] + slabc[j])/((double)(sangb[j])) -
		    penb * (ratlab + ratlabc) -
		    (sqabc[j] / ((double)(sangb[j])) - penb) / effc;
		/* The 1/effc would be (1./effc - 1.) if we specifically wanted
		 * O excess in lAB rather than (lAB + lABC).
		 */
		if (hbtype == HB_LAB) {
			(*ionghz)[j] = (slab[j])/((double)(sangb[j])) -
			    penb * (ratlab) -
			    (sqabc[j] / ((double)(sangb[j])) - penb) * (1./ effc - 1.);
		}
		/* XXX uncertainy calc is NOT right for HB_LAB now. */
		(*ionghzunc)[j] = sqrt((slab[j] + slabc[j] + sqabc[j]/(effc*effc))/
		    (((double)sangb[j])*((double)(sangb[j]))) +
		    (1./effc - ratlab - ratlabc) * (1./effc - ratlab - ratlabc) *
		    penbunc * penbunc +
		    penb * penb * (ratlabunc * ratlabunc + ratlabcunc * ratlabcunc) +
		    (sqabc[j]/(double)(sangb[j]) - penb) *
		    (sqabc[j]/(double)(sangb[j]) - penb) *
		    effcunc * effcunc / (effc * effc * effc * effc));
		}
	}
	/* What if it's negative?  Next level up can worry about that. */
	if (hbtype == HB_LAB) {
		/* We have it in /hb in lAB.  We want it in Hz. Repurpose ratlab */
		ratlab = (double)(HI_AZ_BINS * HI_ENERGIES)/hbtime;
		for (j = 0; j < HI_AZ_BINS; j++) {
			(*ionghz)[j] *= ratlab;
			(*ionghzunc)[j] *= ratlab;
		}
		/* Hey, that's not all.
		 * We have determined the excess counts in the ABs due to ion-gun
		 * oxygen.  However, we have not yet added in the remaining excess
		 * counts in the ABs due to ion-gun hydrogen.  Doing so is the
		 * responsibility of the calling function(!), because there are a
		 * variety of possible ways to do it.
		 */
		return(0);
	}
	/* Convert to Hz in qABC.  Repurpose ratlab and ratlabunc. */
	ratlab = conversionfactor_lAB_qABC(nominalmet, sESA - 1,
	    swptable[cullesa] - 1, &ratlabunc);
	if (ratlab < 0.0001)
		warnx("get_basic_iongun fail %d %d", sESA - 1, swptable[cullesa] - 1);
#ifdef DEBUG
	ii = 0;
#endif
	for (j = 0; j < HI_AZ_BINS; j++) {
		if (ratlabunc >= 0. && (*ionghzunc)[j] >= 0.)
			(*ionghzunc)[j] = sqrt((*ionghzunc)[j] * (*ionghzunc)[j] /
			    ((*ionghz)[j] * (*ionghz)[j]) + ratlabunc * ratlabunc /
			    (ratlab * ratlab)) * fabs((*ionghz)[j] * ratlab);
		(*ionghz)[j] *= ratlab;
#ifdef DEBUG
		if ((*ionghz)[j] < 0.)
			ii++;
#endif
	}
	if (hbtype == HB_QBC) {
		tmp = conversionfactor_lAB_qBC_relqABC(nominalmet, sESA - 1, &qbcunc);
		for (j = 0; j < HI_AZ_BINS; j++) {
			if (qbcunc > 0. && tmp > 0. && (*ionghzunc)[j] >= 0.)
				(*ionghzunc)[j] = sqrt((*ionghzunc)[j] * (*ionghzunc)[j] /
				    ((*ionghz)[j] * (*ionghz)[j]) + qbcunc * qbcunc /
				    (tmp * tmp)) * fabs((*ionghz)[j] * tmp);
			(*ionghz)[j] *= tmp;
		}
	}
#ifdef DEBUG
	if (ii > 0)
		warnx("ionguncor was %d (should be 0)", ii);
#endif
	return(0);
}


/* This is a statistical MERGE assuming no shared uncertainty.  Requires
 * items HI_AZ_BINS long
 */
static void
_mergeunc(double *a, double *da, double *b, double *db)
{
	int i;
	double tmp;

	for (i = 0; i < HI_AZ_BINS; i++) {
		if (da[i] > 0.) {
			if (db[i] > 0.) {
				tmp = 1./(db[i] * db[i]) + 1./(da[i] * da[i]);
				a[i] = (b[i]/(db[i] * db[i]) + a[i]/(da[i] * da[i]))/tmp;
				da[i] = sqrt(1./tmp);
			} else
				da[i] = -1.;
		}
	}
}

/* And this is one if you're not averaging but are ADDING. */
static void
_addunc(double *a, double *da, double *b, double *db)
{
	int i;
	double tmp;

	for (i = 0; i < HI_AZ_BINS; i++) {
		if (da[i] > 0.) {
			if (db[i] > 0.) {
				tmp = sqrt(da[i] * da[i] + db[i] * db[i]);
				a[i] += b[i];
				da[i] = tmp;
			} else
				da[i] = -1.;
		}
	}
}


/* More convenience.  Fill up provided {rates, uncs}[HI_ENERGIES][HI_AZ_BINS]
 * all at once.  Assumed that everything's been set up as required for
 * get_basic_iongun().
 *
 * Return 0 on success.  Bail on first failure of get_basic_iongun().
 * This is based on the original hibg2.c.
 *
 * hbtype can be one of HB_QABC, HB_QBC, or HB_LAB.
 * For lAB, we do subtract additional H signal related to
 * ion gun, not just oxygen component.
 * qBC we scale based on qABC.
 */
int
iongun_populate_all_offsets(int whichcull, int dodespin,
    double penb, double penbunc,
    double rates[HI_ENERGIES][HI_AZ_BINS],
    double uncs[HI_ENERGIES][HI_AZ_BINS],
    double hbtime, int hbtype, int verbosity)
{
	int i, j, k;
	uint32_t mmet;
	double CEMCeff, CEMCunc;
	int swptable[HI_ENERGIES];
	char dothethree, dothefour;
	double *thrcor, *thrunc, *frcor, *frunc;

	for (i = 0; i < HI_ENERGIES; i++)
		for (j = 0; j < HI_AZ_BINS; j++) {
			rates[i][j] = uncs[i][j] = 0.;
		}
	mmet = alltimes[3] / 2 + alltimes[nallt - 4] / 2;
	CEMCeff = expected_detC_efficiency(mmet, &CEMCunc);
	if (get_sweeptable(mmet, swptable)) {
		if (verbosity > 1)
			printf("iongun_populate_all_offsets(): no sweep table?\n");
		return(-1);
	}
	/* Maybe this wantlAB stuff should be broken out to a separate function */
	if (hbtype == HB_LAB) {
		char dothem;

		for (i = 0; i < HI_ENERGIES; i++) {
			dothem = '\0';
			for (j = 0; j < HI_ENERGIES; j++)
				if (swptable[j] == swptable[i])
					dothem |= (1 << j);
			j = get_basic_iongun(dothem, i, whichcull, dodespin,
			    CEMCeff, CEMCunc, penb, penbunc, &thrcor, &thrunc,
			    hbtime, hbtype, verbosity);
			if (j != 0)
				return(j);
			/* Look for negatives. Ion gun on its own may NOT go
			 * negative, but if it does, I want to know.
			 */
			k = 0;
			for (j = 0; j < HI_AZ_BINS; j++) {
				if (thrcor[j] < 0.) {
					k++;
					rates[i][j] = 0.;
				} else
					rates[i][j] = thrcor[j];
				uncs[i][j] = thrunc[j];
			}
			if (verbosity >= 0 && k > 0)
printf("iongun_populate_all_offsets(): found lAB-O negative ion gun corrections\n\
\tat %d angles, step %d.\n", k, i + 1);
			free(thrunc);
			free(thrcor);
		}
		/* Fall through, don't
		 *    return(0);
		 *
		 * The reason is that get_basic_iongun() has returned to us the
		 * just excess signal in ABs arising from ion gun OXYGEN.
		 * There is additional signal in the ABs arising from ion gun
		 * HYDROGEN.  To get that, go through the whole procedure again,
		 * getting the excess hydrogen ion gun signal for the qABCs.
		 * (This is grotesque from a fast processing point of view, but
		 * simpler in terms of what we already have set up.)  Then, the
		 * excess hydrogen signal in the ABs is derivable from
		 * CEMCeff = qABC / (qABC + lAB).
		 * (There is the assumption that CEM C efficiency is not
		 * dependent on hydrogen energy.)
		 *
		 * In what follows, if (lAB), we need to add the new stuff in
		 * quadrature with rates and uncs so far.
		 */
	}
	dothethree = dothefour = '\0';
	/* Ha ha ha.  swptable is 1..6 since 0 is for bg testing.
	 * Otherwise, locally, ESA is 0..5.
	 */
	for (i = 0; i < HI_ENERGIES; i++) {
		if (swptable[i] == 3)
			dothethree |= (1 << i);
		if (swptable[i] == 4)
			dothefour |= (1 << i);
	}
	for (i = 0; i < HI_ENERGIES; i++) {
		if (swptable[i] == 1 || swptable[i] == 2 ||
		    swptable[i] == 5 || swptable[i] == 6) {
			j = get_basic_iongun(dothethree, i, whichcull, dodespin,
			    CEMCeff, CEMCunc, penb, penbunc, &thrcor, &thrunc,
			    hbtime, HB_QABC /* HB_LAB */, verbosity);
			if (j != 0)
				return(j);
			k = get_basic_iongun(dothefour, i, whichcull, dodespin,
			    CEMCeff, CEMCunc, penb, penbunc, &frcor, &frunc,
			    hbtime, HB_QABC /* HB_LAB */, verbosity);
			if (k != 0) {
				free(thrunc);
				free(thrcor);
				return(k);
			}
			if (verbosity > 3)
				printf("ESA %d identified as OLD %d\n", i+1, swptable[i]);
			_mergeunc(thrcor, thrunc, frcor, frunc);
			free(frunc);
			free(frcor);
			/* NOW look for negatives. Ion gun on its own may NOT go
			 * negative, but if it does, I want to know.
			 */
			k = 0;
			if (hbtype == HB_LAB) {
				for (j = 0; j < HI_AZ_BINS; j++) {
					if (thrcor[j] < 0.) {
						k++;
						thrcor[j] = 0.;
						/* keep thrunc[j] as-is */
					}
					/* We care about excess lABs specifically when CEM
					 * C does not trigger.  The scaling then, under
					 * the good-to-a-percent-or-two approximation that
					 * lABC = qABC for real ENAs like this ion-gun H
					 * that shows up in the qABC, is
					 * 1/effc = (qABC + lAB)/qABC = 1 + lAB/qABC
					 * where we just calculated qABC.
					 */
					thrcor[j] *= (1. / CEMCeff - 1.);
					thrunc[j] *= (1. / CEMCeff - 1.);	/* ??? XXX FIX */
					/* XXX nominally I ought to scale the AB
					 * uncertainty by the uncertainty in this ratio,
					 * but I figure it's probably been effectively
					 * included to this point.
					 */
				}
				_addunc(rates[i], uncs[i], thrcor, thrunc);
			} else {
				for (j = 0; j < HI_AZ_BINS; j++) {
					if (thrcor[j] < 0.) {
						k++;
						rates[i][j] = 0.;
					} else
						rates[i][j] = thrcor[j];
					uncs[i][j] = thrunc[j];
				}
			}
			if (verbosity >= 0 && k > 0)
printf("iongun_populate_all_offsets(): found qABC negative ion gun corrections\n\
\tat %d angles, step %d.\n", k, i + 1);
			free(thrunc);
			free(thrcor);
		}
	}
	return(0);
}
