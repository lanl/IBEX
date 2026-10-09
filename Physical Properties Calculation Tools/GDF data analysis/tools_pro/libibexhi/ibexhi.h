/*	$Id: ibexhi.h,v 1.140 2020/02/25 05:43:14 pjanzen Exp $	*/
/* This is a library of functions useful in various places for a variety of
 * programs relevant to IBEX-Hi.  There are also some global variables and
 * some general defines available.
 */
#ifndef IBEXHI_LIBH
#define IBEXHI_LIBH

#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <limits.h>

/* MET is nominally GPS epoch == 01/06/80 00:00:00 GMT/UTC */
/* Use time difference with TAI to be close enough */
#define EPOCHDIFF (315964819)

#define EARTH_RAD (6378.1370)
#define MOON_RAD (0.2725076 * EARTH_RAD)

/* flags in timelog_c */
#define TLC_HIHB  (0)
#define TLC_BM    (1)
#define TLC_LOH   (2)
#define TLC_HIDE  (3)

/* Ordering of hbs */
#define HB_QABC (0)
#define HB_LABC (1)
#define HB_QAB  (2)
#define HB_LAB  (3)
#define HB_QAC  (4)
#define HB_LAC  (5)
#define HB_QBC  (6)
#define HB_LBC  (7)
#define HB_LA   (8)
#define HB_LB   (9)
#define HB_LC   (10)
#define HB_BM   (11)
#define HB_LOH  (12)
#define HB_LOO  (13)
#define HB_TOF0 (14)
#define HB_TOF1 (15)
#define HB_TOF2 (16)
#define HB_TOF3 (17)

/* Default assumption of number of seconds per hb */
#define APPROX_HBTIME (690.5)
#define HB_TIME (690.5)
/* XXX should be adjustable when the stuff is read in. */

/* Size everything to Lo since it has the most energies/steps */
#define LO_ENERGIES (8)
#define HI_ENERGIES (6)
#define HI_BG_SWEEPS (4)
#define HI_AZ_BINS  (60)
#define SS_AZ_BINS  (720)
/* Also reset in externs.c ! */
#define BIN_TYPES (18)

/* Possible CEM voltage settings */
#define CEM_OTHER (0)
#define CEM_1700 (1)
#define CEM_1780 (2)
/* .. to be filled in as matters progress */
#define CEM_CHANGING (-1)
/* if we can't interpolate properly */
#define CEM_NODATA (-100)

/* Internal clock tick of IBEX direct events, from metaevent.h */
#define ME_TIME_SEC_PER_TICK       (0.004200)

/* XXX Yow!  In readhb.c we don't set up this much space, just HI_ENERGIES
 * worth.  We have to be careful then how we try to access this!
 */
typedef int garray[LO_ENERGIES][HI_AZ_BINS];

typedef struct {
	char *name;
	int flag;
	int nmax;
	int n;
	uint32_t *met;
	int *spincount;
	garray **data;
} timelog_c;

typedef struct sepper *sepptr;
typedef struct sepper {
	uint32_t startmet, peakmet, endmet;
	double peakrate;
	sepptr nextsep;
} SEPlist;

typedef struct {
	int spin;
	double met;
	uint32_t pktmet;
} spind;
extern spind *spin_times;
extern int nspin_times;
extern int nmaxspin_times;
extern int nst_256, nst_pps;

typedef struct {
	uint32_t met;
	uint8_t  star_adj;
	uint8_t  spincount;
	uint8_t  pmt_gain;
	uint16_t sky;
	uint8_t *brightness;
} starsensord;
extern starsensord **ss_data;
extern int nss_times;
extern int nmaxss_times;

typedef struct {
	uint32_t met;
	uint32_t errmet;
	uint8_t errcode;
	uint8_t params[4];
} errlogd;
extern errlogd **err_log;
extern int nerr_log;
extern int nmaxerr_log;

/* diags:  0:  first time
 *         1:  last time
 *         2:  lowest area in mem
 *         3:  highest area in mem
 */
typedef struct {
	uint32_t met;
	uint32_t sram_single, srams[4];
	uint32_t sram_multi, sramm[4];
	uint32_t eeprom_single, eeps[4];
	uint32_t eeprom_multi, eepm[4];
	uint32_t sdwr_single, sdwr[4], sdwr_multi;
	uint32_t sdpb_single, sdpb[4], sdpb_multi;
} edacsumd;
extern edacsumd **edac_sum;
extern int nedacsum;
extern int nmaxedacsum;

typedef struct {
	uint32_t met;
	uint32_t eventmet[128];
	uint32_t eventaddr[128];
	uint8_t  eventtype[128];	/* actually just 4 bits worth */
} edaclistd;
extern edaclistd **edac_list;
extern int nedaclist;
extern int nmaxedaclist;

typedef struct {
	uint32_t met;
	uint16_t des[16];
} hided;
extern hided **hidetotlist;
extern int nhidetotlist;
extern int nmaxhidetotlist;

/* If we are reading in histogram bins, we expect a bunch of them
 * named as follows.  They must be initialized (hbunhb: hb_massinit()).
 */
