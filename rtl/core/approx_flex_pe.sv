module approx_flex_pe #(
    parameter int FP_ACC_FRAC = 8
)(
    input logic clk,rst_n,pe_en,acc_clear,mac_en,
    input logic [1:0] prec_mode,
    input logic signed [7:0] act_in,wt_in,
    input logic [2:0] af_sel,
    input logic [4:0] requant_shift,
    input logic round_en,
    output logic signed [23:0] acc_out,
    output logic signed [7:0] af_in_q8,
    output logic signed [15:0] af_out
);
    logic signed [23:0] product_to_acc,acc,acc_next;
    logic acc_overflow;
    logic [1:0] fp0_emax,fp0_oea,fp0_oeb,fp1_emax,fp1_oea,fp1_oeb;

    approxflex_product_router #(.FP_ACC_FRAC(FP_ACC_FRAC)) router(
        .prec_mode(prec_mode),.a_in(act_in),.b_in(wt_in),.product_to_acc(product_to_acc),
        .fp0_emax(fp0_emax),.fp0_oea(fp0_oea),.fp0_oeb(fp0_oeb),
        .fp1_emax(fp1_emax),.fp1_oea(fp1_oea),.fp1_oeb(fp1_oeb));

    fxp24_acc_sat acc_sat(.acc(acc),.addend(product_to_acc),.sum(acc_next),.overflow(acc_overflow));

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) acc<=24'sd0;
        else if(pe_en) begin
            if(acc_clear) acc<=24'sd0;
            else if(mac_en) acc<=acc_next;
        end
    end

    fxp24_requant rq(.acc_in(acc),.shift(requant_shift),.round_en(round_en),.q8_out(af_in_q8));
    reconfig_af_sharedsig afu(.x_q4(af_in_q8),.af_sel(af_sel),.y_q11(af_out));
    assign acc_out=acc;
endmodule
