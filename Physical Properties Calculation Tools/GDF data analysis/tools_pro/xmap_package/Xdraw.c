/*	$Id: Xdraw.c,v 1.3 2018/03/15 21:34:48 pjanzen Exp $	*/

static const char rcsid[] = "@(#) $Id: Xdraw.c,v 1.3 2018/03/15 21:34:48 pjanzen Exp $";

#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xlib.h>

#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef THREADS
#include <pthread.h>
#endif

#include "xmap.h"
#include "extern.h"

/* Only used if appResources.tryPixmap is nonzero */
/* Mercator */
static Pixmap mcpmap;
static GC mcgc;
/* Only used if tryPixmap is nonzero and tryXImage is nonzero */
static XImage *mcxim = NULL;
/* Globe front */
static Pixmap gfpmap;
static GC gfgc;
static XImage *gfxim = NULL;
/* Globe back */
static Pixmap gbpmap;
static GC gbgc;
static XImage *gbxim = NULL;
/* Mollweide */
static Pixmap mwpmap;
static GC mwgc;
static XImage *mwxim = NULL;

/* resize catcher?  XXX deletable? */
static int dpixw = 0;

static void create_mercmap(Drawable, GC);
static void create_glbfmap(Drawable, GC);
static void create_glbbmap(Drawable, GC);
static void create_mollmap(Drawable, GC);


#if 0
void
convenience_XClearWindow()
{
	XClearWindow(XtDisplay(tl), XtWindow(datainph));
}
#endif

void
flushx()
{
	XFlush(XtDisplay(tl));
}

/* Make an image and simply plop it on.  Next four funcs are very similar. */
/* TODO:  Right now it bails if I can't do image maps, so it may fail on
 * old-school setups.
 */
void
draw_merc()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw || !mcxim)
		return;
	display = XtDisplay(tl);
	window = XtWindow(merc);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window, GCForeground | GCBackground, &xgcv);
	create_mercmap(mcpmap, mcgc);
	XPutImage(display, mcpmap, mcgc, mcxim, 0, 0, 0, 0,
	    mercx + 2 * appResources.Border, mercy + 2 * appResources.Border);
	XCopyArea(display, mcpmap, window, gc, 0, 0,
	    mercx + 2 * appResources.Border, mercy + 2 * appResources.Border,
	    0, 0);
	XFreeGC(display, gc);
}

void
draw_glbf()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw || !gfxim)
		return;
	display = XtDisplay(tl);
	window = XtWindow(glbf);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window, GCForeground | GCBackground, &xgcv);
	create_glbfmap(gfpmap, gfgc);
	XPutImage(display, gfpmap, gfgc, gfxim, 0, 0, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border);
	XCopyArea(display, gfpmap, window, gc, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border, 0, 0);
	XFreeGC(display, gc);
}

void
draw_glbb()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw || !gbxim)
		return;
	display = XtDisplay(tl);
	window = XtWindow(glbb);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window, GCForeground | GCBackground, &xgcv);
	create_glbbmap(gbpmap, gbgc);
	XPutImage(display, gbpmap, gbgc, gbxim, 0, 0, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border);
	XCopyArea(display, gbpmap, window, gc, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border, 0, 0);
	XFreeGC(display, gc);
}

void
draw_moll()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw || !mwxim)
		return;
	display = XtDisplay(tl);
	window = XtWindow(moll);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window, GCForeground | GCBackground, &xgcv);
	create_mollmap(mwpmap, mwgc);
	XPutImage(display, mwpmap, mwgc, mwxim, 0, 0, 0, 0,
	    mollx + 2 * appResources.Border, molly + 2 * appResources.Border);
	XCopyArea(display, mwpmap, window, gc, 0, 0,
	    mollx + 2 * appResources.Border, molly + 2 * appResources.Border,
	    0, 0);
	XFreeGC(display, gc);
}


