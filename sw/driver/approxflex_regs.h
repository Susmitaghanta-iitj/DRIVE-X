#ifndef APPROXFLEX_REGS_H
#define APPROXFLEX_REGS_H

#define AF_REG_CTRL      0x00
#define AF_REG_MN        0x04
#define AF_REG_K         0x08
#define AF_REG_MODE      0x0C
#define AF_REG_ACT_BASE  0x10
#define AF_REG_WT_BASE   0x14
#define AF_REG_OUT_BASE  0x18

#define AF_CTRL_START    (1u<<0)
#define AF_STAT_BUSY     (1u<<1)
#define AF_STAT_DONE     (1u<<2)

enum {
    PREC_ORA8  = 0,
    PREC_EX4   = 1,
    PREC_4X2   = 2,
    PREC_2XFP4 = 3
};

enum {
    AF_RELU  = 0,
    AF_SIG   = 1,
    AF_TANH  = 2,
    AF_SWISH = 3,
    AF_GELU  = 4
};

#define AF_MODE_WORD(prec,af,rq,round_en) \
    (((prec)&0x3u) | (((af)&0x7u)<<2) | (((rq)&0x1fu)<<5) | (((round_en)&0x1u)<<10))

#endif
