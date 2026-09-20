import json
from model_desc import Layer, tile_plan

def emit_jobs(layers, array_n):
    jobs=[]
    for li,l in enumerate(layers):
        if l.op in ("conv","dwconv"):
            jobs.extend(tile_plan(l,array_n))
        else:
            jobs.append({"layer":l.name,"op":l.op,"inputs":l.inputs})
    return jobs

if __name__ == "__main__":
    layers=[
        Layer("stem", "conv", cin=3, cout=32, h=320, w=320, k=3, stride=2),
        Layer("block1", "conv", cin=32, cout=64, h=160, w=160, k=3, stride=2),
        Layer("head", "conv", cin=64, cout=255, h=20, w=20, k=1, stride=1),
    ]
    for n in (8,16):
        jobs=emit_jobs(layers,n)
        print(n, len(jobs), "jobs")
