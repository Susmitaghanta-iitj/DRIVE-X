# All-in-one project milestones

This repository now contains all architectural milestones in one tree.

## M0 Arithmetic
- 8-to-5 operand rounder
- signed ORA multiplier
- 32-bit accumulation
- software golden model

## M1 Activation
- shared 8-region Sigmoid PWL
- range clamp/saturation at |u|>=8
- ReLU
- Sigmoid
- Tanh = 2*sigmoid(2x)-1
- Swish/SiLU
- logistic GELU

## M2 Processing element
- local MAC + ACC + AF
- per-PE enable
- requantization

## M3 Configurable systolic array
- ARRAY_N=8 or 16
- row/column masking
- tail-tile utilization control

## M4 Control plane
- AXI4-Lite registers
- descriptor FIFO
- layer execution FSM
- RISC-V C driver
- software queue

## M5 Memory hierarchy
- dual-port SRAM
- banked multi-address memory
- ping-pong buffers
- activation / weight / output local storage

## M6 DMA
- AXI4 burst read
- AXI4 burst write
- combined DMA shell

## M7 Convolution mapping
- M/N/K tiling
- padding-aware implicit-GEMM address generation
- vector unpack/pack utilities

## M8 YOLO graph operators
- convolution
- depthwise convolution descriptor
- residual add
- concat/route runtime support path
- 2x nearest-neighbor upsample
- activation nodes
- detection-head handoff

## M9 YOLO portability
- ONNX lowering entry point
- descriptor/job compiler
- generic style configs for YOLO families
- unsupported-op host fallback

## M10 Postprocessing
- RISC-V decode/NMS path as default
- optional hardware NMS control shell

## M11 Verification
- Python ORA golden model
- AF golden model
- basic tests
- calibration helper
- sigmoid coefficient refit helper

## M12 PPA / deployment hooks
- file list
- parameterized 8x8/16x16 builds
- synthesis-ready RTL module structure

## Remaining before claiming a finished detector
The architecture is all present, but real detector validation still requires:
1. import one exact quantized YOLO ONNX model,
2. fill tensor shapes/weights from that model,
3. verify every graph operator or use host fallback,
4. run cycle-accurate RTL against the software golden model,
5. compare mAP against exact INT8 and floating-point baselines,
6. run FPGA/ASIC synthesis and timing.

These are validation tasks, not missing architectural milestones.
