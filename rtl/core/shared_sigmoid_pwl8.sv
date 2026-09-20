module shared_sigmoid_pwl8(
    input  logic signed [12:0] u_q4,
    output logic signed [16:0] sig_q14
);
    logic sign_u; logic [12:0] abs_u; logic [2:0] seg;
    logic signed [15:0] a_q14,b_q14; logic signed [29:0] mult; logic signed [20:0] pos;
    always_comb begin
        sign_u=u_q4[12]; abs_u=sign_u?$unsigned(-u_q4):$unsigned(u_q4);
        seg=(abs_u>=13'd112)?3'd7:abs_u[6:4];
        unique case(seg)
            3'd0: begin a_q14=16'sd8192; b_q14=16'sd3787; end
            3'd1: begin a_q14=16'sd8825; b_q14=16'sd3120; end
            3'd2: begin a_q14=16'sd10623; b_q14=16'sd1808; end
            3'd3: begin a_q14=16'sd12809; b_q14=16'sd820; end
            3'd4: begin a_q14=16'sd14529; b_q14=16'sd316; end
            3'd5: begin a_q14=16'sd15549; b_q14=16'sd116; end
            3'd6: begin a_q14=16'sd16047; b_q14=16'sd43; end
            default: begin a_q14=16'sd16259; b_q14=16'sd16; end
        endcase
        if(abs_u>=13'd128) pos=21'sd16384;
        else begin
            mult=$signed(b_q14)*$signed({1'b0,abs_u}); pos=$signed(a_q14)+(mult>>>4);
            if(pos<0) pos=0; if(pos>21'sd16384) pos=21'sd16384;
        end
        sig_q14=sign_u?(17'sd16384-pos[16:0]):pos[16:0];
    end
endmodule
