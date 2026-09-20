**DRIVE-X: Adaptive-Precision Vision Inference Engine for Driver-Assistance**

**DRIVE-X** explores the central question: *how far can an ADAS accelerator push runtime precision flexibility and low-bit SIMD efficiency while preserving task quality through hardware-aware precision selection?*
It is a hardware-software research framework for **transprecision, hardware-aware YOLO-family inference for Advanced Driver Assistance Systems (ADAS)**. It combines a reconfigurable low-precision processing element, parameterized systolic arrays, mixed-precision quantization, RISC-V/AXI-oriented control, local memory and DMA building blocks, software/runtime utilities, and ADAS evaluation adapters.

The current RMMEC architecture supports four runtime arithmetic modes: **ORA8**, **exact INT4**, **4×INT2 SIMD**, and **2×FP4 E2M1**. All modes converge into a common saturating **FxP24 accumulator**, requantization path, and shared configurable activation backend.


## Highlights

| Capability | Implementation |
|---|---|
| Precision modes | ORA8, exact INT4, 4×INT2, 2×FP4 E2M1 |
| Low-precision fabric | Four physical RMMEC2 cells per PE |
| Accumulation | One saturating signed FxP24 accumulator per PE |
| Activation | Shared range-aware 8-region PWL sigmoid-based engine |
| Activation functions | ReLU, Sigmoid, Tanh, Swish/SiLU, GELU-oriented path |
| Arrays | Parameterized 8×8 and 16×16 configurations |
| Dataflow | Registered systolic forwarding |
| Tail support | TASC/tile masking and packed K-tail masking |
| Control | RISC-V-oriented host + AXI4-Lite |
| Memory | Banked SRAM and ping-pong buffering primitives |
| Data movement | AXI DMA building blocks |
| Quantization | Independent and hardware-aware mixed precision |
| ADAS datasets | BDD100K and DMD adapters |

## Research Motivation

ADAS perception has strict latency, bandwidth, energy, and compute constraints. A single fixed numeric format can be inefficient because different neural-network layers have different sensitivity to approximation and quantization.This approach investigates a common physical compute substrate that can change precision at runtime, exploit additional SIMD parallelism at low precision, retain a common wide accumulator, and select precision layer-by-layer according to task quality and hardware cost.

The intended research flow is:

```text
ADAS / YOLO model
      |
      v
Quantization + layer sensitivity
      |
      v
Per-model or per-layer precision policy
 ORA8 / INT4 / INT2 / FP4
      |
      v
ONNX/model lowering + descriptors
      |
      v
RISC-V / AXI control + scheduler
      |
      v
DMA + banked local memory
      |
      v
8x8 / 16x16 systolic compute array
      |
      v
transprecision PE
      |
      v
FxP24 accumulation
      |
      v
Requantization + shared activation (FXP8/16)
      |
      v
Post-processing / ADAS output
```

## Transprecision Processing Element

The RMMEC-PE uses **four RMMEC2 cells** as a reusable low-precision arithmetic fabric. The same cells are reorganized according to the active precision mode rather than duplicating a separate datapath for every format.

### ORA8

ORA8 performs one signed 8-bit operand-rounding approximate multiplication per compute step. This mode provides the high-precision approximate path for studying the accuracy/hardware trade-off of approximate multiplication.

### Exact INT4

Four RMMEC2 cells cooperate to reconstruct one exact signed 4-bit multiplication. The result enters the same common accumulation path used by the other modes.

### 4×INT2 SIMD

The four RMMEC2 cells operate as four signed INT2 lanes:

```text
Psum = a0*b0 + a1*b1 + a2*b2 + a3*b3
```

The four products are locally reduced before the single FxP24 accumulator. Four signed 2-bit values are packed into one byte:

```text
bits [1:0] = lane 0
bits [3:2] = lane 1
bits [5:4] = lane 2
bits [7:6] = lane 3
```

This allows four logical K elements to be consumed per packed step.

### 2×FP4 E2M1

The RMMEC2 fabric is split into two FP4 lanes. Cells 0/1 support FP4 lane 0 and cells 2/3 support FP4 lane 1. RMMEC2 contributes significand multiplication and exponent-comparison metadata; wrapper logic supplies sign XOR, exponent processing, conversion, and reduction.

Two FP4 products are converted to a common fixed representation, locally summed, and accumulated through the shared FxP24 backend.

## FP4 Convention

The current project uses a finite-only E2M1 convention:

