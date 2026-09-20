module implicit_gemm_streamer(
 input logic [15:0] cin, hin, win, hout, wout,
 input logic [2:0] kernel,stride,pad,
 input logic [15:0] m_off,n_off,k_idx,
 output logic act_zero,
 output logic [31:0] act_index,
 output logic [31:0] wt_index
);
integer oy,ox,ci,ky,kx,iy,ix;
always_comb begin
 oy = n_off / wout; ox = n_off % wout;
 ci = k_idx / (kernel*kernel);
 ky = (k_idx / kernel) % kernel;
 kx = k_idx % kernel;
 iy = oy*stride + ky - pad;
 ix = ox*stride + kx - pad;
 act_zero = (iy<0)||(ix<0)||(iy>=hin)||(ix>=win);
 if(act_zero) act_index=0;
 else act_index=((iy*win+ix)*cin)+ci;
 wt_index=(m_off*(cin*kernel*kernel))+k_idx;
end
endmodule