extern timelog_c hbs[BIN_TYPES];
extern timelog_c tce;
/* Frequently we want to bin them all into equivalent times (with some
 * timing slop because it can take a few seconds to write out the packets,
 * and I base everything on time of packet creation).  This is where that
 * goes.  hbunhb:hb_makealltimesnculls().
 * The culling gets set up here too because this is the cadence on which it
 * must go.
 */
extern uint32_t *alltimes;
extern int nallt;
extern int HBtimeSlop;
extern char *mculls[8];
extern int defaultmcull;

/* Good times on a direct event cadence */
typedef struct degtll *degtllp;
typedef struct degtll {
	int whichcull;
	double met1, met2;	/* range over which this good time interval is valid */
	char cul[HI_AZ_BINS]; /* bitmap of good angle bins */
	degtllp next;
} degt;

/* hbunhb.c
 * Setup and destruction of orbital data.
 * hb_massinit() is at the start.  To free an orbit's worth of crap,
 * use hb_massfree().
 * hb_makealltimesnculls() is the next setup stage after reading stuff in
 * and before reading in culls.
 *
 * To resync timing after despinning, call remake_alltimesnculls(hbtype)
 * with the hbtype to sync on.  hb_makealltimesnculls() needs to have been
 * called, but not hb_freealltimesnculls().
 */
void hb_massinit(void);
void hb_massfree(void);
void hb_makealltimesnculls(void);
void hb_freealltimesnculls(void);
void remake_alltimesnculls(int);

/* processcull.c
 * read_goodtimes() reads in a file and returns 0 on success, -1 on file not
 * openable, or the line number of the problem.  If it returns -1 the
 * current cull settings remain untouched.  The int argument clears the
 * working cull (if nonzero); if it's zero, the new cull gets ORed on top
 * of what's there.  Argument 3 is verbosity (stuff gets printed if > 0).
 *    Note:  the good times are only read for the extant hbs[], so every
 *    time you read a new pkt_pl, you need to redo the good times.
 * Fourth argument, if not NULL, returns the orbit number.
 * Last argument is which hbs's data to sync with (usually HB_QABC unless
 * syncing to despun data put elsewhere).
 *
 * write_goodtimes(char *fname, int orbit, int multi, int syncwith)
 * dumps to an old-style good times file, once you tell it what orbit this
 * is.  Returns zero on success.
 *   If multi is zero, it's old-style.  Otherwise, it's part of a new-style
 * as accessed by write_all_culls(), which actually writes all of mculls[]
 * and not just mculls[defaultmcull].
 * The writing of these files still needs work.
 *
 * Note that both of these assume tagging based on hb packet creation time.
 * The ISOC does from->to based on closest 24 spins, so this is STILL not
 * quite compatible across.
 *
 * cull_merge() merges 2 into 1 where param 3 is 0==OR, 1==AND, 2==XOR,
 * -1=ANDNOT
 */
void print_culls_populated(void);
int  read_goodtimes(char *, int, int, int *, int);
int  write_goodtimes(char *, int, int, int);
int  write_all_culls(char *, int, int, int);
void cull_merge(int, int, int);
/* First arg is which cull, second is verbosity */
void trim_cull_to_slow_cadence(int, int);
/* Modify an existing cull by dropping intervals for which, at whatever
 * cadence the hbs are collected, the average per-spin-bin-in-the-good-times
 * rate exceeds the threshold/60-ang-bins (thus allowing stuff like the
 * Earth to be removed first).
 * Args are whichcull, whichhb, threshold, and a flag:
 *   flag is 0 to filter ESA by ESA, -1 if we're using the BM, and a
 * positive number whose bits correspond to ESAs (1 << esa) to use in
 * sum (the threshold then corresponds to average per-spin-bin-in-the-
 * good-times summed over all such ESAs) for all energies in the current
 * cull.
 * Final argument is a threshold (in seconds) to extend by on either side;
 * note it's symmetric on packet collection time, and that as this function
 * looks only at data inside an existing cull, margins are not added to
 * data that would trigger the threshold but is not currently in the good
 * times.  Use nonzero margins with great caution!
 */
int cull_by_threshold(int, int, long, int, int);

