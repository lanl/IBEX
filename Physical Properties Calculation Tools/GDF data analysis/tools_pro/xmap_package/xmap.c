/*	$Id: xmap.c,v 1.7 2022/09/03 03:53:12 pjanzen Exp $	*/

static const char rcsid[] = "@(#) $Id: xmap.c,v 1.7 2022/09/03 03:53:12 pjanzen Exp $";

#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Shell.h>

#include <ctype.h>
#include <err.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "xmap.h"
#include "extern.h"

/* resources specific to us */
static XtResource Resources[] = {
{"mapx", "MapX", XtRInt, sizeof(int),
 XtOffsetOf(struct resources, MapX), XtRImmediate, (XtPointer)600 },
{"mapy", "MapY", XtRInt, sizeof(int),
 XtOffsetOf(struct resources, MapY), XtRImmediate, (XtPointer)300 },
{"border", "Border", XtRInt, sizeof(int),
 XtOffsetOf(struct resources, Border), XtRImmediate, (XtPointer)4 },
{"flip", "Flip", XtRInt, sizeof(int),
 XtOffsetOf(struct resources, Flip), XtRImmediate, (XtPointer)0 },
{"trypixmap", "tryPixmap", XtRInt, sizeof(int), 
 XtOffsetOf(struct resources, tryPixmap), XtRImmediate, (XtPointer)1 },
{"tryximage", "tryXImage", XtRInt, sizeof(int), 
 XtOffsetOf(struct resources, tryXImage), XtRImmediate, (XtPointer)1 },
};


void
usage(FILE *fp)
{
	fprintf(fp,
"usage: xmap [-1] [-r filename] {filename | filename-list}\n\
xmap startarc endarc\n\n");
	fprintf(fp,
	    "\tInput should be an ISOC map file or a set of 5 or 6 ESAs\n\
worth of ISOC map files.\n");
	fprintf(fp, "\tIf two arguments are given, default hi_iso_ofs files are read in using\n\
\tthe arguments as arc limits.\n");
	fprintf(fp,
	    "\t-r filename reads in and processes commands:  the contents of the file\n\
\t\t<filename> are injected directly into the keyboard input\n\
\t\tbuffer at start-up.\n\
\t-1 indicates that initial default hi_iso_ofs input files are actually\n\
\t\tin \"one-degree\" data format.\n");
}


