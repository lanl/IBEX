/*	$Id: externs.c,v 1.14 2020/02/13 00:21:11 pjanzen Exp $	*/
static const char rcsid[] = "@(#) $Id: externs.c,v 1.14 2020/02/13 00:21:11 pjanzen Exp $";

#include <limits.h>
#include <stdint.h>

/* Size everything to Lo since it has the most energies/steps */
#define LO_ENERGIES (8)
#define HI_ENERGIES (6)
#define HI_AZ_BINS  (60)
/* Must match ibexhi.h */
#define BIN_TYPES (18)

typedef int garray[LO_ENERGIES][HI_AZ_BINS];

typedef struct {
	char *name;
	int flag;
	int nmax;
	int n;
	uint32_t *met;
	int *spincount;
	garray **data;
} timelog_c;  /* coinc */

timelog_c hbs[BIN_TYPES];

typedef struct {
	int spin;
	double met;
	uint32_t pktmet;
} spind;

spind *spin_times;
int nspin_times = 0;
int nmaxspin_times = 0;
int nst_256 = 0;
int nst_pps = 0;

typedef struct {
	uint32_t met;
	uint8_t  star_adj;
	uint8_t  spincount;
	uint8_t  pmt_gain;
	uint16_t sky;
	uint8_t *brightness;
} starsensord;
starsensord **ss_data;
int nss_times = 0;
int nmaxss_times = 0;

typedef struct {
	uint32_t met;
	uint32_t errmet;
	uint8_t errcode;
	uint8_t params[4];
} errlogd;
errlogd **err_log;
int nerr_log = 0;
int nmaxerr_log = 0;

typedef struct {
	uint32_t met;
	uint32_t sram_single, sram_multi, eeprom_single, eeprom_multi;
	uint32_t sd8051_single, sd8051_multi, sdpd_single, sdpd_multi;
} edacsumd;
edacsumd **edac_sum;
int nedacsum = 0;
int nmaxedacsum = 0;

typedef struct {
	uint32_t met;
	uint32_t eventmet[128];
} edaclistd;
edaclistd **edac_list;
int nedaclist = 0;
int nmaxedaclist = 0;

typedef struct {
	uint32_t met;
	uint16_t des[16];
} hided;
hided **hidetotlist;
int nhidetotlist = 0;
int nmaxhidetotlist = 0;

int HBtimeSlop;

char *mculls[8];
int defaultmcull = 0;

timelog_c tce;

uint32_t *alltimes;
int nallt;

int l_verbosity = 0;
