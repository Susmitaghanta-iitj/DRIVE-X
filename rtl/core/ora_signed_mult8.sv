module ora_signed_mult8(input logic signed [7:0] a,b,output logic signed [16:0] p);
logic [7:0] amag,bmag;logic [4:0] ar,br;logic [1:0] ash,bsh;logic [9:0] p5;logic [16:0] pmag;logic sign_p;
operand_rounder_mag8to5 ra(.x(amag),.xr(ar),.sh(ash));
operand_rounder_mag8to5 rb(.x(bmag),.xr(br),.sh(bsh));
always_comb begin
 amag=a[7]?(~a+1):a; bmag=b[7]?(~b+1):b; sign_p=a[7]^b[7];
 p5=ar*br; pmag={{7{1'b0}},p5}<<(ash+bsh); p=sign_p?-$signed(pmag):$signed(pmag);
end
endmodule
