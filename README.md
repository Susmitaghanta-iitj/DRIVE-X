# ApproxFlex-YOLO RMMEC-FP4

Transprecision ADAS accelerator with ORA8, exact INT4, 4xINT2, 2xFP4 E2M1, one saturating FxP24 accumulator per PE, shared range-aware 8-PWL activation, true registered systolic forwarding, 8x8/16x16 arrays, TASC, packed K-tail masking, RISC-V/AXI control, DMA and banked/ping-pong memory building blocks.

## ADAS quantization

Two distinct studies are supported: independent quantization, where the complete quantizable model uses one of ORA8/INT4/INT2/FP4; and mixed-precision quantization, where each layer selects one of those modes under task-quality and hardware-cost constraints.

Primary dataset adapters are BDD100K for road-object detection, lane marking, and drivable-area segmentation, and DMD for driver gaze/head pose, distraction, and hands/body/face RGB streams. Dataset download is not automated; obtain data from the official providers and follow their terms.

Key directories: `rtl/`, `quantization/`, `adas/`, `hardware_cost/`, `experiments/`, and `sim/`.

Run `make allcheck` for arithmetic checks.
