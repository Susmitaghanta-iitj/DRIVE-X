module approxflex_yolo_top #(
    parameter int ARRAY_N = 8,
    parameter int FP_ACC_FRAC = 8
)(
    input logic clk,
    input logic rst_n,
    input logic [7:0] s_awaddr,
    input logic s_awvalid,
    output logic s_awready,
    input logic [31:0] s_wdata,
    input logic [3:0] s_wstrb,
    input logic s_wvalid,
    output logic s_wready,
    output logic [1:0] s_bresp,
    output logic s_bvalid,
    input logic s_bready,
    input logic [7:0] s_araddr,
    input logic s_arvalid,
    output logic s_arready,
    output logic [31:0] s_rdata,
    output logic [1:0] s_rresp,
    output logic s_rvalid,
    input logic s_rready,
    input logic signed [7:0] act_vec [0:ARRAY_N-1],
    input logic signed [7:0] wt_vec  [0:ARRAY_N-1],
    output logic signed [15:0] af_mat [0:ARRAY_N-1][0:ARRAY_N-1],
    output logic busy,
    output logic done
);
    logic start; logic [15:0] m_dim,n_dim,k_dim; logic [1:0] prec_mode; logic [2:0] af_sel; logic [4:0] rq_shift; logic round_en; logic [31:0] act_base,wt_base,out_base;
    logic [$clog2(ARRAY_N+1)-1:0] rows_req,cols_req; logic [ARRAY_N-1:0] row_mask,col_mask; logic [$clog2(ARRAY_N*ARRAY_N+1)-1:0] active_pe_count; logic [15:0] m_off,n_off,k_idx; logic acc_clear,mac_en,commit_tile;
    logic signed [23:0] acc_mat [0:ARRAY_N-1][0:ARRAY_N-1]; logic signed [7:0] af_in_mat [0:ARRAY_N-1][0:ARRAY_N-1];
    axi_lite_ctrl ctrl(.ACLK(clk),.ARESETn(rst_n),.S_AWADDR(s_awaddr),.S_AWVALID(s_awvalid),.S_AWREADY(s_awready),.S_WDATA(s_wdata),.S_WSTRB(s_wstrb),.S_WVALID(s_wvalid),.S_WREADY(s_wready),.S_BRESP(s_bresp),.S_BVALID(s_bvalid),.S_BREADY(s_bready),.S_ARADDR(s_araddr),.S_ARVALID(s_arvalid),.S_ARREADY(s_arready),.S_RDATA(s_rdata),.S_RRESP(s_rresp),.S_RVALID(s_rvalid),.S_RREADY(s_rready),.start_pulse(start),.m_dim(m_dim),.n_dim(n_dim),.k_dim(k_dim),.prec_mode(prec_mode),.af_sel(af_sel),.requant_shift(rq_shift),.round_en(round_en),.act_base(act_base),.wt_base(wt_base),.out_base(out_base),.busy(busy),.done(done));
    tile_scheduler #(.ARRAY_N(ARRAY_N)) sched(.clk(clk),.rst_n(rst_n),.start(start),.m_dim(m_dim),.n_dim(n_dim),.k_dim(k_dim),.prec_mode(prec_mode),.busy(busy),.done(done),.rows_req(rows_req),.cols_req(cols_req),.m_off(m_off),.n_off(n_off),.k_idx(k_idx),.acc_clear(acc_clear),.mac_en(mac_en),.commit_tile(commit_tile));
    tile_self_control #(.ARRAY_N(ARRAY_N)) tasc(.rows_req(rows_req),.cols_req(cols_req),.row_mask(row_mask),.col_mask(col_mask),.active_pe_count(active_pe_count));
    configurable_systolic_array #(.ARRAY_N(ARRAY_N),.FP_ACC_FRAC(FP_ACC_FRAC)) array(.clk(clk),.rst_n(rst_n),.acc_clear(acc_clear),.mac_en(mac_en),.prec_mode(prec_mode),.af_sel(af_sel),.requant_shift(rq_shift),.round_en(round_en),.row_mask(row_mask),.col_mask(col_mask),.act_vec(act_vec),.wt_vec(wt_vec),.acc_mat(acc_mat),.af_in_mat(af_in_mat),.af_mat(af_mat));
endmodule
