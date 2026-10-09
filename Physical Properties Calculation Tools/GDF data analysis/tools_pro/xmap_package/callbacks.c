/*	$Id: callbacks.c,v 1.5 2022/02/24 19:27:56 pjanzen Exp $	*/

static const char rcsid[] = "@(#) $Id: callbacks.c,v 1.5 2022/02/24 19:27:56 pjanzen Exp $";

#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xaw/Scrollbar.h>
#include <X11/Xaw/Porthole.h>
#include "DrawingA.h"

#include <limits.h>
#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "xmap.h"
#include "extern.h"

/* Window manager delete */
void
wm_quit(Widget w, XEvent *event, String *params, Cardinal *num_params)
{
	if (event->xclient.data.l[0] == wm_delete_window) {
		if (w == tl)
			injectintobuffer("q\n");
	}
}


void
merc_callback(Widget w, XtPointer closure, XEvent *xev,
    Boolean *dont_touch_this)
{
	/* Sometimes you get a bunch of exposure events all at once.  We only
	 * want to redraw on the last one.  Otherwise it can be a bit slow.
	 *
	 * Note that asking for backing store generates an Expose with a count
	 * of zero separate from anything else.  However, if you're running
	 * backing store you have to ask again every time you resize.
	 */
	if (xev->type == Expose) {
		if (((XExposeEvent *)xev)->count > 0)
			return;
	} else
		warnx("drawmap callback on a non-exposure event (type %d)!",
		    xev->type);
	draw_merc_expose();
}

void
glbf_callback(Widget w, XtPointer closure, XEvent *xev,
    Boolean *dont_touch_this)
{
	/* Sometimes you get a bunch of exposure events all at once.  We only
	 * want to redraw on the last one.  Otherwise it can be a bit slow.
	 *
	 * Note that asking for backing store generates an Expose with a count
	 * of zero separate from anything else.  However, if you're running
	 * backing store you have to ask again every time you resize.
	 */
	if (xev->type == Expose) {
		if (((XExposeEvent *)xev)->count > 0)
			return;
	} else
		warnx("drawmap callback on a non-exposure event (type %d)!",
		    xev->type);
	draw_glbf_expose();
}

void
glbb_callback(Widget w, XtPointer closure, XEvent *xev,
    Boolean *dont_touch_this)
{
	/* Sometimes you get a bunch of exposure events all at once.  We only
	 * want to redraw on the last one.  Otherwise it can be a bit slow.
	 *
	 * Note that asking for backing store generates an Expose with a count
	 * of zero separate from anything else.  However, if you're running
	 * backing store you have to ask again every time you resize.
	 */
	if (xev->type == Expose) {
		if (((XExposeEvent *)xev)->count > 0)
			return;
	} else
		warnx("drawmap callback on a non-exposure event (type %d)!",
		    xev->type);
	draw_glbb_expose();
}

void
moll_callback(Widget w, XtPointer closure, XEvent *xev,
    Boolean *dont_touch_this)
{
	/* Sometimes you get a bunch of exposure events all at once.  We only
	 * want to redraw on the last one.  Otherwise it can be a bit slow.
	 *
	 * Note that asking for backing store generates an Expose with a count
	 * of zero separate from anything else.  However, if you're running
	 * backing store you have to ask again every time you resize.
	 */
	if (xev->type == Expose) {
		if (((XExposeEvent *)xev)->count > 0)
			return;
	} else
		warnx("drawmap callback on a non-exposure event (type %d)!",
		    xev->type);
	draw_moll_expose();
}

void
resiz_callback(Widget w, XtPointer closure, XEvent *xev,
    Boolean *dont_touch_this)
{
	Arg wargs[4];
	int n;
	Dimension ww, hh;

	if (xev->type == ConfigureNotify) {
		/* It's a resize. Get all window new sizes and redraw. */
		n = 0;
		XtSetArg(wargs[n], XtNheight, &hh); n++;
		XtSetArg(wargs[n], XtNwidth, &ww); n++;
		XtGetValues(merc, wargs, n);
		mercx = ww - 2 * appResources.Border;
		mercy = hh - 2 * appResources.Border;
		XtGetValues(glbf, wargs, n);
		glbx = ww - 2 * appResources.Border;
		glby = hh - 2 * appResources.Border;
		XtGetValues(glbb, wargs, n);
		if (glbx > ww - 2 * appResources.Border)
			glbx = ww - 2 * appResources.Border;
		if (glby > hh - 2 * appResources.Border)
			glby = hh - 2 * appResources.Border;
		XtGetValues(moll, wargs, n);
		mollx = ww - 2 * appResources.Border;
		molly = hh - 2 * appResources.Border;
		/* printf("%d %d  /%d %d / %d %d\n", mercx, mercy, glbx, glby,
		 *	  mollx, molly);
		 */
		rebuild_data();

	}
}

void
merc_mousecallback(Widget wi, XtPointer closure, XtPointer data)
{
	XawDrawingAreaCallbackStruct *cbs=(XawDrawingAreaCallbackStruct *)data;
	XEvent *xev = cbs->event;
	XButtonReleasedEvent *xbr;
	double lat, lng;

	/* If it's a keypress, I suppose we have to send it. */
	if (xev->type == KeyPress)
		handle_kbd(xev);
	if (xev->type != ButtonRelease)
		return;
	xbr = (XButtonReleasedEvent *)xev;
	if (xbr->y < appResources.Border || xbr->y >= mercy +appResources.Border ||
	    xbr->x < appResources.Border || xbr->x >= mercx +appResources.Border)
		return;
	lat = 90. - (xbr->y - appResources.Border) / (double)mercy * 180.;
	lng = 180. - (xbr->x - appResources.Border) / (double)mercx * 360.;
	if (appResources.Flip)
		lng = -lng;
	printf("map lat & lng: %.1lf, %.1lf\n", lat, lng);
	if (xbr->button == Button1) {
		printf("That is new map centre.\n");
		/* Simplest way to rotate is directly, about the direction
		 * a x b, by acos(a dot b).  But that rotates N around.
		 * We'll allow for that by having a one-button
		 * "rotate-N-toward-N" keyboard command.
		 */
		pushctr();
		ctrlat -= lat; /* enh? XXX PJ */
		ctrlng += lng;
		ctrrot = 0.;
		/* XXX last arg should be zero if we're legit shifted by the if0
		 * stuff above.  originally was ctrlat = lat.*/
		/* build_rotation(ctrlng, ctrlat, ctrrot, 1); */
		build_rotation(ctrlng, ctrlat, ctrrot, 0, dsets[ds].initrot);
		rebuild_data();
	} else if (xbr->button == Button2) {
		/* PJPJ todo:  build_rotation with final 0 should be the same
		 * place.  And inv_rotation is NOT what we want here. */
		apply_rotation(&lng, &lat);
		printf("true lat & lng: %.1lf, %.1lf\n", lat, lng);
	} else if (xbr->button == Button3) {
		/* PJPJ see comment one case up! */
		apply_rotation(&lng, &lat);
		printf("orbits it could have been:  ");
		/* ignore arcs for now for ease */
		print_nearby_arcs(lat, lng, dsets[ds].firstorbit,
		    dsets[ds].lastorbit, 6., 0);
		printf("\n");
	}
}
