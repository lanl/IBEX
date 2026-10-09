/*	$Id: spininfo.c,v 1.6 2020/02/20 04:11:23 pjanzen Exp $	*/
/* Spin_info times from the spacecraft can be hinky.  Fix them here.
 * Also, fix the same way as the ISOC does, so we're consistent on when the
 * clock strikes.  NOTE:  AT PRESENT, THE ISOC SCREWS THIS UP.
 */

static const char rcsid[] = "@(#) $Id: spininfo.c,v 1.6 2020/02/20 04:11:23 pjanzen Exp $";

#include <err.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "ibexhi.h"

double last_mode_spin_period = 0.;

/* Return the number of issues found */
/* Exactly as per ISOC:
 * 1) ceu spin pulse 256ms issue due to clock rollover.
 *     *ping* time is:     xxxx xxx1 1111 1111
 *     CEU reads word      xxxx xxx1
 *     clock rollsover to  xxxx xx10 0000 0000
 *     CEU reads word                0000 0000
 *     and telemeters      xxxx xxx1 0000 0000     oops.
 *
 * These should be isolated events.  E.g. from orbit 11:
 * line-36687:SPIN 914821421.688       208 14.412  np - 2
 * line-36688:SPIN 914821436.101       209 14.413  np - 1  lp
 * line-36689:SPIN 914821450.256       210 14.155  np = 0  tp
 * line-36690:SPIN 914821464.923       211 14.667  np + 1  bp
 * line-36691:SPIN 914821479.335       212 14.412  np + 2  fp
 *
 * Can't fix the edge cases.
 */
int
fix_256_issue()
{
	int i, j, n;
	int ms;
	double avper, pers[4];

	n = 0;
	for (i = 2; i < nspin_times - 2; i++) {
		ms = 1000 * (spin_times[i].met - floor(spin_times[i].met));
		if ((ms & 0xFF) == 0) {
			for (j = i - 1; j <= i + 2; j++)
				pers[j - i + 1] = spin_times[j].met - spin_times[j-1].met;
			avper = (pers[0] + pers[3])/2.;
			if ((fabs(avper - pers[1]) >= 0.004) &&
			    (fabs(avper - pers[2]) >= 0.004) &&
			    (fabs(pers[0] - pers[3]) <= 0.003) &&
			    ((avper - pers[1] <= 0.258) && (avper - pers[1] >= 0.254)) &&
			    ((pers[2] - avper <= 0.258) && (pers[2] - avper >= 0.254))) {
				spin_times[i].met += 0.256;
				n++;
			}
		}
	}
	return(n);
}

/* Return the mode of the period of all data between start and end times.
 * To make this quick (linear time), assume the answer must be between 14.1
 * and 14.5 seconds, and that we need bin only by closest millisecond.
 *
 * Return -1 if there's no proper periods to study.
 */
static double
mode_period(uint32_t stm, uint32_t endm)
{
	int bins[400];
	int i, j, k, mx;

	for (i = 0; i < 400; i++)
		bins[i] = 0;
	for (i = 1; i < nspin_times; i++)
		if (spin_times[i].met > stm && spin_times[i].met <= endm) {
			j = (spin_times[i].met - spin_times[i-1].met - 14.1) * 1000.;
			if (j >= 0 && j < 400)
				bins[j]++;
		}
	mx = 0; k = -1;
	for (i = 0; i < 400; i++)
		if (bins[i] > mx) {
			mx = bins[i];
			k = i;
		}
	if (k >= 0)
		return(14.1 + k / 1000.);
	return(-1.);
}

/* The ISOC noticed long ago that there can be exact 1-second jumps, if the
 * "pulse per second" mistimes.  It automatically "fixes" those, but if the
 * algorithm screws up, which happens regularly, it shifts all the times
 * off by some integer number of seconds.
 *
 * We don't necessarily want to do this ALL the time, because it means DEs
 * and hbs don't line up, and the DE packet can be "created" a second or
 * two before the DEs that it contains, but it's forced on us because the
 * ISOC does this for its osbdba file, so you need it to despin off an
 * osbd2a file.  Dammit.
 *
 * So do EXACTLY what the ISOC does and report how many spin times got
 * shifted.
 *
 * This sucks.
 *
 * It's harder for me than for the ISOC, because the ISOC handling goes arc
 * by arc, and my programs often go orbit by orbit.  So I need to break
 * things down by arc present, which means you can't do this while reading
 * in pkt_pl data unless you've already read inertial_pointing to figure
 * out when the arcs are.  Sigh.  You need this simply to end up with the
 * same mode value for the period that the ISOC uses.
 *
 * For now just assume that what we've loaded is fine.
 */
