/*	$Id: Xinit.c,v 1.4 2021/11/29 20:24:44 pjanzen Exp $	*/
/* Set up X.
 * It's driven from an xterm and has only one main display window.
 * Code is derived from Xinit.c of xmca.c written for the SAO beam lab.
 */

static const char rcsid[] = "@(#) $Id: Xinit.c,v 1.4 2021/11/29 20:24:44 pjanzen Exp $";

#include <X11/X.h>
#include <X11/StringDefs.h>
#include <X11/Intrinsic.h>
#include <X11/Xlib.h>
#include <X11/Core.h>
#include <X11/Shell.h>
#include <X11/Xaw/Box.h>
#include <X11/Xaw/Command.h>
#include <X11/Xaw/Form.h>
#include <X11/Xaw/Label.h>
#include "DrawingA.h"	/* Should be in Xaw, but isn't */

#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "xmap.h"
#include "extern.h"

#include "ibexicon.xbm"

static XtActionsRec loss_main_actions[] = {
	{"wm_quit", wm_quit }
};

XtSignalId wantleave, wantsuspend;


/* Default gnuplot palette, from > show palette palette 256 */
static const int rgp[256] = {
	  0,  16,  23,  28,  32,  36,  39,  42,  45,  48,  50,  53,  55,  58,
	 60,  62,  64,  66,  68,  70,  71,  73,  75,  77,  78,  80,  81,  83,
	 84,  86,  87,  89,  90,  92,  93,  94,  96,  97,  98, 100, 101, 102,
	103, 105, 106, 107, 108, 109, 111, 112, 113, 114, 115, 116, 117, 118,
	119, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133,
	134, 135, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 145,
	146, 147, 148, 149, 150, 151, 151, 152, 153, 154, 155, 156, 156, 157,
	158, 159, 160, 160, 161, 162, 163, 164, 164, 165, 166, 167, 167, 168,
	169, 170, 170, 171, 172, 173, 173, 174, 175, 176, 176, 177, 178, 179,
	179, 180, 181, 181, 182, 183, 183, 184, 185, 186, 186, 187, 188, 188,
	189, 190, 190, 191, 192, 192, 193, 194, 194, 195, 196, 196, 197, 198,
	198, 199, 199, 200, 201, 201, 202, 203, 203, 204, 204, 205, 206, 206,
	207, 208, 208, 209, 209, 210, 211, 211, 212, 212, 213, 214, 214, 215,
	215, 216, 217, 217, 218, 218, 219, 220, 220, 221, 221, 222, 222, 223,
	224, 224, 225, 225, 226, 226, 227, 228, 228, 229, 229, 230, 230, 231,
	231, 232, 233, 233, 234, 234, 235, 235, 236, 236, 237, 237, 238, 238,
	239, 240, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246,
	246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253,
	253, 254, 254, 255 };
static const int ggp[256] = {
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
	  1,   1,   1,   1,   1,   2,   2,   2,   2,   2,   2,   2,   2,   3,
	  3,   3,   3,   3,   3,   3,   4,   4,   4,   4,   4,   5,   5,   5,
	  5,   6,   6,   6,   6,   6,   7,   7,   7,   8,   8,   8,   8,   9,
	  9,   9,  10,  10,  10,  11,  11,  12,  12,  12,  13,  13,  14,  14,
	 14,  15,  15,  16,  16,  17,  17,  18,  18,  19,  19,  20,  20,  21,
	 22,  22,  23,  23,  24,  25,  25,  26,  27,  27,  28,  29,  29,  30,
	 31,  32,  32,  33,  34,  35,  35,  36,  37,  38,  39,  40,  40,  41,
	 42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,
	 56,  57,  58,  60,  61,  62,  63,  64,  65,  67,  68,  69,  70,  72,
	 73,  74,  76,  77,  78,  80,  81,  82,  84,  85,  87,  88,  90,  91,
	 93,  94,  96,  97,  99, 101, 102, 104, 105, 107, 109, 111, 112, 114,
	116, 118, 119, 121, 123, 125, 127, 129, 131, 132, 134, 136, 138, 140,
	142, 144, 147, 149, 151, 153, 155, 157, 159, 162, 164, 166, 168, 171,
	173, 175, 178, 180, 182, 185, 187, 190, 192, 195, 197, 200, 202, 205,
	207, 210, 213, 215, 218, 221, 223, 226, 229, 232, 235, 237, 240, 243,
	246, 249, 252, 255 };
