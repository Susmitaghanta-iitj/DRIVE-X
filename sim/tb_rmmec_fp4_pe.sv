`timescale 1ns/1ps
module tb_rmmec_fp4_pe;
logic clk=0,rst_n=0,pe_en=1,acc_clear=0,mac_en=0; logic [1:0] prec_mode; logic signed [7:0] act_in,wt_in; logic [2:0] af_sel=0; logic [4:0] rq_shift=0; logic round_en=1; logic signed [23:0] acc_out; logic signed [7:0] af_in_q8; logic signed [15:0] af_out;
always #5 clk=~clk;
approx_flex_pe dut(.clk(clk),.rst_n(rst_n),.pe_en(pe_en),.acc_clear(acc_clear),.mac_en(mac_en),.prec_mode(prec_mode),.act_in(act_in),.wt_in(wt_in),.af_sel(af_sel),.requant_shift(rq_shift),.round_en(round_en),.acc_out(acc_out),.af_in_q8(af_in_q8),.af_out(af_out));
task clear_acc; begin @(negedge clk);acc_clear=1;mac_en=0;@(negedge clk);acc_clear=0;end endtask
task mac_once(input [1:0] pm,input [7:0] a,input [7:0] b); begin @(negedge clk);prec_mode=pm;act_in=a;wt_in=b;mac_en=1;@(negedge clk);mac_en=0;end endtask
initial begin prec_mode=0;act_in=0;wt_in=0;repeat(2) @(negedge clk);rst_n=1;clear_acc();mac_once(2'b00,8'sd10,8'sd12);$display("ORA8 ACC=%0d",$signed(acc_out));clear_acc();mac_once(2'b01,8'h07,8'h07);$display("EX4 ACC=%0d",$signed(acc_out));clear_acc();mac_once(2'b10,8'b01_00_11_10,8'b01_11_10_01);$display("4xINT2 ACC=%0d",$signed(acc_out));clear_acc();mac_once(2'b11,{4'b1100,4'b0010},{4'b0010,4'b0011});$display("2xFP4 ACC=%0d",$signed(acc_out));repeat(3) @(posedge clk);$finish;end
endmodule
