module tile_scheduler #(
    parameter int ARRAY_N = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [15:0] m_dim,
    input  logic [15:0] n_dim,
    input  logic [15:0] k_dim,
    input  logic [1:0]  prec_mode,

    output logic busy,
    output logic done,
    output logic [$clog2(ARRAY_N+1)-1:0] rows_req,
    output logic [$clog2(ARRAY_N+1)-1:0] cols_req,
    output logic [15:0] m_off,
    output logic [15:0] n_off,
    output logic [15:0] k_idx,
    output logic acc_clear,
    output logic mac_en,
    output logic commit_tile
);
    typedef enum logic [2:0] {IDLE,LOAD_TILE,CLEAR,RUN_K,COMMIT,NEXT_TILE,DONE} st_t;
    st_t st;
    logic [15:0] m_cur,n_cur,k_cur;
    logic [15:0] k_step;

    always_comb begin
        unique case(prec_mode)
            2'b10: k_step = 16'd4; // 4xINT2
            2'b11: k_step = 16'd2; // 2xFP4
            default: k_step = 16'd1;
        endcase
    end

    function automatic [15:0] minN(input [15:0] x);
        if(x > ARRAY_N) minN = ARRAY_N;
        else minN = x;
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            st<=IDLE; busy<=0; done<=0; m_cur<=0; n_cur<=0; k_cur<=0;
            rows_req<='0; cols_req<='0; m_off<=0; n_off<=0; k_idx<=0;
            acc_clear<=0; mac_en<=0; commit_tile<=0;
        end else begin
            done<=0; acc_clear<=0; mac_en<=0; commit_tile<=0;
            case(st)
                IDLE: if(start) begin
                    busy<=1; m_cur<=0; n_cur<=0; k_cur<=0; st<=LOAD_TILE;
                end
                LOAD_TILE: begin
                    m_off<=m_cur; n_off<=n_cur;
                    rows_req<=minN(m_dim-m_cur)[$clog2(ARRAY_N+1)-1:0];
                    cols_req<=minN(n_dim-n_cur)[$clog2(ARRAY_N+1)-1:0];
                    st<=CLEAR;
                end
                CLEAR: begin
                    acc_clear<=1; k_cur<=0; k_idx<=0; st<=RUN_K;
                end
                RUN_K: begin
                    mac_en<=1; k_idx<=k_cur;
                    if(k_cur + k_step >= k_dim)
                        st<=COMMIT;
                    else
                        k_cur<=k_cur+k_step;
                end
                COMMIT: begin commit_tile<=1; st<=NEXT_TILE; end
                NEXT_TILE: begin
                    if(n_cur + ARRAY_N < n_dim) begin
                        n_cur<=n_cur+ARRAY_N; st<=LOAD_TILE;
                    end else if(m_cur + ARRAY_N < m_dim) begin
                        n_cur<=0; m_cur<=m_cur+ARRAY_N; st<=LOAD_TILE;
                    end else st<=DONE;
                end
                DONE: begin busy<=0; done<=1; st<=IDLE; end
            endcase
        end
    end
endmodule
