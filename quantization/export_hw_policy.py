import argparse,json
from pathlib import Path
MODE={'ORA8':0,'INT4':1,'INT2':2,'FP4':3}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--policy',required=True);ap.add_argument('--layers',required=True);ap.add_argument('--out',required=True);args=ap.parse_args()
 p=json.loads(Path(args.policy).read_text());mapping=p.get('policy',p.get('layers',{}));layers=[x.strip() for x in Path(args.layers).read_text().splitlines() if x.strip()];desc=[]
 for i,name in enumerate(layers):
  mode=mapping.get(name,p.get('global_mode','ORA8'));desc.append({'layer_id':i,'name':name,'prec_mode':MODE[mode],'mode':mode})
 Path(args.out).write_text(json.dumps(desc,indent=2));print('descriptors',len(desc))
if __name__=='__main__':main()
