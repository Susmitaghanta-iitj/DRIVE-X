module precision_address_adapter(
    input logic [1:0] prec_mode,
    input logic [31:0] logical_element_index,
    output logic [31:0] byte_address_index,
    output logic [1:0] packed_lane
);
    always_comb begin
        unique case(prec_mode)
            2'b10: begin // 4xINT2
                byte_address_index = logical_element_index >> 2;
                packed_lane = logical_element_index[1:0];
            end
            2'b11: begin // 2xFP4
                byte_address_index = logical_element_index >> 1;
                packed_lane = {1'b0,logical_element_index[0]};
            end
            default: begin
                byte_address_index = logical_element_index;
                packed_lane = 2'b00;
            end
        endcase
    end
endmodule
