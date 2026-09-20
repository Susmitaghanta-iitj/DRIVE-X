module axi_lite_ctrl #(
    parameter int ADDR_W = 8
)(
    input logic ACLK,
    input logic ARESETn,
    input logic [ADDR_W-1:0] S_AWADDR,
    input logic S_AWVALID,
    output logic S_AWREADY,
    input logic [31:0] S_WDATA,
    input logic [3:0] S_WSTRB,
    input logic S_WVALID,
    output logic S_WREADY,
    output logic [1:0] S_BRESP,
    output logic S_BVALID,
    input logic S_BREADY,
    input logic [ADDR_W-1:0] S_ARADDR,
    input logic S_ARVALID,
    output logic S_ARREADY,
    output logic [31:0] S_RDATA,
    output logic [1:0] S_RRESP,
    output logic S_RVALID,
    input logic S_RREADY,

    output logic start_pulse,
    output logic [15:0] m_dim,
    output logic [15:0] n_dim,
    output logic [15:0] k_dim,
    output logic [1:0] prec_mode,
    output logic [2:0] af_sel,
    output logic [4:0] requant_shift,
    output logic round_en,
    output logic [31:0] act_base,
    output logic [31:0] wt_base,
    output logic [31:0] out_base,
    input  logic busy,
    input  logic done
);
    logic [31:0] mn_reg,k_reg,mode_reg,act_reg,wt_reg,out_reg;
    logic wr_fire,rd_fire;

    assign S_AWREADY=1'b1;
    assign S_WREADY =1'b1;
    assign S_BRESP  =2'b00;
    assign S_ARREADY=1'b1;
    assign S_RRESP  =2'b00;
    assign wr_fire=S_AWVALID&S_WVALID;
    assign rd_fire=S_ARVALID;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) begin
            mn_reg<=0;k_reg<=0;mode_reg<=0;act_reg<=0;wt_reg<=0;out_reg<=0;
            S_BVALID<=0;S_RVALID<=0;S_RDATA<=0;start_pulse<=0;
        end else begin
            start_pulse<=0;

            if(wr_fire) begin
                unique case(S_AWADDR[7:2])
                    6'h00: if(S_WDATA[0]) start_pulse<=1'b1;
                    6'h01: mn_reg<=S_WDATA;
                    6'h02: k_reg<=S_WDATA;
                    6'h03: mode_reg<=S_WDATA;
                    6'h04: act_reg<=S_WDATA;
                    6'h05: wt_reg<=S_WDATA;
                    6'h06: out_reg<=S_WDATA;
                endcase
                S_BVALID<=1;
            end else if(S_BVALID&S_BREADY) S_BVALID<=0;

            if(rd_fire & !S_RVALID) begin
                unique case(S_ARADDR[7:2])
                    6'h00: S_RDATA<={29'd0,done,busy,1'b0};
                    6'h01: S_RDATA<=mn_reg;
                    6'h02: S_RDATA<=k_reg;
                    6'h03: S_RDATA<=mode_reg;
                    6'h04: S_RDATA<=act_reg;
                    6'h05: S_RDATA<=wt_reg;
                    6'h06: S_RDATA<=out_reg;
                    default:S_RDATA<=32'h0;
                endcase
                S_RVALID<=1;
            end else if(S_RVALID&S_RREADY) S_RVALID<=0;
        end
    end

    assign m_dim=mn_reg[15:0];
    assign n_dim=mn_reg[31:16];
    assign k_dim=k_reg[15:0];

    assign prec_mode=mode_reg[1:0];
    assign af_sel=mode_reg[4:2];
    assign requant_shift=mode_reg[9:5];
    assign round_en=mode_reg[10];

    assign act_base=act_reg;
    assign wt_base=wt_reg;
    assign out_base=out_reg;
endmodule
