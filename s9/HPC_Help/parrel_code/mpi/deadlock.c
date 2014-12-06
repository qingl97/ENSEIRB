#include <stdio.h>
#include <string.h>
#include "mpi.h"

#define SIZE 16

int
main(int argc, char **argv)
{
    static int buf1[SIZE], buf2[SIZE];
    int nprocs, rank, tag, src, dst;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);	/* ��ȡ�ܽ����� */
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);	/* ��ȡ�����̵Ľ��̺� */
    
    /* ��ʼ�� buf1 */
    memset(buf1, 1, SIZE);
       
    tag = 123;
    dst = (rank >= nprocs - 1) ? 0 : rank + 1;
    src = (rank == 0) ? nprocs - 1 : rank - 1;
    MPI_Send(buf1, SIZE, MPI_INT, dst, tag, MPI_COMM_WORLD);
    MPI_Recv(buf2, SIZE, MPI_INT, src, tag, MPI_COMM_WORLD, &status);

    MPI_Finalize();

    return 0;    
}
