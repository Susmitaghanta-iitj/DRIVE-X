module descriptor_fifo #(
 parameter int W=192,
 parameter int DEPTH=16
)(
 input logic clk,rst_n,
 input logic push,
 input logic [W-1:0] din,
 input logic pop,
 output logic [W-1:0] dout,
 output logic empty,full
);
localparam int PW=$clog2(DEPTH);
logic [W-1:0] mem[0:DEPTH-1];
logic [PW:0] wrp,rdp;
assign empty=(wrp==rdp);
assign full=(wrp[PW]!=rdp[PW])&&(wrp[PW-1:0]==rdp[PW-1:0]);
assign dout=mem[rdp[PW-1:0]];
always_ff @(posedge clk or negedge rst_n) begin
 if(!rst_n) begin wrp<=0; rdp<=0; end
 else begin
  if(push&&!full) begin mem[wrp[PW-1:0]]<=din; wrp<=wrp+1; end
  if(pop&&!empty) rdp<=rdp+1;
 end
end
endmodule
