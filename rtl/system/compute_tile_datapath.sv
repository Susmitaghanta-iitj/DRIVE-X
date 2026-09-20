module compute_tile_datapath #(parameter int ARRAY_N=8, parameter int FP_ACC_FRAC=8)(input logic clk,rst_n,acc_clear,mac_en,input logic [1:0] prec_mode,input logic [2:0] af_sel,input logic [4:0] requant_shift,input logic round_en,input logic [3:0] lane_valid,input logic [ARRAY_N-1:0] row_mask,col_mask,input logic signed [7:0] act_from_mem[0:ARRAY_N-1],input logic signed [7:0] wt_from_mem[0:ARRAY_N-1],output logic signed [23:0] acc_mat[0:ARRAY_N-1][0:ARRAY_N-1],output logic signed [15:0] af_mat[0:ARRAY_N-1][0:ARRAY_N-1]);
logic signed [7:0] act_masked[0:ARRAY_N-1]; logic signed [7:0] wt_masked[0:ARRAY_N-1]; genvar i;
generate for(i=0;i<ARRAY_N;i=i+1) begin:GM
packed_operand_mask am(.prec_mode(prec_mode),.lane_valid(lane_valid),.in_byte(act_from_mem[i]),.out_byte(act_masked[i]));
packed_operand_mask wm(.prec_mode(prec_mode),.lane_valid(lane_valid),.in_byte(wt_from_mem[i]),.out_byte(wt_masked[i]));
end endgenerate
true_systolic_array #(.ARRAY_N(ARRAY_N),.FP_ACC_FRAC(FP_ACC_FRAC)) sa(.clk(clk),.rst_n(rst_n),.acc_clear(acc_clear),.mac_en(mac_en),.prec_mode(prec_mode),.af_sel(af_sel),.requant_shift(requant_shift),.round_en(round_en),.row_mask(row_mask),.col_mask(col_mask),.act_left(act_masked),.wt_top(wt_masked),.acc_mat(acc_mat),.af_mat(af_mat));
endmodule
