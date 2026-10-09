/*      $Id: menus.c,v 1.5 2022/04/15 02:48:42 pjanzen Exp $     */
/* Top-line menu initialization and callback handling.  Keep menu widgets
 * internal to this file.
 */

static const char rcsid[] = "@(#) $Id: menus.c,v 1.5 2022/04/15 02:48:42 pjanzen Exp $";

#include <X11/X.h>
#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xlib.h>
#include <X11/Core.h>
#include <X11/Shell.h>
#include <X11/Xaw/Form.h>
#include <X11/Xaw/SimpleMenu.h>
#include <X11/Xaw/SmeBSB.h>
#include <X11/Xaw/MenuButton.h>
#include <X11/Xaw/SmeLine.h>

#include <err.h>
#include <stdio.h>

#include "Dialog.h"
#include "extern.h"
#include "xmap.h"

/* Function prototypes no one else need see */
void m_nop(Widget, void *, void *);
void mctr(Widget, void *, void *);
void mrw(Widget, void *, void *);
void mquit(Widget, void *, void *);
void mloadfile(Widget, void *, void *);
void mrunscript(Widget, void *, void *);
void msavefile(Widget, void *, void *);
void mfiledefs(Widget, void *, void *);
static void update_mergemenu(void);
void m_scriptl(Widget, void *, void *);
void m_mapcrap(Widget, void *, void *);

#define N_MENUS (4)
#define N_MEN_MAX (14)

typedef struct {
	char *name;
	/* Item "---" replaced by a line.
	 * "X" indicates unused spots in the list.
	 */
	char *menuitems[N_MEN_MAX];
	/* All callbacks take one argument, which is the list entry number. */
	XtCallbackProc mcallbacks[N_MEN_MAX];
} menstruct;

/* Drop-down menus; I'm keeping the associated Widget arrays
 * menbut, menup, and mentry separate because they can't be initilized
 * here.  This is where all the menu definitions live.
 */
menstruct menus[N_MENUS] = {
{ "File",
  {"---", "Load", "Replace", "Run Script", "Save", "---", "Load Ram Yr",
   "Load AR Yr", "Load Yr", "Load 6 mos", "---", "Defaults", "---", "Quit"},
  {m_nop, mloadfile, mloadfile, mrunscript, msavefile, m_nop, mloadfile,
   mloadfile, mloadfile, mloadfile, m_nop, mfiledefs, m_nop, mquit}
},
{ "Ctr",
  {"---", "Default", "0", "Nose", "Tail", "Ribbon", "Antiribbon", "---",
   "NP Nose", "NP Ribbon", "X", "X", "X", "X"},
  {m_nop, mctr, mctr, mctr, mctr, mctr, mctr, m_nop, mctr, mctr, m_nop, m_nop,
   m_nop, m_nop}
},
/* two spaces at start to leave room for 'x' marks */
{ "Merging",
  {"---", "  Ram+Wake", "  Ram only", "  Wake Only", "---",
   "  arith avg no wt", "  arith avg unc wt", "  geom avg no wt", "---",
   "  drop neg pts", "  keep neg pts", "X", "X", "X"},
  {m_nop, mrw, mrw, mrw, m_nop, mrw, mrw, mrw, m_nop, mrw, mrw, m_nop, m_nop,
   m_nop }
},
{ "Mapping",
  {"---", "Load half year", "Load year", "Load A half", "Load B half",
   "---", "Mercator adj", "Abrate adj", "HEALpix adj", "X", "X", "X", "X", "X"},
  {m_nop, m_scriptl, m_scriptl, m_scriptl, m_scriptl, m_nop, m_mapcrap,
   m_mapcrap, m_mapcrap, m_nop, m_nop, m_nop, m_nop, m_nop }
}
};

Widget menbut[N_MENUS];
Widget menup[N_MENUS];
Widget mentry[N_MENUS][N_MEN_MAX];

/* Menus may require popup windows.  Set up a file dialog (simple, no
 * directory browsing) which also can take any string input,
 * and a Yes/No/Cancel, just in case.
 */
Dialog input_dialog, ync_dialog;

/* --------------------------------------------------------- */
/* Boilerplate below, until the callbacks after init_menus() */
/* --------------------------------------------------------- */

