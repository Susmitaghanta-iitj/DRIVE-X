# AXI4-Lite register map

| Offset | Name | Description |
|---:|---|---|
| 0x00 | CONTROL/STATUS | write bit0=start; read bit1=busy, bit2=done |
| 0x04 | M_N | [15:0]=M, [31:16]=N |
| 0x08 | K | [15:0]=K |
| 0x0C | MODE | [1:0]=PREC_MODE, [4:2]=AF_SEL, [9:5]=REQUANT_SHIFT, [10]=ROUND_EN |
| 0x10 | ACT_BASE | activation base address |
| 0x14 | WT_BASE | weight base address |
| 0x18 | OUT_BASE | output base address |

## PREC_MODE

| Value | Mode |
|---:|---|
| 0 | ORA8 |
| 1 | Exact INT4 using four RMMEC2 cells |
| 2 | 4x signed INT2, locally reduced |
| 3 | 2x FP4 E2M1, locally reduced |
