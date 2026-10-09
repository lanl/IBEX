/*	$Id: mapread.c,v 1.7 2021/11/06 16:24:59 pjanzen Exp $	*/
/* Read in an ISOC map.  Form of returned map is an allocated-to-be-freed
 * 1-D array of double of length nlat * nlng with ordering 
 * (lat) * nlng + lng
 * Also returned: nlng and nlat.
 *
 * Returns NULL on failure; nlng and nlat may have diagnostic value in this
 * case.
 */

static const char rcsid[] = "@(#) $Id: mapread.c,v 1.7 2021/11/06 16:24:59 pjanzen Exp $";

#include <ctype.h>
#include <err.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "extern.h"
#include "xmap.h"

double *
isoc_ingest(char *fname, int verbos, int *nlng, int *nlat, char **title)
{
	FILE *fp;
	char *buf, *baz;
	size_t blen;
	ssize_t len;
	double *dat, tmp;
	int status;
	int i, j, k, nx, ny;

	*nlng = *nlat = -1;
	ny = 0; /* Hush compiler */
	dat = NULL;
	if (title)
		*title = NULL;
	if ((fp = fopen(fname, "r")) == NULL)
		return(NULL);
	buf = NULL;
	/* Haven't allocated dat yet, haven't finished reading header */
	status = 0;
	while ((len = getline(&buf, &blen, fp)) != -1) {
		/* Strip \n to match historical fgetln() call here */
		/* len > 0 always */
		if (buf[len-1] == '\n')
			buf[len-1] = '\0';
		/* Should be no blank lines.  It's either data or starts with '#' */
		/* Last comment line is '###' */
		if (buf[0] == '#') {
			if (status > 1) {
				/* out of order */
				free(dat);	/* It's ok to free(NULL) these days */
				free(buf);
				fclose(fp);
				if (verbos > 0)
					printf("ISOC file %s late comment\n", fname);
				return(NULL);
			}
			if (strcmp(buf, "###") == 0) {
				/* End of comment block.  Change status.  We need to
				 * have nlat and nlng by now.
				 */
				status = 1;
				if (*nlat < 1 || *nlng < 1) {
					free(dat);	/* It's ok to free(NULL) these days */
					free(buf);
					fclose(fp);
					if (verbos > 0)
						printf("ISOC file %s comment block ended with no size specified\n", fname);
					return(NULL);
				}
			} else
			/* Parts of block that we could parse:
			 * h_title='%s'$ is title of plot; initial range requested
			 *     is on this line with h_min= and h_max=
			 *   .. that we MUST parse:
			 * min_0=-90 max_0=90 num_0=%d title_0='%s'$; latitude split
			 * min_1=0 max_1=360 num_1=%d title_1='%s'$; longitude split
			 */
			if ((baz = strstr(buf, "h_title='"))) {
				buf[len-2] = '\0';	/* cut closing "'" */
				if (verbos > 1)
					printf("ISOC file %s title: '%s'\n", fname, 
					    baz + 9);
				if (title)
					*title = strdup(baz + 9);
			} else if ((baz = strstr(buf, " min_0="))) {
				if (sscanf(baz, " min_0=%d max_0=%d num_0=%d title_0",
				    &i , &j, &k) != 3) {
					free(dat);	/* It's ok to free(NULL) these days */
					free(buf);
					fclose(fp);
					if (verbos > 0)
						printf("ISOC file %s misread on min_0\n", fname);
					return(NULL);
				}
				if (i != -90 || j != 90 || k < 1)
					warnx("isoc_ingest: <%s> not expected latitude range",
					    buf);
				if (k < 0)
					k = abs(k);
				if (k < 1)
					k = 1;
				*nlat = k;
			} else if ((baz = strstr(buf, " min_1="))) {
				if (sscanf(baz, " min_1=%d max_1=%d num_1=%d title_1",
				    &i , &j, &k) != 3) {
					free(dat);	/* It's ok to free(NULL) these days */
					free(buf);
					fclose(fp);
					if (verbos > 0)
						printf("ISOC file %s misread on min_1\n", fname);
					return(NULL);
				}
				if (i != 0 || j != 360 || k < 1)
					warnx("isoc_ingest: <%s> not expected longitude range",
					    buf);
				if (k < 0)
					k = abs(k);
				if (k < 1)
					k = 1;
				*nlng = k;
			} else if (strstr(buf, "HEALpix!")) {
				/* non-ISOC extension in xmap save files */
				/* XXX awful kludge */
				*nlat = 1;
				*nlng = 12 * *nlng * *nlng;
			}
		} else {
			if (status < 1) {
				/* out of order */
				free(dat);	/* It's ok to free(NULL) these days */
				free(buf);
				fclose(fp);
				if (verbos > 0)
					printf("ISOC file %s early data\n", fname);
				return(NULL);
			} else {
				if (status == 1) {
					status = 2;
					if ((dat = calloc(*nlat * *nlng, sizeof(double))) == NULL) {
						free(dat);
						free(buf);
						fclose(fp);
						if (verbos > 0)
							printf("ISOC file %s malloc failure\n", fname);
						return(NULL);
					}
					ny = 0;
				}
				/* Data */
				baz = buf;
				while (*baz && isblank(*baz))
					baz++;
				nx = 0;
				while (sscanf(baz, "%lf", &tmp) == 1) {
					dat[*nlng * ny + nx] = tmp;
					nx++;
					if (nx > *nlng) {
						free(dat);
						free(buf);
						fclose(fp);
						if (verbos > 0)
							printf("ISOC file %s too many points line %d\n",
							    fname, ny+1);
						return(NULL);
					}
					while (*baz && !isblank(*baz))
						baz++;
					while (*baz && isblank(*baz))
						baz++;
				}
				if (nx != *nlng) {
					free(dat);
					free(buf);
					fclose(fp);
					if (verbos > 0)
						printf("ISOC file %s too few points line %d\n",
						    fname, ny+1);
					return(NULL);
				}
				ny++;
				nx = 0;
				if (ny > *nlat) {
					free(dat);
					free(buf);
					fclose(fp);
					if (verbos > 0)
						printf("ISOC file %s too many lines %d\n",
						    fname, ny);
					return(NULL);
				}
			}
		}
	}
	/* Could check for ferror(fp) but really everything's covered by
	 * parsing contents of file.
	 */
	if (ny != *nlat) {
		if (verbos > 0)
			printf("ISOC file %s too few lines %d\n",
			    fname, ny);
		free(dat);
		dat= NULL;
	}
	free(buf);
	fclose(fp);
	return(dat);
}