Widget
init_menus(Widget toplevel)
{
	Arg wargs[12];
	int n, i, j;
	char stmp[100];

	/* Not really a menu, but also initialize the dialog boxes we may
	 * need.  Note we can't use the passed argument as the true top level!
	 */
	input_dialog = CreateDialog(tl, "input", Okay | Cancel);
	ync_dialog = CreateDialog(tl, "query", Yes | No | Cancel);
	/* Initialize the menu buttons */
	for (i = 0; i < N_MENUS; i++) {
		n = 0;
		if (rev_vid) {
			XtSetArg(wargs[n], XtNbackground, colwhite); n++;
			XtSetArg(wargs[n], XtNforeground, colblack); n++;
		} else {
			XtSetArg(wargs[n], XtNbackground, colblack); n++;
			XtSetArg(wargs[n], XtNforeground, colwhite); n++;
		}
		XtSetArg(wargs[n], XtNjustify, XtJustifyLeft); n++;
		if (i > 0) {
			XtSetArg(wargs[n], XtNfromHoriz, menbut[i-1]); n++;
		}
		XtSetArg(wargs[n], XtNresize, False); n++;
		XtSetArg(wargs[n], XtNmenuName, menus[i].name); n++;
		XtSetArg(wargs[n], XtNlabel, menus[i].name); n++;
		snprintf(stmp, sizeof(stmp), "menub%d", i+1);
		menbut[i] = XtCreateManagedWidget(stmp, menuButtonWidgetClass,
		    toplevel, wargs, n);
	}

	/* Connect the menu popups */
	for (i = 0; i < N_MENUS; i++) {
		n = 0;
		XtSetArg(wargs[n], XtNlabel, menus[i].name); n++;
		menup[i] = XtCreatePopupShell(menus[i].name, simpleMenuWidgetClass,
		    menbut[i], wargs, n);
	}

	/* Make the individual menus.  Amenable to a for loop, but any fancy
	 * exceptions (e.g., making space for a bitmap at the start) would
	 * need to be done separately.
	 */
	for (i = 0; i < N_MENUS; i++) {
		for (j = 0; j < N_MEN_MAX; j++) {
			if (!strcmp(menus[i].menuitems[j], "---")) {
				mentry[i][j] = XtCreateManagedWidget("line",
				    smeLineObjectClass, menup[i], NULL, 0);
			} else if (strcmp(menus[i].menuitems[j], "X")) {
				/* "X" is just a placeholder */
				mentry[i][j] = XtCreateManagedWidget(menus[i].menuitems[j],
				    smeBSBObjectClass, menup[i], NULL, 0);
				XtAddCallback(mentry[i][j], XtNcallback,
				    menus[i].mcallbacks[j], (void *)j);
			}
		}
	}
	update_mergemenu();
	/* Need to let the remaining widgets know what they're below */
	return(menbut[0]);
}

/* --------------------------------------------------------- */
/* Boilerplate above.  Callbacks below.                      */
/* --------------------------------------------------------- */


void
m_nop(Widget w, void *p1, void *p2)
{
	/* NOP */
	;
	warnx("NOP called");
}

/* 1: default alignment
 * 2: "0"
 * 3: Nose
 * 4: Tail
 * 5: Ribbon
 * 6: Antiribbon
 * 8: NP to nose
 * 9: NP to ribbon centre
 */
void
mctr(Widget w, void *p1, void *p2)
{
	switch((int)p1) {
	case 1:
		/* Not really "default", but might as well put things as McComas
		 * likes to plot
		 */
		printf(">>>TO DO<<<\n");
		break;
	case 2:
		injectintobuffer("%cc0\n", 21);
		break;
	case 3:
		injectintobuffer("%ccn\n", 21);
		break;
	case 4:
		injectintobuffer("%cct\n", 21);
		break;
	case 5:
		injectintobuffer("%ccr\n", 21);
		break;
	case 6:
		injectintobuffer("%ccar\n", 21);
		break;
	case 8:
		injectintobuffer("%cc~n\n", 21);
		break;
	case 9:
		injectintobuffer("%cc~r\n", 21);
		break;
	default:
		warnx("mctr: should not happen");
		break;
	}
}

/* Requires this to be the third menu!  Reset i otherwise. */
static void
update_mergemenu()
{
	Arg wargs[10];
	int n;
	int rw, wstat, noneg, winterp;
	double wbloat;
	int i, j;
	char foo[100];

	get_histflags(&rw, &wstat, &noneg, &winterp, &wbloat);
	i = 2;
	for (j = 0; j < N_MEN_MAX; j++) {
		if (strcmp(menus[i].menuitems[j], "---") &&
		    strcmp(menus[i].menuitems[j], "X")) {
			n = 0;
			snprintf(foo, sizeof(foo), " %s", menus[i].menuitems[j] + 1);
			XtSetArg(wargs[n], XtNlabel, foo); n++;
			XtSetValues(mentry[i][j], wargs, n);
		}
	}
	switch(rw) {
	case 1:
		j = 2;
		break;
	case -1:
		j = 3;
		break;
	default:
		j = 1;
		break;
	}
	n = 0;
	snprintf(foo, sizeof(foo), "*%s", menus[i].menuitems[j] + 1);
	XtSetArg(wargs[n], XtNlabel, foo); n++;
	XtSetValues(mentry[i][j], wargs, n);
	switch(wstat){
	case 1:
		j = 6;
		break;
	case -1:
		j = 7;
		break;
	default:
		j = 5;
		break;
	}
	n = 0;
	snprintf(foo, sizeof(foo), "*%s", menus[i].menuitems[j] + 1);
	XtSetArg(wargs[n], XtNlabel, foo); n++;
	XtSetValues(mentry[i][j], wargs, n);
	if (noneg)
		j = 9;
	else
		j = 10;
	n = 0;
	snprintf(foo, sizeof(foo), "*%s", menus[i].menuitems[j] + 1);
	XtSetArg(wargs[n], XtNlabel, foo); n++;
	XtSetValues(mentry[i][j], wargs, n);
}