/* isoofs.c
 * Handle multiple-cull differences, in particular determine offset
 * angle by angle assuming one cull includes periods of time-varying but
 * isotropic additional noise.
 *
 * isincull(culln, met, esa, angbin) is nonzero if mculls[culln] is nonzero
 *   for the given MET, ESA, and angbin.
 * Use safe_isincull() if despins have gone on and it's not certain that
 * the privided MET is within HBtimeSlop of entries in alltimes[].
 * iso_get_offs(esa, hbtype, goodcull, loosecull, verbosity, *ofs, *ofsunc,
 *      ISOCstyle, *rate, *rateunc) is the entry point for a single ESA.
 *   For the the two culls specified, it returns the offset and offset
 *   uncertainty in the HI_AZ_BIN-element arrays pointed at by ofs and
 *   ofsunc.  If *rate isn't NULL, overall rates and rate uncertainties
 *   come back too.  If ISOCstyle is nonzero, the returned offsets, rates,
 *   and uncertainties are for the overlap of good and loose culls, as per
 *   ISOC format.
 *      Quantities are returned in /hb.  0 is returned on success.
 * iso_get_all_ofs(hbtype, goodcull, loosecull, verbosity, ofs[6][60],
 *      ofsunc[6][60], ISOCstyle, rates[6][60], ratesunc[6][60]) is as
 *   above but for all 6 ESAs.
 * iso_dump_ofs_file(fname, ftype, hbtype, goodcull, loosecull, verbosity,
 *      orbit, crbg, crbgunc, nonneg) dumps a file in one of the following
 *      forms:
 *   ftype =- -1:  diagnostic in ISOC style
 *   ftype == 0 :  ISOC bg file in Hz of rates and sigmas for the offset.
 *                 Note that we need the cosmic ray background to do this.
 * iso_dump_rate_file(fname, ftype, hbtype, goodcull, loosecull, verbosity,
 *      nonneg) is like the above for the following ftypes:
 *   ftype == 1 :  xhihb /f style (in /hb).
 *   ftype == 2 :  xhihb /fo style (in /hb).
 * iso_dump_rate_bgsub_file(fname, hbtype, goodcull, loosecull, verbosity,
 *     bgrate(Hz), bgrateunc(Hz), nonneg) dumps like the first 12 columns of
 *     xhihb /f, but in Hz.  You need to supply a penetrating bg rate to
 *     subtract.
 *
 * nonneg, the final parameter in all iso_dump and iso_get routines,
 * affects how negative offsets get handled.  If the parameter is zero,
 * nothing special is done; if it's nonzero, the offset of the loose cull
 * from the good cull is restricted and never allowed to be negative
 * for any angle range.  If the nonneg parameter is 1, iso_get nonnegging
 * affects only returned RATES (not offsets) since the returned offsets
 * can be processed by the caller as required.  If the nonneg parameter is
 * 2, the offsets are pruned as well to save the caller the effort, which
 * can be nontrivial once ion gun is factored in along with it in ISOCstyle.
 */
int isincull(int, uint32_t, int, int);
int safe_isincull(int, uint32_t, int, int);
int is_any_goodcull(int, uint32_t, char);
int iso_get_offs(char, int, int, int, int, double *, double *, int, double *,
    double *, int, double *, double *, double);
int iso_get_all_ofs(int, int, int, int, double ofs[HI_ENERGIES][HI_AZ_BINS],
    double ofsunc[HI_ENERGIES][HI_AZ_BINS], int,
    double rates[HI_ENERGIES][HI_AZ_BINS],
    double ratesunc[HI_ENERGIES][HI_AZ_BINS], int, int,
    double iong[HI_ENERGIES][HI_AZ_BINS],
    double iongu[HI_ENERGIES][HI_AZ_BINS], double);
int iso_dump_ofs_file(char *, int, int, int, int, int, int, double, double,
    int, uint32_t, uint32_t, double morebgs[HI_ENERGIES][HI_AZ_BINS],
    double morebgus[HI_ENERGIES][HI_AZ_BINS]);
/* backgrounds and 6 sets of additional offsets from elsewhere. */
int iso_dump_ofs_file2(char *, int, int, int, int, int, double, double,
    double bgratehz[HI_ENERGIES], double bgrateunchz[HI_ENERGIES], int,
    uint32_t, uint32_t, double morebgs[HI_ENERGIES][HI_AZ_BINS],
    double morebgus[HI_ENERGIES][HI_AZ_BINS]);
int iso_dump_rate_file(char *, int, int, int, int, int, int);
/* backgrounds and 6 sets of additional offsets from elsewhere (or NULL). */
int iso_dump_rate_bgsub_file(char *, int, int, int, int, double, double, int,
    double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igbr[HI_ENERGIES][HI_AZ_BINS], double igbu[HI_ENERGIES][HI_AZ_BINS]);
/* Record pointing information too */
int iso_dump_rate_bgsub_fileX(char *, int, int, int, int, double, double, int,
    int, int, double abg[HI_ENERGIES], double abu[HI_ENERGIES],
    double igbr[HI_ENERGIES][HI_AZ_BINS], double igbu[HI_ENERGIES][HI_AZ_BINS]);

/* readhb.c
 * Ingest telemetry streams; this is Geoff's code really.
 * hb_massinit() or its equivalent has to have happened first.
 * Arg 1:  filename
 * Arg 2:  min MET
 * Arg 3:  max MET
 * Arg 4:  verbosity
 */
int  process_tlm(char *, uint32_t, uint32_t, int);

/* hi_de_gbc.c
 *
 * This is for reading direct events into hbs.  It's a combination of a lot
 * of ISOC code, shoved into one ugly file so it can keep its statics to
 * itself.
 * There is one entry point, with a filename, an int (nonzero to print a
 * packet pump), and an int (set to 1 to do despinning or to 2 to do
 * histogramming by spin, without despinning).  The intrinsics of saving
 * are all in dode.c.
 * Last two args are startMET and endMET, for those cases where we're
 * despinning half an orbit and we don't want to wait for the other half.
 */
int  assemble_de_packets_old(char *, int, int, uint32_t, uint32_t);