/* Just try to redraw to screen. */
/* TODO: re-enable stuff if tryPixmap is false. */
void
draw_merc_expose()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw)
		return;
	display = XtDisplay(tl);
	window = XtWindow(merc);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window,
	    GCForeground | GCBackground, &xgcv);
	XCopyArea(display, mcpmap, window, gc, 0, 0,
	    mercx + 2 * appResources.Border, mercy + 2 * appResources.Border,
	    0, 0);
	XFreeGC(display, gc);
}
void
draw_glbf_expose()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw)
		return;
	display = XtDisplay(tl);
	window = XtWindow(glbf);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window,
	    GCForeground | GCBackground, &xgcv);
	XCopyArea(display, gfpmap, window, gc, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border, 0, 0);
	XFreeGC(display, gc);
}
void
draw_glbb_expose()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw)
		return;
	display = XtDisplay(tl);
	window = XtWindow(glbb);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window,
	    GCForeground | GCBackground, &xgcv);
	XCopyArea(display, gbpmap, window, gc, 0, 0,
	    glbx + 2 * appResources.Border, glby + 2 * appResources.Border, 0, 0);
	XFreeGC(display, gc);
}
void
draw_moll_expose()
{
	Display *display;
	Drawable window;
	GC gc;
	XGCValues xgcv;

	if (!showdraw)
		return;
	display = XtDisplay(tl);
	window = XtWindow(moll);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;
	gc = XCreateGC(display, window,
	    GCForeground | GCBackground, &xgcv);
	XCopyArea(display, mwpmap, window, gc, 0, 0,
	    mollx + 2 * appResources.Border, molly + 2 * appResources.Border,
	    0, 0);
	XFreeGC(display, gc);
}


static int GotPixmapCreateError;

/* Copy the xloadimage-style temporary error handler if the Pixmap creation
 * fails.
 */
static int
pixmapErrorTrap(Display *disp, XErrorEvent *pErrorEvent)
{
	char buf[128];

	GotPixmapCreateError = 1;
	XGetErrorText(disp, pErrorEvent->error_code, buf, sizeof(buf) - 1);
	printf("serial #%lu (request code %d) got error:\n%s\n",
	    pErrorEvent->serial, pErrorEvent->request_code, buf);
	return(0);
}

/* Really, just set up the pixmaps.
 * The logic is:
 *   draw_data() regenerates the data from num/denom every time.
 *   draw_data_expose() simply XCopys if it can.
 * Sequence is no pixmap, yes pixmap, yes pixmap&XImage.  For the last
 * option, the pixmap that gets used above is made from an XImage, which is
 * way quicker to draw.  This only works on certain screens (for now).
 *
 * Each additional complication is FASTER (pixmap for expose events and
 * panning, XImage for any and all data changes) at the cost of requiring
 * more memory.  The Pixmap comes out of server memory; the XImage comes
 * out of program memory.
 */
