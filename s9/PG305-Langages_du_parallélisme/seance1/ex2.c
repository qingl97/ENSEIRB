#include <stdio.h>
#include "mpi.h"
int main( int argc, char **argv ) {
  //char message[20];                                                                                                                                                             
  signed int num;
  int myrank;
  MPI_Status status;
  MPI_Init( NULL, NULL );
  // get my rank
  MPI_Comm_rank( MPI_COMM_WORLD, &myrank );

  // Get the number of processes                                                                                                                                                  
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  int avant = myrank - 1;
  if (avant < 0) avant = world_size - 1;
  int apres =  (myrank + 1) % world_size;

  if (myrank == 0)/* code for process zero */ {
    // strcpy(message,"Hello, there");                                                                                                                                            
    num = 10;
    MPI_Send(&num, sizeof(signed int), MPI_INT, apres, 99, MPI_COMM_WORLD);
    printf("proc_%d send %d\n ", myrank, num);
    MPI_Recv(&num, sizeof(signed int), MPI_INT, avant, 99, MPI_COMM_WORLD, &status);
    printf("proc_%d recv %d\n ", myrank, num);
  } else /* code for other process */ {
    MPI_Recv(&num, sizeof(signed int), MPI_INT, avant, 99, MPI_COMM_WORLD, &status);
    printf("proc_%d recv %d\n ", myrank, num);
    num = num +1;
    // printf("%d ", num);                                                                                                                                                        
    MPI_Send(&num, sizeof(signed int), MPI_INT, apres, 99, MPI_COMM_WORLD);
    printf("proc_%d send %d\n ", myrank, num);
  }
  MPI_Finalize();
}


