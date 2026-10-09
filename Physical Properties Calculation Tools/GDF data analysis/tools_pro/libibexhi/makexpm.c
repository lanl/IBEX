/*	$Id: makexpm.c,v 1.1 2010/06/22 01:03:41 pjanzen Exp $	*/
/* Make an .xpm file given a filename and a 1-D array of size nx by ny,
 * of double, for lack of a better format.  It scales to 128-level
 * grey scale or to 128-level IDL table-39 (rainbow + white) equivalent,
 * or to gnuplot default table..
 */

#include <stdio.h>

static const char rcsid[] = "@(#) $Id: makexpm.c,v 1.1 2010/06/22 01:03:41 pjanzen Exp $";

/* gnuplot: show palette palette 128 */
static void
dumpgp(FILE *f)
{
	fprintf(f, "%s", "\"  	c #000000\",\n");
	fprintf(f, "%s", "\" 1	c #17000d\",\n");
	fprintf(f, "%s", "\" 2	c #200019\",\n");
	fprintf(f, "%s", "\" 3	c #270026\",\n");
	fprintf(f, "%s", "\" 4	c #2d0032\",\n");
	fprintf(f, "%s", "\" 5	c #33003e\",\n");
	fprintf(f, "%s", "\" 6	c #37004b\",\n");
	fprintf(f, "%s", "\" 7	c #3c0057\",\n");
	fprintf(f, "%s", "\" 8	c #400062\",\n");
	fprintf(f, "%s", "\" 9	c #44006e\",\n");
	fprintf(f, "%s", "\" a	c #480079\",\n");
	fprintf(f, "%s", "\" b	c #4b0084\",\n");
	fprintf(f, "%s", "\" c	c #4e008f\",\n");
	fprintf(f, "%s", "\" d	c #520099\",\n");
	fprintf(f, "%s", "\" e	c #5500a3\",\n");
	fprintf(f, "%s", "\" f	c #5800ac\",\n");
	fprintf(f, "%s", "\"10	c #5b01b5\",\n");
	fprintf(f, "%s", "\"11	c #5d01be\",\n");
	fprintf(f, "%s", "\"12	c #6001c6\",\n");
	fprintf(f, "%s", "\"13	c #6301ce\",\n");
	fprintf(f, "%s", "\"14	c #6501d5\",\n");
	fprintf(f, "%s", "\"15	c #6801dc\",\n");
	fprintf(f, "%s", "\"16	c #6a01e2\",\n");
	fprintf(f, "%s", "\"17	c #6d02e7\",\n");
	fprintf(f, "%s", "\"18	c #6f02ec\",\n");
	fprintf(f, "%s", "\"19	c #7102f1\",\n");
	fprintf(f, "%s", "\"1a	c #7302f5\",\n");
	fprintf(f, "%s", "\"1b	c #7602f8\",\n");
	fprintf(f, "%s", "\"1c	c #7803fb\",\n");
	fprintf(f, "%s", "\"1d	c #7a03fd\",\n");
	fprintf(f, "%s", "\"1e	c #7c03fe\",\n");
	fprintf(f, "%s", "\"1f	c #7e04ff\",\n");
	fprintf(f, "%s", "\"20	c #8004ff\",\n");
	fprintf(f, "%s", "\"21	c #8204ff\",\n");
	fprintf(f, "%s", "\"22	c #8405fd\",\n");
	fprintf(f, "%s", "\"23	c #8605fc\",\n");
	fprintf(f, "%s", "\"24	c #8806f9\",\n");
	fprintf(f, "%s", "\"25	c #8a06f6\",\n");
	fprintf(f, "%s", "\"26	c #8b07f3\",\n");
	fprintf(f, "%s", "\"27	c #8d07ef\",\n");
	fprintf(f, "%s", "\"28	c #8f08ea\",\n");
	fprintf(f, "%s", "\"29	c #9109e5\",\n");
	fprintf(f, "%s", "\"2a	c #9309df\",\n");
	fprintf(f, "%s", "\"2b	c #940ad9\",\n");
	fprintf(f, "%s", "\"2c	c #960bd2\",\n");
	fprintf(f, "%s", "\"2d	c #980bca\",\n");
	fprintf(f, "%s", "\"2e	c #990cc2\",\n");
	fprintf(f, "%s", "\"2f	c #9b0dba\",\n");
	fprintf(f, "%s", "\"30	c #9d0eb1\",\n");
	fprintf(f, "%s", "\"31	c #9e0fa8\",\n");
	fprintf(f, "%s", "\"32	c #a0109e\",\n");
	fprintf(f, "%s", "\"33	c #a21194\",\n");
	fprintf(f, "%s", "\"34	c #a31289\",\n");
	fprintf(f, "%s", "\"35	c #a5137f\",\n");
	fprintf(f, "%s", "\"36	c #a61473\",\n");
	fprintf(f, "%s", "\"37	c #a81568\",\n");
	fprintf(f, "%s", "\"38	c #a9165c\",\n");
	fprintf(f, "%s", "\"39	c #ab1751\",\n");
	fprintf(f, "%s", "\"3a	c #ac1845\",\n");
	fprintf(f, "%s", "\"3b	c #ae1a38\",\n");
	fprintf(f, "%s", "\"3c	c #af1b2c\",\n");
	fprintf(f, "%s", "\"3d	c #b11c1f\",\n");
	fprintf(f, "%s", "\"3e	c #b21e13\",\n");
	fprintf(f, "%s", "\"3f	c #b41f06\",\n");
	fprintf(f, "%s", "\"40	c #b52100\",\n");
	fprintf(f, "%s", "\"41	c #b62200\",\n");
	fprintf(f, "%s", "\"42	c #b82400\",\n");
	fprintf(f, "%s", "\"43	c #b92500\",\n");
	fprintf(f, "%s", "\"44	c #bb2700\",\n");
	fprintf(f, "%s", "\"45	c #bc2900\",\n");
	fprintf(f, "%s", "\"46	c #bd2b00\",\n");
	fprintf(f, "%s", "\"47	c #bf2d00\",\n");
	fprintf(f, "%s", "\"48	c #c02e00\",\n");
	fprintf(f, "%s", "\"49	c #c13000\",\n");
	fprintf(f, "%s", "\"4a	c #c33200\",\n");
	fprintf(f, "%s", "\"4b	c #c43500\",\n");
	fprintf(f, "%s", "\"4c	c #c53700\",\n");
	fprintf(f, "%s", "\"4d	c #c73900\",\n");
	fprintf(f, "%s", "\"4e	c #c83b00\",\n");
	fprintf(f, "%s", "\"4f	c #c93d00\",\n");
	fprintf(f, "%s", "\"50	c #ca4000\",\n");
	fprintf(f, "%s", "\"51	c #cc4200\",\n");
	fprintf(f, "%s", "\"52	c #cd4500\",\n");
	fprintf(f, "%s", "\"53	c #ce4700\",\n");
	fprintf(f, "%s", "\"54	c #cf4a00\",\n");
	fprintf(f, "%s", "\"55	c #d14c00\",\n");
	fprintf(f, "%s", "\"56	c #d24f00\",\n");
	fprintf(f, "%s", "\"57	c #d35200\",\n");
	fprintf(f, "%s", "\"58	c #d45500\",\n");
	fprintf(f, "%s", "\"59	c #d55800\",\n");
	fprintf(f, "%s", "\"5a	c #d75b00\",\n");
	fprintf(f, "%s", "\"5b	c #d85e00\",\n");
	fprintf(f, "%s", "\"5c	c #d96100\",\n");
	fprintf(f, "%s", "\"5d	c #da6400\",\n");
	fprintf(f, "%s", "\"5e	c #db6700\",\n");
	fprintf(f, "%s", "\"5f	c #dd6b00\",\n");
	fprintf(f, "%s", "\"60	c #de6e00\",\n");
	fprintf(f, "%s", "\"61	c #df7200\",\n");
	fprintf(f, "%s", "\"62	c #e07500\",\n");
	fprintf(f, "%s", "\"63	c #e17900\",\n");
	fprintf(f, "%s", "\"64	c #e27c00\",\n");
	fprintf(f, "%s", "\"65	c #e38000\",\n");
	fprintf(f, "%s", "\"66	c #e58400\",\n");
	fprintf(f, "%s", "\"67	c #e68800\",\n");
	fprintf(f, "%s", "\"68	c #e78c00\",\n");
	fprintf(f, "%s", "\"69	c #e89000\",\n");
	fprintf(f, "%s", "\"6a	c #e99400\",\n");
	fprintf(f, "%s", "\"6b	c #ea9900\",\n");
	fprintf(f, "%s", "\"6c	c #eb9d00\",\n");
	fprintf(f, "%s", "\"6d	c #eca100\",\n");
	fprintf(f, "%s", "\"6e	c #eda600\",\n");
	fprintf(f, "%s", "\"6f	c #eeaa00\",\n");
	fprintf(f, "%s", "\"70	c #efaf00\",\n");
	fprintf(f, "%s", "\"71	c #f1b400\",\n");
	fprintf(f, "%s", "\"72	c #f2b800\",\n");
	fprintf(f, "%s", "\"73	c #f3bd00\",\n");
	fprintf(f, "%s", "\"74	c #f4c200\",\n");
	fprintf(f, "%s", "\"75	c #f5c700\",\n");
	fprintf(f, "%s", "\"76	c #f6cd00\",\n");
	fprintf(f, "%s", "\"77	c #f7d200\",\n");
	fprintf(f, "%s", "\"78	c #f8d700\",\n");
	fprintf(f, "%s", "\"79	c #f9dd00\",\n");
	fprintf(f, "%s", "\"7a	c #fae200\",\n");
	fprintf(f, "%s", "\"7b	c #fbe800\",\n");
	fprintf(f, "%s", "\"7c	c #fced00\",\n");
	fprintf(f, "%s", "\"7d	c #fdf300\",\n");
	fprintf(f, "%s", "\"7e	c #fef900\",\n");
	fprintf(f, "%s", "\"7f	c #ffff00\",\n");
}

