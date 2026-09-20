def detection_summary(tp,fp,fn):
    precision=tp/max(1,tp+fp);recall=tp/max(1,tp+fn)
    f1=2*precision*recall/max(1e-12,precision+recall)
    return {"precision":precision,"recall":recall,"f1":f1}

def segmentation_iou(intersection,union):
    return intersection/max(1,union)

def angular_error_deg(pred,true):
    import math
    dot=sum(a*b for a,b in zip(pred,true))
    np=math.sqrt(sum(a*a for a in pred));nt=math.sqrt(sum(a*a for a in true))
    c=max(-1.0,min(1.0,dot/max(1e-12,np*nt)))
    return math.degrees(math.acos(c))
