package approxflex_pkg;
    parameter int DATA_W      = 8;
    parameter int ACC_W       = 24;
    parameter int AF_OUT_W    = 16;
    parameter int FP_ACC_FRAC = 8;

    typedef enum logic [1:0] {
        PREC_ORA8  = 2'b00,
        PREC_EX4   = 2'b01,
        PREC_4X2   = 2'b10,
        PREC_2XFP4 = 2'b11
    } prec_mode_t;

    typedef enum logic [2:0] {
        AF_RELU  = 3'd0,
        AF_SIG   = 3'd1,
        AF_TANH  = 3'd2,
        AF_SWISH = 3'd3,
        AF_GELU  = 3'd4
    } af_sel_t;

    typedef enum logic [3:0] {
        OP_NOP      = 4'd0,
        OP_CONV     = 4'd1,
        OP_DWCONV   = 4'd2,
        OP_ADD      = 4'd3,
        OP_CONCAT   = 4'd4,
        OP_UPSAMPLE = 4'd5,
        OP_DETECT   = 4'd6
    } op_t;
endpackage