void
firstbuild_data()
{
	Display *display;
	Drawable window;
	XGCValues xgcv;
	XWindowAttributes xwa;
	int (*old_handler)(Display *, XErrorEvent *);
	char *imagegoo;

	if (appResources.tryPixmap) {
		display = XtDisplay(tl);
		window = XtWindow(merc);
		/* There's an Xt querying method too, but it's not as simple.
		 * Note I get a width from this, which I could use but which I ignore.
		 */
		XGetWindowAttributes(display, window, &xwa);
		/* XCreatePixmap() can fail; handle it gracefully */
		GotPixmapCreateError = 0;
		/* Make sure everything previous gets the old error handler */
		XSync(display, False);
		old_handler = XSetErrorHandler(pixmapErrorTrap);
		mcpmap = XCreatePixmap(display, window,
		    mercx + 2 * appResources.Border, mercy + 2 * appResources.Border,
		    xwa.depth);
		/* Make sure we get the new error handler. */
		XSync(display, False);
		(void)XSetErrorHandler(old_handler);
		if (GotPixmapCreateError) {
			/* Get rid of everything Pixmappy and don't try again.
			 * At this point we haven't allocated anything else.
			 */
			printf("Not using Pixmap backing for duration!\n");
			appResources.tryPixmap = 0;
			return;
		}
		/* DefaultDepth(display, DefaultScreen(display)) */
		dpixw = mercx + 2 * appResources.Border;
		xgcv.function = GXcopy;
		xgcv.foreground = colblack;
		mcgc = XCreateGC(display, mcpmap, GCForeground | GCFunction,
		    &xgcv);
		/* Can't XClearWindow() since it's not a window */
		XFillRectangle(display, mcpmap, mcgc, 0, 0,
		    mercx + 2 * appResources.Border, mercy + 2 * appResources.Border);
		if (appResources.tryXImage) {
			mcxim = NULL;
			if (xwa.depth != 24) {
				appResources.tryXImage = 0;
				printf("--can't handle depths other than 24-bit; bailing on tryXImage.\n");
			} else if ((imagegoo = calloc((mercx + 2 * appResources.Border)
			    * (mercy + 2 * appResources.Border), 4)) != NULL) {
				mcxim = XCreateImage(display, xwa.visual, xwa.depth,
				    ZPixmap, 0, imagegoo,
				    mercx + 2 * appResources.Border,
				    mercy + 2 * appResources.Border,
				    BitmapPad(display), 0);
				if (mcxim) {
					/* Set up some easy defaults for the image */
mcxim->byte_order = LSBFirst; /* XXX make it the system default */
/* i386 is little endian; there's also the whole byte swapping issue --
 * see swap64() man page.
 */
					mcxim->bitmap_unit = 32;
					/* depth takes care of the rest; servers like to
					 * pad to uint32_t.
					 */
					mcxim->bits_per_pixel = 32;
					if (XInitImage(mcxim) == 0) {
						printf("XInitImage failed:  bailing on tryXImage.\n");
						appResources.tryXImage = 0;
						XDestroyImage(mcxim);	/* also frees imagegoo */
						mcxim = NULL;
					}
					/* build more maps */
					if (mcxim && (imagegoo = calloc(
					    (glbx + 2 * appResources.Border) *
					    (glby + 2 * appResources.Border), 4)) != NULL) {
/* XXX check for failure here again? Or assume that since it worked once
 * it'll work again?
 */
						gfpmap = XCreatePixmap(display, window,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border, xwa.depth);
						gfgc = XCreateGC(display, gfpmap,
						    GCForeground | GCFunction, &xgcv);
						XFillRectangle(display, gfpmap, gfgc, 0, 0,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border);
						gfxim = XCreateImage(display, xwa.visual,
						    xwa.depth, ZPixmap, 0, imagegoo,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border,
						    BitmapPad(display), 0);
						if (gfxim) {
							gfxim->bitmap_unit = 32;
							gfxim->bits_per_pixel = 32;
							if (XInitImage(gfxim) == 0) {
		printf("XInitImage failed on globefront window:  bailing.\n");
								XDestroyImage(gfxim);	/* also frees imagegoo */
								gfxim = NULL;
							}
						}
					}
					if (mcxim && (imagegoo = calloc(
					    (glbx + 2 * appResources.Border) * (glby + 2 *
					    appResources.Border), 4)) != NULL) {
						gbpmap = XCreatePixmap(display, window,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border, xwa.depth);
						gbgc = XCreateGC(display, gbpmap,
						    GCForeground | GCFunction, &xgcv);
						XFillRectangle(display, gbpmap, gbgc, 0, 0,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border);
						gbxim = XCreateImage(display, xwa.visual,
						    xwa.depth, ZPixmap, 0, imagegoo,
						    glbx + 2 * appResources.Border,
						    glby + 2 * appResources.Border,
						    BitmapPad(display), 0);
						if (gbxim) {
							gbxim->bitmap_unit = 32;
							gbxim->bits_per_pixel = 32;
							if (XInitImage(gbxim) == 0) {
		printf("XInitImage failed on globeback window:  bailing.\n");
								XDestroyImage(gbxim);	/* also frees imagegoo */
								gbxim = NULL;
							}
						}
					}
					if (mcxim && (imagegoo = calloc(
					    (mollx + 2 * appResources.Border) * (molly
					     + 2 * appResources.Border), 4)) != NULL) {
						mwpmap = XCreatePixmap(display, window,
						    mollx + 2 * appResources.Border,
						    molly + 2 * appResources.Border, xwa.depth);
						mwgc = XCreateGC(display, mwpmap,
						    GCForeground | GCFunction, &xgcv);
						XFillRectangle(display, mwpmap, mwgc, 0, 0,
						    mollx + 2 * appResources.Border,
						    molly + 2 * appResources.Border);
						mwxim = XCreateImage(display, xwa.visual,
						    xwa.depth, ZPixmap, 0, imagegoo,
						    mollx + 2 * appResources.Border,
						    molly + 2 * appResources.Border,
						    BitmapPad(display), 0);
						if (mwxim) {
							mwxim->bitmap_unit = 32;
							mwxim->bits_per_pixel = 32;
							if (XInitImage(mwxim) == 0) {
		printf("XInitImage failed on Mollweide window:  bailing.\n");
								XDestroyImage(mwxim);	/* also frees imagegoo */
								mwxim = NULL;
							}
						}
					}
				}
			}
		}
	}
}


