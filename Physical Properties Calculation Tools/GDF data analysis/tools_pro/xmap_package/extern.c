/*	$Id: extern.c,v 1.7 2022/09/03 03:53:12 pjanzen Exp $	*/

static const char rcsid[] = "@(#) $Id: extern.c,v 1.7 2022/09/03 03:53:12 pjanzen Exp $";

#include <limits.h>
#include <stdint.h>
#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xlib.h>

#include "xmap.h"

XtAppContext OurAppContext;
Widget tl;
Widget tlf;
Widget info, merc, glbf, glbb, moll;
Atom   wm_delete_window;		/* Handle window manager delete request */

int colblack, colwhite;
int cmap[256];
int ocmap[256];
uint32_t im_cmap[256];
uint32_t im_ocmap[256];
int greyscale;
int rev_vid;

struct resources {
	int  MapX;
	int  MapY;
	int  Border;
	int  Flip;
	int  tryPixmap;
	int  tryXImage;
} appResources;

double *pltdata = NULL;
int pltnlat = 0;
int pltnlng = 0;
int healzn = 0;
int defdattype = 0;

double minval, maxval;
double ctrlat, ctrlng, ctrrot;

int showdraw = 1;
int *mercdata, *glbfdata, *glbbdata, *molldata;
int mercx, mercy, glbx, glby, mollx, molly;

dataset dsets[N_DATASETS];
int nds = 0;	/* number of filled data sets */
int ds = 0;	/* current data set */
int wesa = 3;	/* default displayed ESA (off by one) */
int showmenu = 1;
