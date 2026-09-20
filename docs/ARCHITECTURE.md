# ApproxFlex-YOLO Full Project v1

## Architectural intent

The project is a descriptor-driven object-detection accelerator with a reusable
hardware substrate rather than a hard-coded implementation of one YOLO release.

### Compute
Each PE contains:
- signed 8-bit operand-rounding approximate multiplier,
- 32-bit accumulator,
- requantization to signed S4.4,
- local configurable activation engine,
- shared 8-region Sigmoid PWL core,
- range-aware Sigmoid saturation at |u| >= 8,
- ReLU / Sigmoid / Tanh / Swish(SiLU) / GELU.

### Array
The physical array is parameterized by `ARRAY_N`.
Instantiate:
- `ARRAY_N=8` for an 8x8 array,
- `ARRAY_N=16` for a 16x16 array.

TASC masks unused rows/columns for tail tiles.

### Control
A RISC-V host controls the accelerator through AXI4-Lite registers. The current
register interface launches GEMM-like jobs using M/N/K, AF selection, requant
shift, and base addresses.

### Memory
The local-memory layer contains dual-port SRAM primitives and a banked
multi-addressable wrapper. The intended deployment has independent activation,
weight, and output bank groups with ping-pong buffering.

### DMA
The project includes a compact synthesizable AXI4 burst-read DMA seed. The next
integration step is to connect DMA writes to the banked SRAM allocator and add a
matching burst-write engine.

### Model portability
Different YOLO-family graphs are lowered into the same layer/job descriptor
format. Convolution-like operators map to tiled GEMMs. Add, concat, upsample,
and detect-head operations use the post-processing/runtime path.

The example JSON files are only style examples. Exact deployment should import
an actual ONNX graph.

## What is already complete
- arithmetic primitive,
- local AF architecture,
- 8x8/16x16 parameterized PE array,
- tail-tile masking,
- tiled M/N/K scheduler,
- AXI4-Lite control plane,
- local banked SRAM building blocks,
- AXI4 read-DMA seed,
- C RISC-V driver,
- Python descriptor/tile runtime,
- bit-accurate software golden model for ORA and AF.

## What still requires system integration
- AXI4 write DMA,
- bank allocation / ping-pong policy,
- production-grade implicit-GEMM streamer,
- padding/boundary logic,
- concat/route memory remapping,
- detection-head decode/NMS policy,
- ONNX quantization calibration and ORA-aware coefficient refit,
- cycle-accurate RTL verification against a real YOLO model,
- FPGA/ASIC constraints and synthesis scripts.