#ifdef THREADS
/* Comment on threads:  it's taking my laptop at 2.8 GHz about .065s for the
 * Mercator and the Mollweide and a bit more than half that for each globe.
 * Running all four in parallel, if possible, gets us to sub-tenth-second
 * response (plus X stuff) instead of over-0.2s response.
 */
static void *
silly_merc(void *foo)
{
	free(mercdata);
	mercdata = plot_mercator(mercx, mercy, minval, maxval);
	return(NULL);
}

static void *
silly_glbf(void *foo)
{
	free(glbfdata);
	glbfdata = plot_globe(1, glbx, glby, minval, maxval);
	return(NULL);
}

static void *
silly_glbb(void *foo)
{
	free(glbbdata);
	glbbdata = plot_globe(0, glbx, glby, minval, maxval);
	return(NULL);
}

static void *
silly_moll(void *foo)
{
	free(molldata);
	molldata = plot_mollweide(mollx, molly, minval, maxval);
	return(NULL);
}
#endif


void
rebuild_data()
{
#ifdef THREADS
	pthread_t pt1, pt2, pt3;
	int i;
#endif

	if (appResources.tryPixmap) {
		/* We may have changed size */
		if (mercx != dpixw) {
			dpixw = mercx;
#ifdef THREADS
			if (pthread_create(&pt1, NULL, silly_merc, NULL) != 0) {
				warnx("Failed thread 1 create, rebuild_data()");
				silly_merc(NULL);
				pt1 = NULL;
			}
			if (pthread_create(&pt2, NULL, silly_glbf, NULL) != 0) {
				warnx("Failed thread 2 create, rebuild_data()");
				silly_glbf(NULL);
				pt2 = NULL;
			}
			if (pthread_create(&pt3, NULL, silly_glbb, NULL) != 0) {
				warnx("Failed thread 3 create, rebuild_data()");
				silly_glbb(NULL);
				pt3 = NULL;
			}
			/* I'm my own thread too */
			silly_moll(NULL);
			if (pt1) {
				if ((i = pthread_join(pt1, NULL)))
					warn("thread 1 free, rebuild_data()");
			}
			if (pt2) {
				if ((i = pthread_join(pt2, NULL)))
					warn("thread 2 free, rebuild_data()");
			}
			if (pt3) {
				if ((i = pthread_join(pt3, NULL)))
					warn("thread 3 free, rebuild_data()");
			}
#else
			free(mercdata);
			mercdata = plot_mercator(mercx, mercy, minval, maxval);
			free(glbfdata);
			glbfdata = plot_globe(1, glbx, glby, minval, maxval);
			free(glbbdata);
			glbbdata = plot_globe(0, glbx, glby, minval, maxval);
			free(molldata);
			molldata = plot_mollweide(mollx, molly, minval, maxval);
#endif

			if (mwxim)
				XDestroyImage(mwxim);	/* Also frees imagegoo */
			mwxim = NULL;
			XFreeGC(XtDisplay(tl), mwgc);
			XFreePixmap(XtDisplay(tl), mwpmap);
			if (gbxim)
				XDestroyImage(gbxim);	/* Also frees imagegoo */
			gbxim = NULL;
			XFreeGC(XtDisplay(tl), gbgc);
			XFreePixmap(XtDisplay(tl), gbpmap);
			if (gfxim)
				XDestroyImage(gfxim);	/* Also frees imagegoo */
			gfxim = NULL;
			XFreeGC(XtDisplay(tl), gfgc);
			XFreePixmap(XtDisplay(tl), gfpmap);
			if (mcxim)
				XDestroyImage(mcxim);	/* Also frees imagegoo */
			mcxim = NULL;
			XFreeGC(XtDisplay(tl), mcgc);
			XFreePixmap(XtDisplay(tl), mcpmap);
			firstbuild_data();
			draw_merc();
			draw_glbf();
			draw_glbb();
			draw_moll();
		}
	}
}


