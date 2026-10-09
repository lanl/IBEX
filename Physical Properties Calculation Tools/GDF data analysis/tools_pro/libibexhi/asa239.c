/*	$Id: asa239.c,v 1.1 2010/06/22 01:03:41 pjanzen Exp $	*/
/* Note: the website from where I got this,
 * http://people.sc.fsu.edu/~burkardt/cpp_src/cpp_src.html ,
 * had additional functions on this file which I did not need; they had an
 * explicit LGPL restriction.  That part's been replaced.
 *
 * The ASA code (Applied Statistics Algorithms) is an odder case.
 * See the STATLIB world:  basically, this are all published algorithms,
 * and "The Royal Statistical Society holds the copyright to these
 * routines, but has given its permission for their distribution provided
 * that no fee is charged."
 *
 * Now, the Royal Stat Soc wrote it in Fortran, I think, and for anything
 * like statlib we get the qualifier "No guarantee is given that the
 * algorithms have been entered correctly, or that they perform as claimed
 * in the journal."
 *
 * But I think I'm all right using this.
 * Note that alngam should simply duplicate lgamma() in libm.
 * There was a function gamma_inc_values() which was never used, so I
 * killed it.
 * I've made everything static but for the one function I expect to call
 * remotely, gammad().  The debugging code at the end is also my code.
 */
static const char rcsid[] = "@(#) $Id: asa239.c,v 1.1 2010/06/22 01:03:41 pjanzen Exp $";
#include <math.h>
#include <stdio.h>
#include <stdlib.h>


/*****************************************************************************
 *
 *  Purpose:
 *
 *    ALNGAM computes the logarithm of the gamma function.
 *
 *  Modified:
 *
 *    13 January 2008
 *
 *  Author:
 *
 *    Allan Macleod
 *    C++ version by John Burkardt
 *
 *  Reference:
 *
 *    Allan Macleod,
 *    Algorithm AS 245,
 *    A Robust and Reliable Algorithm for the Logarithm of the Gamma Function,
 *    Applied Statistics,
 *    Volume 38, Number 2, 1989, pages 397-402.
 *
 *  Parameters:
 *
 *    Input, double XVALUE, the argument of the Gamma function.
 *
 *    Output, int IFAULT, error flag.
 *    0, no error occurred.
 *    1, XVALUE is less than or equal to 0.
 *    2, XVALUE is too big.
 *
 *    Output, double ALNGAM, the logarithm of the gamma function of X.
 */
static double
alngam ( double xvalue, int *ifault )
{
  double alr2pi = 0.918938533204673;
  double r1[9] = {
    -2.66685511495, 
    -24.4387534237, 
    -21.9698958928, 
     11.1667541262, 
     3.13060547623, 
     0.607771387771, 
     11.9400905721, 
     31.4690115749, 
     15.2346874070 };
  double r2[9] = {
    -78.3359299449, 
    -142.046296688, 
     137.519416416, 
     78.6994924154, 
     4.16438922228, 
     47.0668766060, 
     313.399215894, 
     263.505074721, 
     43.3400022514 };
  double r3[9] = {
    -2.12159572323E+05, 
     2.30661510616E+05, 
     2.74647644705E+04, 
    -4.02621119975E+04, 
    -2.29660729780E+03, 
    -1.16328495004E+05, 
    -1.46025937511E+05, 
    -2.42357409629E+04, 
    -5.70691009324E+02 };
  double r4[5] = {
     0.279195317918525, 
     0.4917317610505968, 
     0.0692910599291889, 
     3.350343815022304, 
     6.012459259764103 };
  double value;
  double x;
  double x1;
  double x2;
  double xlge = 510000.0;
  double xlgst = 1.0E+30;
  double y;

  x = xvalue;
  value = 0.0;

/*  Check the input. */

  if ( xlgst <= x )
  {
    *ifault = 2;
    return value;
  }

  if ( x <= 0.0 )
  {
    *ifault = 1;
    return value;
  }

  *ifault = 0;

/*  Calculation for 0 < X < 0.5 and 0.5 <= X < 1.5 combined. */

  if ( x < 1.5 )
  {
    if ( x < 0.5 )
    {
      value = - log ( x );
      y = x + 1.0;

/*  Test whether X < machine epsilon. */

      if ( y == 1.0 )
      {
        return value;
      }
    }
    else
    {
      value = 0.0;
      y = x;
      x = ( x - 0.5 ) - 0.5;
    }

    value = value + x * (((( 
        r1[4]   * y 
      + r1[3] ) * y 
      + r1[2] ) * y 
      + r1[1] ) * y 
      + r1[0] ) / (((( 
                  y 
      + r1[8] ) * y 
      + r1[7] ) * y 
      + r1[6] ) * y 
      + r1[5] );

    return value;
  }

/*  Calculation for 1.5 <= X < 4.0. */

  if ( x < 4.0 )
  {
    y = ( x - 1.0 ) - 1.0;

    value = y * (((( 
        r2[4]   * x 
      + r2[3] ) * x 
      + r2[2] ) * x 
      + r2[1] ) * x 
      + r2[0] ) / (((( 
                  x 
      + r2[8] ) * x 
      + r2[7] ) * x 
      + r2[6] ) * x 
      + r2[5] );
  }

/*  Calculation for 4.0 <= X < 12.0. */

  else if ( x < 12.0 ) 
  {
    value = (((( 
        r3[4]   * x 
      + r3[3] ) * x 
      + r3[2] ) * x 
      + r3[1] ) * x 
      + r3[0] ) / (((( 
                  x 
      + r3[8] ) * x 
      + r3[7] ) * x 
      + r3[6] ) * x 
      + r3[5] );
  }

/*  Calculation for 12.0 <= X. */

  else
  {
    y = log ( x );
    value = x * ( y - 1.0 ) - 0.5 * y + alr2pi;

    if ( x <= xlge )
    {
      x1 = 1.0 / x;
      x2 = x1 * x1;

      value = value + x1 * ( ( 
             r4[2]   * 
        x2 + r4[1] ) * 
        x2 + r4[0] ) / ( ( 
        x2 + r4[4] ) * 
        x2 + r4[3] );
    }
  }

  return value;
}


