module local_memory_subsystem #(
    parameter int DATA_W=64,
    parameter int AW=12
)(
    input logic clk,
    input logic act_load_we,
    input logic [AW-1:0] act_load_addr,
    input logic [DATA_W-1:0] act_load_data,
    input logic wt_load_we,
    input logic [AW-1:0] wt_load_addr,
    input logic [DATA_W-1:0] wt_load_data,
    input logic [AW-1:0] act_compute_addr,
    input logic [AW-1:0] wt_compute_addr,
    output logic [DATA_W-1:0] act_compute_data,
    output logic [DATA_W-1:0] wt_compute_data,
    input logic out_we,
    input logic [AW-1:0] out_waddr,
    input logic [DATA_W-1:0] out_wdata,
    input logic [AW-1:0] out_raddr,
    output logic [DATA_W-1:0] out_rdata,
    input logic swap_act,
    input logic swap_wt
);
    pingpong_buffer #(.DW(DATA_W),.AW(AW)) act_buf(.clk(clk),.swap(swap_act),.load_we(act_load_we),.load_addr(act_load_addr),.load_data(act_load_data),.compute_addr(act_compute_addr),.compute_data(act_compute_data));
    pingpong_buffer #(.DW(DATA_W),.AW(AW)) wt_buf(.clk(clk),.swap(swap_wt),.load_we(wt_load_we),.load_addr(wt_load_addr),.load_data(wt_load_data),.compute_addr(wt_compute_addr),.compute_data(wt_compute_data));
    dual_port_sram #(.DW(DATA_W),.AW(AW)) out_buf(.clk(clk),.a_we(out_we),.a_addr(out_waddr),.a_wdata(out_wdata),.a_rdata(),.b_we(1'b0),.b_addr(out_raddr),.b_wdata('0),.b_rdata(out_rdata));
endmodule
