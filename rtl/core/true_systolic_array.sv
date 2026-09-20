module true_systolic_array #(
    parameter int ARRAY_N=8,
    parameter int FP_ACC_FRAC=8
)(
    input logic clk,rst_n,acc_clear,mac_en,
    input logic [1:0] prec_mode,
    input logic [2:0] af_sel,
    input logic [4:0] requant_shift,
    input logic round_en,
    input logic [ARRAY_N-1:0] row_mask,col_mask,
    input logic signed [7:0] act_left[0:ARRAY_N-1],
    input logic signed [7:0] wt_top[0:ARRAY_N-1],
    output logic signed [23:0] acc_mat[0:ARRAY_N-1][0:ARRAY_N-1],
    output logic signed [15:0] af_mat[0:ARRAY_N-1][0:ARRAY_N-1]
);
    logic signed [7:0] act_pipe[0:ARRAY_N-1][0:ARRAY_N];
    logic signed [7:0] wt_pipe[0:ARRAY_N][0:ARRAY_N-1];
    logic signed [7:0] af_in_unused[0:ARRAY_N-1][0:ARRAY_N-1];
    genvar r,c;

    generate
        for(r=0;r<ARRAY_N;r=r+1) begin:GINA
            assign act_pipe[r][0]=act_left[r];
        end
        for(c=0;c<ARRAY_N;c=c+1) begin:GINW
            assign wt_pipe[0][c]=wt_top[c];
        end
        for(r=0;r<ARRAY_N;r=r+1) begin:GR
            for(c=0;c<ARRAY_N;c=c+1) begin:GC
                approx_flex_pe_forward #(.FP_ACC_FRAC(FP_ACC_FRAC)) pe(
                    .clk(clk),.rst_n(rst_n),.pe_en(row_mask[r]&col_mask[c]),
                    .acc_clear(acc_clear),.mac_en(mac_en),.prec_mode(prec_mode),
                    .act_in(act_pipe[r][c]),.wt_in(wt_pipe[r][c]),
                    .af_sel(af_sel),.requant_shift(requant_shift),.round_en(round_en),
                    .act_out(act_pipe[r][c+1]),.wt_out(wt_pipe[r+1][c]),
                    .acc_out(acc_mat[r][c]),.af_in_q8(af_in_unused[r][c]),.af_out(af_mat[r][c])
                );
            end
        end
    endgenerate
endmodule
