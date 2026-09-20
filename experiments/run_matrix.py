import argparse,json,itertools
from pathlib import Path

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--suite",default="experiments/adas_suite.json")
    ap.add_argument("--out",default="experiments/generated_matrix.json")
    args=ap.parse_args()
    s=json.loads(Path(args.suite).read_text())
    rows=[]
    for task in s["tasks"]:
        rows.append({**task,"quantization":"reference"})
        rows.append({**task,"quantization":"int8_baseline"})
        for q in s["quantization"]["independent"]:
            rows.append({**task,"quantization":"independent","mode":q})
        rows.append({**task,"quantization":"mixed_precision"})
    Path(args.out).write_text(json.dumps(rows,indent=2))
    print("experiments",len(rows))

if __name__=="__main__":main()