/* hi_de_pj.c
 * This is a replacement of hi_de_gbc.c and surroundings.
 * Args:  filename, a startMET and and endMET, a 16-bit flag for the 16
 * possible event types, and a function to call once for each valid DE
 * found.
 *
 * DEs are sorted by spin by event.  So all events in one spin (according
 * to spacecraft) are reported before any event in the next spin, but the
 * events are not time-ordered per spin across event types by default.
 */
int read_in_des(char *, uint32_t, uint32_t, uint16_t,
    void (*hook)(double, uint16_t, int, int, double));
int read_in_des_ordered(char *, uint32_t, uint32_t, uint16_t,
    void (*hook)(double, uint16_t, int, int, double));
int assemble_de_packets(char *, int, int, uint32_t, uint32_t);

/* decull.c
 * It takes a bit of a separate routine to read in good times on a direct
 * event cadence.  Put that here.
 * sanity_check_spininfo() returns 0 on sane.
 * DE_isincull() takes cull number, MET (double), ESA, angbin, and the
 *     array of read DE good times from read_goodDEtimes().
 * build_exp() bins up good-times exposure in 0.1 degree bins, by NUMBER OF
 *     SPINS, once read_goodDEtimes() has populated a degt *.  It includes
 *     flyback corrections.  The second argument is which cull (0-7) and
 *     the third argument is nonzero to despin.  Returns 0 on success.
 */
int  sanity_check_spininfo();
int  DE_isincull(int, double, int, int, degt *);
int  read_goodDEtimes(char *, degt **, int, uint32_t, uint32_t, int);
void free_degt(degt *);
int  build_exp(degt *, int, int, int expos[HI_ENERGIES][3600]);

/* processhb.c
 *
 * A lot of this is a variety of status reporting
 * XXX and a lot could be merged with pprintf(). XXX
 * print_hb_overflows(), print_bm_overflows(), and print_hb_comps()
 * are just that:  report on how many overflows or compressed data were
 * seen.  print_tce() says if the Total Count Excess ever got hit, but
 * as far as I can tell, that's all buggy on the spacecraft and is always
 * zero.
 * cull_partial_hbs() and further_cull_hbs() take a verbosity argument, and
 * remove hbs with less than 48 or 96 spins, and hbs where slow-cadence and
 * hi-cadence don't match up, respectively.
 * print_timing() looks for and at fuzzy histogram timings, and takes a
 * verbosity argument.  get_cadence() looks over the whole orbit for what
 * the mean/median histogram cadence is (to the closest second, since I use
 * just CEU MET time, which isn't too accurate).  XXX this should then be
 * used as the default rate on the s/c from which slop is determined!  It
 * should get called early and USED!! XXX
 * compare_hb_to_de() is an early vague comparison of when might be good
 * times to compare DEs and hbs.  It doesn't actually _do_ such a
 * comparison.
 * print_bgs() takes a threshold and a verbosity, and figures out what kind
 * of cosmic ray background is likely there, by comparing qABC to unqABC.
 * XXX still under analysis!
 * bin_raw_counts is a diagnostic tool to look at the frequency at which
 * various raw values show up from the spacecraft.  It allocates its return
 * array (though it may return NULL if it can't).
 * fix_hb_de_off_by_ones(hb1, hb2, nmax, verbosity, FILE *) resolves
 * situations where nmax or fewer counts (2 is a sensible default) appear
 * one bin off between histogram numbers hb1 and hb2, by making hb2 match
 * hb1.
 */
int  get_max_E(int);
int  get_max_bmcounts();
int  print_hb_overflows(timelog_c, int);
int  print_bm_overflows(timelog_c, int);
int  print_hb_comps(timelog_c, int);
int  print_tce(int);
int  cull_partial_hbs(int);
int  further_cull_hbs(int);
int  print_timing(int);
int  get_cadence(timelog_c *, int *);
void compare_hb_to_de(int, int);
void print_bgs(int, int, SEPlist *, int);
/* threshold, rate, unc */
void get_bgs(int, double *, double *, SEPlist *, int);
void get_bgs_time(double *, double *, uint32_t, uint32_t, int);
void get_bgs_time_ang(double *, double *, uint32_t, uint32_t, int, int, int);
long *bin_raw_counts(uint32_t, uint32_t, int, int, int, char);
int  fix_hb_de_off_by_ones(int, int, int, int, FILE *);
/* informational printf()s if the int is nonzero */
void findnzeroLVSCI(int);
void drop_null_hbs(int);

/* dode.c
 *
 * non-ISOC handling of direct events.
 * You can set a limited range of phase to plot over 60 bins.
 * You can ask for specific hbs[] to be replaced with specific sets of DEs,
 *   and all DE types are allowed (so you can confirm we're not getting
 *   event types that we shouldn't).
 * You will soon be able to ask for spun vs despun.  At present, it's just
 * spun.
 * Event types are as defined at ISOC, 0-15, and are represented by
 *    1 << evtype in a uint16_t.
 * Things will choke BADLY if you haven't read in your orbital spin bin
 * databases first.   XXX
 */