int
populate_data_isoc(char *fname[HI_ENERGIES], int whichdat, int verbos)
{
	int i, j;
	int lt, lg;
	char *foo;

	j = 0;
	clear_hist(whichdat);
	for (i = 0; i < HI_ENERGIES; i++) {
		if (fname[i] != NULL) {
			if ((dsets[whichdat].esa[i] = isoc_ingest(fname[i], verbos,
			    &lg, &lt, &foo))) {
				if (j > 0 && (dsets[whichdat].nbinlat != lt ||
				    dsets[whichdat].nbinlng != lg)) {
					warnx(
"%s not same size as prior:  bailing from populate_data_isoc()",
					    fname[i]);
					for (i = 0; i < HI_ENERGIES; i++)
						if (dsets[whichdat].filled[i] != 0) {
							free(dsets[whichdat].esa[i]);
							dsets[whichdat].filled[i] = 0;
						}
					return(-1);
				} else {
					dsets[whichdat].nbinlat = lt;
					dsets[whichdat].nbinlng = lg;
					/* Who can tell with an ISOC map? */
					dsets[whichdat].firstorbit = 0;
					dsets[whichdat].firstarc = -1;
					dsets[whichdat].lastorbit = 0;
					dsets[whichdat].lastarc = -1;
					dsets[whichdat].min[i] = 0.;
					dsets[whichdat].max[i] =
					    max_arr(dsets[whichdat].esa[i], lt * lg);
				}
				dsets[whichdat].filled[i] = 1;
				dsets[whichdat].healn = 0;
				if (j == 0)
					dsets[whichdat].name = foo;
				else
					free(foo);
				j++;
			}
		}
	}
	if (j == 0)
		return(1);
	return(0);
}
