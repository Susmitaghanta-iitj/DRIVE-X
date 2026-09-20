import argparse,json,math
from pathlib import Path
from approxflex_quant import QMode

MODES=[QMode.ORA8,QMode.INT4,QMode.INT2,QMode.FP4]

def norm(x,lo,hi):
    return 0.0 if hi<=lo else (x-lo)/(hi-lo)

def score(candidate,baseline,weights):
    # candidate/baseline keys: quality, latency, energy, memory
    # Higher quality is better; lower hardware metrics are better.
    qloss=max(0.0,baseline["quality"]-candidate["quality"])
    return (weights["quality"]*qloss+
            weights["latency"]*candidate["latency"]/baseline["latency"]+
            weights["energy"]*candidate["energy"]/baseline["energy"]+
            weights["memory"]*candidate["memory"]/baseline["memory"])

def greedy_search(layer_table,baseline,weights,min_quality):
    policy={}
    current=dict(baseline)
    # layer_table[layer][mode] contains measured/simulated marginal candidate stats.
    for layer,options in layer_table.items():
        best=None
        for mode_name,stats in options.items():
            cand=dict(current)
            cand["quality"]=current["quality"]-stats.get("quality_drop",0.0)
            cand["latency"]=current["latency"]-stats.get("latency_save",0.0)
            cand["energy"]=current["energy"]-stats.get("energy_save",0.0)
            cand["memory"]=current["memory"]-stats.get("memory_save",0.0)
            if cand["quality"]<min_quality:continue
            s=score(cand,baseline,weights)
            if best is None or s<best[0]:best=(s,mode_name,cand)
        if best is None:
            policy[layer]="ORA8"
        else:
            _,policy[layer],current=best
    return policy,current

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--sensitivity",required=True)
    ap.add_argument("--out",required=True)
    ap.add_argument("--min-quality",type=float,required=True)
    ap.add_argument("--w-quality",type=float,default=10.0)
    ap.add_argument("--w-latency",type=float,default=1.0)
    ap.add_argument("--w-energy",type=float,default=1.0)
    ap.add_argument("--w-memory",type=float,default=0.5)
    args=ap.parse_args()
    data=json.loads(Path(args.sensitivity).read_text())
    weights={"quality":args.w_quality,"latency":args.w_latency,"energy":args.w_energy,"memory":args.w_memory}
    policy,estimate=greedy_search(data["layers"],data["baseline"],weights,args.min_quality)
    Path(args.out).write_text(json.dumps({"type":"mixed_precision","policy":policy,"estimated":estimate,"weights":weights},indent=2))
    print("wrote",args.out)

if __name__=="__main__":main()