int
fix_PPS_issue_as_per_ISOC(uint32_t stmet, uint32_t endmet)
{
	int i, n;
	double tmp, timeshift;

	n = 0;
	last_mode_spin_period = mode_period(stmet, endmet);
	for (i = 0; i < nspin_times - 1; i++) {
		if (spin_times[i+1].met <= endmet && spin_times[i].met >= stmet) {
			tmp = spin_times[i+1].met - spin_times[i].met -
			    last_mode_spin_period;
			if (fabs(tmp) > 0.005) {
				n++;
				timeshift = 0.;
				if (fabs(tmp - 1.) < 0.005)
					timeshift = -1.;
				else if (fabs(tmp - 2.) < 0.005)
					timeshift = -2.;
				else if (fabs(tmp + 1.) < 0.005)
					timeshift = 1.;
				else if (fabs(tmp + 2.) < 0.005)
					timeshift = 2.;
	/* Include this next bit if the ISOC ever pulls its head out of its ass */
#if 0
				else if (fabs(tmp - last_mode_spin_period + 1.) < 0.005)
					timeshift = 1.;
				else if (fabs(tmp - last_mode_spin_period - 1.) < 0.005)
					timeshift = -1.;
#endif
				else
					n--;
				spin_times[i+1].met += timeshift;
			}
		}
	}
	return(n);
}

/* If we have multiple arcs loaded and initialized inertial_pointing, we'll
 * always want to do the same mangling.  Put the framework here.  It's also
 * in the printspininfo program.
 *
 * Return the number of mangled times.
 */
int
fix_PPS_all_arcs()
{
	int i, j, k, ch;
	uint32_t mmet;
	int npps;

	/* only do this once; this is reset to zero in process_tlm(). */
	if (nst_pps > 0)
		return(nst_pps);
	j = k = 0;
	npps = 0;
	while (j < nspin_times) {
		i = get_orbit_at_met((uint32_t) spin_times[j].met, &ch);
		j++;
		if (get_burn_MET_after_orbit(i, ch, &mmet) == 0) {
			while (j < nspin_times && spin_times[j].met < mmet)
				j++;
		} else {
			/* probably no inertial_pointing loaded; just do the best we
			 * can, I guess.  A verbosity for an error message would be
			 * grand.
			 */
			warnx("fix_PPS_all_arcs():  inertial_pointing failed");
			return(nst_pps = fix_PPS_issue_as_per_ISOC(0, 0xFFFFFFFF));
		}
		j--;
		npps += fix_PPS_issue_as_per_ISOC((uint32_t) spin_times[k].met - 1,
		    mmet);
		j++;
		k = j;
	}
	nst_pps = npps;
	return(npps);
}

/* Under the assumption that we've done this once already, and that we have
 * only one arc present, and that we didn't reload stuff, return our latest
 * mode for the spin period.  If we haven't done it (it's slow), do it now.
 * It should have been done by assemble_de().
 *
 * This can be used as a reasonable guess for blown spin periods, if
 * there's nothing better handy.
 */
double
get_mode_period()
{
	if (last_mode_spin_period < 1.)
		last_mode_spin_period = mode_period(0, 0xFFFFFFFF);
	return(last_mode_spin_period);
}


/* Oh dear, things only get worse.  osbdba files fill in gaps in the spins.
 * We should too, I suppose.  Return how many gaps we filled; fill in only
 * ones of 10 or fewer spins (make it adjustable?).
 *
 * XXX at present this mangles both pktmet and spin counts.
 * XXX relies on get_mode_period() so will fail somewhat on multi-arc
 * orbits.
 */
int
fix_gaps_in_spins()
{
	int i, j, n;
	double md, tmp, tmp2;
	double fillper;
	int filln;

	n = 0;
	md = get_mode_period();
	for (i = 1; i < nspin_times; i++) {
		tmp = spin_times[i].met - spin_times[i-1].met;
		tmp2 = tmp / md;
		if (tmp2 > 1.8 && tmp2 < 10.3 &&
		    fabs(tmp2 - round(tmp2)) < 0.1 /* ??? */) {
			fillper = tmp / round(tmp2);
			filln = (int)(round(tmp2) + 0.1);
			if (nspin_times + filln -1 > nmaxspin_times) {
				spind *stmp;
				stmp = realloc(spin_times,
				    sizeof(spind) * (nmaxspin_times + 2000));
				nmaxspin_times += 2000;
				if (!stmp)
					errx(100, "FATAL: fix_gaps_in_spins out of mem");
				spin_times = stmp;
			}
			nspin_times += filln - 1;
			for (j = nspin_times; j >= i + filln - 1; j--)
				memcpy(spin_times + j, spin_times + j - filln + 1,
				    sizeof(spind));
			for (j = i; j < i + filln - 1; j++) {
				spin_times[j].met = spin_times[i-1].met +
				    (j - i + 1) * fillper;
				spin_times[j].pktmet = 0;
				spin_times[j].spin = spin_times[i-1].spin + j - i + 1;
			}
			i += filln - 1;
			n += filln - 1;
		}
	}
	return(n);
}
