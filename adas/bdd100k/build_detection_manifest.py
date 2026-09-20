import argparse,json
from pathlib import Path

KEEP={"car","truck","bus","person","rider","bike","motor","traffic sign","traffic light"}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--labels",required=True)
    ap.add_argument("--images",required=True)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()
    labels=json.loads(Path(args.labels).read_text())
    rows=[]
    for frame in labels:
        objects=[]
        for lab in frame.get("labels",[]):
            cat=lab.get("category","")
            if cat not in KEEP or "box2d" not in lab:continue
            b=lab["box2d"]
            objects.append({"class":cat,"xyxy":[b["x1"],b["y1"],b["x2"],b["y2"]]})
        rows.append({"image":str(Path(args.images)/frame["name"]),"objects":objects,"attributes":frame.get("attributes",{})})
    Path(args.out).write_text("\n".join(json.dumps(x) for x in rows))
    print("frames",len(rows))

if __name__=="__main__":main()
