module operand_rounder_mag8to5(input logic [7:0] x,output logic [4:0] xr,output logic [1:0] sh);
always_comb begin
    if(x<=31) begin xr=x[4:0];sh=0; end
    else if(x<=63) begin xr={x[5:2],x[1]};sh=1; end
    else if(x<=127) begin xr={x[6:4],x[3],x[1]};sh=2; end
    else begin xr={x[7:6],x[5],x[3],x[1]};sh=3; end
end
endmodule
