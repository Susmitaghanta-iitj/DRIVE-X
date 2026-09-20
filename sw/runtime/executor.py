from model_desc import tile_plan
SUPPORTED_HW = {"conv","dwconv","add","upsample","activation"}
class Executor:
    def __init__(self,array_n=8):
        assert array_n in (8,16)
        self.array_n=array_n
    def compile(self,layers):
        jobs=[]
        for l in layers:
            if l.op in ("conv","dwconv"):
                jobs.extend(tile_plan(l,self.array_n))
            elif l.op in SUPPORTED_HW:
                jobs.append({"layer":l.name,"op":l.op})
            else:
                jobs.append({"layer":l.name,"op":"host_fallback","source_op":l.op})
        return jobs
