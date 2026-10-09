/*	$Id: retcol.c,v 1.3 2011/10/09 14:48:31 pjanzen Exp $	*/
/* Given the setup line from an IDMS file (comma separated), return the
 * column number (starting at 1, not zero) in which the requested string
 * appears.  -1 means it wasn't there.  (Don't ignore case.)
 */

#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static const char rcsid[] = "@(#) $Id: retcol.c,v 1.3 2011/10/09 14:48:31 pjanzen Exp $";

int
retcol(char *blah, char *colname, char delim)
{
	char *t, *tt;
	int i;
	char *b;

	/* Need to find start-of-line/delimiter before string and
	 * end-of-line/delimiter at string end.  Otherwise we match
	 * on just a subset.
	 */
	i = 0;
	b = blah;
	do {
		tt = strstr(b, colname);
		if (!tt)
			return(-1);
		t = tt + strlen(colname);
		/* Put in a little hack here to accommodate a space */
		if (((tt == b) || ((tt != b) &&
		    (*(tt-1) == delim || (isspace(*(tt-1)) && *(tt-2) == delim)))) &&
		    ((*t == delim) || (*t == '\n') || (*t == '\0')))
			i = 1;
		b = t;
	} while (i == 0);
	for (t = blah; t < tt; t++)
		if (*t == delim)
			i++;
	return(i);
}


/* Generalization of CSV file parsing:  return the nth string in a line,
 * delimited by char delim.  No parsing of the string.
 */
int
strcolval(char *blah, int n, char *rets, int retn, char delim)
{
	char *t;
	int i;

	i = 1;
	t = blah;
	*rets = '\0';
	while (*t && i < n) {
		if (*t == delim)
			i++;
		t++;
	}
	if (i < n)
		return(-1);
	i = 0;
	/* For this variant, trim leading whitespace */
	while (*t && (*t != delim) && isspace(*t))
		t++;
	while (*t && (*t != delim) && i < retn - 1) {
		i++;
		*rets++ = *t++;
	}
	*rets = '\0';
	return(0);
}


/* Return -1 on error */
int
intcolval(char *blah, int coln, char delim, int *retval)
{
	char locstr[100];
	long rv;

	if (strcolval(blah, coln, locstr, 100, delim) != 0)
		return(-1);
	/* In this variant we expect some hex numbers on input, so ld -> li */
	if ((sscanf(locstr, "%li", &rv) != 1) || (rv > INT_MAX || rv < INT_MIN))
		return(-1);
	*retval = (int)rv;
	return(0);
}


/* Return -1 on error */
int
uint32colval(char *blah, int coln, char delim, uint32_t *retval)
{
	char locstr[100];
	unsigned long rv;

	if (strcolval(blah, coln, locstr, 100, delim) != 0)
		return(-1);
	if ((sscanf(locstr, "%lu", &rv) != 1) || (rv > 0xFFFFFFFF))
		return(-1);
	*retval = (uint32_t)rv;
	return(0);
}


/* Return -1 on error */
int
dblcolval(char *blah, int coln, char delim, double *retval)
{
	char locstr[100];
	double rv;

	if (strcolval(blah, coln, locstr, 100, delim) != 0)
		return(-1);
	if (sscanf(locstr, "%lf", &rv) != 1)
		return(-1);
	*retval = rv;
	return(0);
}
