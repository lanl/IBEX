#	$Id: Makefile,v 1.6 2021/11/29 20:24:44 pjanzen Exp $

PROG= xmap
# add callbacks.c
SRCS= DrawingA.c Dialog.c apue.c callbacks.c extern.c kbd.c mappage.c \
	mapread.c abrate.c healpix.c hist2d.c ipointing.c Xdraw.c Xinit.c \
	menus.c xmap.c
# CFLAGS= -g
CFLAGS+= -W -Wall -DTHREADS -I/usr/X11R6/include -I/usr/local/include
# Uses vectors.c from libibexhi, but not libibexhi itself.
CFLAGS+= -W -Wall -I${.CURDIR}/../libibexhi
LDADD= -L/usr/X11R6/lib -lXaw -lXmu -lXt -lX11 -lcurses -lm -lpthread
#	-L${.CURDIR}/../libibexhi/obj -libexhi -lm -lz
#	 -L${.CURDIR}/../localccsds/obj -lccsds -L/usr/local/lib -lcspice -lm -lz
# Xaw3d looks worse here
NOMAN= noman

.include <bsd.prog.mk>
