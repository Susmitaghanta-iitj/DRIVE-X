from __future__ import annotations
from dataclasses import dataclass
from enum import IntEnum
from typing import Dict, Iterable, List, Tuple
import math

class QMode(IntEnum):
    ORA8 = 0
    INT4 = 1
    INT2 = 2
    FP4  = 3

@dataclass
class QuantTensor:
    values: List[float]
    scale: float
    mode: QMode

def percentile_abs(values: Iterable[float], percentile: float=0.999) -> float:
    xs=sorted(abs(float(x)) for x in values)
    if not xs: return 1.0
    i=max(0,min(len(xs)-1,int(percentile*(len(xs)-1))))
    return max(xs[i],1e-12)

def symmetric_scale(values: Iterable[float], qmax: int, percentile: float=0.999) -> float:
    return percentile_abs(values,percentile)/float(qmax)

def quant_int(values: Iterable[float], bits: int, percentile: float=0.999) -> QuantTensor:
    qmax=(1<<(bits-1))-1
    qmin=-(1<<(bits-1))
    vals=list(values)
    scale=symmetric_scale(vals,qmax,percentile)
    q=[max(qmin,min(qmax,int(round(x/scale)))) for x in vals]
    return QuantTensor(q,scale,QMode.INT4 if bits==4 else QMode.INT2)

def ora8_round_mag(x: int) -> Tuple[int,int]:
    x=abs(int(x))
    if x<=31:return x,0
    if x<=63:return ((x>>2)<<1)|((x>>1)&1),1
    if x<=127:return (((x>>4)&7)<<2)|(((x>>3)&1)<<1)|((x>>1)&1),2
    return (((x>>6)&3)<<3)|(((x>>5)&1)<<2)|(((x>>3)&1)<<1)|((x>>1)&1),3

def ora8_product(a: int,b: int) -> int:
    ar,sa=ora8_round_mag(a);br,sb=ora8_round_mag(b)
    p=(ar*br)<<(sa+sb)
    return -p if ((a<0)^(b<0)) else p

# Project FP4: finite-only E2M1, bias=1, exp00=zero.
FP4_TABLE=[]
for code in range(16):
    s=(code>>3)&1;e=(code>>1)&3;f=code&1
    if e==0:v=0.0
    else:v=(1.0+0.5*f)*(2.0**(e-1))
    FP4_TABLE.append(-v if s else v)

def quant_fp4_scalar(x: float) -> int:
    return min(range(16),key=lambda i:abs(FP4_TABLE[i]-float(x)))

def dequant_fp4(code: int) -> float:
    return FP4_TABLE[code&0xf]

def quantize(values: Iterable[float], mode: QMode, percentile: float=0.999):
    vals=list(values)
    if mode==QMode.ORA8:
        scale=symmetric_scale(vals,127,percentile)
        return [max(-128,min(127,int(round(v/scale)))) for v in vals],scale
    if mode==QMode.INT4:
        q=quant_int(vals,4,percentile);return q.values,q.scale
    if mode==QMode.INT2:
        q=quant_int(vals,2,percentile);return q.values,q.scale
    if mode==QMode.FP4:
        # Per-tensor power-of-two scale keeps conversion hardware-friendly.
        amax=percentile_abs(vals,percentile)
        max_fp=max(abs(v) for v in FP4_TABLE) or 1.0
        raw=amax/max_fp
        scale=2.0**round(math.log2(max(raw,1e-12)))
        return [quant_fp4_scalar(v/scale) for v in vals],scale
    raise ValueError(mode)

def dequantize(q,scale,mode):
    if mode==QMode.FP4:return [dequant_fp4(x)*scale for x in q]
    return [float(x)*scale for x in q]
