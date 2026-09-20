import argparse,json
from pathlib import Path

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--images",required=True)
    ap.add_argument("--masks",required=True)
    ap.add_argument("--task",choices=["lane","drivable"],required=True)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()
    images=Path(args.images);masks=Path(args.masks)
    rows=[]
    for im in sorted(images.glob("*")):
        if not im.is_file():continue
        candidates=[masks/(im.stem+".png"),masks/im.name]
        mask=next((x for x in candidates if x.exists()),None)
        if mask:rows.append({"image":str(im),"mask":str(mask),"task":args.task})
    Path(args.out).write_text("\n".join(json.dumps(x) for x in rows))
    print("pairs",len(rows))

if __name__=="__main__":main()
