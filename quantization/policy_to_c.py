import argparse,json
from pathlib import Path
MODE={'ORA8':'PREC_ORA8','INT4':'PREC_EX4','INT2':'PREC_4X2','FP4':'PREC_2XFP4'}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--descriptors',required=True);ap.add_argument('--out',required=True);args=ap.parse_args();ds=json.loads(Path(args.descriptors).read_text())
 lines=['#include "approxflex_regs.h"','typedef struct { unsigned layer_id; unsigned prec_mode; } approxflex_precision_desc_t;','const approxflex_precision_desc_t approxflex_precision_policy[] = {']
 for d in ds:lines.append('  {%d, %s}, /* %s */'%(d['layer_id'],MODE[d['mode']],d['name']))
 lines+=['};','const unsigned approxflex_precision_policy_count = %d;'%len(ds)];Path(args.out).write_text('\n'.join(lines)+'\n')
if __name__=='__main__':main()
