/*	$Id: kbd.c,v 1.25 2022/09/03 03:53:12 pjanzen Exp $	*/

static const char rcsid[] = "@(#) $Id: kbd.c,v 1.25 2022/09/03 03:53:12 pjanzen Exp $";

#include <sys/types.h>
#include <ctype.h>
#include <dirent.h>
#include <err.h>
#include <fnmatch.h>
#include <libgen.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <curses.h>
#include <term.h>
#include <time.h>

#include "xmap.h"
#include "extern.h"

#define OUT_LEN (1024)

static char *kbd_delch, *kbd_golft;
static char kbdbuf[OUT_LEN];
static int  kbdn = 0;

static void cinbuf(char);

static void kbd_dc(void);
static void kbd_dl(void);

static void
kbd_dc()
{
	putp(kbd_golft);
	putp(kbd_delch);
}

static void
kbd_dl()
{
	int i;

	/* Okay, so it is NOT efficient */
	for (i = 0; i < kbdn; i++)
		kbd_dc();
}

static int
f_foo_sort(const void *a, const void *b)
{
	return(strcmp(*(char **)a, *(char **)b));
}

void
injectintobuffer(const char *fmt, ...)
{
	int  i, l;
	char *str;
	va_list ap;

	va_start(ap, fmt);
	l = vasprintf(&str, fmt, ap);
	va_end(ap);
	if (str == NULL)
		errx(1, "asprintf, injectintobuffer()");
	for (i = 0; i < l; i++)
		cinbuf(str[i]);
	free(str);
	fflush(stdout);
}

void
dumpfileintobuffer(const char *fname)
{
	FILE *fp;
	int i;

	if ((fp = fopen(fname, "r")) == NULL)
		return;
	while ((i = fgetc(fp)) != EOF)
		cinbuf((char)i);
	fclose(fp);
}


