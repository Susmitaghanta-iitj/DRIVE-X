module vector_unpacker #(
    parameter int ARRAY_N=8,
    parameter int BUS_W=128
)(
    input logic [BUS_W-1:0] data,
    output logic signed [7:0] vec [0:ARRAY_N-1]
);
integer i;
always_comb begin
    for(i=0;i<ARRAY_N;i=i+1) begin
        if((i*8+7)<BUS_W) vec[i]=$signed(data[i*8 +: 8]);
        else vec[i]='0;
    end
end
endmodule
