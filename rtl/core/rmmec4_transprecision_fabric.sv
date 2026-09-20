module rmmec4_transprecision_fabric #(
    parameter int FP_ACC_FRAC = 8
)(
    input  logic [1:0] fabric_mode,
    input  logic [7:0] A,
    input  logic [7:0] B,
    output logic signed [23:0] product_out,
    output logic [1:0] fp0_emax,
    output logic [1:0] fp0_oea,
    output logic [1:0] fp0_oeb,
    output logic [1:0] fp1_emax,
    output logic [1:0] fp1_oea,
    output logic [1:0] fp1_oeb
);
    localparam logic [1:0] MODE_EX4   = 2'b00;
    localparam logic [1:0] MODE_4X2   = 2'b01;
    localparam logic [1:0] MODE_2XFP4 = 2'b10;

    logic [1:0] cA [0:3];
    logic [1:0] cB [0:3];
    logic [3:0] cpp [0:3];
    logic [1:0] cemax [0:3], coe1 [0:3], coe2 [0:3];

    genvar gi;
    generate
        for (gi=0; gi<4; gi=gi+1) begin: G_RMM
            rmm2ec u_rmm2ec(.A(cA[gi]), .B(cB[gi]), .pp(cpp[gi]), .EMax(cemax[gi]), .OE1(coe1[gi]), .OE2(coe2[gi]));
        end
    endgenerate

    logic signed [3:0] a4s, b4s;
    logic [3:0] a4mag, b4mag;
    logic sign4;
    logic [7:0] int4_mag_product;
    logic signed [8:0] int4_signed_product;

    logic signed [1:0] a2s[0:3], b2s[0:3];
    logic [1:0] a2mag[0:3], b2mag[0:3];
    logic lane_sign[0:3];
    logic signed [4:0] lane_prod[0:3];
    logic signed [6:0] int2_sum;

    logic [3:0] fpA0, fpA1, fpB0, fpB1;
    logic fp0_sign, fp1_sign;
    logic [1:0] fp0_ea, fp0_eb, fp1_ea, fp1_eb;
    logic fp0_fa, fp0_fb, fp1_fa, fp1_fb;
    logic fp0_zero, fp1_zero;
    logic [1:0] fp0_ma, fp0_mb, fp1_ma, fp1_mb;
    logic signed [23:0] fp0_fixed, fp1_fixed;
    logic signed [24:0] fp_pair_sum;
    integer i;
    integer fp0_shift;
    integer fp1_shift;
    integer fp0_unbiased_sum;
    integer fp1_unbiased_sum;

    function automatic [1:0] abs2_signed(input logic signed [1:0] x);
        logic signed [2:0] ex;
        begin
            ex = x;
            if (ex < 0) abs2_signed = $unsigned(-ex)[1:0];
            else        abs2_signed = $unsigned(ex)[1:0];
        end
    endfunction

    always_comb begin
        for (i=0; i<4; i=i+1) begin
            cA[i]=2'b00; cB[i]=2'b00; a2s[i]='0; b2s[i]='0; a2mag[i]='0; b2mag[i]='0; lane_sign[i]=1'b0; lane_prod[i]='0;
        end

        a4s = $signed(A[3:0]);
        b4s = $signed(B[3:0]);
        sign4 = a4s[3] ^ b4s[3];
        a4mag = a4s[3] ? $unsigned(-$signed(a4s)) : $unsigned(a4s);
        b4mag = b4s[3] ? $unsigned(-$signed(b4s)) : $unsigned(b4s);

        fpA0=A[3:0]; fpA1=A[7:4]; fpB0=B[3:0]; fpB1=B[7:4];
        fp0_sign=fpA0[3]^fpB0[3]; fp1_sign=fpA1[3]^fpB1[3];
        fp0_ea=fpA0[2:1]; fp0_eb=fpB0[2:1]; fp1_ea=fpA1[2:1]; fp1_eb=fpB1[2:1];
        fp0_fa=fpA0[0]; fp0_fb=fpB0[0]; fp1_fa=fpA1[0]; fp1_fb=fpB1[0];
        fp0_zero=(fp0_ea==2'b00)||(fp0_eb==2'b00);
        fp1_zero=(fp1_ea==2'b00)||(fp1_eb==2'b00);
        fp0_ma=fp0_zero?2'b00:{1'b1,fp0_fa}; fp0_mb=fp0_zero?2'b00:{1'b1,fp0_fb};
        fp1_ma=fp1_zero?2'b00:{1'b1,fp1_fa}; fp1_mb=fp1_zero?2'b00:{1'b1,fp1_fb};

        unique case (fabric_mode)
            MODE_EX4: begin
                cA[0]=a4mag[1:0]; cB[0]=b4mag[1:0];
                cA[1]=a4mag[3:2]; cB[1]=b4mag[1:0];
                cA[2]=a4mag[1:0]; cB[2]=b4mag[3:2];
                cA[3]=a4mag[3:2]; cB[3]=b4mag[3:2];
            end
            MODE_4X2: begin
                for (i=0;i<4;i=i+1) begin
                    a2s[i]=$signed(A[i*2 +: 2]); b2s[i]=$signed(B[i*2 +: 2]);
                    a2mag[i]=abs2_signed(a2s[i]); b2mag[i]=abs2_signed(b2s[i]);
                    lane_sign[i]=a2s[i][1]^b2s[i][1]; cA[i]=a2mag[i]; cB[i]=b2mag[i];
                end
            end
            MODE_2XFP4: begin
                cA[0]=fp0_ea; cB[0]=fp0_eb; cA[1]=fp0_ma; cB[1]=fp0_mb;
                cA[2]=fp1_ea; cB[2]=fp1_eb; cA[3]=fp1_ma; cB[3]=fp1_mb;
            end
            default: begin end
        endcase

        int4_mag_product={4'b0,cpp[0]}+({4'b0,cpp[1]}<<2)+({4'b0,cpp[2]}<<2)+({4'b0,cpp[3]}<<4);
        int4_signed_product=sign4 ? -$signed({1'b0,int4_mag_product}) : $signed({1'b0,int4_mag_product});

        for (i=0;i<4;i=i+1)
            lane_prod[i]=lane_sign[i] ? -$signed({1'b0,cpp[i]}) : $signed({1'b0,cpp[i]});
        int2_sum=$signed(lane_prod[0])+$signed(lane_prod[1])+$signed(lane_prod[2])+$signed(lane_prod[3]);

        fp0_fixed=24'sd0; fp1_fixed=24'sd0;
        fp0_unbiased_sum=$unsigned(fp0_ea)+$unsigned(fp0_eb)-2;
        fp1_unbiased_sum=$unsigned(fp1_ea)+$unsigned(fp1_eb)-2;
        fp0_shift=FP_ACC_FRAC-2+fp0_unbiased_sum;
        fp1_shift=FP_ACC_FRAC-2+fp1_unbiased_sum;

        if(!fp0_zero) begin
            if(fp0_shift>=0) fp0_fixed=$signed({20'd0,cpp[1]})<<<fp0_shift;
            else fp0_fixed=$signed({20'd0,cpp[1]})>>>(-fp0_shift);
            if(fp0_sign) fp0_fixed=-fp0_fixed;
        end
        if(!fp1_zero) begin
            if(fp1_shift>=0) fp1_fixed=$signed({20'd0,cpp[3]})<<<fp1_shift;
            else fp1_fixed=$signed({20'd0,cpp[3]})>>>(-fp1_shift);
            if(fp1_sign) fp1_fixed=-fp1_fixed;
        end

        fp_pair_sum=$signed(fp0_fixed)+$signed(fp1_fixed);
        unique case(fabric_mode)
            MODE_EX4: product_out={{15{int4_signed_product[8]}},int4_signed_product};
            MODE_4X2: product_out={{17{int2_sum[6]}},int2_sum};
            MODE_2XFP4: product_out=fp_pair_sum[23:0];
            default: product_out=24'sd0;
        endcase
    end

    assign fp0_emax=cemax[0]; assign fp0_oea=coe1[0]; assign fp0_oeb=coe2[0];
    assign fp1_emax=cemax[2]; assign fp1_oea=coe1[2]; assign fp1_oeb=coe2[2];
endmodule