static void
cinbuf(char c)
{
	int i;

	/* Special characters: delete and backspace are the same, ^U erases
	 * line, and ^W erases word.  ^R refreshes line.
	 * We don't do cursoring.  Sue me.
	 */
	switch(c) {
	case 8:	/* ^H */
	case 0x7F:	/* del */
		if (kbdn) {
			kbdn--;
			kbd_dc();
		}
		break;
	case 18:	/* ^R */
		if (kbdn) {
			int i;
			/* printf("^R\n"); */
			for (i = 0; i < kbdn; i++)
				putchar(kbdbuf[i]);
		}
		break;
	case 21:	/* ^U */
		if (kbdn) {
			kbd_dl();
			kbdn = 0;
		}
		break;
	case 23:	/* ^W */
		while (kbdn && !isspace(kbdbuf[--kbdn]))
			kbd_dc();
		kbd_dc();
		break;
	case 13:	/* return */
	case 10:	/* linefeed */
		putchar('\n');
		kbdparse();
		break;
	case 'A': /* autoscale */
	case '<': /* scale less */
	case '>': /* scale more */
	case '0': /* default rotation */
	case 'Z': /* flip colour map */
	case '^': /* rotate north UP */
	/* Earlier I may have thought of something else I wanted
	 * with the arrow keys, but for now they'll rotate the map.
	 * Save HJKL for swapping ESAs and stored sets of maps.
	 *
	 * Note:  shifting goes by the last pltnlat or pltnlng, which may or
	 * may not be sensible once HEALpix are on screen.
	 */
	case 'h': /* one bin left */
	case 'j': /* one bin down */
	case 'k': /* one bin up */
	case 'l': /* one bin right */
	case 'H': /* previous map */
	case 'J': /* one ESA down */
	case 'K': /* one ESA up */
	case 'L': /* next map */
	case 'u': /* rotate one way */
	case 'n': /* rotate the other way */
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '[': /* Heh.  This is the shit. */
	case ']':
		if (kbdn == 0) {
			if (c == '0') {
				ctrlat = 0.;
				ctrlng = 0.;
				ctrrot = 0.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'Z') {
				int itmp;
				uint32_t jtmp;
				for (i = 0; i < 256; i++) {
					itmp = cmap[i];
					cmap[i] = ocmap[i];
					ocmap[i] = itmp;
					jtmp = im_cmap[i];
					im_cmap[i] = im_ocmap[i];
					im_ocmap[i] = jtmp;
				}
				/* rebuild_data() is slower */
				draw_merc();
				draw_glbf();
				draw_glbb();
				draw_moll();
			} else if (c == '^') {
				ctrrot = 0.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'h') {
				ctrlng -= (360. / pltnlng);
				if (ctrlng < 0)
					ctrlng += 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'l') {
				ctrlng += (360. / pltnlng);
				if (ctrlng > 360.)
					ctrlng -= 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'k') {
				ctrlat -= (180. / pltnlat);
				if (ctrlat < -180.)
					ctrlat += 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'j') {
				ctrlat += (180. / pltnlat);
				if (ctrlat > 180.)
					ctrlat -= 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'u') {
				ctrrot += (180. / pltnlat);
				if (ctrrot > 180.)
					ctrrot -= 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'n') {
				ctrrot -= (180. / pltnlat);
				if (ctrrot < -180.)
					ctrrot += 360.;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == '[' || c == ']') {
				/* Hmm; we should preserve scaling and rescale only on
				 * request.
				 */
				int j, fo, fa, lo, la;
				double mm, mx;

				if (dsets[ds].firstorbit > 5 && dsets[ds].lastorbit > 5) {
					j = get_arcs_per_orbit(dsets[ds].firstorbit);
					mm = minval;
					mx = maxval;
					if (c == ']') {
						if (j <= 1 || dsets[ds].firstarc + 1 == j) {
							fo = dsets[ds].firstorbit + 1;
							fa = 0;
						} else {
							fo = dsets[ds].firstorbit;
							fa = dsets[ds].firstarc + 1;
						}
					} else {
						if (j <= 1 || dsets[ds].firstarc == 0) {
							fo = dsets[ds].firstorbit - 1;
							fa = get_arcs_per_orbit(fo) - 1;
							if (fo < 1)
								fo = 1;
						} else {
							fo = dsets[ds].firstorbit;
							fa = dsets[ds].firstarc - 1;
						}
					}
					j = get_arcs_per_orbit(dsets[ds].lastorbit);
					if (c == ']') {
						if (j <= 1 || dsets[ds].lastarc + 1 == j) {
							lo = dsets[ds].lastorbit + 1;
							la = 0;
						} else {
							lo = dsets[ds].lastorbit;
							la = dsets[ds].lastarc + 1;
						}
					} else {
						if (j <= 1 || dsets[ds].lastarc == 0) {
							lo = dsets[ds].lastorbit - 1;
							la = get_arcs_per_orbit(lo) - 1;
							if (lo < fo)
								lo = fo;
						} else {
							lo = dsets[ds].lastorbit;
							la = dsets[ds].lastarc - 1;
						}
					}

					if (build_hist(fo, fa, lo, la, 10, 0, ds) == 0) {
						pltdata = dsets[ds].esa[wesa];
						pltnlat = dsets[ds].nbinlat;
						pltnlng = dsets[ds].nbinlng;
						minval = mm;
						maxval = mx;
						dsets[ds].min[wesa] = mm;
						dsets[ds].max[wesa] = mx;
						healzn = dsets[ds].healn;
						asprintf(&(dsets[ds].name),
						    "Orbits %04d%c - %04d%c [%s]",
						    fo, fa + 'a', lo, la + 'a',
						    dsets[ds].fnameext);
						build_rotation(ctrlng, ctrlat, ctrrot, 0,
						    dsets[ds].initrot);
						rebuild_data();
						create_title();
					} else
						/* Data wasn't changed */
						printf("...at edge of inertial_pointing data\n");
				}
			} else if (c == 'H') {
				/* interesting:  when ramping around, only ramp to
				 * other data sets that have the same ESA.  So you
				 * could get stranded with ESA 1...
				 */
				do {
					ds--;
					if (ds < 0)
						ds = nds - 1;
				} while (dsets[ds].filled[wesa] == 0);
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'L') {
				do {
					ds++;
					if (ds >= nds)
						ds = 0;
				} while (dsets[ds].filled[wesa] == 0);
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'J') {
				do {
					wesa--;
					if (wesa < 0)
						wesa = HI_ENERGIES - 1;
				} while (dsets[ds].filled[wesa] == 0);
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c == 'K') {
				do {
					wesa++;
					if (wesa >= HI_ENERGIES)
						wesa = 0;
				} while (dsets[ds].filled[wesa] == 0);
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else if (c >= '1' && c <= '6') {
				if (dsets[ds].filled[(c - '1')]) {
					wesa = c - '1';
					pltdata = dsets[ds].esa[wesa];
					pltnlat = dsets[ds].nbinlat;
					pltnlng = dsets[ds].nbinlng;
					minval = dsets[ds].min[wesa];
					maxval = dsets[ds].max[wesa];
					healzn = dsets[ds].healn;
					build_rotation(ctrlng, ctrlat, ctrrot, 0,
					    dsets[ds].initrot);
					rebuild_data();
					create_title();
				} else
					beep();
			} else { /* 'A', '>', '<' */
				/* PJ XXX Really want this to be fast.  If I do a
				 * rebuild_data() then it's slow.  To fix.
				 */
				minval = 0.;
				if (c == 'A')
					maxval = max_arr(pltdata, healzn ?
					    12 * healzn * healzn : pltnlng * pltnlat);
				else if (c == '>')
					maxval *= 1.05;
				else if (c == '<')
					maxval /= 1.05;
				dsets[ds].min[wesa] = minval;
				dsets[ds].max[wesa] = maxval;
				rebuild_data();
				create_title();
			}
			break;
		}
		/* else fall through */
	default:
		if (isprint(c) && (kbdn + 1 < OUT_LEN)) {
			putchar(c);
			kbdbuf[kbdn++] = c;
		} else {
			fputc(7, stderr);	/* Ring bell */
			/* printf("--char was %d\n", c); */
		}
		break;
	}
}


void
handle_kbd(XEvent *xev)
{
	char stuph[10];
	int n;

	n = XLookupString((XKeyEvent *)xev, stuph, 9, NULL, NULL);
	stuph[n] = '\0';
	injectintobuffer("%s", stuph);
}


void
Xreadkbd(XtPointer unused, int *source, XtInputId *id)
{
	char stuph[100];    /* That's all we will buffer */
	ssize_t got;

	got = read(STDIN_FILENO, stuph, 99);
	stuph[got] = '\0';
	injectintobuffer("%s", stuph);
}


void
init_kbd()
{
	if (atexit(tty_atexit))
		errx(1, "atexit");
	tty_cbreak(STDIN_FILENO);
	if (signal(SIGTSTP, tty_suspend_interrupt) == SIG_ERR)
		err(1, "SIGTSTP");
	if (signal(SIGINT, tty_quit_interrupt) == SIG_ERR)
		err(1, "SIGINT");
	if (signal(SIGQUIT, tty_quit_interrupt) == SIG_ERR)
		err(1, "SIGQUIT");
	if (signal(SIGTERM, tty_quit_interrupt) == SIG_ERR)
		err(1, "SIGTERM");
	/* The following isn't really kbd, but rather tty.  Oh well */
	setupterm(NULL, STDOUT_FILENO, NULL);
	kbd_delch = tigetstr("dch1");
/*	kbd_delln = tigetstr("dl1"); */
	kbd_golft = tigetstr("cub1");
}

void
kbdparse()
{
	int i, j, k, l, m, ii;
	float t1, t2;
	double tmp1, tmp2;
	char p[1024], q[1024];
	int initarc, initorb, lastorb, lastarc;

	kbdbuf[kbdn] = '\0';
	switch (kbdbuf[0]) {
	case 'b':
		if (sscanf(kbdbuf + 1, "%d", &i) == 1 && i >= 0 && i < 20) {
			j = 2 * (i - appResources.Border);
			mercx -= j;
			mercy -= j;
			glbx -= j;
			glby -= j;
			mollx -= j;
			molly -= j;
			appResources.Border = i;
			/* This slightly shifts scaling, but such is life. */
			rebuild_data();
		} else
			printf("buh?\n");
		break;
	case 'c':	/* centre on stuff */
		ii = 1;
		if (kbdbuf[1] == 'r') {	/* ribbon */
			/* McComas 2020 paper centre */
			ctrlng = 219.2;
			ctrlat = 39.9;
			ii = 0;
		} else if (kbdbuf[1] == 'n') {	/* nose */
			/* McComas 2020 paper nose */
			ctrlng = 255.7;
			ctrlat = 5.1;
			ii = 0;
		} else if (kbdbuf[1] == 't') {	/* tail */
			/* McComas 2020 paper nose */
			ctrlng = 255.7 - 180.;
			ctrlat = -5.1;
			ii = 0;
		} else if (kbdbuf[1] == 'a' && kbdbuf[2] == 'r') { /* antiribbon */
			/* McComas 2020 paper centre */
			ctrlng = 219.2 - 180.;
			ctrlat = -39.9;
			ii = 0;
		} else if (kbdbuf[1] == '0') {	/* (0,0) */
			ctrlng = 0.;
			ctrlat = 0.;
			ctrrot = 0.;
			ii = 0;
		} else if (kbdbuf[1] == '~') {
			if (kbdbuf[2] == 'n') {	/* North pole is nose */
				ctrlng = 255.7;
				ctrlat = -85.0;
				ii = 0;
			} else if (kbdbuf[2] == 'r') { /* North pole is ribbon centre */
				ctrlng = 219.2;
				ctrlat = -50.1;
				ii = 0;
			}
		} else if (sscanf(kbdbuf + 1, "%lf,%lf", &tmp1, &tmp2) == 2) {
			ctrlng = tmp2;
			ctrlat = tmp1;
			ii = 0;
		} else
			printf("centre {[a]nti[r]ibbon|[r]ibbon|[n]ose|[t]ail|[0]},\n\
      or lat,long (with no leading zero); c~[nr] to put nose or ribbon at N\n");
		if (!ii) {
			build_rotation(ctrlng, ctrlat, ctrrot, 0, dsets[ds].initrot);
			rebuild_data();
			create_title();
		}
		break;
	case 'd':
		j = 1;
		while (isspace(kbdbuf[j]))
			j++;
		if (kbdbuf[j] == '\0')
			printf("d dumpbase\n");
		else if ((k = dump_currentdata(kbdbuf + j, ds)))
			printf("Dumped:  error %d\n", k);
		else
			printf("Dumped.\n");
		break;
	case 'e':
		j = 1;
		while (isspace(kbdbuf[j]))
			j++;
		if (!j)
			printf("e loadspec\n");
		else {
			char *pp, *qq;
			DIR *dirp;
			struct dirent *dp;
			char *filez[HI_ENERGIES];

			m = nds % N_DATASETS;
			if (nds < N_DATASETS)
				nds++;
			clear_hist(m);
			/* XXX portability:  some implementations of dirname()
			 * and basename() overwrite the string passed to it.
			 */
			pp = dirname(kbdbuf + j);
			qq = basename(kbdbuf + j);
			j = 0;
			dirp = opendir(pp);
			if (dirp) {
				while ((dp = readdir(dirp)) != NULL)
					if (fnmatch(qq, dp->d_name, 0) == 0)
						if (j < HI_ENERGIES) {
							filez[j] = strdup(dp->d_name);
							j++;
						}
				closedir(dirp);
			}
			if (j > 0) {
				/* Hah. */
				qsort(filez, j, sizeof(char *), f_foo_sort);
				for (k = j; k < HI_ENERGIES; k++)
					filez[k] = NULL;
				if (j == 5) {
					/* assume no ESA 1 */
					for (k = HI_ENERGIES-1; k > 0; k--)
						filez[k] = filez[k-1];
					filez[0] = NULL;
				}
				for (k = 0; k < HI_ENERGIES; k++)
					if (filez[k]) {
						qq = filez[k];
						asprintf(filez + k, "%s/%s", pp, qq);
						free(qq);
					}
				if (populate_data_isoc(filez, m, 10) == 0) {
					ds = m;
					if (!dsets[ds].filled[wesa]) {
						wesa = 0;
						while (!dsets[ds].filled[wesa] &&
						    wesa < HI_ENERGIES)
							wesa++;
						/* for populate_data_isoc() to have
						 * succeeded, at least one of the data sets
						 * is filled.  Could confirm wesa < * HI_ENERGIES,
						 * I guess.
						 */
					}
					pltdata = dsets[ds].esa[wesa];
					pltnlat = dsets[ds].nbinlat;
					pltnlng = dsets[ds].nbinlng;
					minval = dsets[ds].min[wesa];
					maxval = dsets[ds].max[wesa];
					healzn = dsets[ds].healn;
					build_rotation(ctrlng, ctrlat, ctrrot, 0,
					    dsets[ds].initrot);
					rebuild_data();
					create_title();
				} else {
					printf("failed to load:\n");
					for (k = 0; k < HI_ENERGIES; k++)
						if (filez[k])
							printf("\t%d %s\n", k+1, filez[k]);
				}
			} else
				printf("couldn't populate.\n");
		}
		break;
	case 'g':
		if (sscanf(kbdbuf + 1, "%d", &k) == 1 && k > 0 && k <= nds) {
			k--;
			if (!dsets[k].filled[wesa]) {
				wesa = 0;
				while (!dsets[k].filled[wesa] && wesa < HI_ENERGIES)
					wesa++;
			}
			if (wesa < HI_ENERGIES) {
				ds = k;
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
			} else
				printf("can't go to that NULL data set.\n");
		} else
			printf("can't go to that data set.\n");
		break;
	case 'N':
		j = 1;
		while (isspace(kbdbuf[j]))
			j++;
		if (kbdbuf[j]) {
			free(dsets[ds].name);
			dsets[ds].name = strdup(kbdbuf + j);
			create_title();
		} else
			printf("N newtitle (of currently displayed map set)\n");
		break;
	case 'P':
		if (kbdbuf[1] == 'P') {
			showdraw = !showdraw;
			if (showdraw) {
				printf("<normal refresh>\n");
				rebuild_data();
			} else
				printf("<not refreshing screen>\n");
		} else if (sscanf(kbdbuf + 1, "%lf", &tmp1) == 1 && tmp1 > 0.) {
			struct timespec pausefoo;

			pausefoo.tv_sec = (int) tmp1;
			pausefoo.tv_nsec = (long)(fmod(tmp1, 1.) * 1e9);
			j = nanosleep(&pausefoo, NULL);
		} else
			printf("P seconds-to-pause (floating point)\n");
		break;
	case 'p':
		printf("%d set%s loaded; set %d onscreen:\n", nds,
		    nds > 1 ? "s":"", ds+1);
		for (i = 0; i < nds; i++) {
			printf("\nSet %d: <%s>\n", i+1, dsets[i].name);
			printf("\tOrbits %04d%c - %04d%c\n", dsets[i].firstorbit,
			    (dsets[i].firstorbit > 0 && dsets[i].firstarc >= 0)?
			    ('a' + dsets[i].firstarc):' ', dsets[i].lastorbit,
			    (dsets[i].lastorbit > 0 && dsets[i].lastarc >= 0)?
			    ('a' + dsets[i].lastarc):' ');
			printf("\tPopulated: ");
			for (j = 0; j < HI_ENERGIES; j++) {
				if (dsets[i].filled[j])
					printf("%d", j+1);
				else
					printf("-");
			}
			printf("\n\t\t[[ %.2lf %.2lf %.2lf ]\n",
			    dsets[i].initrot[0][0], dsets[i].initrot[0][1],
			    dsets[i].initrot[0][2]);
			printf("\t\t [ %.2lf %.2lf %.2lf ]\n",
			    dsets[i].initrot[1][0], dsets[i].initrot[1][1],
			    dsets[i].initrot[1][2]);
			printf("\t\t [ %.2lf %.2lf %.2lf ]]\n",
			    dsets[i].initrot[2][0], dsets[i].initrot[2][1],
			    dsets[i].initrot[2][2]);
		}
		break;
	case 'q':
		exit(0);
		break;
	case 'R':	/* Set colourbar limits to current map */
		/* No harm doing this even for unloaded map sets */
		for (i = 0; i < nds; i++) {
			dsets[i].min[wesa] = minval;
			dsets[i].max[wesa] = maxval;
		}
		printf("All loaded ESA %d maps set to current colourbar.\n",
		    wesa + 1);
		break;
	case 'r':
		if (sscanf(kbdbuf + 1, "%f%f", &t1, &t2) == 2 && t2 > t1) {
			minval = t1;
			maxval = t2;
			dsets[ds].min[wesa] = minval;
			dsets[ds].max[wesa] = maxval;
			/* Not the fastest way to rescale. */
			rebuild_data();
			create_title();
		} else {
			i = 1;
			while (isspace(kbdbuf[i]))
				i++;
			if (kbdbuf[i] == '?')
				printf("Range: %.2lf - %.2lf\n", minval, maxval);
			else
				printf("huh?\n");
		}
		break;
	case 's':
		j = 1;
		k = 0;
		while (isspace(kbdbuf[j]))
			j++;
		if (kbdbuf[j] == 'f') {
			j++;
			if (sscanf(kbdbuf + j, "%1023s%1023s", p, q) != 2) {
				printf("Resetting path specs to default.\n");
				set_histfile(NULL, NULL);
			} else {
				printf("Setting path specs.\n");
				set_histfile(p, q);
			}
		} else if (kbdbuf[j] == 'F') {
			j++;
			if (sscanf(kbdbuf + j, "%d%d", &i, &k) != 1 ||
			    (i != 1 && i != 6)) {
				printf("usage: sF [1|6]\n");
			} else {
				if (i == 1) {
					printf("Set default to 1-deg files.\n");
					defdattype = 2;
				} else {
					printf("Set default to 6-deg files.\n");
					defdattype = 0;
				}
			}
			k = 0;
		} else if (kbdbuf[j] == 'b') {
			j++;
			if (sscanf(kbdbuf + j, "%d%d%lf%lf", &i, &k, &tmp1, &tmp2)
			    != 4) {
				printf("usage: sb number-of-long-bins number-of-lat-bins NP-long NP-lat\n");
			} else {
				printf("Setting binning specs.\n");
				set_histbins(i, k, tmp1, tmp2);
				k = 1;
			}
		} else if (kbdbuf[j] == 'h') {
			j++;
			if (sscanf(kbdbuf + j, "%d%d", &i, &k) != 1 || i < -1 ||
			    i > 16) {
				printf("usage: sh n_side (1-16)\n");
			} else {
				printf("%s HEALpix option.\n", i ? "Setting":"Clearing");
				set_histheal(i);
				k = 1;
			}
		} else if (kbdbuf[j] == 'a') {
			j++;
			if (sscanf(kbdbuf + j, "%d%d", &i, &k) != 1 ||
			    (i < 200 && i != 0) || i > 10000) {
				printf("usage: sa n_pixel (200-10000)\n");
			} else {
				printf("%s Abratepix option.\n", i ? "Setting":"Clearing");
				set_histabrate(i);
				k = 1;
			}
		} else if (kbdbuf[j] == 'o') {
			j++;
			if (sscanf(kbdbuf + j, "%d%d%d%d", &i, &k, &l, &m) != 4) {
				printf("usage: so ramwake statsum dropneg interp\n");
			} else {
				printf("Setting binning options.\n");
				/* For now, interp of 1 means use ISOC binning.
				 * Set the bloat to 7.0 degrees and don't make it
				 * user adjustable yet.
				 */
				if (m == 1)
					set_histflags(i, k, l, m, 7.);
				else
					set_histflags(i, k, l, m, -1.);
				k = 1;
			}
		} else if (kbdbuf[j] != '?')
			printf("buh?\n");
		if (k == 1) {	/* rebuild on changing map projection */
			char *pp;

			pp = strdup(dsets[ds].name);
			if (build_hist(dsets[ds].firstorbit, dsets[ds].firstarc,
			    dsets[ds].lastorbit, dsets[ds].lastarc, 0, 0, ds) == 0) {
				/* todo initrot[][] */
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				dsets[ds].name = pp;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
			}
		}
		print_histspecs(-1);
		break;
	case 't':
		j = 1;
		while (isspace(kbdbuf[j]))
			j++;
		if (sscanf(kbdbuf + j, "%d", &initorb) == 1) {
			while (isdigit(kbdbuf[j]))
				j++;
			if (!isspace(kbdbuf[j]) && kbdbuf[j]) {
				initarc = kbdbuf[j] - 'a';
				j++;
			} else
				initarc = 0;
			while (isspace(kbdbuf[j]))
				j++;
			if (sscanf(kbdbuf + j, "%d", &lastorb) == 1) {
				while (isdigit(kbdbuf[j]))
					j++;
				if (!isspace(kbdbuf[j]) && kbdbuf[j]) {
					lastarc = kbdbuf[j] - 'a';
					j++;
				} else
					lastarc = 0;
				while (isspace(kbdbuf[j]))
					j++;
				if (sscanf(kbdbuf + j, "%d", &m) == 1) {
					m--;
					if (m < 0 || m >= N_DATASETS) {
						m = nds % N_DATASETS;
						if (nds < N_DATASETS)
							nds++;
						printf("invalid choice of data slot; using %d.\n", m);
					} else {
						if (m >= nds)
							nds = m + 1;
					}
				} else {
					m = nds % N_DATASETS;
					if (nds < N_DATASETS)
						nds++;
				}
				clear_hist(m);

				dsets[m].datatype = defdattype;
				if (build_hist(initorb, initarc, lastorb, lastarc, 10,
				    0, m) == 0) {
					asprintf(&(dsets[m].name), "Orbits %04d%c - %04d%c [%s]",
					    initorb, initarc + 'a', lastorb, lastarc + 'a',
					    dsets[m].fnameext);
					/* todo initrot[][] */
					ds = m;
					pltdata = dsets[ds].esa[wesa];
					pltnlat = dsets[ds].nbinlat;
					pltnlng = dsets[ds].nbinlng;
					minval = dsets[ds].min[wesa];
					maxval = dsets[ds].max[wesa];
					healzn = dsets[ds].healn;
					build_rotation(ctrlng, ctrlat, ctrrot, 0,
					    dsets[ds].initrot);
					rebuild_data();
					create_title();
				} else
					printf(
"Didn't have sufficient inertial_pointing data to create requested map.\n");
			} else
				printf("urgh?\n");
		} else
			printf("ungh?\n");
		break;
	case 'U':
		if (popctr()) {
			build_rotation(ctrlng, ctrlat, ctrrot, 0, dsets[ds].initrot);
			rebuild_data();
		} else
			printf("can't undo.\n");
		break;
	case '`':
		print_currot();
		break;
	case '/':	/* ratio maps! */
	case '-':	/* subtracted maps */
		if (sscanf(kbdbuf + 1, "%d%d%d", &i, &j, &k) == 3 &&
		    i > 0 && i <= N_DATASETS &&
		    j > 0 && j <= N_DATASETS && j != i &&
		    k > 0 && k <= N_DATASETS && k != i && k != j) {
			i--;
			j--;
			k--;
			if (maps_compatible(i, j) == 0) {
				clear_hist(k);
				if (k >= nds)
					nds = k + 1;
				if (kbdbuf[0] == '/')
					asprintf(&(dsets[k].name), "Ratio of maps: %d/%d",
					    i+1, j+1);
				else
					asprintf(&(dsets[k].name),
					    "Difference of maps: %d - %d", i+1, j+1);
				dsets[k].healn = dsets[i].healn;
				dsets[k].nbinlat = dsets[i].nbinlat;
				dsets[k].nbinlng = dsets[i].nbinlng;
				dsets[k].firstorbit = dsets[i].firstorbit;
				if (dsets[j].firstorbit < dsets[k].firstorbit) {
					dsets[k].firstorbit = dsets[j].firstorbit;
					dsets[k].firstarc = dsets[j].firstarc;
				} else
					dsets[k].firstarc = dsets[i].firstarc;
				dsets[k].lastorbit = dsets[i].lastorbit;
				if (dsets[j].lastorbit > dsets[k].lastorbit) {
					dsets[k].lastorbit = dsets[j].lastorbit;
					dsets[k].lastarc = dsets[j].lastarc;
				} else
					dsets[k].lastarc = dsets[i].lastarc;
				for (l = 0; l < 3; l++)
					for (m = 0; m < 3; m++)
						dsets[k].initrot[l][m] = dsets[i].initrot[l][m];
				if (dsets[k].healn)
					m = dsets[k].healn * dsets[k].healn * 12;
				else
					m = dsets[k].nbinlat * dsets[k].nbinlng;
				for (ii = 0; ii < HI_ENERGIES; ii++) {
					if (dsets[i].filled[ii] && dsets[j].filled[ii]) {
						if ((dsets[k].esa[ii] = (double *)calloc(m,
						    sizeof(double))) == NULL)
							err(1, "calloc()");
						if (kbdbuf[0] == '/') {
							for (l = 0; l < m; l++)
								/* choice of threshold? */
								if (fabs((dsets[j].esa[ii])[l]) > 1e-3)
									(dsets[k].esa[ii])[l] =
									    (dsets[i].esa[ii])[l] /
									    (dsets[j].esa[ii])[l];
								else
									(dsets[k].esa[ii])[l] = 1.;
									/* XXX makes sense for ratio map? */
						} else {
							for (l = 0; l < m; l++)
								/* XXX include only if BOTH nonzero */
								if ((dsets[j].esa[ii])[l] != 0. &&
								    (dsets[i].esa[ii])[l] != 0.)
									(dsets[k].esa[ii])[l] =
									    (dsets[i].esa[ii])[l] -
									    (dsets[j].esa[ii])[l];
								else
									(dsets[k].esa[ii])[l] = 0.;
						}
						dsets[k].filled[ii] = 1;
					} else
						dsets[k].filled[ii] = 0;
				}
				for (ii = 0; ii < HI_ENERGIES; ii++) {
					if (dsets[k].filled[ii]) {
						dsets[k].min[ii] = min_arr(dsets[k].esa[ii], m);
						dsets[k].max[ii] = max_arr(dsets[k].esa[ii], m);
					}
				}
				ds = k;
				pltdata = dsets[ds].esa[wesa];
				pltnlat = dsets[ds].nbinlat;
				pltnlng = dsets[ds].nbinlng;
				minval = dsets[ds].min[wesa];
				maxval = dsets[ds].max[wesa];
				healzn = dsets[ds].healn;
				build_rotation(ctrlng, ctrlat, ctrrot, 0,
				    dsets[ds].initrot);
				rebuild_data();
				create_title();
				printf("Hope you like your fancy map.\n");
			} else
				printf("Oops:  ratio map inputs do not share pixels.\n");
		} else
			printf("%cmap1 map2 map3 to make map3 = map1 %c map2\n",
			    kbdbuf[0], kbdbuf[0]);
		break;
	case '?':
		printf("Commands:\n\
Mouse (in Mercator):\n\
    Left:  centre data at given point\n\
    Middle:  print more information on given location\n\
    Right:  print what orbit arcs might be at given location\n\
\n\
Keyboard:\n\
  Instant:\n\
    A     : autoscale\n\
    <, >  : scale less/more\n\
    0     : default map alignment\n\
    1 - 6 : display ESA 1-6 in current data set\n\
    ^     : rotate north upward from centre\n\
    h, l  : rotate left/right in longitude\n\
    j, k  : rotate down/up in latitude\n\
    u, n  : rotate in the remaining axis\n\
    H, L  : rotate through loaded maps\n\
    J, K  : rotate through ESAs\n\
    [, ]  : change currently loaded dataset to one orbit/arc earlier/later\n\
    Z     : play with colormaps for no good reason\n\
  Need <Enter>:\n\
    b border   : set the number of black border pixels\n\
    c[ar|n|r|t]: set centre of map to antiribbon, nose, ribbon, or tail\n\
                 c0 resets to lat, long = 0.  c~[nr] sets the North Pole to\n\
                 nose or ribbon centre.\n\
    c lat,long : set centre of map to (lat, long)\n\
    d basename : dump the current set of maps to ISOC-style files\n\
    e wildcarded-base : enter (load) a set of ISOC-style maps into the\n\
                 next entry\n\
    g <n>      : go to data set specified (which may be impossible in any\n\
                 other way, depending on ESAs loaded)\n\
    N string   : rename current map set\n\
    P <seconds>: pause (for scripted movies)\n\
    PP         : toggle displaying changes (for scripted movies)\n\
    p          : print out what's been loaded\n\
    R          : set all scales identical to onscreen for given ESA.\n\
    r min max  : set map colour range ('r ?' to query)\n\
    s [f|b|o] [args] : set histogramming parameters for non-ISOC files.\n\
            sf filenamebase filenameextension : set filename specs to load.\n\
            sF [6|1] : set file format to 6-degree (\"hi_iso_ofs\") format\n\
                   or 1-degree (\"hidebin\") format.\n\
            sb nlong nlat NP-long NP-lat : when binning, bin in\n\
                   nlong x nlat pixels, with the ""north pole"" from which\n\
                   latitude and longitude are calculated to be at the specified\n\
                   actual latitude and longitude (in degrees).\n\
            sa pixn  : set up an Abrate map of about pixn pixels (0 to disable)\n\
            sh healn : set up HEALpix n_side (set to zero to disable).\n\
            so ramwake statsum noneg interp mapsigma : all params are ints.\n\
                   ramwake:  0: include ram & wake.\n\
                             1: include ram only.\n\
                            -1: include wake only.\n\
                   statsum:  0: unweighted averaging.\n\
                             1: weight arithmetically using uncertainty.\n\
                            -1: unweighted geometric averaging.\n\
                   noneg:  nonzero to drop negative points from summing.\n\
                   interp:  0:  don't interpolate.\n\
                            1:  do an evil approx of ISOC 7 deg lat/lng smear.\n\
                   # mapsigma:  plot uncertainties rather than count rates.\n\
    t firstarc lastarc [slot] : build up a histogram with the current\n\
            parameters, starting at firstarc and ending at lastarc.  Store\n\
            it in the next slot (or the specified slot, if a slot is given).\n\
    U            : undo last left mouse-click\n\
    /<i> <j> <k> : make map k into map<i> divided by map<j>, if possible.\n\
    -<i> <j> <k> : make map k into map<i> minus map<j>, if possible.\n\
    `          : print current rotation matrix\n\n\
    q                : quit.\n\n\
    ?                : show this help.\n");
		break;
	default:
		printf("Huh?\n");
		break;
	}
	kbdn = 0;
}
