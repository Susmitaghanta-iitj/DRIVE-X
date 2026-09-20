PREC_ORA8, PREC_EX4, PREC_4X2, PREC_2XFP4 = range(4)
AF_RELU, AF_SIG, AF_TANH, AF_SWISH, AF_GELU = range(5)

FP_ACC_FRAC = 8

def sext(v,bits):
    v &= (1<<bits)-1
    return v-(1<<bits) if v&(1<<(bits-1)) else v

def round_mag_8to5(x):
    if x<=31: return x,0
    if x<=63: return ((x>>2)<<1)|((x>>1)&1),1
    if x<=127:
        return (((x>>4)&7)<<2)|(((x>>3)&1)<<1)|((x>>1)&1),2
    return (((x>>6)&3)<<3)|(((x>>5)&1)<<2)|(((x>>3)&1)<<1)|((x>>1)&1),3

def ora_mul_signed(a,b):
    am,bm=abs(int(a)),abs(int(b))
    ar,sa=round_mag_8to5(am)
    br,sb=round_mag_8to5(bm)
    p=(ar*br)<<(sa+sb)
    return -p if ((a<0)^(b<0)) else p

def int2_lanes(byte):
    return [sext((byte>>(2*i))&3,2) for i in range(4)]

def fp4_e2m1_to_real(n):
    s=(n>>3)&1
    e=(n>>1)&3
    f=n&1
    if e==0: return 0.0
    m=1.0+0.5*f
    val=m*(2.0**(e-1))
    return -val if s else val

def fp4_pair_fixed_product(a_byte,b_byte,frac=FP_ACC_FRAC):
    total=0
    for lane in range(2):
        a=(a_byte>>(4*lane))&0xF
        b=(b_byte>>(4*lane))&0xF
        val=fp4_e2m1_to_real(a)*fp4_e2m1_to_real(b)
        total += int(round(val*(1<<frac)))
    return total

def product_by_mode(a_byte,b_byte,mode):
    if mode==PREC_ORA8:
        return ora_mul_signed(sext(a_byte,8),sext(b_byte,8))
    if mode==PREC_EX4:
        return sext(a_byte,4)*sext(b_byte,4)
    if mode==PREC_4X2:
        aa=int2_lanes(a_byte);bb=int2_lanes(b_byte)
        return sum(x*y for x,y in zip(aa,bb))
    if mode==PREC_2XFP4:
        return fp4_pair_fixed_product(a_byte,b_byte)
    return 0

A=[8192,8825,10623,12809,14529,15549,16047,16259]
B=[3787,3120,1808,820,316,116,43,16]

def sigmoid_pwl8_from_q4(u_q4):
    sign=u_q4<0
    au=abs(int(u_q4))
    if au>=128: pos=16384
    else:
        seg=min(7,au//16)
        pos=A[seg]+((B[seg]*au)>>4)
        pos=max(0,min(16384,pos))
    return 16384-pos if sign else pos

def af_q11(x_q4,af):
    if af==AF_RELU: return max(0,x_q4)<<7
    if af==AF_SIG: return sigmoid_pwl8_from_q4(x_q4)>>3
    if af==AF_TANH:
        s=sigmoid_pwl8_from_q4(x_q4*2); return (2*s-16384)>>3
    if af==AF_SWISH:
        s=sigmoid_pwl8_from_q4(x_q4); return (x_q4*s)>>7
    if af==AF_GELU:
        u=x_q4+(x_q4>>1)+(x_q4>>3)+(x_q4>>4)+(x_q4>>6)
        s=sigmoid_pwl8_from_q4(u); return (x_q4*s)>>7
    return 0

def pack_int2(vals):
    out=0
    for i,v in enumerate(vals): out |= ((v&3)<<(2*i))
    return out

def pack_fp4(v0,v1):
    return (v0&0xF)|((v1&0xF)<<4)

def selftest():
    assert product_by_mode(0x07,0x07,PREC_EX4)==49
    a=pack_int2([-2,-1,0,1]);b=pack_int2([1,-2,-1,1])
    assert product_by_mode(a,b,PREC_4X2)==1

    # FP4 lane0: +1.0 * +1.5 = 1.5
    # lane1: -2.0 * +1.0 = -2.0
    # reduced pair = -0.5; with FP_ACC_FRAC=8 => -128.
    one   = 0b0010 # s0,e01,f0 = 1.0
    one5  = 0b0011 # 1.5
    neg2  = 0b1100 # -2.0
    aa=pack_fp4(one,neg2)
    bb=pack_fp4(one5,one)
    assert product_by_mode(aa,bb,PREC_2XFP4)==-128
    return True

if __name__=="__main__":
    print("selftest",selftest())
    print("fp4 example fixed", product_by_mode(pack_fp4(0b0010,0b1100), pack_fp4(0b0011,0b0010), PREC_2XFP4))
