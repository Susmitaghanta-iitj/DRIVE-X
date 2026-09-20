import argparse,json
from pathlib import Path

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--root",required=True)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()
    root=Path(args.root);rows=[]
    for p in root.rglob("*.mp4"):
        low=str(p).lower()
        view="face" if "face" in low else "hands" if "hand" in low else "body" if "body" in low else "unknown"
        rows.append({"video":str(p),"view":view})
    Path(args.out).write_text("\n".join(json.dumps(x) for x in rows))
    print("videos",len(rows))

if __name__=="__main__":main()
