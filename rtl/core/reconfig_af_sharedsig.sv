module reconfig_af_sharedsig(
    input  logic signed [7:0] x_q4,
    input  logic [2:0] af_sel,
    output logic signed [15:0] y_q11
);
    logic signed [12:0] x_ext, u;
    logic signed [16:0] sig;
    logic signed [31:0] prod;
    logic signed [31:0] tmp;

    always_comb begin
        x_ext = {{5{x_q4[7]}}, x_q4};

        unique case (af_sel)
            3'd2: u = x_ext <<< 1;
            3'd4: u = x_ext + (x_ext >>> 1) + (x_ext >>> 3) + (x_ext >>> 4) + (x_ext >>> 6);
            default: u = x_ext;
        endcase
    end

    shared_sigmoid_pwl8 core(.u_q4(u), .sig_q14(sig));

    always_comb begin
        prod = $signed(x_q4) * $signed(sig);
        unique case (af_sel)
            3'd0: tmp = x_q4[7] ? 32'sd0 : ($signed(x_q4) <<< 7);
            3'd1: tmp = $signed(sig) >>> 3;
            3'd2: tmp = (($signed(sig) <<< 1) - 32'sd16384) >>> 3;
            3'd3: tmp = prod >>> 7;
            3'd4: tmp = prod >>> 7;
            default: tmp = 32'sd0;
        endcase
        if (tmp > 32767) y_q11 = 16'sh7fff;
        else if (tmp < -32768) y_q11 = 16'sh8000;
        else y_q11 = tmp[15:0];
    end
endmodule
