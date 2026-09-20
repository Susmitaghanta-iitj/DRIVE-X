module fxp24_requant(
    input logic signed [23:0] acc_in,
    input logic [4:0] shift,
    input logic round_en,
    output logic signed [7:0] q8_out
);
    logic signed [24:0] ext,rounded,shifted,addend;
    always_comb begin
        ext={acc_in[23],acc_in}; addend=25'sd0;
        if(round_en&&shift!=0) addend=25'sd1<<<(shift-1);
        if(round_en&&shift!=0) rounded=(ext<0)?(ext-addend):(ext+addend); else rounded=ext;
        shifted=rounded>>>shift;
        if(shifted>127) q8_out=8'sd127;
        else if(shifted<-128) q8_out=-8'sd128;
        else q8_out=shifted[7:0];
    end
endmodule
