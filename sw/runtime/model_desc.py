from dataclasses import dataclass
from typing import List, Optional

PREC_ORA8, PREC_EX4, PREC_4X2, PREC_2XFP4 = range(4)
AF_RELU, AF_SIG, AF_TANH, AF_SWISH, AF_GELU = range(5)

@dataclass
class Layer:
    name: str
    op: str
    cin: int = 0
    cout: int = 0
    h: int = 0
    w: int = 0
    k: int = 1
    stride: int = 1
    pad: int = 0
    prec_mode: int = PREC_ORA8
    af: int = AF_SWISH
    rq_shift: int = 8
    round_en: int = 1
    inputs: Optional[List[int]] = None
    def gemm_dims(self):
        if self.op == "conv": return self.cout, self.h*self.w, self.cin*self.k*self.k
        if self.op == "dwconv": return self.cout, self.h*self.w, self.k*self.k
        return None

def k_step_for_mode(mode):
    if mode == PREC_4X2: return 4
    if mode == PREC_2XFP4: return 2
    return 1

def tile_plan(layer: Layer, array_n: int):
    dims=layer.gemm_dims()
    if not dims:return []
    m,n,k=dims; jobs=[]
    for mo in range(0,m,array_n):
        for no in range(0,n,array_n):
            jobs.append({"layer":layer.name,"m_off":mo,"n_off":no,"rows":min(array_n,m-mo),"cols":min(array_n,n-no),"k":k,"k_step":k_step_for_mode(layer.prec_mode),"prec_mode":layer.prec_mode,"af":layer.af,"rq_shift":layer.rq_shift,"round_en":layer.round_en})
    return jobs
