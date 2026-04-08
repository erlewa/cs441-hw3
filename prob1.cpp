// Use 8 processors with MPI to find the minimum value 
#include <cstdlib>
#include <mpi.h>
#include <stdio.h>
#include <ctime>

int main(int argc, char *argv[]) 
{
  MPI_Init(&argc, &argv);

  int my_rank;
  int p;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &p); 

  size_t n = 8'000'000;
  int max_val = 1'000'000'000;
  int* array = (int*) std::malloc(n*sizeof(int));

  if (my_rank == 0) {

    std::srand(std::time(0));
    for (size_t i = 0; i < n; i++) {
      array[i] = rand() % max_val;
    }
  }

  MPI_Bcast(array, n, MPI_INT, 0, MPI_COMM_WORLD);
  
  unsigned int start = static_cast<int>((n/p)*my_rank);
  unsigned int end = static_cast<int>((n/p)*my_rank+(n/p)-1);
  
  int r_min = max_val; 
  for (unsigned int i = start; i < end; i++) {
    if (array[i] < r_min) {
      r_min = array[i];
    }
  }

  int g_min;
  MPI_Reduce(&r_min, &g_min, 1, MPI_INT, MPI_MIN, 0, MPI_COMM_WORLD);

  if (my_rank == 0) {
    printf("Minimum: %d\n", g_min);
    free((void*) array);
  }
  MPI_Finalize();

  return 0;
}
