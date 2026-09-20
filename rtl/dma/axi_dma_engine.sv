module axi_dma_engine #(
    parameter int ADDR_W=32,
    parameter int DATA_W=64
)(
    input logic clk,rst_n,rd_start,wr_start,
    input logic [ADDR_W-1:0] rd_addr,wr_addr,
    input logic [15:0] rd_beats,wr_beats,
    output logic rd_busy,rd_done,wr_busy,wr_done,
    output logic local_wr_en,
    output logic [15:0] local_wr_index,
    output logic [DATA_W-1:0] local_wr_data,
    output logic [15:0] local_rd_index,
    input logic [DATA_W-1:0] local_rd_data,
    output logic [ADDR_W-1:0] M_ARADDR,
    output logic [7:0] M_ARLEN,
    output logic [2:0] M_ARSIZE,
    output logic [1:0] M_ARBURST,
    output logic M_ARVALID,
    input logic M_ARREADY,
    input logic [DATA_W-1:0] M_RDATA,
    input logic [1:0] M_RRESP,
    input logic M_RLAST,M_RVALID,
    output logic M_RREADY,
    output logic [ADDR_W-1:0] M_AWADDR,
    output logic [7:0] M_AWLEN,
    output logic [2:0] M_AWSIZE,
    output logic [1:0] M_AWBURST,
    output logic M_AWVALID,
    input logic M_AWREADY,
    output logic [DATA_W-1:0] M_WDATA,
    output logic [DATA_W/8-1:0] M_WSTRB,
    output logic M_WLAST,M_WVALID,
    input logic M_WREADY,
    input logic [1:0] M_BRESP,
    input logic M_BVALID,
    output logic M_BREADY
);
    axi4_read_dma #(.ADDR_W(ADDR_W),.DATA_W(DATA_W)) rd(.clk(clk),.rst_n(rst_n),.start(rd_start),.src_addr(rd_addr),.beats(rd_beats),.busy(rd_busy),.done(rd_done),.M_ARADDR(M_ARADDR),.M_ARLEN(M_ARLEN),.M_ARSIZE(M_ARSIZE),.M_ARBURST(M_ARBURST),.M_ARVALID(M_ARVALID),.M_ARREADY(M_ARREADY),.M_RDATA(M_RDATA),.M_RRESP(M_RRESP),.M_RLAST(M_RLAST),.M_RVALID(M_RVALID),.M_RREADY(M_RREADY),.wr_en(local_wr_en),.wr_data(local_wr_data),.wr_index(local_wr_index));
    axi4_write_dma #(.ADDR_W(ADDR_W),.DATA_W(DATA_W)) wr(.clk(clk),.rst_n(rst_n),.start(wr_start),.dst_addr(wr_addr),.beats(wr_beats),.busy(wr_busy),.done(wr_done),.M_AWADDR(M_AWADDR),.M_AWLEN(M_AWLEN),.M_AWSIZE(M_AWSIZE),.M_AWBURST(M_AWBURST),.M_AWVALID(M_AWVALID),.M_AWREADY(M_AWREADY),.M_WDATA(M_WDATA),.M_WSTRB(M_WSTRB),.M_WLAST(M_WLAST),.M_WVALID(M_WVALID),.M_WREADY(M_WREADY),.M_BRESP(M_BRESP),.M_BVALID(M_BVALID),.M_BREADY(M_BREADY),.rd_index(local_rd_index),.rd_data(local_rd_data));
endmodule
