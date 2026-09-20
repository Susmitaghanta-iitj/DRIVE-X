module residual_add(input logic signed [15:0] a,b,output logic signed [15:0] y);
logic signed [16:0] s;
always_comb begin s=a+b; if(s>32767)y=16'sh7fff; else if(s<-32768)y=16'sh8000; else y=s[15:0]; end
endmodule