/****************************************************************************
 *
 *  Purpose:
 *
 *    ALNORM computes the cumulative density of the standard normal distribution.
 *
 *  Modified:
 *
 *    17 January 2008
 *
 *  Author:
 *
 *    David Hill
 *    C++ version by John Burkardt
 *
 *  Reference:
 *
 *    David Hill,
 *    Algorithm AS 66:
 *    The Normal Integral,
 *    Applied Statistics,
 *    Volume 22, Number 3, 1973, pages 424-427.
 *
 *  Parameters:
 *
 *    Input, double X, is one endpoint of the semi-infinite interval
 *    over which the integration takes place.
 *
 *    Input, bool UPPER, determines whether the upper or lower
 *    interval is to be integrated:
 *    .TRUE.  => integrate from X to + Infinity;
 *    .FALSE. => integrate from - Infinity to X.
 *
 *    Output, double ALNORM, the integral of the standard normal
 *    distribution over the desired interval.
 */
static double
alnorm ( double x, int upper )
{
  double a1 = 5.75885480458;
  double a2 = 2.62433121679;
  double a3 = 5.92885724438;
  double b1 = -29.8213557807;
  double b2 = 48.6959930692;
  double c1 = -0.000000038052;
  double c2 = 0.000398064794;
  double c3 = -0.151679116635;
  double c4 = 4.8385912808;
  double c5 = 0.742380924027;
  double c6 = 3.99019417011;
  double con = 1.28;
  double d1 = 1.00000615302;
  double d2 = 1.98615381364;
  double d3 = 5.29330324926;
  double d4 = -15.1508972451;
  double d5 = 30.789933034;
  double ltone = 7.0;
  double p = 0.398942280444;
  double q = 0.39990348504;
  double r = 0.398942280385;
  int up;
  double utzero = 18.66;
  double value;
  double y;
  double z;

  up = upper;
  z = x;

  if ( z < 0.0 )
  {
    up = !up;
    z = - z;
  }

  if ( ltone < z && ( ( !up ) || utzero < z ) )
  {
    if ( up )
    {
      value = 0.0;
    }
    else
    {
      value = 1.0;
    }
    return value;
  }

  y = 0.5 * z * z;

  if ( z <= con )
  {
    value = 0.5 - z * ( p - q * y 
      / ( y + a1 + b1 
      / ( y + a2 + b2 
      / ( y + a3 ))));
  }
  else
  {
    value = r * exp ( - y ) 
      / ( z + c1 + d1 
      / ( z + c2 + d2 
      / ( z + c3 + d3 
      / ( z + c4 + d4 
      / ( z + c5 + d5 
      / ( z + c6 ))))));
  }

  if ( !up )
  {
    value = 1.0 - value;
  }

  return value;
}


/****************************************************************************
 *
 *  Purpose:
 *
 *    GAMMAD computes the Incomplete Gamma Integral
 *
 *  Auxiliary functions:
 *
 *    ALOGAM = logarithm of the gamma function, 
 *    ALNORM = algorithm AS66
 *
 *  Modified:
 *
 *    20 January 2008
 *
 *  Author:
 *
 *    B Shea
 *    C++ version by John Burkardt
 *
 *  Reference:
 *
 *    B Shea,
 *    Algorithm AS 239:
 *    Chi-squared and Incomplete Gamma Integral,
 *    Applied Statistics,
 *    Volume 37, Number 3, 1988, pages 466-473.
 *
 *  Parameters:
 *
 *    Input, double X, P, the parameters of the incomplete 
 *    gamma ratio.  0 <= X, and 0 < P.
 *
 *    Output, int IFAULT, error flag.
 *    0, no error.
 *    1, X < 0 or P <= 0.
 *
 *    Output, double GAMMAD, the value of the incomplete 
 *    Gamma integral.
 */