/* set min and max phase */
void setup_hb_to_DEang(double, double);
/* ask for DE types in second arg to be stored in hb number <first arg> */
void setup_hb_to_DE(int, uint16_t);
void clear_hb_to_DE();
uint16_t convert_de_name_to_bitmap(char *);
/* set up the hbs to be populated with nondespun DEs */
void setup_spundata();
/* set up the hbs to be populated with spun DEs (OSBdb and OSBdb2 must be
 * initialized)
*/
void setup_despundata();
/* internal routines used in hi_de_gbc.c to save nondespun/despun DEs */
void shove_des_into_hbs_nodespin(uint32_t, uint16_t, int, int, int, int);
void shove_des_into_hbs_despun(uint32_t, uint16_t, int, int, int, int);
/* Next two routines just to be used internally by hi_de_pj.c */
void adp_despin(double, uint16_t, int, int, double);
void adp_nodespin(double, uint16_t, int, int, double);
#ifdef DO_PS
void dump_good_evs(char *, int, uint16_t, int, int);
#endif

/* bursts.c
 * Look for bursts in populated histograms, using lA, lB, and lC, and
 * reporting for pretty much everything.  Needs further_cull_hbs() to
 * have happened to be sensible.
 *
 * Arg 1:  min counts necessary for a burst to be considered.
 * Arg 2:  fractional threshold for a burst to be considered.
 * Arg 3:  verbosity.
 */
typedef struct {
	uint32_t met;
	int ESA;
	int angbin;
	int qABC, lABC, qAB, lAB, qAC, lAC, qBC, lBC, lA, lB, lC;
} burst_rec;

/* allocs and returns an array of length returned in int *. */
burst_rec *return_bursts(int, double, int, int *);
void print_bursts(int, double, int);

/* osdb.c
 * Read and query Orbital Spin Bin databases.
 * OSdb is the osbdba file; if osbd2a exists, we'll need to load it
 * separately (into OSBdb2).
 */
int  initialize_OSBdb(char *);
int  initialize_OSBdb2(char *);
void clear_OSBdbs();
int  is_OSBdb_initialized();
/* arg1 = MET.  The double * gets the period and the value returned is the
 * spin or -1 if invalid lookup.
 */
int32_t get_OSBdbstuff(double smet, double *period);
int32_t get_OSBdb2stuff(double smet, double *period);
/* Return the phase (0. - 1.) for a given spin (arg1) and Direct Event
 * timestamp (arg 2).
 */
double get_OSBdbphase(int, int);
/* For the same arguments, get the DESPUN phase.  Third arg returns despun
 * spin
 */
double get_OSBdbphase2(int, int, int *);
/* Convenience lookups that might come in handy */
double get_metfromspin(int spin);
double get_metfromspin2(int spin);
double get_perfromspin(int spin);
double get_perfromspin2(int spin);
int    get_lastspin();
int    get_lastspin2();
/* For mapping a cull onto nondespun data */
int  get_OSBhowspun(uint32_t, uint32_t, double *, double *, int *);
double get_flyback_correction_bybin(int, int, int, int);
int  get_spun_flyback_correction(double **, int, int);
int  spinup_cull(int, int);
/* Allocates and returns an array of spun-ness for a given histogram type */
int  get_spinup_ranges(double **, int);
/* Simple loading of osbdba/osbd2a files, to prime things without actually
 * despinning.
 */
int  getdefault_osbdba(int, int);
int  getdefault_osbdba_MET(uint32_t);
int  get_osbdba_cksums(uint32_t *, uint32_t *);
/* Pick out just times not requiring despinning, given loaded osbd[b2]a */
int  get_nonspuntimes(double, int, int);
int  get_hbtime(int, int, char, double *);
/* spininfo processing rather than osbdba reading, to same effect */
double get_spininfo_hbtime(double, double, double *);
int  populate_osb_from_spininfo(int);
void make_spintime_array(double **, double **, int *, double, double);
int  find_spun_spininfo(double, double, double, double, int, SEPlist **,
    FILE *, double *, int);
void fake_osbd2a(SEPlist *);

/* readewind.c
 *
 * This reads in files of ELSP>EESA LOW Electron OMNI Spectra
 * (Wind 3dp, Electron omnidirectional fluxes 3 eV - 30 keV)
 * and processes them.
 */
/* negative on failure, 0 on complete success, positive on partial coverage
 * of time range requested.  Last param is requested channel (-1 for default).
 */
int    reap_wind(char *, uint32_t, uint32_t, int);
/* Free memory of WIND data */
void   break_wind(void);
/* time range in MET */
double get_avgwindeflux(double, double);
int    get_navgwindeflux(double, double);
/* single time in MET */
double get_closestwindeflux(double);
/* Speed:  dump/load a binary variant, with basically no checking */
int  dump_bwind(char *);
int  load_bwind(char *);

/* readpointing.c
 *
 * This reads in the inertial_pointing file and deals with it.
 */
int init_inertialpointing(char *);	/* returns zero on success */
char *str_orbit_at_met(uint32_t, int);
int get_orbit_at_met(uint32_t, int *);	/* returns negative on failure */
/* args: orbit, arc, &ra, &dec, returned in J2000.  0 on success. */
int get_ibex_dir(int, int, double *, double *);
/* returns 0 on success */
int get_burn_MET_of_orbit(int, int, uint32_t *);
int get_burn_MET_after_orbit(int, int, uint32_t *);
int get_arcs_per_orbit(int);
/* args:  orbit, arc, angle (0-360), &lat, &long, returned in ECLIPJ2000.
 * Returns 0 on success.
 */