static const int bgp[256] = {
	  0,   6,  13,  19,  25,  31,  38,  44,  50,  56,  62,  68,  74,  80,
	 86,  92,  98, 104, 109, 115, 121, 126, 132, 137, 142, 147, 152, 157,
	162, 167, 172, 176, 181, 185, 190, 194, 198, 202, 205, 209, 213, 216,
	219, 222, 225, 228, 231, 234, 236, 238, 241, 243, 244, 246, 248, 249,
	250, 251, 252, 253, 254, 254, 255, 255, 255, 255, 255, 254, 254, 253,
	252, 251, 250, 248, 247, 245, 243, 242, 239, 237, 235, 232, 230, 227,
	224, 221, 218, 214, 211, 207, 203, 200, 196, 192, 187, 183, 179, 174,
	169, 165, 160, 155, 150, 145, 140, 134, 129, 123, 118, 112, 107, 101,
	 95,  89,  83,  77,  71,  65,  59,  53,  47,  41,  34,  28,  22,  16,
	  9,   3,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0 };

#if 0
static const int rct39[256] = {
0  , 4  , 9  , 13 , 18 , 22 , 27 , 31 , 36 , 40 , 45 , 50 , 58 , 61 , 64 ,
68 , 69 , 72 , 74 , 77 , 79 , 80 , 82 , 83 , 84 , 86 , 87 , 88 , 86 , 87 ,
87 , 87 , 85 , 84 , 84 , 84 , 79 , 78 , 77 , 76 , 71 , 70 , 68 , 66 , 60 ,
58 , 55 , 46 , 43 , 40 , 36 , 33 , 25 , 21 , 16 , 12 , 4  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 4  , 8  , 12 ,
21 , 25 , 29 , 42 , 46 , 51 , 55 , 63 , 67 , 72 , 76 , 80 , 89 , 93 , 97 ,
110, 114, 119, 123, 131, 135, 140, 144, 153, 157, 161, 165, 178, 182, 187,
191, 199, 203, 208, 212, 221, 225, 229, 242, 246, 250, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255 };
static const int gct39[256] = {
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 4  , 16 ,
21 , 25 , 29 , 38 , 42 , 46 , 51 , 55 , 63 , 67 , 72 , 84 , 89 , 93 , 97 ,
106, 110, 114, 119, 127, 131, 135, 140, 152, 157, 161, 165, 174, 178, 182,
187, 195, 199, 203, 216, 220, 225, 229, 233, 242, 246, 250, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 250, 242, 238,
233, 229, 221, 216, 212, 199, 195, 191, 187, 178, 174, 170, 165, 161, 153,
148, 144, 131, 127, 123, 119, 110, 106, 102, 97 , 89 , 85 , 80 , 76 , 63 ,
59 , 55 , 51 , 42 , 38 , 34 , 29 , 21 , 17 , 12 , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
255 };
static const int bct39[256] = {
0  , 3  , 7  , 10 , 14 , 19 , 23 , 28 , 32 , 38 , 43 , 48 , 59 , 63 , 68 ,
72 , 77 , 81 , 86 , 91 , 95 , 100, 104, 109, 118, 122, 127, 132, 136, 141,
145, 150, 154, 159, 163, 168, 177, 182, 186, 191, 195, 200, 204, 209, 214,
218, 223, 232, 236, 241, 245, 250, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 246, 242,
238, 225, 220, 216, 212, 203, 199, 195, 191, 187, 178, 174, 170, 157, 152,
148, 144, 135, 131, 127, 123, 114, 110, 106, 102, 89 , 84 , 80 , 76 , 67 ,
63 , 59 , 55 , 46 , 42 , 38 , 25 , 21 , 16 , 12 , 8  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  ,
255 };
#else
/* Frederic's IBEX colour table */
static const int rct39[256] = {
  0,  64,  62,  60,  59,  57,  55,  53,  51,  49,  48,  46,  44,  42,  40,  38,
 37,  35,  33,  31,  29,  27,  26,  24,  22,  20,  18,  16,  15,  13,  11,   9,
  7,   5,   4,   2,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   6,  12,  18,  24,  30,  36,
 43,  49,  55,  61,  67,  73,  79,  85,  91,  97, 103, 109, 115, 121, 128, 134,
140, 146, 152, 158, 164, 170, 176, 182, 188, 194, 200, 206, 213, 219, 225, 231,
237, 243, 249, 255, 254, 253, 252, 251, 249, 248, 247, 246, 245, 244, 243, 242,
241, 240, 238, 237, 236, 235, 234, 233, 232, 231, 230, 229, 227, 226, 225, 224,
223, 222, 221, 220, 219, 218, 216, 215, 214, 213, 212, 211, 210, 209, 208, 207,
205, 204, 203, 202, 201, 200, 201, 203, 204, 205, 207, 208, 209, 211, 212, 213,
215, 216, 217, 219, 220, 221, 223, 224, 225, 227, 228, 230, 231, 232, 234, 235,
236, 238, 239, 240, 242, 243, 244, 246, 247, 248, 250, 251, 252, 254, 255, 255};
static const int gct39[256] = {
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   6,  12,  18,  24,  30,  36,  42,  47,  53,  59,  65,
 71,  77,  83,  89,  95, 101, 107, 113, 119, 125, 130, 136, 142, 148, 154, 160,
166, 172, 178, 184, 190, 196, 202, 208, 213, 219, 225, 231, 237, 243, 249, 255,
253, 252, 250, 249, 247, 246, 244, 243, 241, 240, 238, 236, 235, 233, 232, 230,
229, 227, 226, 224, 222, 221, 219, 218, 216, 215, 213, 212, 210, 209, 207, 205,
204, 202, 201, 199, 198, 196, 195, 193, 192, 190, 192, 193, 195, 196, 198, 199,
201, 202, 204, 205, 207, 209, 210, 212, 213, 215, 216, 218, 219, 221, 223, 224,
226, 227, 229, 230, 232, 233, 235, 236, 238, 240, 241, 243, 244, 246, 247, 249,
250, 252, 253, 255, 250, 245, 240, 235, 229, 224, 219, 214, 209, 204, 199, 194,
189, 184, 178, 173, 168, 163, 158, 153, 148, 143, 138, 133, 127, 122, 117, 112,
107, 102,  97,  92,  87,  82,  76,  71,  66,  61,  56,  51,  46,  41,  36,  31,
 25,  20,  15,  10,   5,   0,   3,   6,   9,  12,  16,  19,  22,  25,  28,  31,
 34,  37,  41,  44,  47,  50,  53,  56,  59,  62,  66,  69,  72,  75,  78,  81,
 84,  87,  91,  94,  97, 100, 103, 106, 109, 112, 116, 119, 122, 125, 128, 255};
