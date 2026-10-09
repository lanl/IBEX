/*	$Id: xmap.h,v 1.13 2022/09/03 03:53:12 pjanzen Exp $	*/

#ifndef PJ_XMAP
#define PJ_XMAP

#include <X11/Intrinsic.h>
#include <X11/Xlib.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>

#define HI_ENERGIES (6)
/* Hmmm... Really I ought to alloc as needed. */
#define N_DATASETS (50)

typedef struct {
	char *name;
	int nbinlat, nbinlng;
	int firstorbit, lastorbit;
	int firstarc, lastarc;
	int filled[HI_ENERGIES];
	double *esa[HI_ENERGIES];
	double min[HI_ENERGIES];
	double max[HI_ENERGIES];
	double initrot[3][3];	/* XXX to be figured out */
	int healn;
	char *fnamebase, *fnameext;
	int datatype;	/* 0 = raw counts, rest TBD; not used yet */
} dataset;
/* datatype:
 * XXX right now only 0 & 2 work.
 * 0:  data file is made of rates and uncertainties
 * 1:  as 0 but we want resulting uncertainties
 * 2:  data file is made of counts, exposure (ms), bg rate, bg rate unc
 *     and we want rates.
 * 3:  as 2, but we want exposure, just for kicks
 * 4:  as 2, but we want resulting uncertainties
 * ...
 * XXX something to indicate it's ISOC files?
 */

/* abrate.c */
void abrate_init(int);
int  n_abrate(int);
int  abrate_ndx(double, double, int);

/* apue.c */
int  tty_cbreak(int);
int  tty_reset(int);
void tty_atexit(void);
void tty_suspend(void);
void tty_quit(void);

/* callbacks.c */
void wm_quit(Widget, XEvent *, String *, Cardinal *);
void merc_callback(Widget, XtPointer, XEvent *, Boolean *);
void glbf_callback(Widget, XtPointer, XEvent *, Boolean *);
void glbb_callback(Widget, XtPointer, XEvent *, Boolean *);
void moll_callback(Widget, XtPointer, XEvent *, Boolean *);
void resiz_callback(Widget, XtPointer, XEvent *, Boolean *);
void merc_mousecallback(Widget, XtPointer, XtPointer);

/* healpix.c */
int  healpix_ndx(double, double, int);

/* hist2d.c */
/* includes vectors.c from libibexhi */
double d2r(double);
double r2d(double);
void   scalm(double, double a[3]);
double dotp(double a[3], double b[3]);
void   renorm(double x[3]);
void   rd2vec(double x[3], double, double);
void   vec2latlong(double x[3], double *, double *);
void   rotaroundaxis(double x[3], double, double y[3]);
void equat_to_eclip(double *, double *);
/* local */
void clear_hist(int);
void print_histspecs(int);
char *getfext(void);
void set_histfile(char *, char *);
void set_histbins(int, int, double, double);
void set_histflags(int, int, int, int, double);
void get_histflags(int *, int *, int *, int *, double *);
void set_histheal(int);
void set_histabrate(int);
int  build_hist(int, int, int, int, int, int, int);
int  dump_currentdata(char *, int);

/* ipointing.c */
int  init_inertialpointing(char *);
void print_nearby_arcs(double, double, int, int, double, int);
int  simple_init_inertialpointing(char *, int);
int  get_arcs_per_orbit(int);

/* kbd.c */
void injectintobuffer(const char *fmt, ...);
void dumpfileintobuffer(const char *);
void handle_kbd(XEvent *);
void Xreadkbd(XtPointer, int *, XtInputId *);
void init_kbd(void);
void kbdparse(void);

/* mappage.c */
/* includes vector.c from libibexhi */
void   pushctr(void);
int    popctr(void);
void   print_currot(void);
double max_arr(double *, int);
double min_arr(double *, int);
int    maps_compatible(int, int);
void   copy_currotm(double a[3][3]);
void   build_rotation(double, double, double, int, double foo[3][3]);
void   apply_rotation(double *, double *);
void   apply_inv_rotation(double *, double *);
double get_pixel_value(double, double, char *);
int   *plot_mercator(int, int, double, double);
int   *plot_globe(int, int, int, double, double);
int   *plot_mollweide(int, int, double, double);

/* mapread.c */
double *isoc_ingest(char *, int, int *, int *, char **);
int     populate_data_isoc(char *fname[HI_ENERGIES], int, int);

/* menus.c */
Widget init_menus(Widget);

/* Xdraw.c */
void flushx(void);
void draw_merc(void);
void draw_glbf(void);
void draw_glbb(void);
void draw_moll(void);
void draw_merc_expose(void);
void draw_glbf_expose(void);
void draw_glbb_expose(void);
void draw_moll_expose(void);
void firstbuild_data(void);
void rebuild_data(void);
void create_title(void);

/* Xinit.c */
void tty_suspend_interrupt(int);
void tty_quit_interrupt(int);
void initX(void);
int  colorindexrgb(Widget, int, int, int);
int  colorindexname(Widget, char *);

/* xmap.c */
void usage(FILE *);

#endif
