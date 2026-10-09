/*	$Id: realspice.c,v 1.17 2020/01/03 01:06:28 pjanzen Exp $	*/
/* A variety of functions for including real spice data rather than files
 * created off the "where's my satellite" part of the website.  First
 * feature of interest is blocking out FOV including the moon or Earth;
 * I may want to dabble in magnetospheric reconstruction eventually.
 *
 * Because spice for IBEX is set up a bit oddly (two frames per orbit,
 * nothing saying how the thing is spinning over time) I will still use
 * inertial_pointing to get pointing, and will use spice only to look
 * up positions.
 */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <cspice/SpiceUsr.h>
#include <cspice/SpiceZfc.h>	/* For xxx_set_the_speed_of_light() */

#include "ibexhi.h"

static const char rcsid[] = "@(#) $Id: realspice.c,v 1.17 2020/01/03 01:06:28 pjanzen Exp $";

/* J2000 starts January 1, 2000, 11:58:55.816 UTC */
#define EPHEM_MET_OFS (630763116.8)
#define JUP_RAD (71492.)

/* Until you've initialized, any spice command will abort the program.
 * Keep a quick check on that.
 */
static int spice_is_in = 0;

/* Convenience function to convert from eV for a proton to km/s */
double
eV2kms(double x)
{
	return(sqrt(2. * x * 1.6021773e-19 / 1.6726231e-27) / 1000.);
}

double
kms2eV(double x)
{
	return(0.5e6 * 1.6726231e-27 / 1.6021773e-19 * x * x);
}


/* Return zero on success, which may be less than total success, depending
 * on how much the meta kernel contains.  But I'd like to block out all
 * possible funkiness with various kernels into the contents of ONE loaded
 * metakernel.
 */
int
init_spice(const char *metaname, int verbosity)
{
	char frob[2048];
	int i;
	SpiceInt count, handle;
#define  FILLEN   (128)
#define  TYPLEN   (32)
#define  SRCLEN   (128)
	SpiceChar file[FILLEN];
	SpiceChar filtyp[TYPLEN];
	SpiceChar source[SRCLEN];
	SpiceBoolean found;

	spice_is_in = 0;
	/* Print errors but do not abort.  You need to explicitly reset
	 * the error flag after the first error to have anything else
	 * in spice work.
	 */
	erract_c("SET", 1+strlen("RETURN"), "RETURN");
	furnsh_c(metaname);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("furnsh_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	if (verbosity > 1) {
		ktotal_c("all", &count);
		printf("SPKs loaded: %d\n", (int)count);
		if (verbosity > 2) {
			for (i = 0;  i < count;  i++) {
				kdata_c(i, "all", FILLEN, TYPLEN, SRCLEN, file, filtyp,
				    source, &handle,  &found);
			printf ("%s :: %s :: %s\n", file, filtyp, source);
			}
		}
	}
	spice_is_in = 1;
	return(0);
}


/* If we're missing some crap the first time we try to initialize spice, it
 * sets an error and blocks further business.
 * This routine resets the error flag and tries again; the idea is you
 * don't have to quit and restart xhihb if you borked on the first spice
 * try.
 */
int
reinit_spice(const char *fname, int verbosity)
{
	int i;
	SpiceInt  count, handle;
	SpiceChar file[FILLEN];
	SpiceChar filtyp[TYPLEN];
	SpiceChar source[SRCLEN];
	SpiceBoolean found;

	reset_c();
	/* unload if there's anything in now. */
	if (spice_is_in) {
		ktotal_c("all", &count);
		if (verbosity > 1 && count > 0)
			printf("unloading %ld kernels...\n", count);
		for (i = count-1;  i >= 0;  i--) {
			kdata_c(i, "all", FILLEN, TYPLEN, SRCLEN, file, filtyp,
			    source, &handle,  &found);
			unload_c(file);
			/* just in case this failed... */
			reset_c();
		}
	}
	return(init_spice(fname, verbosity));
}

/* Stupid wrapper just so I don't have to include spice headers elsewhere */
void
reset_spice()
{
	reset_c();
}


/* Returns 0 on success.  asc is +1 if IBEX is ascending and -1 if IBEX is
 * descending.  Coordinates are GSE.  Units are km.
 */
