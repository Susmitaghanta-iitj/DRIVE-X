module packed_operand_mask(
    input logic [1:0] prec_mode,
    input logic [3:0] lane_valid,
    input logic [7:0] in_byte,
    output logic [7:0] out_byte
);
    integer i;
    always_comb begin
        out_byte=in_byte;
        if(prec_mode==2'b10) begin
            for(i=0;i<4;i=i+1)
                if(!lane_valid[i]) out_byte[i*2 +: 2]=2'b00;
        end else if(prec_mode==2'b11) begin
            if(!lane_valid[0]) out_byte[3:0]=4'b0000;
            if(!lane_valid[1]) out_byte[7:4]=4'b0000;
        end
    end
endmodule
