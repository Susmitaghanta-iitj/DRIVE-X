module output_packer #(
    parameter int ARRAY_N=8,
    parameter int BUS_W=128
)(
    input logic signed [15:0] row [0:ARRAY_N-1],
    output logic [BUS_W-1:0] data
);
integer i;
always_comb begin
    data='0;
    for(i=0;i<ARRAY_N;i=i+1) begin
        if((i*16+15)<BUS_W) data[i*16 +: 16]=row[i];
    end
end
endmodule
