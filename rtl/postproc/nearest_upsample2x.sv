module nearest_upsample2x #(
    parameter int DW = 16
)(
    input  logic [DW-1:0] x,
    output logic [DW-1:0] y00,
    output logic [DW-1:0] y01,
    output logic [DW-1:0] y10,
    output logic [DW-1:0] y11
);
    assign y00=x; assign y01=x; assign y10=x; assign y11=x;
endmodule