int
getIBEXlocGSE(double met, double *x, double *y, double *z, int *asc,
    int verbosity)
{
	char frob[2048];
	SpiceDouble ephemtim, lighttime, pt[6];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	/* Want velocity too, to tell ascending/descending
	 * spkpos_c("IBEX", ephemtim, "GSE", "NONE", "EARTH", pt, &lighttime);
	 */
	spkezr_c("IBEX", ephemtim, "GSE", "NONE", "EARTH", pt, &lighttime);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("spkezr_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	*x = pt[0];
	*y = pt[1];
	*z = pt[2];
	/* Ascending if location dot velocity > 0 */
	if (pt[0] * pt[3] + pt[1] * pt[4] + pt[2] * pt[5] >= 0)
		*asc = 1;
	else
		*asc = -1;
	return(0);
}


/* Returns 0 on success.  For uniformity, numbers are J2000 if coordsys is
 * NULL.  If speed is positive, take particle propagation time at that
 * velocity (km/s) -- e.g., if you're looking for stuff from Jupiter.  If
 * speed is <= zero, don't do any aberration correction.  Distances are of
 * course in km.
 *
 * XXX Note that this requires my hacked version of the spice library,
 * where I can play with the speed of light!  Then I can use all the extant
 * cool algorithms for aberration.
 */
int
getIBEXtoOBJ_coord(double met, double *x, double *y, double *z, double speed,
    const char *object, int verbosity, const char *coordsys)
{
	char frob[2048];
	SpiceDouble ephemtim, lighttime, pt[3], tmp;

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	if (speed <= 0.)
		spkpos_c(object, ephemtim, coordsys?coordsys:"J2000",
		    "NONE", "IBEX", pt, &lighttime);
	else {
		if (verbosity > 3)
			printf("Changing speed for object %s\n", object);
		/* Don't leave a mucked speed of light out there. */
		tmp = clight_c();
		xxx_set_the_speed_of_light(speed);
		/* Light time correction inwards, plus aberration due to relative
		 * velocity.  I think that's right.  It's only Jupiter, anyhow.
		 */
		spkpos_c(object, ephemtim, coordsys?coordsys:"J2000",
		    "LT+S", "IBEX", pt, &lighttime);
		xxx_set_the_speed_of_light(tmp);
	}
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("spkpos_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	*x = pt[0];
	*y = pt[1];
	*z = pt[2];
	return(0);
}

/* Original invocation is J2000 */
int
getIBEXtoOBJ(double met, double *x, double *y, double *z, double speed,
    const char *object, int verbosity)
{
	return(getIBEXtoOBJ_coord(met, x, y, z, speed, object, verbosity,
	    "J2000"));
}


/* 0 on success.  Coords in R_e.  This is for plotting purposes. */
int
getIBEXmoonGSE(double met, double ibexpos[3], double lunarpos[3], int verbosity)
{
	char frob[2048];
	SpiceDouble ephemtim, lighttime, pt[3];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	spkpos_c("IBEX", ephemtim, "GSE", "NONE", "EARTH", pt, &lighttime);
	ibexpos[0] = pt[0] / EARTH_RAD;
	ibexpos[1] = pt[1] / EARTH_RAD;
	ibexpos[2] = pt[2] / EARTH_RAD;
	spkpos_c("MOON", ephemtim, "GSE", "NONE", "EARTH", pt, &lighttime);
	lunarpos[0] = pt[0] / EARTH_RAD;
	lunarpos[1] = pt[1] / EARTH_RAD;
	lunarpos[2] = pt[2] / EARTH_RAD;
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("spkpos_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	return(0);
}

/* 0 on success.  Return a separate flag (infov nonzero in object in FOV
 * somewhere) so caller doesn't have to go through the 60-element array.
 * The idea is that this will be used to populate a cull.  anglebinz[i] is
 * zero unless the object is in the FOV there.
 * speed has the same meaning as in getIBEXtoOBJ().
 * objectradius is in km and is needed to determine edges.
 * angfov is the number of degrees full-width that you think IBEX can see.
 * pointing directions are to be looked up from inertial_pointing (although
 * it's buried in spice probably somewhere too) and sent along.  I want
 * the 3-vector here in J2000.
 *
 * Note however that the axis to which we want to start the spin is the
 * ECLIPJ2000 z axis, not the J2000 z axis.
 */
int
IBEX_OBJ_in_FOV(double met, double speed, const char *object,
    double objectradius, double angfov, double ibpoint[3],
    int *infov, int anglebinz[HI_AZ_BINS], int verbosity)
{
	double ib2obj[3];	/* km in J2000 */
	double t1[3], t2[3];
	double d, db, tmp;
	int i;

	if (!spice_is_in)
		return(-1);
	for (i = 0; i < HI_AZ_BINS; i++)
		anglebinz[i] = 0;
	*infov = 0;
	if (getIBEXtoOBJ(met, ib2obj, ib2obj + 1, ib2obj + 2, speed, object,
	    verbosity))
		return(1);
	t1[0] = ib2obj[0];
	t1[1] = ib2obj[1];
	t1[2] = ib2obj[2];
	t2[0] = ibpoint[0];
	t2[1] = ibpoint[1];
	t2[2] = ibpoint[2];
	renorm(t1);
	renorm(t2);
	/* cosine of angle of centre out of IBEX spin plane axis.  d is zero
	 * if object is right IN the spin plane.
	 */
	d = dotp(t1, t2);
	tmp = sqrt(ib2obj[0] * ib2obj[0] + ib2obj[1] * ib2obj[1] +
	    ib2obj[2] * ib2obj[2]);
	db = atan(objectradius / tmp);
	/* Make two separate checks in case centre is in FOV but edge is not */
	if (fabs(d) > sin(d2r(angfov / 2.))) {
		/* If that's too far out, try for the nearest edge, which is
		 * closer to the spin plane by one radius, or an angle whose
		 * tangent is a radius divided by the distance the thing is away.
		 */
		if (fabs(d) > sin(d2r(angfov / 2.) + db)) {
			/* We're not in FOV. */
			return(0);
		}
	}
	*infov = 1;
	/* Now we need to figure out the range of spin bins are affected. For
	 * brutality just figure it's one radius to either side of the centre,
	 * all the time.  It may be a bit too much, but oh well.
	 */
	db = r2d(db);
	db += angfov / 2.;
	tmp = getspinbinj2000(t2, t1);
	for (i = tmp - db/(360./HI_AZ_BINS);
	    i <= tmp + db/(360./HI_AZ_BINS) + 0.99; i++)
		anglebinz[(i + HI_AZ_BINS) % HI_AZ_BINS] = 1;
	return(0);
}


/* Return 0 on success.  Assuming that the ibexhi.h structures are
 * populated, fill up one cull as specified with the requested foreground
 * object of stated size emitting objects at speed as needed by
 * IBEX_OBJ_in_FOV().
 * init_inertialpointing() needs to have been called first.
 */
int
populate_cull_object(const char *objname, double objsize, int culltofill,
    double speed)
{
	int i, j, k, foo;
	double ra, dec;
	double ibpt[3];
	int binz[HI_AZ_BINS];
/* XXX should get these numbers from the response function Hi_E_central(),
 * but for now I don't want to force Hi_cal_init().  I really should.
 */
	double c_es[HI_ENERGIES] = {450., 710., 1110., 1740., 2730., 4290.};

	if (!spice_is_in)
		return(-1);
	if (culltofill >= 0 && culltofill < 8) {
		/* Check for the fancy "Jupiter" style setup. */
		if (fabs(speed + M_PI) < 1e-10) {
			for (i = 0; i < nallt; i++)
				for (j = 0; j < HI_AZ_BINS; j++)
					mculls[culltofill][i * HI_AZ_BINS + j] = 0;
			for (i = 0; i < nallt; i++) {
				/* Put this here in case of repoints... it returns J2000. */
				j = get_orbit_at_met(alltimes[i], &k);
				if (j > 0 && get_ibex_dir(j, k, &ra, &dec) == 0) {
					rd2vec(ibpt, ra, dec);
					for (k = 0; k < HI_ENERGIES; k++) {
						if (IBEX_OBJ_in_FOV((double)alltimes[i],
						    eV2kms(c_es[k]), objname, objsize,
						    16.0, ibpt, &foo, binz, 0))
							return(1);
						if (foo) {
							for (j = 0; j < HI_AZ_BINS; j++)
								mculls[culltofill][i * HI_AZ_BINS + j] |=
								    (binz[j] << k);
						}
					}
				}
			}
		} else {
			for (i = 0; i < nallt; i++) {
				/* Put this here in case of repoints... it returns J2000. */
				j = get_orbit_at_met(alltimes[i], &k);
				if (j > 0 && get_ibex_dir(j, k, &ra, &dec) == 0) {
					rd2vec(ibpt, ra, dec);
					if (IBEX_OBJ_in_FOV((double)alltimes[i], speed,
					    objname, objsize, 16.0, ibpt, &foo, binz, 0))
						return(1);
					if (foo) {
						for (j = 0; j < HI_AZ_BINS; j++)
							mculls[culltofill][i * HI_AZ_BINS + j] =
							    binz[j] * 0x3F;
					} else {
						for (j = 0; j < HI_AZ_BINS; j++)
							mculls[culltofill][i * HI_AZ_BINS + j] = 0;
					}
				}
			}
		}
	}
	return(0);
}


/* Return 0 on success.  Assuming that the ibexhi.h structures are
 * populated, fill up culls as indicated with the specified foreground
 * objects.  init_inertialpointing() needs to have been called first.
 */
int
populate_culls_fg_objects(int earthcull, int mooncull, int jupitercull)
{
	int i, j, k, foo;
	double ra, dec;
	double ibpt[3];
	int binz[HI_AZ_BINS];
/* XXX should get these numbers from the response function Hi_E_central(),
 * but for now I don't want to force Hi_cal_init().  I really should.
 */
	double c_es[HI_ENERGIES] = {450., 710., 1110., 1740., 2730., 4290.};

	if (!spice_is_in)
		return(-1);
#if 0
	if (earthcull >= 0 && earthcull < 8) {
		i = populate_cull_object("EARTH", 3.5 * EARTH_RAD, earthcull, -1.0);
		if (i)
			return(i);
	}
	if (mooncull >= 0 && mooncull < 8) {
		i = populate_cull_object("MOON", MOON_RAD, mooncull, -1.0);
		if (i)
			return(i);
	}
	if (jupitercull >= 0 && jupitercull < 8) {
		i = populate_cull_object( "JUPITER", 75. * JUP_RAD, jupitercull,
		    -M_PI);
		if (i)
			return(i);
	}
	return(0);
#endif
	if (earthcull >= 0 && earthcull < 8) {
		for (i = 0; i < nallt; i++) {
			/* Put this here in case of repoints... it returns J2000. */
			j = get_orbit_at_met(alltimes[i], &k);
			if (j > 0 && get_ibex_dir(j, k, &ra, &dec) == 0) {
				rd2vec(ibpt, ra, dec);
				if (IBEX_OBJ_in_FOV((double)alltimes[i], -1., "EARTH",
				    3.5 * EARTH_RAD, 16.0, ibpt, &foo, binz, 0))
					return(1);
				if (foo) {
					for (j = 0; j < HI_AZ_BINS; j++)
						mculls[earthcull][i * HI_AZ_BINS + j] =
						    binz[j] * 0x3F;
				} else {
					for (j = 0; j < HI_AZ_BINS; j++)
						mculls[earthcull][i * HI_AZ_BINS + j] = 0;
				}
			}
		}
	}
	/* This is a nearly redundant duplicate of above... */
	if (mooncull >= 0 && mooncull < 8) {
		for (i = 0; i < nallt; i++) {
			j = get_orbit_at_met(alltimes[i], &k);
			if (j > 0 && get_ibex_dir(j, k, &ra, &dec) == 0) {
				rd2vec(ibpt, ra, dec);
				if (IBEX_OBJ_in_FOV((double)alltimes[i], -1., "MOON",
				    MOON_RAD, 16.0, ibpt, &foo, binz, 0)) {
					printf(" -- alltimes at %d (%u)\n", i, alltimes[0]);
					return(1);
				}
				if (foo) {
					for (j = 0; j < HI_AZ_BINS; j++)
						mculls[mooncull][i * HI_AZ_BINS + j] =
						    binz[j] * 0x3F;
				} else {
					for (j = 0; j < HI_AZ_BINS; j++)
						mculls[mooncull][i * HI_AZ_BINS + j] = 0;
				}
			}
		}
	}
	/* Jupiter isn't quite as redundant */
	if (jupitercull >= 0 && jupitercull < 8) {
		for (i = 0; i < nallt; i++)
			for (j = 0; j < HI_AZ_BINS; j++)
				mculls[jupitercull][i * HI_AZ_BINS + j] = 0;
		for (i = 0; i < nallt; i++) {
			/* Put this here in case of repoints... it returns J2000. */
			j = get_orbit_at_met(alltimes[i], &k);
			if (j > 0 && get_ibex_dir(j, k, &ra, &dec) == 0) {
				rd2vec(ibpt, ra, dec);
				for (k = 0; k < HI_ENERGIES; k++) {
					if (IBEX_OBJ_in_FOV((double)alltimes[i],
					    eV2kms(c_es[k]), "JUPITER", 75. * JUP_RAD,
					    16.0, ibpt, &foo, binz, 0))
						return(1);
					if (foo) {
						for (j = 0; j < HI_AZ_BINS; j++)
							mculls[jupitercull][i * HI_AZ_BINS + j] |=
							    (binz[j] << k);
					}
				}
			}
		}
	}
	return(0);
}


/* Return 0 on success.  All I want is the pointing direction in the GSE xy
 * plane (i.e., perpendicular to the look directions).  Returned is an
 * angle in RADIANS.  Actually, I may also want absolute pointing too.
 */
int
getGSEpointingdir(double met, double *angxy, double *angxz, double *angtot,
    int verbosity)
{
	double ra, dec;
	char frob[2048];
	int j, k;
	SpiceDouble rotat[3][3], ephemtim;
	double ibpt[3], ibnewpt[3];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	j = get_orbit_at_met((uint32_t)met, &k);
	if (get_ibex_dir(j, k, &ra, &dec)) {
		if (verbosity > 0)
			printf("No pointing information at time %u.\n", (uint32_t)met);
		return(2);
	}
	rd2vec(ibpt, ra, dec);
	pxform_c("J2000", "GSE", ephemtim, rotat);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("pxform_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	mxv_c(rotat, ibpt, ibnewpt);	/* will not throw error */
	*angxy = atan2(ibnewpt[1], ibnewpt[0]);
	*angxz = atan2(ibnewpt[2], ibnewpt[0]);
	*angtot = acos(ibnewpt[0]);
	return(0);
}


/* It's latitude and longitude, meaning dec first and then RA */
int
conv_ECLIPJ2000_GSE(double met, double *lat, double *lgt, int verbosity)
{
	char frob[2048];
	SpiceDouble rotat[3][3], ephemtim;
	double ibpt[3], ibnewpt[3];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	rd2vec(ibpt, *lgt, *lat);
	pxform_c("ECLIPJ2000", "GSE", ephemtim, rotat);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("pxform_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	mxv_c(rotat, ibpt, ibnewpt);	/* will not throw error */
	vec2latlong(ibnewpt, lat, lgt);
	return(0);
}


/* And kind of the reverse, for a vector. */
int
conv_GSE_ECLIPJ2000(double met, double vecc[3], int verbosity)
{
	char frob[2048];
	SpiceDouble rotat[3][3], ephemtim;
	double ibnewpt[3];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	pxform_c("GSE", "ECLIPJ2000", ephemtim, rotat);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("pxform_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	mxv_c(rotat, vecc, ibnewpt);	/* will not throw error */
	return(0);
}


/* Even more general. */
int
conv_coord_sys(double vecc[3], const char *cfrom, const char *cto,
    double met, int verbosity)
{
	SpiceDouble rotat[3][3], ephemtim;
	double newv[3];
	char frob[2048];

	if (!spice_is_in)
		return(-1);
	ephemtim = met - EPHEM_MET_OFS;
	pxform_c(cfrom, cto, ephemtim, rotat);
	if (failed_c()) {
		if (verbosity > 0) {
			getmsg_c("LONG", 2048, frob);
			printf("pxform_c : %s (", frob);
			getmsg_c("SHORT", 2048, frob);
			printf("%s)\n", frob);
		}
		return(1);
	}
	/* (Note I could just put into vecc according to the documentation) */
	mxv_c(rotat, vecc, newv);	/* will not throw error */
	vecc[0] = newv[0];
	vecc[1] = newv[1];
	vecc[2] = newv[2];
	return(0);
}