```text
bit 3    : sign
bits 2:1 : exponent
bit 0    : fraction
bias     : 1
```

Exponent `00` is treated as zero. The current architecture does not implement subnormals, Inf, or NaN. The normalized significand represents 1.0 or 1.5. This is a project-specific architectural convention and is not intended as full IEEE floating-point compliance.

## Common Accumulation and Activation Path

All precision modes converge to:

```text
mode-specific product
        -> sign extension / format conversion
        -> saturating FxP24 accumulator
        -> programmable round / shift
        -> saturation / requantization
        -> signed INT8 S4.4
        -> shared activation engine
        -> 16-bit activation output
```

The common accumulator is important: low-bit SIMD increases arithmetic parallelism without requiring four independent full-width accumulators.

The activation subsystem contains a shared, range-aware, eight-region piecewise-linear sigmoid approximation. The project uses this common nonlinear kernel to support ReLU, Sigmoid, Tanh, Swish/SiLU, and GELU-oriented activation paths.

## Systolic Array

The compute array is parameterized by `ARRAY_N`.

- `ARRAY_N=8`: 8×8 array / 64 PEs.
- `ARRAY_N=16`: 16×16 array / 256 PEs.

The design uses registered systolic forwarding. Tail control masks unused rows, columns, and packed lanes when matrix dimensions are not exact multiples of the physical array or SIMD packing factor.

Precision-aware K stepping is:

| Mode | Logical K elements per packed step |
|---|---:|
| ORA8 | 1 |
| INT4 | 1 |
| INT2 | 4 |
| FP4 | 2 |

## Control, Scheduling, Memory, and DMA

The control path includes AXI4-Lite register logic, descriptor FIFO support, layer execution logic, convolution address generation, precision-aware address adaptation, packed operand handling, output packing, and tile scheduling. A RISC-V host is the intended software control point.

The memory subsystem contains dual-port SRAM primitives, banked multi-address memory, a local-memory subsystem, and ping-pong buffering. The intended deployment separates activation, weight, and output traffic into bank groups and overlaps movement with computation where possible.

The repository also contains AXI DMA building blocks. The read-side DMA is an integration seed; full production-quality write-side and bank-allocation integration remains future work.

## YOLO Mapping

It is a reusable substrate rather than a fixed RTL implementation of YOLOv3, YOLOv5, or YOLOv8, are provided under `configs/`.

The intended mapping is:

```text
ADAS model
   -> ONNX graph
   -> operator lowering
   -> Conv/linear operators -> implicit GEMM -> tiled systolic execution
   -> Add/route/upsample/detection operators -> runtime/post-processing
```

The JSON files are examples. A real deployment should import and lower the actual trained model graph.

## ADAS Evaluation

### BDD100K

The BDD100K adapters target outside-vehicle perception:

- road-object detection,
- lane marking,
- drivable-area segmentation.

Manifest utilities are under `adas/bdd100k/`. For publication-quality experiments, report overall results and relevant daytime/nighttime and weather subsets when sample counts are sufficient.

### DMD

The DMD adapter targets driver-monitoring experiments involving face/body/hands RGB streams, gaze/head pose, and distraction-related tasks. Utilities are under `adas/dmd/`.

Datasets are not redistributed or automatically downloaded. Obtain them from their official providers and comply with their licenses and terms.

## Quantization Framework

The `quantization/` directory supports two different studies.

### Independent quantization

A complete quantizable model is evaluated using one arithmetic mode at a time:

- floating/reference model,
- exact INT8 baseline,
- ORA8,
- exact INT4,
- 4×INT2,
- 2×FP4 E2M1.

This creates clean per-mode quality and hardware-cost baselines.

### Hardware-aware mixed precision

Each quantizable layer may select one mode from `{ORA8, INT4, INT2, FP4}`. The search can combine task-quality degradation with accelerator latency, energy, and model/storage cost.

Important utilities include:

- `quantization/approxflex_quant.py`
- `quantization/independent_quant.py`
- `quantization/layer_sensitivity.py`
- `quantization/mixed_precision_search.py`
- `quantization/export_hw_policy.py`
- `quantization/policy_to_c.py`

The resulting policy can be exported to the hardware/runtime layer descriptor flow.

## Repository Structure

