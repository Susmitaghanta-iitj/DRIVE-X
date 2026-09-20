module int2_pack4(
    input logic signed [1:0] x0,
    input logic signed [1:0] x1,
    input logic signed [1:0] x2,
    input logic signed [1:0] x3,
    output logic [7:0] packed
);
    always_comb packed = {x3,x2,x1,x0};
endmodule
