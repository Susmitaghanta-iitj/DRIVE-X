#include "approxflex_queue.h"
int approxflex_q_push(approxflex_queue_t *q,const approxflex_job_t *j){
    unsigned n=(q->head+1u)&31u;
    if(n==q->tail) return -1;
    q->q[q->head]=*j; q->head=n; return 0;
}
int approxflex_q_pop(approxflex_queue_t *q,approxflex_job_t *j){
    if(q->tail==q->head) return -1;
    *j=q->q[q->tail]; q->tail=(q->tail+1u)&31u; return 0;
}
