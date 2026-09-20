module pingpong_buffer #(
 parameter int DW=64, AW=10
)(
 input logic clk,
 input logic swap,
 input logic load_we,
 input logic [AW-1:0] load_addr,
 input logic [DW-1:0] load_data,
 input logic [AW-1:0] compute_addr,
 output logic [DW-1:0] compute_data
);
logic bank_sel;
logic [DW-1:0] m0[0:(1<<AW)-1], m1[0:(1<<AW)-1];
always_ff @(posedge clk) begin
 if(swap) bank_sel<=~bank_sel;
 if(load_we) begin
  if(bank_sel) m0[load_addr]<=load_data; else m1[load_addr]<=load_data;
 end
 if(bank_sel) compute_data<=m1[compute_addr]; else compute_data<=m0[compute_addr];
end
initial bank_sel=0;
endmodule
