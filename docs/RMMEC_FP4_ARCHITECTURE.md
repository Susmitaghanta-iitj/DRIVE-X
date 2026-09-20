# ApproxFlex-YOLO v5: RMMEC2 + 2xFP4 Architecture

## Source-derived RMMEC2 behavior

The uploaded RMMEC2 block exposes:
- `pp[3:0]` for a 2-bit by 2-bit unsigned product,
- `EMax=max(E1,E2)`,
- `OE1=EMax-E1`,
- `OE2=EMax-E2`.

The uploaded RMMEC4 shows four RMMEC2 cells reused between multiplication and
exponent-comparison style operation.

## Project extension

ApproxFlex-YOLO v5 uses exactly four physical RMMEC2 cells per PE as a
reconfigurable low-precision fabric:

- Exact INT4:
  four RMMEC2 cells reconstruct one exact signed 4-bit multiplication.
- 4xINT2:
  four cells each multiply the magnitudes of one signed INT2 lane; signs are
  restored and the four products are locally reduced.
- 2xFP4 E2M1:
  cells 0/1 form FP4 lane0 and cells 2/3 form FP4 lane1.
  In each lane one RMMEC2 receives the exponents and exposes EMax/OE metadata,
  while one RMMEC2 multiplies the two-bit effective significands.

RMMEC2 alone is not a complete FP multiplier. FP multiplication still requires
sign XOR and exponent addition. This project adds those small wrapper functions
around the RMMEC2 fabric.

## FP4 design choice

This first hardware mode uses a finite-only project E2M1 convention:
- bit3 sign
- bits2:1 exponent
- bit0 fraction
- exponent bias = 1
- exponent 00 is treated as zero
- no subnormal, Inf, or NaN handling in v5
- normalized significand is `{1,fraction}` representing 1.0 or 1.5

Two FP4 products are converted to a common fixed representation with
`FP_ACC_FRAC=8`, locally summed, and fed to the same FxP24 accumulator.

## Precision modes

- 00: 1x ORA8
- 01: 1x Exact INT4 using four RMMEC2 cells
- 10: 4x signed INT2 using four RMMEC2 cells + local reduction
- 11: 2x FP4 E2M1 using two RMMEC2 cells per FP4 lane + local reduction

## K steps

- ORA8: 1
- Exact4: 1
- 4xINT2: 4
- 2xFP4: 2

## Common backend

mode product -> FxP24 -> round/shift/saturate -> INT8 S4.4
-> shared 8-PWL AF -> 16-bit AF output.