/* 1: Ram + wake
 * 2: Ram
 * 3: Wake
 *
 * 5: Unweighted avg
 * 6: Unc weighted avg
 * 7: Unweighted geom avg
 *
 * 9:  drop negative points
 * 10:  keep negative points
 */
void
mrw(Widget w, void *p1, void *p2)
{
	int rw, wstat, dropneg, winterp;
	double wbloat;

	get_histflags(&rw, &wstat, &dropneg, &winterp, &wbloat);
	switch((int)p1) {
	case 1:
		rw = 0;
		break;
	case 2:
		rw = 1;
		break;
	case 3:
		rw = -1;
		break;
	case 5:
		wstat = 0;
		break;
	case 6:
		wstat = 1;
		break;
	case 7:
		wstat = -1;
		break;
	case 9:
		dropneg = 1;
		break;
	case 10:
		dropneg = 0;
		break;
	default:
		warnx("mrw: should not happen");
		break;
	}
	set_histflags(rw, wstat, dropneg, winterp, wbloat);
	/* Update menu list */
	update_mergemenu();
	/* Need to rebuild the data, too.  There's an easy way to do that... */
	injectintobuffer("%cso %d %d %d %d\n", 21, rw, wstat, dropneg, winterp);
}

void
mquit(Widget w, void *p1, void *p2)
{
	injectintobuffer("%cq\n", 21);
}

/* Placeholders */
void
mloadfile(Widget w, void *p1, void *p2)
{
	String filename;

	filename = XtNewString("hoink");
	if (PopupDialog(input_dialog, "File:", filename, &filename,
	    XtGrabExclusive) == Okay) {
		printf("Was okay:  file <%s>\n", filename);
	}
	XtFree(filename);
}

static char *lastscript=NULL;

void
mrunscript(Widget w, void *p1, void *p2)
{
	String filename;
	FILE *fp;

	if (lastscript)
		filename = XtNewString(lastscript);
	else
		filename = XtNewString("");
	if (PopupDialog(input_dialog, "Script to run:", filename, &filename,
	    XtGrabExclusive) == Okay) {
		dumpfileintobuffer(filename);
		/* Sadly, there's no indication of success here.
		 * At least check if there was a file to open...
		 */
		if ((fp = fopen(filename, "r")) == NULL) {
			printf("Could not find %s\n", filename);
			XtFree(filename);
		} else {
			printf("[script completed]\n");
			lastscript = filename;
		}
	} else
		XtFree(filename);
}

void
msavefile(Widget w, void *p1, void *p2)
{
	String filename;

	filename = XtNewString("hoink");
	if (PopupDialog(input_dialog, "Save file basename (ESA appended):",
	    filename, &filename, XtGrabExclusive) == Okay) {
		printf("Was okay:  file <%s>\n", filename);
	}
	XtFree(filename);
}

void
mfiledefs(Widget w, void *p1, void *p2)
{
	printf("TBD\n");
}

/* XXX To add:  common scalings of all maps:
 * XXX              note that my .qABC files are rates, not fluxes, so
 * XXX              there's an efficiency correction to care about too
 */
/* This uses whatever defaults are set for ram/wake, averaging, and file
 * spec.
 */
