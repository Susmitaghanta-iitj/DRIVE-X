# ADAS experiment protocol

For every task report the floating/reference model, exact INT8 baseline, independent ORA8, INT4, INT2, FP4, and mixed ApproxFlex precision policy. Pair task quality with hardware metrics. The default hardware-cost JSON contains placeholders only; replace it with post-synthesis measurements before publication.

BDD100K slices should include overall plus daytime/night and weather subsets when sample count is sufficient. DMD evaluation should report gaze/head-pose angular error separately from distraction/hands metrics.