int get_la_lng_from_orb_ang(int, int, double, double *, double *);
int simple_init_inertialpointing(char *, int);	/* returns zero on success */
int is_pointing_inited(void);

/* realspice.c
 * Local SPICE magic.
 * Note that you don't need to link with -lcspice unless you call these
 * specific routines!  You do need spice installed to compile this, though,
 * and beyond that it has to be my hacked version where the speed of light
 * is adjustable.
 *
 * Distance units are always km.
 */
/* Convenience function, proton eV --> km/s */
double eV2kms(double);
double kms2eV(double);
/* Return 0 on success; has to run first!  First arg is meta kernel
 * containing everything that you want, period.  Second is verbosity
 * (0 = quiet, 1 = noisier, 2 = noisiest)
 */
int  init_spice(const char *, int);
/* If spice didn't init, or you didn't get everything in the kernel you
 * wanted, you need to reset the errors and run the next bit.
 */
int  reinit_spice(const char *, int);
/* In case of error other than failed init */
void reset_spice(void);
/* 0 on success; args are MET, x, y, z, isascending (+1 or -1), verbosity) */
int  getIBEXlocGSE(double, double *, double *, double *, int *, int);
/* 0 on success; args are MET, x, y, z, propagation speed (<= 0. to
 * ignore), object name, verbosity.  Coordinates are J2000, or the final
 * string of getIBEXtoOBJ_coord() (if not NULL).
 */
int  getIBEXtoOBJ_coord(double, double *, double *, double *, double,
    const char *, int, const char *);
int  getIBEXtoOBJ(double, double *, double *, double *, double,
    const char *, int);
/* 0 on success; MET, IBEX pos, lunar pos, verbosity */
int    getIBEXmoonGSE(double, double ibexpos[3], double lunarpos[3], int);
/* 0 on success:  looks for an object in FOV and sets up an angle-bin cull
 * for it.  Arguments:  MET, propagation speed (as before), object name,
 * object radius (km), IBEX full angular FOV in degrees, IBEX pointing
 * vector in J2000, flag (set to nonzero if object is in FOV), angle-bin
 * cull selecting for object, verbosity.
 */
int  IBEX_OBJ_in_FOV(double, double, const char *, double, double,
    double ibpoint[3], int *, int anglebinz[HI_AZ_BINS], int);
/* Convenience implementation of above:  populate mculls[] for earth, moon,
 * and Jupiter.  Set argument to -1 to disable that search.
 * Args:  which element of mcull to put earth cull, moon cull, and Jupiter
 * cull in, respectively.
 * The Jupiter cull is set for the central speed of each ESA; XXX it
 * doesn't use Hi_cal though.
 */
int  populate_culls_fg_objects(int, int, int);
/* And IBEX_OBJ_in_FOV is not as convenient as I thought.  Add a function
 * for just a single object.  Args are object name, object radius (km),
 * which cull to populate, and speed (as IBEX_OBJ_in_FOV).  A negative
 * speed means light speed, EXCEPT if the speed is -M_PI, in which case
 * it means use the central energy of each ESA (as Jupiter).  XXX doesn't
 * use Hi_cal though.
 */
int  populate_cull_object(const char *, double, int, double);
/* 0 on success.  args: MET, angle (xy, xz) in RADIANS returned, total off-sun
 * angle in RADIANS returned, verbosity
 */
int  getGSEpointingdir(double, double *, double *, double *, int);
/* 0 on success.  args: MET, latitude, longitude, verbosity */
int  conv_ECLIPJ2000_GSE(double, double *, double *, int);
int  conv_GSE_ECLIPJ2000(double, double[3], int);
/* 0 on success.  The initial double[3] is replaced.  First string is coord
 * system FROM, second string is TO.  Next is MET.  Final argument is
 * verbosity.
 */
int  conv_coord_sys(double[3], const char *, const char *, double, int);

/* readsweep.c, for the sweep table */
int  init_sweeptable(char *);
void nice_sweeptable();
int  get_sweeptable(uint32_t, int sweep[6]);
int  get_sweep_unq_ratio(uint32_t, int, double *, double *, double*);
int  is_sweep_same(uint32_t, uint32_t, char);
uint32_t MET_for_most_appropriate_sweep_table(uint32_t, uint32_t, int);
char *ESAstr_at_met(uint32_t, int);

/* asa239.c, Applied Statistics Algorithm:  x, p (>0), ret error (0 = good)
 * This is the incomplete gamma integral for x and p.  The int * is 0 on
 * success.
 */
double gammad(double, double, int *);

/* makexpm.c
 * produce a colour plot from an array of nx by ny doubles or ints in an
 * array, using one of 3 colour tables.  Data is normalized to its max and
 * min for colour-table purposes; at present there's no way to change that
 * except to force some data to the limits you want, or truncate to a range
 * before calling this.
 *
 * Arg 1:  filename to create.
 * Args 2&3:  nx, ny
 * Arg 4:  array of data
 * Arg 5:  colour table:  default (0) is grey scale.  1 is IDL CT 39.
 *           2 is the default gnuplot palette.
 * Return:  0 on success
 */
