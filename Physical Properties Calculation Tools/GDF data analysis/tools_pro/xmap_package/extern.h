/*	$Id: extern.h,v 1.8 2022/09/03 03:53:12 pjanzen Exp $	*/

#ifndef PJ_EXTERN
#define PJ_EXTERN

#include <limits.h>
#include <stdint.h>
#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xlib.h>

#include "xmap.h"

extern XtAppContext OurAppContext;
extern Widget tl;
extern Widget tlf;
extern Widget info, merc, glbf, glbb, moll;
extern Atom   wm_delete_window;

extern int colblack, colwhite;
extern int cmap[256];
extern int ocmap[256];
extern uint32_t im_cmap[256];
extern uint32_t im_ocmap[256];
extern int greyscale;
extern int rev_vid;

extern struct resources {
	int  MapX;
	int  MapY;
	int  Border;
	int  Flip;
	int  tryPixmap;
	int  tryXImage;
} appResources;

extern double *pltdata;
extern int pltnlat;
extern int pltnlng;
extern int healzn;
extern int defdattype;

extern double minval, maxval;
extern double ctrlat, ctrlng, ctrrot;

extern int showdraw;
extern int *mercdata, *glbfdata, *glbbdata, *molldata;
extern int mercx, mercy, glbx, glby, mollx, molly;

extern dataset dsets[N_DATASETS];
extern int nds, ds, wesa;
extern int showmenu;

#endif
