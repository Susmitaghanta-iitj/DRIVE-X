import argparse,json
from pathlib import Path
from approxflex_quant import QMode

def make_policy(layer_names,mode):
    return {
        "type":"independent",
        "global_mode":mode.name,
        "layers":{name:mode.name for name in layer_names}
    }

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--layers",required=True,help="text file: one quantizable layer name per line")
    ap.add_argument("--out",default="policies")
    args=ap.parse_args()
    names=[x.strip() for x in Path(args.layers).read_text().splitlines() if x.strip()]
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    for mode in QMode:
        (out/f"independent_{mode.name.lower()}.json").write_text(json.dumps(make_policy(names,mode),indent=2))
    print("wrote",len(QMode),"independent policies to",out)

if __name__=="__main__":main()
