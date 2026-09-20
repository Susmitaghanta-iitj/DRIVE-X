module postproc_dispatch(input logic [3:0] op,input logic signed [15:0] x0,x1,output logic signed [15:0] y);
logic signed [16:0] s;
always_comb begin s=x0+x1; case(op) 4'd3: begin if(s>32767)y=16'sh7fff; else if(s<-32768)y=16'sh8000; else y=s[15:0]; end default:y=x0; endcase end
endmodule