double gammad ( double x, double p, int *ifault )
{
  double a;
  double an;
  double arg;
  double b;
  double c;
  double elimit = - 88.0;
  double oflo = 1.0E+37;
  double plimit = 1000.0;
  double pn1;
  double pn2;
  double pn3;
  double pn4;
  double pn5;
  double pn6;
  double rn;
  double tol = 1.0E-14;
  int upper;
  double value;
  double xbig = 1.0E+08;

  value = 0.0;

/*  Check the input. */

  if ( x < 0.0 )
  {
    *ifault = 1;
    return value;
  }

  if ( p <= 0.0 )
  {
    *ifault = 1;
    return value;
  }

  *ifault = 0;

  if ( x == 0.0 )
  {
    value = 0.0;
    return value;
  }

/*  If P is large, use a normal approximation. */

  if ( plimit < p )
  {
    pn1 = 3.0 * sqrt ( p ) * ( pow ( x / p, 1.0 / 3.0 ) 
    + 1.0 / ( 9.0 * p ) - 1.0 );

    upper = 0;	/* false */
    value = alnorm ( pn1, upper );
    return value;
  }

/*  If X is large set value = 1. */

  if ( xbig < x )
  {
    value = 1.0;
    return value;
  }

/*  Use Pearson's series expansion.
 *  (Note that P is not large enough to force overflow in ALOGAM).
 *  No need to test IFAULT on exit since P > 0.
 */
  if ( x <= 1.0 || x < p )
  {
    arg = p * log ( x ) - x - alngam ( p + 1.0, ifault );
    c = 1.0;
    value = 1.0;
    a = p;

    for ( ; ; )
    {
      a = a + 1.0;
      c = c * x / a;
      value = value + c;

      if ( c <= tol )
      {
        break;
      }
    }

    arg = arg + log ( value );

    if ( elimit <= arg )
    {
      value = exp ( arg );
    }
    else
    {
      value = 0.0;
    }
  }

/*  Use a continued fraction expansion. */

  else 
  {
    arg = p * log ( x ) - x - alngam ( p, ifault );
    a = 1.0 - p;
    b = a + x + 1.0;
    c = 0.0;
    pn1 = 1.0;
    pn2 = x;
    pn3 = x + 1.0;
    pn4 = x * b;
    value = pn3 / pn4;

    for ( ; ; )
    {
      a = a + 1.0;
      b = b + 2.0;
      c = c + 1.0;
      an = a * c;
      pn5 = b * pn3 - an * pn1;
      pn6 = b * pn4 - an * pn2;

      if ( pn6 != 0.0 )
      {
        rn = pn5 / pn6;

        if ( ((value - rn >= 0.0) ? value - rn : rn - value) <=
             ((tol < tol * rn)  ? tol : tol * rn ) )
        {
          break;
        }
        value = rn;
      }

      pn1 = pn3;
      pn2 = pn4;
      pn3 = pn5;
      pn4 = pn6;

/*  Re-scale terms in continued fraction if terms are large. */

      if ( oflo <= abs ( pn5 ) )
      {
        pn1 = pn1 / oflo;
        pn2 = pn2 / oflo;
        pn3 = pn3 / oflo;
        pn4 = pn4 / oflo;
      }
    }

    arg = arg + log ( value );

    if ( elimit <= arg )
    {
      value = 1.0 - exp ( arg );
    }
    else
    {
      value = 1.0;
    }
  }

  return value;
}



#ifdef TESTING
double
poiss(double lamb, int n)
{
	int i;
	double tmp;

	tmp = 1.;
	for (i = 1; i <= n; i++)
		tmp *= i;
	return(exp(-lamb) * pow(lamb, n) / tmp);
}


int
main()
{
	double a, b;
	int i, j;

	/* Note the order of the arguments is REVERSED wrt Num Rec -
	 * the second argument is the parameter and the first is x.
	 */
	printf("Enter two arguments\n");
	scanf("%lf%lf", &a, &b);
	printf("Incomplete gamma returns: %lf\n", 
	    gammad(a, b, &i));
	printf("return error code %d\n", i);
	for (i = 0; i < 150; i++)
		printf("%lf %lf %lf\n", i/10.,
		    gammad(i/10., 10., &j), gammad(i/10., 3., &j));

	for (i = 0; i < 16; i++) {
		printf("%d %lf %lf\n", i, poiss(13.52, i), gammad(13.52, i, &j) -
		    gammad(13.52, i+1, &j));
	}

	exit(0);
}
#endif