static const int bct39[256] = {
  0,  64,  69,  75,  80,  86,  91,  97, 102, 108, 113, 119, 124, 129, 135, 140,
146, 151, 157, 162, 168, 173, 179, 184, 190, 195, 200, 206, 211, 217, 222, 228,
233, 239, 244, 250, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
249, 243, 237, 231, 225, 219, 212, 206, 200, 194, 188, 182, 176, 170, 164, 158,
152, 146, 140, 134, 127, 121, 115, 109, 103,  97,  91,  85,  79,  73,  67,  61,
 55,  49,  42,  36,  30,  24,  18,  12,   6,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   0,   0,   0,   0,   0,   6,  12,  19,  25,  31,  37,  44,  50,  56,  62,
  68, 75,  81,  87,  93, 100, 106, 112, 118, 124, 131, 137, 143, 149, 155, 162,
168, 174, 180, 187, 193, 199, 205, 211, 218, 224, 230, 236, 243, 249, 255, 255};
#endif

void
tty_suspend_interrupt(int dummy)
{
	XtNoticeSignal(wantsuspend);
}
void
tty_safe_suspender(XtPointer closure, XtSignalId *id)
{
	tty_suspend();
}

void
tty_quit_interrupt(int dummy)
{
	XtNoticeSignal(wantleave);
}
void
tty_safe_quitter(XtPointer closure, XtSignalId *id)
{
	tty_quit();
}


