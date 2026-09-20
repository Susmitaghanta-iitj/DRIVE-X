module fxp24_acc_sat(
    input logic signed [23:0] acc,
    input logic signed [23:0] addend,
    output logic signed [23:0] sum,
    output logic overflow
);
    logic signed [24:0] wide;
    always_comb begin
        wide=$signed({acc[23],acc})+$signed({addend[23],addend});
        overflow=(wide>25'sd8388607)||(wide< -25'sd8388608);
        if(wide>25'sd8388607) sum=24'sh7fffff;
        else if(wide< -25'sd8388608) sum=24'sh800000;
        else sum=wide[23:0];
    end
endmodule
