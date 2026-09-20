module fp4_pack2(
    input logic [3:0] x0,
    input logic [3:0] x1,
    output logic [7:0] packed
);
    always_comb packed = {x1,x0};
endmodule