int make_xpmf(char *, int, int, double *, int);
int make_xpmi(char *, int, int, int *, int);

/* pprintf.c
 * Printing with a verbosity level.  The idea is you set l_verbosity
 * to the level you want to see, and specify the urgency as the first
 * parameter of a printf() or fprintf(stderr) (depending where you want
 * the output to go).
 * If pprintloginit(levels) is run, the program keeps a running tally of
 * how many messages went to each level (reset if levels < 0).  This tally
 * can be accessed by pprintlogct(levelinquestion).
 */
extern int l_verbosity;

int  pprintf(int, const char *, ...);
int  errpprintf(int, const char *, ...);
void pprintloginit(int);
int  pprintlogct(int);

/* readhk.c
 * read_housekeep() needs a specific filename and filetype (hk_plot,
 * created by hi_hk_isoc), and the column of it that contains the single
 * kind of housekeeping data you care about.  (This limits the range of h/k
 * you can correlate severely.) It returns 0 on success.
 * After read_housekeep() has succeeded,
 * get_hkinfo(MET, &retval, &closestMET) returns zero on success.  If it
 * succeeded, it also returns interpolated h/k for the given time as well
 * as the MET of the closest-in-time available h/k telemetry.
 * Note that for now only one point is allowed at a time to correlate.
 *
 * Ideally this all gets replaced with something that parses housekeeping
 * on its own, but that's not been needed yet.
 */
int  read_housekeep(char *, int);
int  get_hkinfo(uint32_t, double *, uint32_t *);
int  read_CEMV_housekeep(char *);
int  get_CEMsetting(uint32_t);
char *guess_cem_hkname(uint32_t);

/* retcol.c
 * Handle csv files (e.g., from IDMS or from hk_print).
 * retcol(longstring, columnname, delimiter) returns the column number
 *     (starting at 1, not at 0) where columnname appears in longstring,
 *     or -1 if it didn't match.  Case matters.
 * strcolval(longstring, column-number, returnstring, returnstringlength,
 *     delimiter) copies over the string in the specified column-number,
 *     with columns delimited by delimiter.  Return is zero on success.
 * *colval(longstring, column-number, delimiter, pointer-to-storage)
 *     are functions that populate a given data type from the specified
 *     column of longstring.  Return is zero on success.
 */
int retcol(char *, char *, char);
int strcolval(char *, int, char *, int, char);
int intcolval(char *, int, char, int *);
int uint32colval(char *, int, char, uint32_t *);
int dblcolval(char *, int, char, double *);

/* iongun.c
 * Try to figure out WIND hot-electron-based corrections to signal rates.
 * Needs WIND data to have been read in, as well as SPICE if you want to do
 * the correction only when IBEX is in the solar wind.
 */
/* Plug-in replacement for iso_get_all_ofs() */
int  iso_and_ion_get_all_ofs(int, int, int, int,
    double ofs[HI_ENERGIES][HI_AZ_BINS], double ofsunc[HI_ENERGIES][HI_AZ_BINS],
    int, double rates[HI_ENERGIES][HI_AZ_BINS],
    double ratesunc[HI_ENERGIES][HI_AZ_BINS], int, int);
/* Some analysis routines:  all use m consecutive histograms of type
 * whichhb, where f is zero if the histograms need to be consecutive and
 * without gaps, corresponding to times when any angle is good in
 * whichcull's cullesa.  All alloc and return in bgs an array of backgrounds,
 * length nbgs.  nbgs is zero if there was a problem.
 * get_min_iso_bgs(n, m, whichhb, whichesas, whichcull, cullesa, f, **bgs,*nbgs)
 *    takes the n-angle minimum isotropic background present in the sum of
 *    whichesas (OR of 1<<(0..5)).
 * get_wind_e_bgs(m, whichhb, whichcull, cullesa, f, **bgs, *nbgs)
 *    gives average WIND hot electron data (WIND data must have previously
 *    been read in) -- a -1 is inserted for any data-free period.
 * get_iso_excess_lAB(m, whichesa, whichcull, cullesa, f, effc, penb, **bgs,
 *    *nbgs) works out excess lAB counts in whichesa.  There is no
 *    uncertainty tracking and penb must be in /hb, not in Hz.
 * get_basic_iongun(esa1, cullesa, whichcull, dodespin, effc, effcunc,
 *    penb, penbunc, **ionghz, **ionghzunc, hbtime, hbtype, verbosity) allocs
 *    and returns the simplest of the "real" "final" ion gun corrections.
 *    Everything here is in Hz.
 *
 * The idea is to do linear fits between these to work out the ion gun
 * correction from the data.
 */
double expected_detC_efficiency(uint32_t, double *);
double conversionfactor_lAB_qABC(uint32_t, int, int, double *);
double conversionfactor_lAB_qBC_relqABC(uint32_t, int, double *);
void get_min_iso_bgs(int, int, int, int, int, int, int, double **, int *);
void get_wind_e_bgs(int, int, int, int, int, double **, int *);
void get_iso_excess_lAB(int, int, int, int, int, double, double, double **,
    int *);
