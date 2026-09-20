module conv_address_gen(
    input  logic [15:0] cin,
    input  logic [15:0] hout,
    input  logic [15:0] wout,
    input  logic [2:0] kernel,
    input  logic [2:0] stride,
    input  logic [15:0] m_off,
    input  logic [15:0] n_off,
    input  logic [15:0] k_idx,
    output logic [31:0] act_linear_index,
    output logic [31:0] wt_linear_index
);
    logic [31:0] spatial, c_idx, ky, kx;
    logic [31:0] oy, ox;
    always_comb begin
        spatial = n_off;
        oy = spatial / wout;
        ox = spatial % wout;

        c_idx = k_idx / (kernel*kernel);
        ky = (k_idx / kernel) % kernel;
        kx = k_idx % kernel;

        // This is a compact linearized address seed for the streaming engine.
        // Padding boundary handling belongs in the streamer.
        act_linear_index = ((oy*stride + ky) * (wout*stride) + (ox*stride + kx)) * cin + c_idx;
        wt_linear_index  = (m_off * (cin*kernel*kernel)) + k_idx;
    end
endmodule