static void
dumpct39(FILE *f)
{
	fprintf(f, "%s", "\"  	c #000000\",\n");
	fprintf(f, "%s", "\" 1	c #090007\",\n");
	fprintf(f, "%s", "\" 2	c #12000e\",\n");
	fprintf(f, "%s", "\" 3	c #1b0017\",\n");
	fprintf(f, "%s", "\" 4	c #240020\",\n");
	fprintf(f, "%s", "\" 5	c #2d002b\",\n");
	fprintf(f, "%s", "\" 6	c #3a003b\",\n");
	fprintf(f, "%s", "\" 7	c #400044\",\n");
	fprintf(f, "%s", "\" 8	c #45004d\",\n");
	fprintf(f, "%s", "\" 9	c #4a0056\",\n");
	fprintf(f, "%s", "\" a	c #4f005f\",\n");
	fprintf(f, "%s", "\" b	c #520068\",\n");
	fprintf(f, "%s", "\" c	c #540076\",\n");
	fprintf(f, "%s", "\" d	c #57007f\",\n");
	fprintf(f, "%s", "\" e	c #560088\",\n");
	fprintf(f, "%s", "\" f	c #570091\",\n");
	fprintf(f, "%s", "\"10	c #55009a\",\n");
	fprintf(f, "%s", "\"11	c #5400a3\",\n");
	fprintf(f, "%s", "\"12	c #4f00b1\",\n");
	fprintf(f, "%s", "\"13	c #4d00ba\",\n");
	fprintf(f, "%s", "\"14	c #4700c3\",\n");
	fprintf(f, "%s", "\"15	c #4400cc\",\n");
	fprintf(f, "%s", "\"16	c #3c00d6\",\n");
	fprintf(f, "%s", "\"17	c #3700df\",\n");
	fprintf(f, "%s", "\"18	c #2b00ec\",\n");
	fprintf(f, "%s", "\"19	c #2400f5\",\n");
	fprintf(f, "%s", "\"1a	c #1900ff\",\n");
	fprintf(f, "%s", "\"1b	c #1000ff\",\n");
	fprintf(f, "%s", "\"1c	c #0400ff\",\n");
	fprintf(f, "%s", "\"1d	c #0004ff\",\n");
	fprintf(f, "%s", "\"1e	c #0015ff\",\n");
	fprintf(f, "%s", "\"1f	c #001dff\",\n");
	fprintf(f, "%s", "\"20	c #002aff\",\n");
	fprintf(f, "%s", "\"21	c #0033ff\",\n");
	fprintf(f, "%s", "\"22	c #003fff\",\n");
	fprintf(f, "%s", "\"23	c #0048ff\",\n");
	fprintf(f, "%s", "\"24	c #0059ff\",\n");
	fprintf(f, "%s", "\"25	c #0061ff\",\n");
	fprintf(f, "%s", "\"26	c #006eff\",\n");
	fprintf(f, "%s", "\"27	c #0077ff\",\n");
	fprintf(f, "%s", "\"28	c #0083ff\",\n");
	fprintf(f, "%s", "\"29	c #008cff\",\n");
	fprintf(f, "%s", "\"2a	c #009dff\",\n");
	fprintf(f, "%s", "\"2b	c #00a5ff\",\n");
	fprintf(f, "%s", "\"2c	c #00b2ff\",\n");
	fprintf(f, "%s", "\"2d	c #00bbff\",\n");
	fprintf(f, "%s", "\"2e	c #00c7ff\",\n");
	fprintf(f, "%s", "\"2f	c #00d8ff\",\n");
	fprintf(f, "%s", "\"30	c #00e1ff\",\n");
	fprintf(f, "%s", "\"31	c #00e9ff\",\n");
	fprintf(f, "%s", "\"32	c #00f6ff\",\n");
	fprintf(f, "%s", "\"33	c #00ffff\",\n");
	fprintf(f, "%s", "\"34	c #00fff2\",\n");
	fprintf(f, "%s", "\"35	c #00ffe1\",\n");
	fprintf(f, "%s", "\"36	c #00ffd8\",\n");
	fprintf(f, "%s", "\"37	c #00ffcb\",\n");
	fprintf(f, "%s", "\"38	c #00ffc3\",\n");
	fprintf(f, "%s", "\"39	c #00ffbb\",\n");
	fprintf(f, "%s", "\"3a	c #00ffae\",\n");
	fprintf(f, "%s", "\"3b	c #00ff9d\",\n");
	fprintf(f, "%s", "\"3c	c #00ff94\",\n");
	fprintf(f, "%s", "\"3d	c #00ff87\",\n");
	fprintf(f, "%s", "\"3e	c #00ff7f\",\n");
	fprintf(f, "%s", "\"3f	c #00ff72\",\n");
	fprintf(f, "%s", "\"40	c #00ff6a\",\n");
	fprintf(f, "%s", "\"41	c #00ff59\",\n");
	fprintf(f, "%s", "\"42	c #00ff50\",\n");
	fprintf(f, "%s", "\"43	c #00ff43\",\n");
	fprintf(f, "%s", "\"44	c #00ff3b\",\n");
	fprintf(f, "%s", "\"45	c #00ff2e\",\n");
	fprintf(f, "%s", "\"46	c #00ff26\",\n");
	fprintf(f, "%s", "\"47	c #00ff15\",\n");
	fprintf(f, "%s", "\"48	c #00ff0c\",\n");
	fprintf(f, "%s", "\"49	c #00ff00\",\n");
	fprintf(f, "%s", "\"4a	c #08ff00\",\n");
	fprintf(f, "%s", "\"4b	c #15ff00\",\n");
	fprintf(f, "%s", "\"4c	c #1dff00\",\n");
	fprintf(f, "%s", "\"4d	c #2eff00\",\n");
	fprintf(f, "%s", "\"4e	c #37ff00\",\n");
	fprintf(f, "%s", "\"4f	c #43ff00\",\n");
	fprintf(f, "%s", "\"50	c #4cff00\",\n");
	fprintf(f, "%s", "\"51	c #59ff00\",\n");
	fprintf(f, "%s", "\"52	c #61ff00\",\n");
	fprintf(f, "%s", "\"53	c #72ff00\",\n");
	fprintf(f, "%s", "\"54	c #7bff00\",\n");
	fprintf(f, "%s", "\"55	c #87ff00\",\n");
	fprintf(f, "%s", "\"56	c #90ff00\",\n");
	fprintf(f, "%s", "\"57	c #9dff00\",\n");
	fprintf(f, "%s", "\"58	c #a5ff00\",\n");
	fprintf(f, "%s", "\"59	c #b6ff00\",\n");
	fprintf(f, "%s", "\"5a	c #bfff00\",\n");
	fprintf(f, "%s", "\"5b	c #cbff00\",\n");
	fprintf(f, "%s", "\"5c	c #d4ff00\",\n");
	fprintf(f, "%s", "\"5d	c #e1ff00\",\n");
	fprintf(f, "%s", "\"5e	c #f2ff00\",\n");
	fprintf(f, "%s", "\"5f	c #faff00\",\n");
	fprintf(f, "%s", "\"60	c #fffa00\",\n");
	fprintf(f, "%s", "\"61	c #ffee00\",\n");
	fprintf(f, "%s", "\"62	c #ffe500\",\n");
	fprintf(f, "%s", "\"63	c #ffd800\",\n");
	fprintf(f, "%s", "\"64	c #ffc700\",\n");
	fprintf(f, "%s", "\"65	c #ffbf00\",\n");
	fprintf(f, "%s", "\"66	c #ffb200\",\n");
	fprintf(f, "%s", "\"67	c #ffaa00\",\n");
	fprintf(f, "%s", "\"68	c #ffa100\",\n");
	fprintf(f, "%s", "\"69	c #ff9400\",\n");
	fprintf(f, "%s", "\"6a	c #ff8300\",\n");
	fprintf(f, "%s", "\"6b	c #ff7b00\",\n");
	fprintf(f, "%s", "\"6c	c #ff6e00\",\n");
	fprintf(f, "%s", "\"6d	c #ff6600\",\n");
	fprintf(f, "%s", "\"6e	c #ff5900\",\n");
	fprintf(f, "%s", "\"6f	c #ff5000\",\n");
	fprintf(f, "%s", "\"70	c #ff3f00\",\n");
	fprintf(f, "%s", "\"71	c #ff3700\",\n");
	fprintf(f, "%s", "\"72	c #ff2a00\",\n");
	fprintf(f, "%s", "\"73	c #ff2200\",\n");
	fprintf(f, "%s", "\"74	c #ff1500\",\n");
	fprintf(f, "%s", "\"75	c #ff0c00\",\n");
	fprintf(f, "%s", "\"76	c #ff0000\",\n");
	fprintf(f, "%s", "\"77	c #ff0000\",\n");
	fprintf(f, "%s", "\"78	c #ff0000\",\n");
	fprintf(f, "%s", "\"79	c #ff0000\",\n");
	fprintf(f, "%s", "\"7a	c #ff0000\",\n");
	fprintf(f, "%s", "\"7b	c #ff0000\",\n");
	fprintf(f, "%s", "\"7c	c #ff0000\",\n");
	fprintf(f, "%s", "\"7d	c #ff0000\",\n");
	fprintf(f, "%s", "\"7e	c #ff0000\",\n");
	fprintf(f, "%s", "\"7f	c #ffffff\",\n");
}

