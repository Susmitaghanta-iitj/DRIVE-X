import argparse,json,subprocess,tempfile
from pathlib import Path

MODES=["ORA8","INT4","INT2","FP4"]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--layers",required=True)
    ap.add_argument("--evaluator",required=True,help="command template; receives POLICY_JSON env var")
    ap.add_argument("--baseline-quality",type=float,required=True)
    ap.add_argument("--baseline-latency",type=float,required=True)
    ap.add_argument("--baseline-energy",type=float,required=True)
    ap.add_argument("--baseline-memory",type=float,required=True)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()
    layers=[x.strip() for x in Path(args.layers).read_text().splitlines() if x.strip()]
    result={"baseline":{"quality":args.baseline_quality,"latency":args.baseline_latency,"energy":args.baseline_energy,"memory":args.baseline_memory},"layers":{}}
    # Evaluator contract is intentionally external: it should emit one JSON object
    # with quality_drop/latency_save/energy_save/memory_save for a one-layer perturbation.
    import os
    for layer in layers:
        result["layers"][layer]={}
        for mode in MODES:
            policy={"type":"sensitivity","layers":{layer:mode}}
            with tempfile.NamedTemporaryFile("w",suffix=".json",delete=False) as f:
                json.dump(policy,f);p=f.name
            env=dict(os.environ);env["POLICY_JSON"]=p
            cp=subprocess.run(args.evaluator,shell=True,env=env,capture_output=True,text=True,check=True)
            result["layers"][layer][mode]=json.loads(cp.stdout)
            Path(p).unlink(missing_ok=True)
    Path(args.out).write_text(json.dumps(result,indent=2))

if __name__=="__main__":main()