int  get_basic_iongun(char, int, int, int, double, double, double, double,
    double **, double **, double, int, int);
int iongun_populate_all_offsets(int, int, double, double,
    double rates[HI_ENERGIES][HI_AZ_BINS],
    double uncs[HI_ENERGIES][HI_AZ_BINS], double, int, int);

/* penbg.c
 * Ratio of penetrating background of various coincidences appears to
 * change over time.  Make this the interface to the background tests --
 * any necessary initialization will happen transparently.
 *
 * get_penbg_ratio(met, hbtype, *unc) returns the ratio.
 * get_test_results(whichtest, hbtype, *rate, *unc) returns a specific test
 * (0 on sensible results, nonzero on failure).
 * The latter function will allow arrays to be populated to mimic the older
 * method of just assuming the ratios found during one test.
 */
double get_penbg_ratio(uint32_t, int, double *);
int    get_test_results(int, int, double *, double *);

/* sepsearch.c
 * Look for SEP events (e.g. to remove from bg calculation times)
 * Args: interval (seconds), minhztocare, sigmasneeded, sigmahyst,
 *   list of events (NULL to disable allocating this), verbosity.
 * Set interval < 0 to initialize parameters to default (8 * HB_TIME,
 *   0.02, 4.0, 1.25).
 */
int find_seps(int, double, double, double, SEPlist **, int);
int in_SEP(uint32_t, SEPlist *);

/* sheath.c
 * simple tests for in solar wind, vs in shock, etc.
 */
/* 1 behind bow shock, 0 in solar wind.  Input is GSE coords in km */
int  in_nominal_BS(double x[3]);
/* Set up a cull indicating nominally in solar wind, for one ESA only */
int  make_cull_in_nominal_SW(int, int);
/* sum the energies in garray data specified by bits of char, and fit to
 * solar wind shape.  Return height and unc of contam, plus reduced
 * chisquared.  Note that mpfit did the fitting and so uncertainties and
 * chisquared may not mean quite what you think.
 */
void get_dswcontam(garray, char, double *, double *, double *);

/* spininfo.c
 * modify/correct timing of spins as (mis)recorded on the spacecraft.
 * fix_256_issue() is always called on reading in data via process_tlm().
 */
int    fix_256_issue();
int    fix_PPS_issue_as_per_ISOC(uint32_t, uint32_t);
int    fix_PPS_all_arcs();
double get_mode_period();
int    fix_gaps_in_spins();

/* vectors.c
 * simple 3-element-array arithmetic, which started at the lunar calcs.
 */
double d2r(double);
double r2d(double);
double dotp(double a[3], double b[3]);
/* a = b x c */
double crosv(double a[3], double b[3], double c[3]);
/* (a x b) . c */
double acrosv(double a[3], double b[3], double c[3]);
void   subv(double a[3], double b[3]);
void   scalm(double, double a[3]);
void   renorm(double x[3]);
void   rd2vec(double x[3], double, double);
void   vec2latlong(double x[3], double *, double *);
void   equat_to_eclip(double *, double *);
void   eclip_to_equat(double *, double *);
double getspinbin(double x[3], double y[3]);
double getspinbinj2000(double x[3], double y[3]);
void   rotaroundaxis(double x[3], double, double y[3]);

/* utility functions */
char *laststrstr(char *, char *);	/* like strstr() but last, not first */
int  bitsofchar(char);			/* How many bits are set? */
void mon_minmax(double *, int, double *, double *);
void mon_linear_fit(double *, double *, int, double *, double *, double *,
    double *, double *);
void mon_avg(double *, int, double *, double *);

/* From OpenBSD src/bin/md5/crc.h.  Actual functions and license in crc.c */
#define	CKSUM_DIGEST_LENGTH		4
#define	CKSUM_DIGEST_STRING_LENGTH	(10 + 1 + 19)

typedef struct CKSUMContext {
	uint32_t crc;
	off_t len;
} CKSUM_CTX;

void	 CKSUM_Init(CKSUM_CTX *);
void	 CKSUM_Update(CKSUM_CTX *, const uint8_t *, size_t);
void	 CKSUM_Final(CKSUM_CTX *);
char    *CKSUM_End(CKSUM_CTX *, char *);
char    *CKSUM_Data(const uint8_t *, size_t, char *);
/* End of OpenBSD crc.h insert */

/* Response function:  this part of the library can be used stand-alone,
 * but it makes things straightforward to put it in here.  I don't use the
 * Hi_cal.h that it comes with because it defines a bunch of stuff that
 * doesn't need to be externally visible.
 *
 * Requires the environment variable HI_CAL_DIR; previously there was a
 * default directory hard-coded.
 */
int   Hi_cal_init(void);
float Hi_PSF(float, float);   /* TAKES DEGREES, theta/phi */
float Hi_PSF_ab(float, float);     /* TAKES RADIANS, alpha/beta */
float Hi_G_double(int);
float Hi_G_triple(int);
float Hi_G_DE(int, char *);
float Hi_E_central(int);
float Hi_T_double(int, float);
float Hi_T_triple(int, float);

/* Convenience functions */
float Hi_resp_d(float, float, int, float);
float Hi_resp_t(float, float, int, float);

#endif
