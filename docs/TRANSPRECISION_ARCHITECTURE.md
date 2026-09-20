# ApproxFlex-YOLO v4 Transprecision Philosophy

## Arithmetic modes per PE

The revised PE supports four runtime modes:

| PREC_MODE | Mode | Meaning |
|---|---|---|
| 00 | ORA8 | one signed 8-bit operand-rounding approximate multiplication |
| 01 | EX4 | one exact signed 4-bit multiplication |
| 10 | 4X2 | four signed INT2 multiplies reduced locally to one scalar dot-product contribution |
| 11 | EX5 | one exact signed 5-bit multiplication |

The 4X2 mode does not create four accumulators. It computes:

Psum = a0*b0 + a1*b1 + a2*b2 + a3*b3

and feeds Psum into the same single FxP24 accumulator used by all other modes.

## Common accumulation path

mode-specific product
-> sign extension
-> single signed FxP24 accumulator
-> programmable round/shift
-> saturation to signed INT8
-> interpret as S4.4
-> shared range-aware 8-PWL activation engine
-> 16-bit AF output

## K stepping

ORA8 / EX4 / EX5 process one logical K element per cycle.

4X2 processes four logical K elements per cycle because four INT2 values are packed in one byte.
The tile scheduler therefore increments K by 4 in PREC_4X2 mode.

## Memory packing

ORA8, EX4 and EX5: one logical operand per byte.

4X2: four two-bit signed operands packed per byte:
  bits[1:0] = lane0
  bits[3:2] = lane1
  bits[5:4] = lane2
  bits[7:6] = lane3

## Activation

All precision modes converge to the same post-accumulation activation format:
FxP24 -> requantize -> signed INT8 S4.4 -> AF.

The AF engine remains:
ReLU / Sigmoid / Tanh / Swish(SiLU) / GELU
with one shared eight-region Sigmoid PWL kernel and range saturation at |u| >= 8.
