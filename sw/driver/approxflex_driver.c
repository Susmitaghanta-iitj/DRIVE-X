#include "approxflex_driver.h"
#include "approxflex_regs.h"

static inline void wr32(uintptr_t a,uint32_t v){*(volatile uint32_t*)a=v;}
static inline uint32_t rd32(uintptr_t a){return *(volatile uint32_t*)a;}

void approxflex_launch(approxflex_dev_t *d,const approxflex_job_t *j){
    wr32(d->base+AF_REG_MN,((uint32_t)j->n<<16)|j->m);
    wr32(d->base+AF_REG_K,j->k);
    wr32(d->base+AF_REG_MODE,AF_MODE_WORD(j->prec_mode,j->af_sel,j->requant_shift,j->round_en));
    wr32(d->base+AF_REG_ACT_BASE,j->act_base);
    wr32(d->base+AF_REG_WT_BASE,j->wt_base);
    wr32(d->base+AF_REG_OUT_BASE,j->out_base);
    wr32(d->base+AF_REG_CTRL,AF_CTRL_START);
}
int approxflex_busy(approxflex_dev_t *d){return !!(rd32(d->base+AF_REG_CTRL)&AF_STAT_BUSY);}
int approxflex_done(approxflex_dev_t *d){return !!(rd32(d->base+AF_REG_CTRL)&AF_STAT_DONE);}
