import math

def fit_region(xs):
    ys=[1.0/(1.0+math.exp(-x)) for x in xs]
    mx=sum(xs)/len(xs); my=sum(ys)/len(ys)
    num=sum((x-mx)*(y-my) for x,y in zip(xs,ys)); den=sum((x-mx)**2 for x in xs) or 1.0
    b=num/den; a=my-b*mx; return a,b

def generate():
    coeff=[]
    for i in range(8):
        xs=[k/16 for k in range(i*16,(i+1)*16)]
        a,b=fit_region(xs); coeff.append((round(a*(1<<14)),round(b*(1<<14))))
    return coeff

if __name__=="__main__":
    for i,(a,b) in enumerate(generate()): print(i,a,b)
