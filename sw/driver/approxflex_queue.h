#ifndef APPROXFLEX_QUEUE_H
#define APPROXFLEX_QUEUE_H
#include "approxflex_driver.h"
typedef struct {
    approxflex_job_t q[32];
    unsigned head,tail;
} approxflex_queue_t;
int approxflex_q_push(approxflex_queue_t *q,const approxflex_job_t *j);
int approxflex_q_pop(approxflex_queue_t *q,approxflex_job_t *j);
#endif
