module nms_topk #(
    parameter int MAX_BOXES=256
)(
    input logic clk,rst_n,
    input logic start,
    input logic [15:0] box_count,
    input logic [15:0] score_thresh_q15,
    input logic [15:0] iou_thresh_q15,
    output logic busy,done
);
    typedef enum logic [1:0] {IDLE,RUN,DONE} st_t;
    st_t st; logic [15:0] idx;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin st<=IDLE;busy<=0;done<=0;idx<=0; end
        else begin done<=0; case(st)
            IDLE: if(start) begin busy<=1;idx<=0;st<=RUN;end
            RUN: if(idx+1>=box_count) st<=DONE; else idx<=idx+1;
            DONE: begin busy<=0;done<=1;st<=IDLE;end
        endcase end
    end
endmodule