/* The stupid thing here is that I put in a n-pixel margin on all sides
 * that's not included in nx or ny.  So I have to shift n extra pixels, and
 * then blank the outside.
 */
static void
create_map(Drawable window, GC gc, int nx, int ny, int *dat, XImage *xim)
{
	Display *display;
	XGCValues xgcv;
	XRectangle *xrp;
	int i, j, k, l, kk;

	display = XtDisplay(tl);
	xgcv.foreground = colwhite;
	xgcv.background = colblack;

if (!xim) {
	for (i = 0; i < 256; i++) {
		j = 0;
		for (k = 0; k < nx; k++)
			for (l = 0; l < ny; l++)
				if (dat[k + l * nx] == i)
					j++;
		if (j) {
			if ((xrp = (XRectangle *)malloc(j * sizeof(XRectangle))) == NULL) {
				return;
			}
			j = 0;
			for (k = 0; k < nx; k++)
				for (l = 0; l < ny; l++)
					if (dat[k + l * nx] == i) {
						xrp[j].x = k + appResources.Border;
						xrp[j].y = (ny - 1 - l) + appResources.Border;
						xrp[j].width = 1;
						xrp[j].height = 1;
						j++;
					}
			XSetForeground(display, gc, cmap[i]);
			XFillRectangles(display, window, gc, xrp, j);
			free(xrp);
		}
	}
} else {
	/* Draw right into a ZPixmap XImage. */
	for (j = 0; j < ny; j++) {
		for (i = 0; i < nx; i++) {
			k = dat[j * nx + i];
			kk = (appResources.Border + (ny - j - 1)) * xim->bytes_per_line
			    + (i + appResources.Border) * 4;
			memcpy(xim->data + kk, im_cmap + k, 4);
		}
	}
	/* And zero the boundary; but it's calloc()ed to start, so no need. */
}
}


/* Assumption is that the global array mercdata has already been built from
 * pltdata.
 */
static void
create_mercmap(Drawable window, GC gc)
{
	create_map(window, gc, mercx, mercy, mercdata, mcxim);
}
static void
create_glbfmap(Drawable window, GC gc)
{
	create_map(window, gc, glbx, glby, glbfdata, gfxim);
}
static void
create_glbbmap(Drawable window, GC gc)
{
	create_map(window, gc, glbx, glby, glbbdata, gbxim);
}
static void
create_mollmap(Drawable window, GC gc)
{
	create_map(window, gc, mollx, molly, molldata, mwxim);
}

void
create_title()
{
	Arg wargs[2];
	int n, i;
	char titl[100];

	n= 0;
	i = -log10(fabs(dsets[ds].max[wesa])) + 2;
	if (i < 0)
		i = 0;
	snprintf(titl, sizeof(titl),
	    "%d: %-30s ESA %d (%.*lf - %.*lf) ctr lt lg (%.0lf, %.0lf) [%.0lf]",
	    ds+1, dsets[ds].name, wesa+1, i, dsets[ds].min[wesa], i,
	    dsets[ds].max[wesa], ctrlat, ctrlng, ctrrot);
	XtSetArg(wargs[n], XtNlabel, titl); n++;
	/* XtSetArg(wargs[n], XtNforeground, colwhite); n++; */
     XtSetValues(info, wargs, n);
}
