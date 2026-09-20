module k_tail_mask(
    input logic [1:0] prec_mode,
    input logic [15:0] k_idx,
    input logic [15:0] k_dim,
    output logic [3:0] lane_valid
);
    integer remaining;
    always_comb begin
        remaining = k_dim-k_idx;
        lane_valid=4'b0001;
        case(prec_mode)
            2'b10: begin
                if(remaining>=4) lane_valid=4'b1111;
                else case(remaining)
                    3: lane_valid=4'b0111;
                    2: lane_valid=4'b0011;
                    1: lane_valid=4'b0001;
                    default: lane_valid=4'b0000;
                endcase
            end
            2'b11: begin
                if(remaining>=2) lane_valid=4'b0011;
                else if(remaining==1) lane_valid=4'b0001;
                else lane_valid=4'b0000;
            end
            default: lane_valid=(remaining>0)?4'b0001:4'b0000;
        endcase
    end
endmodule
