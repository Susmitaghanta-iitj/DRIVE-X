module memory_compute_bridge #(parameter int ARRAY_N=8,parameter int MEM_W=128)(input logic [MEM_W-1:0] act_word,wt_word,output logic signed [7:0] act_vec[0:ARRAY_N-1],output logic signed [7:0] wt_vec[0:ARRAY_N-1]);
vector_unpacker #(.ARRAY_N(ARRAY_N),.BUS_W(MEM_W)) ua(.data(act_word),.vec(act_vec));
vector_unpacker #(.ARRAY_N(ARRAY_N),.BUS_W(MEM_W)) uw(.data(wt_word),.vec(wt_vec));
endmodule
