/*
 * $Id: hi_de_pack.h,v 1.1 2010/07/03 04:25:53 pjanzen Exp $
 *
 * HI DE packing test material definitions
 *
 * This is semantically equivalent to what is in the SSR after culling
 * together with some test implementation routines.  Eventually this
 * morphs into something usable.
 */

#ifndef hi_de_pack_h
#define hi_de_pack_h

typedef unsigned short	PKTword;
typedef unsigned char	PKTbyte;

/* #include "ceu_types.h" */
/* WAS
 * ceu_types.h
 *
 * A few types needed for common code.
 *
 * I haven't named this file types.h because there are too many files
 * of that name floating about....
 */

#ifndef BYTE_WORD_DWORD
#define BYTE_WORD_DWORD
typedef unsigned char   BYTE;
typedef   signed char  SBYTE;
typedef unsigned short  WORD;
typedef   signed short SWORD;
typedef unsigned int   DWORD;
#endif /* BYTE_WORD_DWORD */

/*
 * End of ceu_types.h
 */

/*
 * This is not identical to PLFW working structure,
 * but it contains the same information
 */
typedef struct test_hide {
	/* Cf. HI DE TimeTag */
	PKTword	timestamp;	/* 12 bits of timestamp */
	/* Cf. HI DE CoinType */
	PKTbyte	type;		/* 0..15 lookup values */
	/* Cf. HI DE TMflag */
	PKTbyte	yn;		/* 1 == send, 2 == skip, 0 == empty */
} HI_DE;

typedef struct test_lode {
	PKTword timestamp;
	PKTbyte type;
	PKTbyte yn;
	PKTbyte	status[4];
	PKTword toffs[4];
} LO_DE;

/*
 * for storing either one
 */
typedef union hilo_de {
	HI_DE	hi;		/* 4 bytes */
	LO_DE	lo;		/* 16 bytes */
	BYTE	ssr[16];	/* don't care */
} DEVENT;

typedef union hilo_de_ptr {
	HI_DE	*hip;
	LO_DE	*lop;
	BYTE	*ptr;
} DE_PTR;

#define HI_SIZE		sizeof(HI_DE)
#define LO_SIZE		sizeof(LO_DE)

/* different flags might be used on flight */
#define TM_ZIP		0	/* open slot */
#define TM_YES		1	/* event caught & telemetered */
#define TM_NOT		2	/* event caught, but discarded */

/* maximum direct events per spin bin */
#define MAX_DE_BIN	512	/* 4B/event in 512B block * 2 blocks */
#define MAX_DE_KEEP	255	/* fits in 8 bits */
#ifndef DE_PRELOAD
#define DE_PRELOAD	5
#endif /* DE_PRELOAD */
#ifndef RAND_RETRIES
#define RAND_RETRIES	2
#endif /* RAND_RETRIES */

/* maximum direct events to pack */
#define MAX_DE_PKT	3200	/* for storage; scheme breaks at 4095 */
#define MAX_DE_NOM	800	/* nominal value is 800 */
#define DE_TS_BITS	12

#define NTYPES		16
#define NSPINS		12	/* 2 Energies/Spin * 6 steps */
#define NAZIMS		60

#ifndef USE_NEW_CULL_PACK
#define USE_NEW_CULL_PACK 0
#endif /* USE_NEW_CULL_PACK */

/*
 * Basic Packet structure:
 *
 +++	first and spare bytes first
 +++	then a counter of number of packed bytes.
 *
 * pack_hide() generates the packed list of:
 *
 *	16 12-bit counters of total DE detected.
 *	16 12-bit flags, one flag word per type, one bit per spin, 
 *	  1 == data present, 0 == data absent
 *	list of violator offsets
 *	  (first one is offset to timestamps)
 *	  (last one is total number of events)
 *	list of timestamps.
 *
 +++	checksum
 *
 * Pack order is by SPIN (and then TYPE within each spin)
 */
#define DE_ABSENT	0x0
#define DE_PRESENT	0x1

/*
 * For the present we will wire up 15s/spin and 4.20 ms / tick
 * which means that timestamps are at most 3579.97 < 3580
#define TS_US_PER_TICK	4200
 */

#endif /* hi_de_pack_h */

/*
 * eof
 */
