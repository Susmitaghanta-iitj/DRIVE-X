module layer_exec_engine #(
    parameter int ARRAY_N=8
)(
    input logic clk,rst_n,
    input logic start,
    input logic [3:0] op,
    input logic [15:0] m_dim,n_dim,k_dim,
    input logic [15:0] hin,win,
    input logic [2:0] kernel,stride,pad,

    output logic busy,done,
    output logic dma_prefetch,
    output logic compute_start,
    input logic compute_done,
    output logic post_start,
    input logic post_done,
    output logic writeback_start,
    input logic writeback_done
);
typedef enum logic [2:0] {IDLE,PREFETCH,COMPUTE,POST,WRITEBACK,DONE} st_t;
st_t st;
always_ff @(posedge clk or negedge rst_n) begin
 if(!rst_n) begin
  st<=IDLE;busy<=0;done<=0;dma_prefetch<=0;compute_start<=0;post_start<=0;writeback_start<=0;
 end else begin
  done<=0;dma_prefetch<=0;compute_start<=0;post_start<=0;writeback_start<=0;
  case(st)
   IDLE: if(start) begin busy<=1; st<=PREFETCH; end
   PREFETCH: begin dma_prefetch<=1; st<=COMPUTE; end
   COMPUTE: begin compute_start<=1; if(compute_done) st<=POST; end
   POST: begin post_start<=1; if(post_done) st<=WRITEBACK; end
   WRITEBACK: begin writeback_start<=1; if(writeback_done) st<=DONE; end
   DONE: begin busy<=0;done<=1;st<=IDLE;end
  endcase
 end
end
endmodule
