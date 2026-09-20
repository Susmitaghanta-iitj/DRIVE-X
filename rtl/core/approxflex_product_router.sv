module approxflex_product_router #(
    parameter int FP_ACC_FRAC = 8
)(
    input  logic [1:0] prec_mode,
    input  logic signed [7:0] a_in,
    input  logic signed [7:0] b_in,
    output logic signed [23:0] product_to_acc,

    output logic [1:0] fp0_emax,
    output logic [1:0] fp0_oea,
    output logic [1:0] fp0_oeb,
    output logic [1:0] fp1_emax,
    output logic [1:0] fp1_oea,
    output logic [1:0] fp1_oeb
);
    logic signed [16:0] ora8_product;
    logic [1:0] fabric_mode;
    logic signed [23:0] fabric_product;

    ora_signed_mult8 ora8(.a(a_in),.b(b_in),.p(ora8_product));

    always_comb begin
        unique case(prec_mode)
            2'b01: fabric_mode = 2'b00;
            2'b10: fabric_mode = 2'b01;
            2'b11: fabric_mode = 2'b10;
            default: fabric_mode = 2'b00;
        endcase
    end

    rmmec4_transprecision_fabric #(.FP_ACC_FRAC(FP_ACC_FRAC)) fabric(
        .fabric_mode(fabric_mode),.A(a_in),.B(b_in),.product_out(fabric_product),
        .fp0_emax(fp0_emax),.fp0_oea(fp0_oea),.fp0_oeb(fp0_oeb),
        .fp1_emax(fp1_emax),.fp1_oea(fp1_oea),.fp1_oeb(fp1_oeb)
    );

    always_comb begin
        if(prec_mode==2'b00) product_to_acc={{7{ora8_product[16]}},ora8_product};
        else product_to_acc=fabric_product;
    end
endmodule
