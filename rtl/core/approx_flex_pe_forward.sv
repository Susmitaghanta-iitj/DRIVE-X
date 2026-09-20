module approx_flex_pe_forward #(
    parameter int FP_ACC_FRAC = 8
)(
    input logic clk,rst_n,pe_en,acc_clear,mac_en,
    input logic [1:0] prec_mode,
    input logic signed [7:0] act_in,wt_in,
    input logic [2:0] af_sel,
    input logic [4:0] requant_shift,
    input logic round_en,
    output logic signed [7:0] act_out,wt_out,
    output logic signed [23:0] acc_out,
    output logic signed [7:0] af_in_q8,
    output logic signed [15:0] af_out
);
    logic signed [7:0] act_q,wt_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin act_q<='0; wt_q<='0; end
        else if(pe_en) begin act_q<=act_in; wt_q<=wt_in; end
    end

    approx_flex_pe #(.FP_ACC_FRAC(FP_ACC_FRAC)) core(
        .clk(clk),.rst_n(rst_n),.pe_en(pe_en),.acc_clear(acc_clear),.mac_en(mac_en),
        .prec_mode(prec_mode),.act_in(act_in),.wt_in(wt_in),
        .af_sel(af_sel),.requant_shift(requant_shift),.round_en(round_en),
        .acc_out(acc_out),.af_in_q8(af_in_q8),.af_out(af_out)
    );

    assign act_out=act_q;
    assign wt_out=wt_q;
endmodule
