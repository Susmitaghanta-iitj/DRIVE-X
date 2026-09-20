module axi4_read_dma #(
    parameter int ADDR_W = 32,
    parameter int DATA_W = 64
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [ADDR_W-1:0] src_addr,
    input  logic [15:0] beats,
    output logic busy,
    output logic done,
    output logic [ADDR_W-1:0] M_ARADDR,
    output logic [7:0] M_ARLEN,
    output logic [2:0] M_ARSIZE,
    output logic [1:0] M_ARBURST,
    output logic M_ARVALID,
    input  logic M_ARREADY,
    input  logic [DATA_W-1:0] M_RDATA,
    input  logic [1:0] M_RRESP,
    input  logic M_RLAST,
    input  logic M_RVALID,
    output logic M_RREADY,
    output logic wr_en,
    output logic [DATA_W-1:0] wr_data,
    output logic [15:0] wr_index
);
    typedef enum logic [1:0] {IDLE,AR,RDATA,DONE} st_t;
    st_t st; logic [15:0] count;
    assign M_ARSIZE=$clog2(DATA_W/8); assign M_ARBURST=2'b01;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin st<=IDLE;busy<=0;done<=0;M_ARVALID<=0;M_RREADY<=0;wr_en<=0;wr_data<=0;wr_index<=0;count<=0;M_ARADDR<=0;M_ARLEN<=0; end
        else begin
            done<=0;wr_en<=0;
            case(st)
                IDLE: if(start) begin busy<=1;M_ARADDR<=src_addr;M_ARLEN<=(beats==0)?8'd0:((beats>256)?8'd255:beats[7:0]-1'b1);M_ARVALID<=1;count<=0;st<=AR;end
                AR: if(M_ARVALID&&M_ARREADY) begin M_ARVALID<=0;M_RREADY<=1;st<=RDATA;end
                RDATA: if(M_RVALID&&M_RREADY) begin wr_en<=1;wr_data<=M_RDATA;wr_index<=count;count<=count+1;if(M_RLAST) begin M_RREADY<=0;st<=DONE;end end
                DONE: begin busy<=0;done<=1;st<=IDLE;end
            endcase
        end
    end
endmodule