int
main(int argc, char **argv)
{
	int ch;
	char *f, *p;
	XEvent xev;
	int i, j, k, l;

	f = NULL;
	/* GNUisance code.  Kick, scream... */
	if (argc > 1 && !strcmp(argv[1], "--help")) {
		usage(stdout);
		exit(0);
	}
	if (argc > 1 && !strcmp(argv[1], "--version")) {
		printf("%s\n", rcsid);	/* Close enough to a version */
		exit(0);
	}

	rev_vid = 0;
	minval = 0.;
	for (i = 0; i < N_DATASETS; i++) {
		for (j = 0; j < HI_ENERGIES; j++)
			dsets[i].filled[j] = 0;
		dsets[i].name = NULL;
		dsets[i].fnamebase = NULL;
		dsets[i].fnameext = NULL;
		dsets[i].healn = 0;
	}
	set_histfile(NULL, NULL);
	/* Make sure we have a terminal */
	if (!isatty(STDIN_FILENO))
		exit(2);
	/* do X init first, to strip X options off the command line */
	tl = XtOpenApplication(&OurAppContext, "Xloss", NULL, 0,
	    &argc, argv, NULL, sessionShellWidgetClass, NULL, 0);
	XtGetApplicationResources(tl, (XtPointer)&appResources, Resources,
	    XtNumber(Resources), NULL, 0);

	greyscale = 0;
	/* parse command line */
	while ((ch = getopt(argc, argv, "1Ghr:Xx")) != -1)
		switch (ch) {
		case '1':
			defdattype = 2;
			break;
		case 'G':
			greyscale = 1;
			break;
		case 'r':
			free(f);
			f = strdup(optarg);
			break;
		case 'X': /* Not documented */
			showmenu = 0;
			break;
		case 'x':	/* Not documented */
			rev_vid = 1;
			break;
		case 'h':
		default:
			usage(stdout);
			exit(1);
			break;
		}
	argc -= optind;
	argv += optind;

	simple_init_inertialpointing("inertial pointing file unavailable", 0);

	if (argc == HI_ENERGIES || argc == HI_ENERGIES - 1) {
		char *gag[HI_ENERGIES];

		k = HI_ENERGIES - argc;
		for (i = 1; i < HI_ENERGIES; i++)
			gag[i] = argv[i - k];
		if (k)
			gag[0] = NULL;
		else
			gag[0] = argv[0];
		if (populate_data_isoc(gag, 0, 10))
			exit(1);
		nds = 1;
		ds = 0;
		wesa = 3;
		pltdata = dsets[ds].esa[wesa];
		pltnlat = dsets[ds].nbinlat;
		pltnlng = dsets[ds].nbinlng;
		minval = dsets[ds].min[wesa];
		maxval = dsets[ds].max[wesa];
		build_rotation(0, 0., 0., 0, NULL);
		copy_currotm(dsets[ds].initrot);
		/* TODO: give title; default title exists. */
	} else if (argc == 2) {
		/* initial arc, final arc */
		p = argv[0];
		if (sscanf(p, "%d", &i) == 1) {
			while (isdigit(*p))
				p++;
			if (!isspace(*p) && *p)
				k = *p - 'a';
			else
				k = 0;
			p = argv[1];
			if (sscanf(p, "%d", &j) == 1) {
				while (isdigit(*p))
					p++;
				if (!isspace(*p) && *p)
					l = *p - 'a';
				else
					l = 0;
			} else {
				usage(stderr);
				exit(1);
			}
			ds = 0;
			dsets[ds].datatype = defdattype;
			if (build_hist(i, k, j, l, 10, 0, ds))
				exit(1);
			nds = 1;
			wesa = 4;
			pltdata = dsets[ds].esa[wesa];
			pltnlat = dsets[ds].nbinlat;
			pltnlng = dsets[ds].nbinlng;
			minval = dsets[ds].min[wesa];
			maxval = dsets[ds].max[wesa];
			asprintf(&(dsets[ds].name), "Orbits %04d%c - %04d%c [%s]",
			    i, k + 'a', j, l + 'a', dsets[ds].fnameext);
		} else {
			usage(stderr);
			exit(1);
		}
	} else if (argc == 1) {
		/* Load up one map for a whole data set. */
		pltdata = isoc_ingest(argv[0], 10, &pltnlng, &pltnlat, NULL);
		if (pltdata == NULL)
			errx(1, "couldn't read in %s", argv[0]);
		printf("Read in:  %d by %d\n", pltnlng, pltnlat);
		minval = 0.;
		maxval = max_arr(pltdata, pltnlng * pltnlat);
		/* Sigh... fill up a slot with one entry. */
		wesa = 0;
		ds = 0;
		nds = 1;
		dsets[ds].min[wesa] = minval;
		dsets[ds].max[wesa] = maxval;
		dsets[ds].nbinlat = pltnlat;
		dsets[ds].nbinlng = pltnlng;
		dsets[ds].healn = 0;
		for (i = 0; i < HI_ENERGIES; i++)
			dsets[ds].filled[i] = 0;
		dsets[ds].esa[wesa] = pltdata;
		dsets[ds].filled[wesa] = 1;
		build_rotation(0, 0., 0., 0, NULL);
		copy_currotm(dsets[ds].initrot);
		/* There's also a h_title we could use */
		dsets[ds].name = strdup(argv[0]);
	} else {
		usage(stderr);
		exit(1);
	}

	ctrlat = 0.;
	ctrlng = 0.;
	ctrrot = 0.;
	mercx = mollx = appResources.MapX;
	mercy = molly = appResources.MapY;
	/* Extra frames mean the globes must be a little smaller. */
	glbx = glby = appResources.MapY - 7;

	mercdata = plot_mercator(mercx, mercy, minval, maxval);
	glbfdata = plot_globe(1, glbx, glby, minval, maxval);
	glbbdata = plot_globe(0, glbx, glby, minval, maxval);
	molldata = plot_mollweide(mollx, molly, minval, maxval);

	initX();
	init_kbd();
	firstbuild_data();
	draw_merc();
	draw_glbf();
	draw_glbb();
	draw_moll();
	create_title();
	if (f) {
		dumpfileintobuffer(f);
		free(f);
		firstbuild_data();
		draw_merc();
		draw_glbf();
		draw_glbb();
		draw_moll();
	}

	/* Like XtAppMainLoop, but with more stuff to check */
	while(1) {
		XtAppNextEvent(OurAppContext, &xev);
		if (xev.type == KeyPress)
			handle_kbd(&xev);
		else
			XtDispatchEvent(&xev);
	}

	exit(0);
}
