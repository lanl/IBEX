/*	$Id: util.c,v 1.2 2013/08/01 23:43:04 pjanzen Exp $	*/
/* Various utility functions */
static const char rcsid[] = "@(#) $Id: util.c,v 1.2 2013/08/01 23:43:04 pjanzen Exp $";

#include <err.h>
#include <math.h>
#include <string.h>

char *
laststrstr(char *big, char *little)
{
	char *p, *q, *qq;

	p = big;
	qq = NULL;
	while ((q = strstr(p, little))) {
		qq = q;
		p = q + strlen(little);
	}
	return(qq);
}


int
bitsofchar(char c)
{
	int i;

	for (i = 0; c; i++)
		c &= c-1;
	return(i);
}


/* Just find the min and max values in an array of doubles.
 */
void
mon_minmax(double *y, int n, double *min, double *max)
{
	int i;
	
	*min = *max = y[0];
	for (i = 1; i < n; i++) {
		if (y[i] > *max)
			*max = y[i];
		else if (y[i] < *min)
			*min = y[i];
	}
}

/* Do a linear fit to a set of data.
 *
 * Returned:  a, b, da, db, and r^2 from y = a + b x
 */
void
mon_linear_fit(double *x, double *y, int n, double *a, double *da,
    double *b, double *db, double *rsq)
{
	double sx, sy, sxy, sx2, sy2;
	double delta;
	double syy;
	int i;
	
	if (n < 3) {
		warnx("mon_linear_fit: not enough data points");
		return;
	}
	sx = sy = sxy = sx2 = sy2 = 0.0;
	for (i = 0; i < n; i++) {
		sx += x[i];
		sx2 += x[i] * x[i];
		sxy += x[i] * y[i];
		sy += 1.0 * y[i];
		sy2 += 1.0 * y[i] * y[i];
	}
	delta = n * sx2 - sx * sx;	/* Can't be zero */
	*a = (sx2 * sy - sx * sxy) / delta;
	*b = (n * sxy - sx * sy) / delta;
	syy = (sy2 + n * (*a)*(*a) + (*b)*(*b)*sx2 - 2.0*((*a)*sy + (*b)*sxy -
		  (*a)*(*b)*sx)) / (n - 2);
	*da = sqrt(syy * sx2 / delta);
	*db = sqrt(syy * n / delta);
	*rsq = sxy - sx * sy / n;
	*rsq *= *rsq;
	delta = ((sx2 - sx * sx/n) * (sy2 - sy * sy/n));
	if (delta == 0)
		*rsq = 1.0;
	else
		*rsq /= delta;
}

/* Just like a linear fit, only now it's just an average.
 */
void
mon_avg(double *y, int n, double *a, double *da)
{
	double sx, sx2;
	int i;
	
	if (n < 1) {
		warnx("mon_avg: not enough points");
		return;
	}
	sx = sx2 = 0.0;
	for (i = 0; i < n; i++) {
		sx += (double)*(y + i);
		sx2 += (double)*(y + i) * (double)*(y+i);
	}
	*a = sx / n;
	*da = sqrt((sx2 - sx * sx / n) / (n - 1));
}


#ifdef TESTING
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char **argv)
{
	char foo[5000], goo[50], *p;
	int a;
	unsigned char c;

	printf("First string:  ");
	fgets(foo, 5000, stdin);
	foo[strcspn(foo, "\n")] = '\0'; /* Trim \n */
	printf("Search string:  ");
	fgets(goo, 50, stdin);
	goo[strcspn(goo, "\n")] = '\0'; /* Trim \n */
	p = laststrstr(foo, goo);
	printf("Last instance of search in first:  %s\n", p?p:"NONE");
	printf("Enter a number:  ");
	fgets(goo, 50, stdin);
	a = atoi(goo);
	c = (a & 0xFF);
	printf("Bits set in %d:  %d\n", (unsigned int)c, bitsofchar(c));
	return(0);
}
#endif
