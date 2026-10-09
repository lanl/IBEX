/*	$Id: apue.c,v 1.1 2018/02/22 01:25:51 pjanzen Exp $	*/
/*	These routines are taken from or based on ones from "Advanced
 *	Programming in the Unix Environment", by W. Richard Stevens.
 *  Pulled from xmca code from Harvard-SAO use.  Signal handling
 *  cleaned and X-ified.
 */

static const char rcsid[] = "@(#) $Id: apue.c,v 1.1 2018/02/22 01:25:51 pjanzen Exp $";

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

static struct termios	save_termios;
static int				ttysavefd = -1;
static enum { RESET, RAW, CBREAK }	ttystate = RESET;

/* These two are now in Xinit.c so as to use the X11R6 interrupt interface.
 * They are simple shells for what's in this file.
 */
void tty_suspend_interrupt(int);
void tty_quit_interrupt(int);

int
tty_cbreak(int fd)	/* put terminal into a cbreak mode */
{
	struct termios	buf;

	if (tcgetattr(fd, &save_termios) < 0)
		return(-1);

	buf = save_termios;	/* structure copy */

	buf.c_lflag &= ~(ECHO | ICANON);
					/* echo off, canonical mode off */

	buf.c_cc[VMIN] = 1;	/* Case B: 1 byte at a time, no timer */
	buf.c_cc[VTIME] = 0;

	if (tcsetattr(fd, TCSAFLUSH, &buf) < 0)
		return(-1);
	ttystate = CBREAK;
	ttysavefd = fd;
	return(0);
}

#if 0	/* We don't need this */
int
tty_raw(int fd)		/* put terminal into a raw mode */
{
	struct termios	buf;

	if (tcgetattr(fd, &save_termios) < 0)
		return(-1);

	buf = save_termios;	/* structure copy */

	buf.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
					/* echo off, canonical mode off, extended input
					   processing off, signal chars off */

	buf.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
					/* no SIGINT on BREAK, CR-to-NL off, input parity
					   check off, don't strip 8th bit on input,
					   output flow control off */

	buf.c_cflag &= ~(CSIZE | PARENB);
					/* clear size bits, parity checking off */
	buf.c_cflag |= CS8;
					/* set 8 bits/char */

	buf.c_oflag &= ~(OPOST);
					/* output processing off */

	buf.c_cc[VMIN] = 1;	/* Case B: 1 byte at a time, no timer */
	buf.c_cc[VTIME] = 0;

	if (tcsetattr(fd, TCSAFLUSH, &buf) < 0)
		return(-1);
	ttystate = RAW;
	ttysavefd = fd;
	return(0);
}
#endif

int
tty_reset(int fd)		/* restore terminal's mode */
{
	int i;

	if (ttystate != CBREAK && ttystate != RAW)
		return(0);

	/* We may already be backgrounded if we're in a shell; don't die. */
	signal(SIGTTOU, SIG_IGN);
	i = tcsetattr(fd, TCSAFLUSH, &save_termios);
	signal(SIGTTOU, SIG_DFL);
	if (i < 0)
		return(-1);
	ttystate = RESET;
	return(0);
}

void
tty_atexit(void)		/* can be set up by atexit(tty_atexit) */
{
	if (ttysavefd >= 0)
		tty_reset(ttysavefd);
}

#if 0	/* Not needed */
struct termios *
tty_termios(void)		/* let caller see original tty state */
{
	return(&save_termios);
}
#endif

void
tty_suspend(void)
{
	if (ttysavefd >= 0)
		tty_reset(ttysavefd);
	fflush(stdout);
	kill(getpid(), SIGSTOP);
	/* signal(SIGTSTP, tty_suspend_interrupt);  NO LONGER NEEDED */
	/* Assume we started in cbreak mode.  This is reasonable */
	tty_cbreak(STDIN_FILENO);
}

void
tty_quit(void)
{
	exit(1);	/* atexit() should catch this. */
}
