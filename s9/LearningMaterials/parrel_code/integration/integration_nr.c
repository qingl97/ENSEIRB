/* $Id: integration_nr.c,v 1.2 2005/06/20 03:28:52 zlb Exp $ */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "integration_nr.h"

#define MACHINE_PREC	1e-15			/* 机器精度 */

double
integration_nr(double a, double b, double eps, void(*F1)(double x, double *f))
{
    double res;
    interval_t *root, *I, *J;			/* 区间集合链表指针 */
    int pass, inter_count = 1, inter_max = 0;

    if (a == b)
	return 0.0;
    eps *= 12.0 / (b - a);

    root = malloc(sizeof(*root));
    (*F1)(root->x0 = a, &root->f0);
    (*F1)(root->x1 = b, &root->f1);
    root->next = root->last = NULL;

    res = 0.0;
    while (inter_count > 0) {			/* 主循环 */
	for (pass = 0; pass < 2; pass++) {
	    I = root;
	    if (pass) (*F1)(0.0, NULL);		/* 等待所有函数值的计算完成 */
	    while (I != NULL) {
		double h, v0, v1, xc;
		xc = 0.5 * (I->x1 + I->x0);	/* 计算区间中点 */
		if (pass == 0) {
		    (*F1)(xc, &I->fc);		/* 请求计算函数值 */
		    I = I->next;
		    continue;
		}
		h = I->x1 - I->x0;
		v0 = 0.5 * h * (I->f0 + I->f1);
		v1 = (v0 + I->fc * h) * 0.5;
		if (fabs(v1 - v0) < h * eps ||	/* 误差满足要求或区间长度太小 */
		    fabs(h) < (1.0 + fabs(xc)) * MACHINE_PREC) {
		    res += v1;
		    if (I->last != NULL) I->last->next = I->next;
		    if (I->next != NULL) I->next->last = I->last;
		    J = I;
		    I = I->next;
		    free(J);			/* 删除计算已完成的区间 */
		    if (J == root) root = NULL;
		    inter_count--;
		    continue;
		}
		J = malloc(sizeof(*J));		/* 申请一个新区间 */
		if (++inter_count > inter_max) inter_max = inter_count;
		J->x1 = I->x1;
		J->f1 = I->f1;
		I->x1 = J->x0 = xc;
		I->f1 = J->f0 = I->fc;
		J->next = I->next;
		if (I->next != NULL) I->next->last = J;
		I->next = J;
		J->last = I;
		I = J->next;
	    }
	}
    }

    printf("Maxi. nunmber of intervals allocated: %d.\n", inter_max);
    return res;
}
