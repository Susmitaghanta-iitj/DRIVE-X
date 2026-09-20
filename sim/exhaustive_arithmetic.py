from golden_model import *

def test_exact4():
    for a in range(16):
        for b in range(16):
            got=product_by_mode(a,b,PREC_EX4)
            exp=sext(a,4)*sext(b,4)
            assert got==exp,(a,b,got,exp)

def test_int2():
    for a in range(256):
        aa=int2_lanes(a)
        for b in range(256):
            bb=int2_lanes(b)
            got=product_by_mode(a,b,PREC_4X2)
            exp=sum(x*y for x,y in zip(aa,bb))
            assert got==exp,(a,b,got,exp)

def test_fp4_pair():
    # Exhaustive nibble-pair product primitive: 16 x 16.
    for a in range(16):
        for b in range(16):
            packed_a=pack_fp4(a,0)
            packed_b=pack_fp4(b,0)
            got=product_by_mode(packed_a,packed_b,PREC_2XFP4)
            exp=int(round(fp4_e2m1_to_real(a)*fp4_e2m1_to_real(b)*(1<<FP_ACC_FRAC)))
            assert got==exp,(a,b,got,exp)

if __name__=="__main__":
    test_exact4(); print("Exact4 exhaustive PASS")
    test_int2(); print("4xINT2 exhaustive 256x256 PASS")
    test_fp4_pair(); print("FP4 primitive exhaustive 16x16 PASS")
