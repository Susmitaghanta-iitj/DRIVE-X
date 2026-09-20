# v2 integration

Added in this drop:
1. AXI4 burst write DMA.
2. Ping-pong local buffer primitive.
3. Descriptor FIFO for RISC-V queued execution.
4. Padding-aware implicit-GEMM address streamer.
5. Post-processing dispatcher seed.
6. More tolerant ONNX graph importer.

## End-to-end intended execution

RISC-V/ONNX runtime
-> descriptor FIFO
-> AXI DMA prefetch
-> inactive ping-pong SRAM bank
-> tile scheduler/TASC
-> implicit-GEMM streamer
-> 8x8 or 16x16 ApproxFlex array
-> local shared-Sigmoid AF
-> output SRAM
-> AXI write DMA
-> RISC-V detection decode/NMS

## Why NMS remains software initially

NMS is control-heavy and model/postprocessing dependent. Keeping it on the
RISC-V host makes the first accelerator usable across different YOLO heads.
A hardware NMS block can be added after profiling establishes it as a bottleneck.

## Verification gate before PPA claims

Do not claim end-to-end YOLO functionality until:
- real quantized ONNX graph is lowered,
- every operator is supported or intentionally delegated,
- RTL arithmetic is cross-checked against the golden model,
- DMA/bank addressing is verified,
- detections/mAP are compared against the exact quantized baseline.