static void
dumpgreyscale(FILE *f)
{
	fprintf(f, "%s", "\"  	c #000000\",\n");
	fprintf(f, "%s", "\" 1	c #020202\",\n");
	fprintf(f, "%s", "\" 2	c #040404\",\n");
	fprintf(f, "%s", "\" 3	c #060606\",\n");
	fprintf(f, "%s", "\" 4	c #080808\",\n");
	fprintf(f, "%s", "\" 5	c #0A0A0A\",\n");
	fprintf(f, "%s", "\" 6	c #0C0C0C\",\n");
	fprintf(f, "%s", "\" 7	c #0E0E0E\",\n");
	fprintf(f, "%s", "\" 8	c #101010\",\n");
	fprintf(f, "%s", "\" 9	c #121212\",\n");
	fprintf(f, "%s", "\" a	c #141414\",\n");
	fprintf(f, "%s", "\" b	c #161616\",\n");
	fprintf(f, "%s", "\" c	c #181818\",\n");
	fprintf(f, "%s", "\" d	c #1A1A1A\",\n");
	fprintf(f, "%s", "\" e	c #1C1C1C\",\n");
	fprintf(f, "%s", "\" f	c #1E1E1E\",\n");
	fprintf(f, "%s", "\"10	c #202020\",\n");
	fprintf(f, "%s", "\"11	c #222222\",\n");
	fprintf(f, "%s", "\"12	c #242424\",\n");
	fprintf(f, "%s", "\"13	c #262626\",\n");
	fprintf(f, "%s", "\"14	c #282828\",\n");
	fprintf(f, "%s", "\"15	c #2A2A2A\",\n");
	fprintf(f, "%s", "\"16	c #2C2C2C\",\n");
	fprintf(f, "%s", "\"17	c #2E2E2E\",\n");
	fprintf(f, "%s", "\"18	c #303030\",\n");
	fprintf(f, "%s", "\"19	c #323232\",\n");
	fprintf(f, "%s", "\"1a	c #343434\",\n");
	fprintf(f, "%s", "\"1b	c #363636\",\n");
	fprintf(f, "%s", "\"1c	c #383838\",\n");
	fprintf(f, "%s", "\"1d	c #3A3A3A\",\n");
	fprintf(f, "%s", "\"1e	c #3C3C3C\",\n");
	fprintf(f, "%s", "\"1f	c #3E3E3E\",\n");
	fprintf(f, "%s", "\"20	c #404040\",\n");
	fprintf(f, "%s", "\"21	c #424242\",\n");
	fprintf(f, "%s", "\"22	c #444444\",\n");
	fprintf(f, "%s", "\"23	c #464646\",\n");
	fprintf(f, "%s", "\"24	c #484848\",\n");
	fprintf(f, "%s", "\"25	c #4A4A4A\",\n");
	fprintf(f, "%s", "\"26	c #4C4C4C\",\n");
	fprintf(f, "%s", "\"27	c #4E4E4E\",\n");
	fprintf(f, "%s", "\"28	c #505050\",\n");
	fprintf(f, "%s", "\"29	c #525252\",\n");
	fprintf(f, "%s", "\"2a	c #545454\",\n");
	fprintf(f, "%s", "\"2b	c #565656\",\n");
	fprintf(f, "%s", "\"2c	c #585858\",\n");
	fprintf(f, "%s", "\"2d	c #5A5A5A\",\n");
	fprintf(f, "%s", "\"2e	c #5C5C5C\",\n");
	fprintf(f, "%s", "\"2f	c #5E5E5E\",\n");
	fprintf(f, "%s", "\"30	c #606060\",\n");
	fprintf(f, "%s", "\"31	c #626262\",\n");
	fprintf(f, "%s", "\"32	c #646464\",\n");
	fprintf(f, "%s", "\"33	c #666666\",\n");
	fprintf(f, "%s", "\"34	c #686868\",\n");
	fprintf(f, "%s", "\"35	c #6A6A6A\",\n");
	fprintf(f, "%s", "\"36	c #6C6C6C\",\n");
	fprintf(f, "%s", "\"37	c #6E6E6E\",\n");
	fprintf(f, "%s", "\"38	c #707070\",\n");
	fprintf(f, "%s", "\"39	c #727272\",\n");
	fprintf(f, "%s", "\"3a	c #747474\",\n");
	fprintf(f, "%s", "\"3b	c #767676\",\n");
	fprintf(f, "%s", "\"3c	c #787878\",\n");
	fprintf(f, "%s", "\"3d	c #7A7A7A\",\n");
	fprintf(f, "%s", "\"3e	c #7C7C7C\",\n");
	fprintf(f, "%s", "\"3f	c #7E7E7E\",\n");
	fprintf(f, "%s", "\"40	c #808080\",\n");
	fprintf(f, "%s", "\"41	c #828282\",\n");
	fprintf(f, "%s", "\"42	c #848484\",\n");
	fprintf(f, "%s", "\"43	c #868686\",\n");
	fprintf(f, "%s", "\"44	c #888888\",\n");
	fprintf(f, "%s", "\"45	c #8A8A8A\",\n");
	fprintf(f, "%s", "\"46	c #8C8C8C\",\n");
	fprintf(f, "%s", "\"47	c #8E8E8E\",\n");
	fprintf(f, "%s", "\"48	c #909090\",\n");
	fprintf(f, "%s", "\"49	c #929292\",\n");
	fprintf(f, "%s", "\"4a	c #949494\",\n");
	fprintf(f, "%s", "\"4b	c #969696\",\n");
	fprintf(f, "%s", "\"4c	c #989898\",\n");
	fprintf(f, "%s", "\"4d	c #9A9A9A\",\n");
	fprintf(f, "%s", "\"4e	c #9C9C9C\",\n");
	fprintf(f, "%s", "\"4f	c #9E9E9E\",\n");
	fprintf(f, "%s", "\"50	c #A0A0A0\",\n");
	fprintf(f, "%s", "\"51	c #A2A2A2\",\n");
	fprintf(f, "%s", "\"52	c #A4A4A4\",\n");
	fprintf(f, "%s", "\"53	c #A6A6A6\",\n");
	fprintf(f, "%s", "\"54	c #A8A8A8\",\n");
	fprintf(f, "%s", "\"55	c #AAAAAA\",\n");
	fprintf(f, "%s", "\"56	c #ACACAC\",\n");
	fprintf(f, "%s", "\"57	c #AEAEAE\",\n");
	fprintf(f, "%s", "\"58	c #B0B0B0\",\n");
	fprintf(f, "%s", "\"59	c #B2B2B2\",\n");
	fprintf(f, "%s", "\"5a	c #B4B4B4\",\n");
	fprintf(f, "%s", "\"5b	c #B6B6B6\",\n");
	fprintf(f, "%s", "\"5c	c #B8B8B8\",\n");
	fprintf(f, "%s", "\"5d	c #BABABA\",\n");
	fprintf(f, "%s", "\"5e	c #BCBCBC\",\n");
	fprintf(f, "%s", "\"5f	c #BEBEBE\",\n");
	fprintf(f, "%s", "\"60	c #C0C0C0\",\n");
	fprintf(f, "%s", "\"61	c #C2C2C2\",\n");
	fprintf(f, "%s", "\"62	c #C4C4C4\",\n");
	fprintf(f, "%s", "\"63	c #C6C6C6\",\n");
	fprintf(f, "%s", "\"64	c #C8C8C8\",\n");
	fprintf(f, "%s", "\"65	c #CACACA\",\n");
	fprintf(f, "%s", "\"66	c #CCCCCC\",\n");
	fprintf(f, "%s", "\"67	c #CECECE\",\n");
	fprintf(f, "%s", "\"68	c #D0D0D0\",\n");
	fprintf(f, "%s", "\"69	c #D2D2D2\",\n");
	fprintf(f, "%s", "\"6a	c #D4D4D4\",\n");
	fprintf(f, "%s", "\"6b	c #D6D6D6\",\n");
	fprintf(f, "%s", "\"6c	c #D8D8D8\",\n");
	fprintf(f, "%s", "\"6d	c #DADADA\",\n");
	fprintf(f, "%s", "\"6e	c #DCDCDC\",\n");
	fprintf(f, "%s", "\"6f	c #DEDEDE\",\n");
	fprintf(f, "%s", "\"70	c #E0E0E0\",\n");
	fprintf(f, "%s", "\"71	c #E2E2E2\",\n");
	fprintf(f, "%s", "\"72	c #E4E4E4\",\n");
	fprintf(f, "%s", "\"73	c #E6E6E6\",\n");
	fprintf(f, "%s", "\"74	c #E8E8E8\",\n");
	fprintf(f, "%s", "\"75	c #EAEAEA\",\n");
	fprintf(f, "%s", "\"76	c #ECECEC\",\n");
	fprintf(f, "%s", "\"77	c #EEEEEE\",\n");
	fprintf(f, "%s", "\"78	c #F0F0F0\",\n");
	fprintf(f, "%s", "\"79	c #F2F2F2\",\n");
	fprintf(f, "%s", "\"7a	c #F4F4F4\",\n");
	fprintf(f, "%s", "\"7b	c #F6F6F6\",\n");
	fprintf(f, "%s", "\"7c	c #F8F8F8\",\n");
	fprintf(f, "%s", "\"7d	c #FAFAFA\",\n");
	fprintf(f, "%s", "\"7e	c #FCFCFC\",\n");
	fprintf(f, "%s", "\"7f	c #FEFEFE\",\n");
}

