import json, math, statistics

def choose_symmetric_int8_scale(values, percentile=0.999):
    vals=sorted(abs(float(v)) for v in values)
    if not vals: return 1.0
    idx=min(len(vals)-1,max(0,int(percentile*(len(vals)-1))))
    amax=max(vals[idx],1e-12)
    return amax/127.0

def quantize_int8(values, scale):
    out=[]
    for v in values:
        q=round(float(v)/scale)
        out.append(max(-128,min(127,q)))
    return out

def save_calibration(path, table):
    with open(path,"w") as f: json.dump(table,f,indent=2)
