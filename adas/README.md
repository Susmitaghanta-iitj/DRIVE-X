# ADAS Evaluation Suite

ApproxFlex-YOLO uses ADAS as the application umbrella.

## Primary outside-vehicle dataset: BDD100K

Supported experiment adapters:
- road-object detection,
- lane marking,
- drivable-area segmentation.

The scripts consume user-downloaded BDD100K data and do not redistribute it.

## Driver monitoring: DMD

The DMD manifest builder targets RGB face/body/hands streams and OpenLABEL-style
annotations. Dataset access and use remain subject to DMD's terms.

## Experiment structure

For every task:

1. floating/reference model,
2. INT8 baseline,
3. independent ORA8,
4. independent INT4,
5. independent INT2,
6. independent FP4,
7. hardware-aware mixed precision.

The mixed policy is exported as per-layer ApproxFlex precision modes.
