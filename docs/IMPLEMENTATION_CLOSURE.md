# Implementation closure update

This revision closes the main architectural gaps identified after v5.

## Added

1. True systolic operand forwarding: activations move left-to-right and weights top-to-bottom through registered PE links.
2. Packed K-tail masking for 4xINT2 and 2xFP4; invalid tail lanes are zeroed.
3. Saturating FxP24 accumulation using a 25-bit overflow check.
4. Memory-to-compute bridge for unpacking local SRAM words into array-edge vectors.
5. Exhaustive software verification for Exact4 (16x16), packed 4xINT2 (256x256 byte pairs), and FP4 primitive (16x16 nibbles).

## Still requires external validation

- AXI protocol compliance needs HDL simulation/formal verification.
- Real YOLO validation needs a target ONNX model and trained weights.
- mAP/PPA needs model execution and FPGA/ASIC tools.
- NMS remains a RISC-V software responsibility by default.
- FP4 remains the documented finite-only E2M1 project format.
