# ADAS Quantization Framework

This directory adds two distinct evaluation modes for ApproxFlex-YOLO.

## Independent quantization

A complete model is evaluated with one arithmetic mode at a time:

- ORA8
- Exact INT4
- 4xINT2
- 2xFP4 E2M1

This produces clean per-mode accuracy / hardware-cost baselines.

## Mixed-precision quantization

Each quantizable layer chooses one mode from:

`{ORA8, INT4, INT2, FP4}`.

The search objective is task-aware and hardware-aware. It combines normalized
accuracy degradation, accelerator latency, energy, and model/storage cost.

The policy format is JSON and can be emitted directly into ApproxFlex layer
descriptors.

## ADAS datasets

The default outside-vehicle suite uses BDD100K for:
- road-object detection,
- lane marking,
- drivable-area segmentation.

Driver-monitoring experiments use DMD for:
- gaze / head pose,
- distraction,
- hand/body/face streams.

Dataset download is intentionally not automated; users must obtain the data
under the corresponding dataset terms.
