import argparse,json,math
from pathlib import Path

def estimate(layers,policy,costs,array_n):
    cycles=0.0;energy=0.0;bits=0
    for l in layers:
        mode=policy.get(l["name"],"ORA8")
        c=costs[mode]
        m,n,k=l["m"],l["n"],l["k"]
        tiles=math.ceil(m/array_n)*math.ceil(n/array_n)
        cycles += tiles*k*c["latency_per_k"]
        energy += tiles*k*c["energy_per_k"]*array_n*array_n
        bits += l.get("params",0)*c["bits_per_value"]
    return {"latency":cycles,"energy":energy,"memory":bits/8.0}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--layers",required=True)
    ap.add_argument("--policy",required=True)
    ap.add_argument("--costs",default="hardware_cost/default_costs.json")
    ap.add_argument("--array",type=int,choices=[8,16],default=8)
    args=ap.parse_args()
    layers=json.loads(Path(args.layers).read_text())
    pobj=json.loads(Path(args.policy).read_text())
    policy=pobj.get("policy",pobj.get("layers",{}))
    costs=json.loads(Path(args.costs).read_text())
    print(json.dumps(estimate(layers,policy,costs,args.array),indent=2))

if __name__=="__main__":main()