int
make_xpmf(char *fname, int nx, int ny, double *v, int ctable)
{
	int i, j, k;
	double vmax, vmin;
	FILE *f;

	if ((f = fopen(fname, "w")) == NULL)
		return(-1);
	fprintf(f, "%s", "/* XPM */\n");
	fprintf(f, "%s", "static char * Plot_7bpp[] = {\n");
	fprintf(f, "\"%d %d 128 2\",\n", nx, ny);
	switch(ctable) {
		case 2:
			dumpgp(f);
			break;
		case 1:
			dumpct39(f);
			break;
		default:
			dumpgreyscale(f);
			break;
	}
	/* End of boilerplate.  Now do ranges on the array */
	vmax = vmin = *v;
	for (i = 0; i < nx * ny; i++) {
			if (v[i] > vmax)
				vmax = v[i];
			if (v[i] < vmin)
				vmin = v[i];
	}
	if (vmax == vmin)
		vmax = vmin + 1;
	for (j = 0; j < ny; j++) {
		fprintf(f, "\"");
		for (i = 0; i < nx; i++) {
			k = ((v[i + nx * j] - vmin)/(vmax - vmin) * 127. + 0.5);
			if (k == 0)
				fprintf(f, "  ");
			else
				fprintf(f, "%2x", k);
		}
		if (j < ny - 1)
			fprintf(f, "\",\n");
		else
			fprintf(f, "\"};\n");
	}
	fclose(f);
	return(0);
}