void
m_scriptl(Widget w, void *p1, void *p2)
{
	double minv, maxv;
	int i, esa;

	switch((int)p1) {
	case 1:
		injectintobuffer("%c%s", 21,
"t 11 34 1\nN 2009A (11-34)\nt 35 58 2\nN 2009B (35-58)\nt 59 82 3\nN 2010A (59-82)\nt 83 106 4\nN 2010B (83-106)\nt 107 130a 5\nN 2011A (107-130a)\nt 130b 150a 6\nN 2011B (130b-150a)\nt 150b 170a 7\nN 2012A (150b-170a)\nt 170b 190b 8\nN 2012B (170b-190b)\nt 191a 210b 9\nN 2013A (191a-210b)\nt 211a 230b 10\nN 2013B (211a-230b)\nt 231a 250b 11\nN 2014A (231a-250b)\nt 251a 270b 12\nN 2014B (251a-270b)\nt 271a 290b 13\nN 2015A (271a-290b)\nt 291a 310b 14\nN 2015B (291a-310b)\nt 311a 330b 15\nN 2016A (311a-330b)\nt 331a 351a 16\nN 2016B (331a-351a)\nt 351b 371a 17\nN 2017A (351b-371a)\nt 371b 391a 18\nN 2017B (371b-391a)\nt 391b 411b 19\nN 2018A (391b-411b)\nt 412a 431b 20\nN 2018B (412a 431b)\nt 432a 451b 21\nN 2019A (432a-451b)\nt 452a 471b 22\nN 2019B (452a-471b)\nt 472a 491b 23\nN 2020A (472a-491b)\nt 492a 511b 24\nN 2020B (492a-511b)\nt 512a 531b 25\nN 2021A (512a-531b)\nt 532a 552a 26\nN 2021B (532a-552a)\n");
		break;
	case 2:
		injectintobuffer("%c%s", 21,
"t 11 58 1\nN 2009 (11-58)\nt 59 106 2\nN 2010 (59-106)\nt 107 150a 3\nN 2011 (107-150a)\nt 150b 190b 4\nN 2012 (150b-190b)\nt 191a 230b 5\nN 2013 (191a-230b)\nt 231a 270b 6\nN 2014 (231a-270b)\nt 271a 310b 7\nN 2015 (271a-310b)\nt 311a 351a 8\nN 2016 (311a-351a)\nt 351b 391a 9\nN 2017 (351b-391a)\nt 391b 431b 10\nN 2018 (391b-431b)\nt 432a 471b 11\nN 2019 (432a-471b)\nt 472a 511b 12\nN 2020 (472a-511b)\nt 512a 552a 13\nN 2021 (512a-552a)\n");
		break;
	case 3:
		injectintobuffer("%c%s", 21,
"t 11 34 1\nN 2009A (11-34)\nt 59 82 2\nN 2010A (59-82)\nt 107 130a 3\nN 2011A (107-130a)\nt 150b 170a 4\nN 2012A (150b-170a)\nt 191a 210b 5\nN 2013A (191a-210b)\nt 231a 250b 6\nN 2014A (231a-250b)\nt 271a 290b 7\nN 2015A (271a-290b)\nt 311a 330b 8\nN 2016A (311a-330b)\nt 351b 371a 9\nN 2017A (351b-371a)\nt 391b 411b 10\nN 2018A (391b-411b)\nt 432a 451b 11\nN 2019A (432a-451b)\nt 472a 491b 12\nN 2020A (472a-491b)\nt 512a 531b 13\nN 2021A (512a-531b)\n");
		break;
	case 4:
		injectintobuffer("%c%s", 21,
"t 35 58 1\nN 2009B (35-58)\nt 83 106 2\nN 2010B (83-106)\nt 130b 150a 3\nN 2011B (130b-150a)\nt 170b 190b 4\nN 2012B (170b-190b)\nt 211a 230b 5\nN 2013B (211a-230b)\nt 251a 270b 6\nN 2014B (251a-270b)\nt 291a 310b 7\nN 2015B (291a-310b)\nt 331a 351a 8\nN 2016B (331a-351a)\nt 371b 391a 9\nN 2017B (371b-391a)\nt 412a 431b 10\nN 2018B (412a 431b)\nt 452a 471b 11\nN 2019B (452a-471b)\nt 492a 511b 12\nN 2020B (492a-511b)\nt 532a 552a 13\nN 2021B (532a-552a)\n");
		break;
	default:
		warnx("m_scriptl: should not happen");
		break;
	}
	if ((int)p1 >= 1 && (int)p1 <= 4) {
		/* scale it all... */
		for (esa = 0; esa < HI_ENERGIES; esa++) {
			minv = 1e99;
			maxv = -1e99;
			for (i = 0; i <= ((int)p1 == 2 ? 26:13); i++)
				if (dsets[i].filled[esa]) {
					if (dsets[i].min[esa] < minv)
						minv = dsets[i].min[esa];
					if (dsets[i].max[esa] > maxv)
						maxv = dsets[i].max[esa];
				}
			if (minv > maxv) {
				minv = maxv = 0.;
			}
			for (i = 0; i <= ((int)p1 == 2 ? 26:13); i++) {
				dsets[i].min[esa] = minv;
				dsets[i].max[esa] = maxv;
			}
			if (i == wesa) {
				minval = minv;
				maxval = maxv;
			}
		}
		rebuild_data();
		create_title();
	}
}

void
m_mapcrap(Widget w, void *p1, void *p2)
{
	printf("TBD\n");
}
