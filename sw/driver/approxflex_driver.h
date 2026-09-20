#ifndef APPROXFLEX_DRIVER_H
#define APPROXFLEX_DRIVER_H
#include <stdint.h>

typedef struct { uintptr_t base; } approxflex_dev_t;

typedef struct {
    uint16_t m,n,k;
    uint8_t prec_mode;
    uint8_t af_sel;
    uint8_t requant_shift;
    uint8_t round_en;
    uint32_t act_base,wt_base,out_base;
} approxflex_job_t;

void approxflex_launch(approxflex_dev_t *d,const approxflex_job_t *j);
int approxflex_busy(approxflex_dev_t *d);
int approxflex_done(approxflex_dev_t *d);
#endif
