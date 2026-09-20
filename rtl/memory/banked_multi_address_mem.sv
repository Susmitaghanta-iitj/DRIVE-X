module banked_multi_address_mem #(
    parameter int BANKS=8,DW=64,AW=10
)(
    input logic clk,
    input logic [$clog2(BANKS)-1:0] rd_bank0,rd_bank1,wr_bank,
    input logic [AW-1:0] rd_addr0,rd_addr1,wr_addr,
    output logic [DW-1:0] rd_data0,rd_data1,
    input logic wr_en,
    input logic [DW-1:0] wr_data
);
    logic [DW-1:0] a_rdata[0:BANKS-1],b_rdata[0:BANKS-1]; genvar b;
    generate for(b=0;b<BANKS;b=b+1) begin:GB
        dual_port_sram #(.DW(DW),.AW(AW)) mem(.clk(clk),.a_we(wr_en&&wr_bank==b),.a_addr(wr_addr),.a_wdata(wr_data),.a_rdata(a_rdata[b]),.b_we(1'b0),.b_addr((rd_bank1==b)?rd_addr1:rd_addr0),.b_wdata('0),.b_rdata(b_rdata[b]));
    end endgenerate
    always_comb begin rd_data0=a_rdata[rd_bank0];rd_data1=b_rdata[rd_bank1];end
endmodule
