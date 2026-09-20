from golden_model import *
assert selftest()
assert ora_mul_signed(0,17)==0
assert ora_mul_signed(31,31)==961
assert ora_mul_signed(-31,31)==-961
assert af_q11(-16,AF_RELU)==0
assert af_q11(0,AF_TANH)==0
print("basic golden tests: PASS")