```text
DRIVE-X/
├── adas/                 # ADAS datasets, manifests and metrics
│   ├── bdd100k/
│   └── dmd/
├── configs/              # 8x8/16x16 and YOLO-style configurations
├── docs/                 # Architecture, register map and build notes
├── experiments/          # ADAS experiment definitions and matrix runner
├── hardware_cost/        # Hardware cost model and placeholder defaults
├── quantization/         # Independent/mixed precision framework
├── rtl/
│   ├── control/          # AXI control, scheduling, packing, addressing
│   ├── core/             # PE, arithmetic, arrays, accumulator, activation
│   ├── dma/              # AXI DMA building blocks
│   ├── memory/           # SRAM, banking and ping-pong buffers
│   ├── postproc/         # Upsample, residual, NMS/post-processing seeds
│   ├── rmmec/            # RMMEC2 primitive
│   ├── system/           # Memory/compute integration
│   └── top/              # ApproxFlex-YOLO top-level RTL
├── scripts/              # RTL file list
├── sim/                  # Golden model and arithmetic/RTL tests
├── sw/
│   ├── driver/           # RISC-V-oriented C driver/register interface
│   └── runtime/          # Calibration, ONNX lowering and job emission
├── Makefile
└── README.md
```

## Quick Start

### Requirements

The repository's basic arithmetic checks use Python 3. RTL simulation requires a SystemVerilog simulator compatible with the source files. ONNX/model experiments may require additional Python ML dependencies depending on the workflow being used.

Clone the repository:

```bash
git clone https://github.com/mukullokhande99/DRIVE-X.git
cd DRIVE-X
```

Run the complete lightweight verification flow:

```bash
make allcheck
```

Individual targets:

```bash
make test
make golden
make exhaustive
make list
```

`make allcheck` runs the project test, golden-model checks, exhaustive arithmetic checks, and the PWL sigmoid refit utility.

## Verification

The `sim/` directory contains:

- `golden_model.py`: software arithmetic/activation reference model.
- `exhaustive_arithmetic.py`: arithmetic-space checks.
- `test_project.py`: project-level Python checks.
- `tb_rmmec_pe.sv`: SystemVerilog PE testbench.

For publishable results, extend verification beyond these lightweight checks to cycle-accurate RTL/model comparison, randomized packed-tail cases, real network traces, synthesis/PnR timing, and end-to-end task-quality validation.

## Configuration

Project configurations include:

```text
configs/project_config_8x8.json
configs/project_config_16x16.json
configs/yolo_v3_style.json
configs/yolo_v5_style.json
configs/yolo_v8_style.json
```

Architecture documentation is available in:

```text
docs/ARCHITECTURE.md
docs/RMMEC_FP4_ARCHITECTURE.md
docs/TRANSPRECISION_ARCHITECTURE.md
docs/REGISTER_MAP.md
docs/ALL_MILESTONES.md
```

## Software Runtime

The `sw/driver/` directory contains the C-side register and queue interface. The `sw/runtime/` directory contains utilities for model descriptions, ONNX lowering, calibration, job emission, execution scaffolding, and PWL coefficient fitting.

The intended software flow is:

```text
trained model
 -> calibration / quantization
 -> ONNX/model lowering
 -> ApproxFlex model description
 -> precision policy
 -> layer/tile jobs
 -> C driver / AXI registers
 -> accelerator
```

## Current Implementation Status

Implemented or represented in the repository:

- ORA8 arithmetic path.
- RMMEC2-based INT4/INT2/FP4 fabric.
- common FxP24 accumulation.
- shared activation architecture.
- parameterized 8×8/16×16 systolic arrays.
- registered systolic forwarding.
- tail-tile and packed-lane masking.
- precision-aware scheduling/address support.
- AXI4-Lite control plane.
- banked SRAM/ping-pong primitives.
- DMA building blocks.
- C driver/runtime scaffolding.
- bit-oriented software golden/reference models.
- ADAS dataset adapters.
- independent and mixed-precision search infrastructure.

System-level work still appropriate for further integration/validation includes:

- production-grade AXI write DMA and memory allocation,
- complete ping-pong scheduling across real network layers,
- production implicit-GEMM streaming and boundary/padding logic,
- concat/route remapping,
- full detection-head decode/NMS integration,
- real ONNX calibration and ORA-aware coefficient refitting,
- cycle-accurate full-model RTL validation,
- FPGA/ASIC constraints, synthesis and physical-design flows,
- replacement of placeholder hardware costs with measured/post-synthesis data.



## License

No explicit license file is currently included in the repository. Unless a license is added, standard copyright restrictions apply. Add an appropriate `LICENSE` file before distributing or reusing the project under specific open-source terms.



