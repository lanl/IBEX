/*	$Id: pprintf.c,v 1.4 2016/09/03 03:24:34 pjanzen Exp $	*/
/* Priority-based printing.  Hardwired stdout and stderr as two functions. */

static const char rcsid[] = "@(#) $Id: pprintf.c,v 1.4 2016/09/03 03:24:34 pjanzen Exp $";

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "ibexhi.h"

static int log_initialized = 0;
static int *log_cts;
static int log_n;


static void
addlogcount(int vbs)
{
	if (log_initialized && vbs >= 0 && vbs < log_n)
		log_cts[vbs]++;
}

int
pprintf(int vbs, const char *s, ...)
{
	va_list ap;
	int i;

	i = 0;
	addlogcount(vbs);
	if (vbs <= l_verbosity) {
		va_start(ap, s);
		i = vprintf(s, ap);
		va_end(ap);
	}
	return(i);
}


/* The idea here is that if you've asked for REALLY quiet, you don't even
 * want to see fatal error messages.
 */
int
errpprintf(int vbs, const char *s, ...)
{
	va_list ap;
	int i;

	i = 0;
	addlogcount(vbs);
	if (vbs <= l_verbosity) {
		va_start(ap, s);
		i = vfprintf(stderr, s, ap);
		va_end(ap);
	}
	return(i);
}

/* Log how many requests at each verbosity, for future use. */
void
pprintloginit(int num)
{
	if (log_initialized)
		free(log_cts);
	if (num <= 0)
		log_initialized = 0;
	else if ((log_cts = (int *)calloc(sizeof(int), num)) == NULL)
		log_initialized = 0;
	else {
		log_n = num;
		log_initialized = 1;
	}
}


int
pprintlogct(int num)
{
	if (log_initialized && num >= 0 && num < log_n)
		return(log_cts[num]);
	return(0);
}