int
make_xpmi(char *fname, int nx, int ny, int *v, int ctable)
{
	int i, j, k;
	double vmax, vmin;
	FILE *f;

	if ((f = fopen(fname, "w")) == NULL)
		return(-1);
	fprintf(f, "%s", "/* XPM */\n");
	fprintf(f, "%s", "static char * Plot_7bpp[] = {\n");
	fprintf(f, "\"%d %d 128 2\",\n", nx, ny);
	switch(ctable) {
		case 2:
			dumpgp(f);
			break;
		case 1:
			dumpct39(f);
			break;
		default:
			dumpgreyscale(f);
			break;
	}
	/* End of boilerplate.  Now do ranges on the array */
	vmax = vmin = *v;
	for (i = 0; i < nx * ny; i++) {
			if (v[i] > vmax)
				vmax = v[i];
			if (v[i] < vmin)
				vmin = v[i];
	}
	if (vmax == vmin)
		vmax = vmin + 1;
	for (j = 0; j < ny; j++) {
		fprintf(f, "\"");
		for (i = 0; i < nx; i++) {
			k = ((v[i + nx * j] - vmin)/(vmax - vmin) * 127. + 0.5);
			if (k == 0)
				fprintf(f, "  ");
			else
				fprintf(f, "%2x", k);
		}
		if (j < ny - 1)
			fprintf(f, "\",\n");
		else
			fprintf(f, "\"};\n");
	}
	fclose(f);
	return(0);
}

#ifdef TESTING
#include <stdlib.h>

int
main(int argc, char **argv)
{
	double oob[5000];
	int i, j;

	for (i = 0; i < 47; i++)
		for (j = 0; j < 91; j++) {
			oob[j + 91 * i] = 0;
			if ((35 - j) * (35 - j) + (22 - i)*(22 - i) < 25)
			oob[j + 91 * i] = i + j;
		}

	make_xpmf("dumbtest.xpm", 91, 47, oob, 1);
	make_xpmf("dumbtest2.xpm", 91, 47, oob, 0);
	/* make_xpmf("dumbtest2.xpm", 47, 91, oob, 2); */
	exit(0);
}
#endif
