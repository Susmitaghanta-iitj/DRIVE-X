module axi4_write_dma #(
    parameter int ADDR_W=32,
    parameter int DATA_W=64
)(
    input logic clk,rst_n,start,
    input logic [ADDR_W-1:0] dst_addr,
    input logic [15:0] beats,
    output logic busy,done,
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
    output logic M_BREADY,
    output logic [15:0] rd_index,
    input logic [DATA_W-1:0] rd_data
);
    typedef enum logic [2:0] {IDLE,AW,WDATA,BRESP,DONE} st_t; st_t st; logic [15:0] count;
    assign M_AWSIZE=$clog2(DATA_W/8); assign M_AWBURST=2'b01; assign M_WSTRB='1;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin st<=IDLE;busy<=0;done<=0;M_AWVALID<=0;M_WVALID<=0;M_BREADY<=0;M_WLAST<=0;M_AWADDR<=0;M_AWLEN<=0;rd_index<=0;M_WDATA<=0;count<=0;end
        else begin
            done<=0;
            case(st)
                IDLE: if(start) begin busy<=1;count<=0;rd_index<=0;M_AWADDR<=dst_addr;M_AWLEN<=(beats==0)?0:((beats>256)?8'd255:beats[7:0]-1'b1);M_AWVALID<=1;st<=AW;end
                AW: if(M_AWVALID&&M_AWREADY) begin M_AWVALID<=0;M_WVALID<=1;st<=WDATA;end
                WDATA: if(M_WVALID&&M_WREADY) begin M_WDATA<=rd_data;rd_index<=count+1;count<=count+1;M_WLAST<=(count+2>=beats);if(count+1>=beats) begin M_WVALID<=0;M_WLAST<=0;M_BREADY<=1;st<=BRESP;end end
                BRESP: if(M_BVALID&&M_BREADY) begin M_BREADY<=0;st<=DONE;end
                DONE: begin busy<=0;done<=1;st<=IDLE;end
            endcase
        end
    end
endmodule
