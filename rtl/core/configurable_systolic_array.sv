module configurable_systolic_array #(
    parameter int ARRAY_N=8,
    parameter int FP_ACC_FRAC=8
)(
    input logic clk,rst_n,acc_clear,mac_en,
    input logic [1:0] prec_mode,
    input logic [2:0] af_sel,
    input logic [4:0] requant_shift,
    input logic round_en,
    input logic [ARRAY_N-1:0] row_mask,col_mask,
    input logic signed [7:0] act_vec[0:ARRAY_N-1],
    input logic signed [7:0] wt_vec[0:ARRAY_N-1],
    output logic signed [23:0] acc_mat[0:ARRAY_N-1][0:ARRAY_N-1],
    output logic signed [7:0] af_in_mat[0:ARRAY_N-1][0:ARRAY_N-1],
    output logic signed [15:0] af_mat[0:ARRAY_N-1][0:ARRAY_N-1]
);
    logic signed [15:0] af_local[0:ARRAY_N-1][0:ARRAY_N-1];
    true_systolic_array #(.ARRAY_N(ARRAY_N),.FP_ACC_FRAC(FP_ACC_FRAC)) sa(
        .clk(clk),.rst_n(rst_n),.acc_clear(acc_clear),.mac_en(mac_en),
        .prec_mode(prec_mode),.af_sel(af_sel),.requant_shift(requant_shift),.round_en(round_en),
        .row_mask(row_mask),.col_mask(col_mask),.act_left(act_vec),.wt_top(wt_vec),
        .acc_mat(acc_mat),.af_mat(af_local));
    genvar r,c;
    generate for(r=0;r<ARRAY_N;r=r+1) begin:GR
        for(c=0;c<ARRAY_N;c=c+1) begin:GC
            assign af_mat[r][c]=af_local[r][c];
            fxp24_requant rq(.acc_in(acc_mat[r][c]),.shift(requant_shift),.round_en(round_en),.q8_out(af_in_mat[r][c]));
        end
    end endgenerate
endmodule