void
initX()
{
	Arg    wargs[12];
	int    n, i;
	char   fuzz[100];
	long   ltmp;
	XSizeHints *xsh;
	Dimension xx, yy;
	Widget tmpentry;

	i = DefaultScreen(XtDisplay(tl));
	colblack = BlackPixel(XtDisplay(tl), i);
	colwhite = WhitePixel(XtDisplay(tl), i);
	/* We don't resize based on DisplayWidth(XtDisplay(tl), i);
	 * it's just plain fixed.  This is different from xhihb and xloss.
	 */
	if (greyscale) {
		for (i = 0; i < 256; i++) {
			cmap[i] = colorindexrgb(tl, 256 * i, 256 * i, 256 * i);
			ocmap[i] = colorindexrgb(tl, 256 * rct39[i],
			    256 * gct39[i], 256 * bct39[i]);
			im_cmap[i] = (i << 1) * 0x10101;
			im_ocmap[i] = (rct39[i] << 16) + (gct39[i] << 8) + bct39[i];
		}
	} else
		for (i = 0; i < 256; i++) {
			cmap[i] = colorindexrgb(tl, 256 * rct39[i],
			    256 * gct39[i], 256 * bct39[i]);
			/* Grey scale is not too useful but gnuplot map might be. */
			/* ocmap[i] = colorindexrgb(tl, 256 * i, 256 * i, 256 * i); */
			ocmap[i] = colorindexrgb(tl, 256 * rgp[i], 256 * ggp[i],
			    256 * bgp[i]);
			im_cmap[i] = (rct39[i] << 16) + (gct39[i] << 8) + bct39[i];
			/* im_ocmap[i] = (i << 1) * 0x10101; */
			im_ocmap[i] = (rgp[i] << 16) + (ggp[i] << 8) + bgp[i];
		}

	n = 0;
	XtSetArg(wargs[n], XtNbackground, colblack); n++;
	XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	tlf = XtCreateManagedWidget("form", formWidgetClass, tl, wargs, n);

	/* For now, a drawing panel, two drawing panels evenly spaced below,
	 * and then another drawing panel.  On top:  a text display.
	 * Above the text display:  some menus, handled on their own.
	 */
	if (showmenu)
		tmpentry = init_menus(tlf);
	n = 0;
	if (rev_vid) {
		XtSetArg(wargs[n], XtNbackground, colwhite); n++;
		XtSetArg(wargs[n], XtNforeground, colblack); n++;
	} else {
		XtSetArg(wargs[n], XtNbackground, colblack); n++;
		XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	}
	XtSetArg(wargs[n], XtNjustify, XtJustifyLeft); n++;
	XtSetArg(wargs[n], XtNresize, False); n++;
	if (showmenu) {
		XtSetArg(wargs[n], XtNfromVert, tmpentry); n++;
	}
	XtSetArg(wargs[n], XtNlabel, "12: 123456789012345678901234567890 ESA 1 (123 - 30.00) ctr lt lg (123. 123.) [123.]"); n++;
	info = XtCreateManagedWidget("textbox", labelWidgetClass, tlf, wargs, n);
	n = 0;
	if (rev_vid) {
		XtSetArg(wargs[n], XtNbackground, colwhite); n++;
		XtSetArg(wargs[n], XtNforeground, colblack); n++;
	} else {
		XtSetArg(wargs[n], XtNbackground, colblack); n++;
		XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	}
	/* faster updates, according to viewres */
	XtSetArg(wargs[n], XtNbackgroundPixmap, None); n++;
	XtSetArg(wargs[n], XtNheight, mercy + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNwidth, mercx + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNresize, True); n++;
	XtSetArg(wargs[n], XtNborderColor, colwhite); n++;
	XtSetArg(wargs[n], XtNtop, XtChainTop); n++;
	/* XtSetArg(wargs[n], XtNbottom, XtChainBottom); n++; */
	XtSetArg(wargs[n], XtNfromVert, info); n++;
	XtSetArg(wargs[n], XtNright, XtChainRight); n++;
	merc = XtCreateManagedWidget("mercator", drawingAreaWidgetClass, tlf,
	    wargs, n);
	XtAddEventHandler(merc, ExposureMask, FALSE, merc_callback, NULL);
	XtAddCallback(merc, XtNinputCallback, merc_mousecallback, NULL);
	/* Only the mercator can be clicked on for now */
	n = 0;
	if (rev_vid) {
		XtSetArg(wargs[n], XtNbackground, colwhite); n++;
		XtSetArg(wargs[n], XtNforeground, colblack); n++;
	} else {
		XtSetArg(wargs[n], XtNbackground, colblack); n++;
		XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	}
	/* faster updates, according to viewres */
	XtSetArg(wargs[n], XtNbackgroundPixmap, None); n++;
	XtSetArg(wargs[n], XtNheight, glby + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNwidth, glbx + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNborderColor, colwhite); n++;
	/* XtSetArg(wargs[n], XtNtop, XtChainTop); n++; */
	/* XtSetArg(wargs[n], XtNbottom, XtChainBottom); n++; */
	XtSetArg(wargs[n], XtNfromVert, merc); n++;
	/* XtSetArg(wargs[n], XtNright, XtChainRight); n++; */
	XtSetArg(wargs[n], XtNresize, True); n++;
	glbf = XtCreateManagedWidget("globe1", drawingAreaWidgetClass,
	    tlf, wargs, n);
	XtAddEventHandler(glbf, ExposureMask, FALSE, glbf_callback, NULL);
	n = 0;
	if (rev_vid) {
		XtSetArg(wargs[n], XtNbackground, colwhite); n++;
		XtSetArg(wargs[n], XtNforeground, colblack); n++;
	} else {
		XtSetArg(wargs[n], XtNbackground, colblack); n++;
		XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	}
	/* faster updates, according to viewres */
	XtSetArg(wargs[n], XtNbackgroundPixmap, None); n++;
	XtSetArg(wargs[n], XtNheight, glby + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNwidth, glbx + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNborderColor, colwhite); n++;
	/* XtSetArg(wargs[n], XtNtop, XtChainTop); n++; */
	/* XtSetArg(wargs[n], XtNbottom, XtChainBottom); n++; */
	XtSetArg(wargs[n], XtNfromHoriz, glbf); n++;
	XtSetArg(wargs[n], XtNfromVert, merc); n++;
	XtSetArg(wargs[n], XtNright, XtChainRight); n++;
	XtSetArg(wargs[n], XtNresize, True); n++;
	glbb = XtCreateManagedWidget("globe2", drawingAreaWidgetClass, tlf,
	    wargs, n);
	XtAddEventHandler(glbb, ExposureMask, FALSE, glbb_callback, NULL);
	/* The way we're set up, all the panes resize if any resizes.
	 * So we'll stick the resize handler, randomly, here.
	 */
	XtAddEventHandler(glbb, StructureNotifyMask, FALSE, resiz_callback, NULL);
	n = 0;
	if (rev_vid) {
		XtSetArg(wargs[n], XtNbackground, colwhite); n++;
		XtSetArg(wargs[n], XtNforeground, colblack); n++;
	} else {
		XtSetArg(wargs[n], XtNbackground, colblack); n++;
		XtSetArg(wargs[n], XtNforeground, colwhite); n++;
	}
	/* faster updates, according to viewres */
	XtSetArg(wargs[n], XtNbackgroundPixmap, None); n++;
	XtSetArg(wargs[n], XtNheight, molly + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNwidth, mollx + 2*appResources.Border); n++;
	XtSetArg(wargs[n], XtNborderColor, colwhite); n++;
	/* XtSetArg(wargs[n], XtNtop, XtChainTop); n++; */
	XtSetArg(wargs[n], XtNbottom, XtChainBottom); n++;
	XtSetArg(wargs[n], XtNfromVert, glbf); n++;
	XtSetArg(wargs[n], XtNright, XtChainRight); n++;
	XtSetArg(wargs[n], XtNresize, True); n++;
	moll = XtCreateManagedWidget("mollweide", drawingAreaWidgetClass, tlf,
	    wargs, n);
	XtAddEventHandler(moll, ExposureMask, FALSE, moll_callback, NULL);

	/* We need to check the keyboard for input. */
	XtAppAddInput(OurAppContext, STDIN_FILENO, (XtPointer)XtInputReadMask,
	    &Xreadkbd, NULL);

	XtRealizeWidget(tl);
	while(!XtIsRealized(tl))
		;

	/* Try to keep aspect ratio on resizes, for lack of a better idea */
	xsh = XAllocSizeHints();
	XGetWMNormalHints(XtDisplay(tl), XtWindow(tl), xsh, &ltmp);
	n = 0;
	XtSetArg(wargs[n], XtNwidth, &xx); n++;
	XtSetArg(wargs[n], XtNheight, &yy); n++;
	XtGetValues(tl, wargs, n);
	xsh->min_aspect.x = xx;
	xsh->min_aspect.y = yy;
	xsh->max_aspect.x = xx;
	xsh->max_aspect.y = yy;
	xsh->flags |= PAspect;
	XSetWMNormalHints(XtDisplay(tl), XtWindow(tl), xsh);

	/* Window name is xmap and possibly more data (ESA?). */
	snprintf(fuzz, 100, "xmap");
	XStoreName(XtDisplay(tl), XtWindow(tl), fuzz);
	XSetIconName(XtDisplay(tl), XtWindow(tl), fuzz);
	/* draw_data(); */
	/* Not really visible on screen until XtAppMainLoop or equivalent,
	 * in truth. */
	/* ...and set it up so f.delete works */
	XtAppAddActions(OurAppContext, loss_main_actions,
	    XtNumber(loss_main_actions));
	XtOverrideTranslations(tl,
	    XtParseTranslationTable("<Message>WM_PROTOCOLS: wm_quit()"));
	wm_delete_window = XInternAtom(XtDisplay(tl), "WM_DELETE_WINDOW", False);
	XSetWMProtocols(XtDisplay(tl), XtWindow(tl), &wm_delete_window, 1);
	/* Why not set up a cute icon?  Nice Xt code based on oclock in X11
	 * distribution.
	 */
	n = 0;
	XtSetArg(wargs[n], XtNiconPixmap,
	    XCreateBitmapFromData(XtDisplay(tl), XtScreen(tl)->root,
	        ibexicon_bits, ibexicon_width, ibexicon_height)); n++;
	XtSetValues(tl, wargs, n);
	wantleave = XtAppAddSignal(OurAppContext, tty_safe_quitter, NULL);
	wantsuspend = XtAppAddSignal(OurAppContext, tty_safe_suspender, NULL);
}



/* colorindexrgb and colorindexname are from a U.Regina tutorial */
int
colorindexrgb(Widget w, int r, int g, int b)
{
	Display *display;
	int screen;
	Colormap lcmap;
	XColor color;

	display = XtDisplay(w);
	screen  = DefaultScreen(display);
	lcmap    = DefaultColormap(display, screen);

	color.red = r;
	color.green = g;
	color.blue = b;

	if (XAllocColor(display, lcmap, &color))
		return(color.pixel);
	else {
		warnx("Can't allocate colour (%d, %d, %d)", r, g, b);
		return(WhitePixel(display, screen));
	}
}

int
colorindexname(Widget w, char *name)
{
	Display *display;
	int screen;
	Colormap lcmap;
	XColor color, exact;

	display = XtDisplay(w);
	screen  = DefaultScreen(display);
	lcmap    = DefaultColormap(display, screen);

	if (XAllocNamedColor(display, lcmap, name, &color, &exact))
		return(color.pixel);
	else {
		warnx("Can't allocate colour %s", name);
		return(WhitePixel(display, screen));
	}
}
