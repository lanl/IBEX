# $Id: Makefile,v 1.32 2020/02/13 00:21:11 pjanzen Exp $

LIB=    ibexhi
CFLAGS+= -W -Wall -I${.CURDIR}/../localccsds -I/usr/local/include
CFLAGS+= -I${.CURDIR}/../mpfit # -DDO_PS
## CFLAGS += -DDO_SINGLES
SRCS=   asa239.c crc.c \
	makexpm.c pprintf.c retcol.c \
	externs.c bursts.c hbunhb.c processhb.c readhb.c readhk.c readsweep.c \
	osdb.c readewind.c realspice.c processcull.c sepsearch.c \
	sheath.c dode.c hi_de_gbc.c isoofs.c readpointing.c vectors.c util.c \
	spininfo.c hi_de_pj.c decull.c penbg.c iongun.c Hi_cal.c mpfit.c
# depends on -L${.CURDIR}/../localccsds/obj -lccsds -lm
# Ignore for now the headers on which it depends.

NOPROFILE= noprofile
NOPIC=     nopic

.PATH:  ${.CURDIR}/../response ${.CURDIR}/../mpfit

.include <bsd.lib.mk>
