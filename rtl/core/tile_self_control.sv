module tile_self_control #(
    parameter int ARRAY_N=8
)(
    input logic [$clog2(ARRAY_N+1)-1:0] rows_req,cols_req,
    output logic [ARRAY_N-1:0] row_mask,col_mask,
    output logic [$clog2(ARRAY_N*ARRAY_N+1)-1:0] active_pe_count
);
integer i;
always_comb begin
 row_mask='0; col_mask='0;
 for(i=0;i<ARRAY_N;i=i+1) begin if(i<rows_req) row_mask[i]=1'b1; if(i<cols_req) col_mask[i]=1'b1; end
 active_pe_count=rows_req*cols_req;
end
endmodule
