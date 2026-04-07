// Compute the sum off all values in a 3x4 Matrix
// Assign on thread to each column
// Sum the results of the columns on the host

// I store the 3x4 matrix in a 1 dimensional array to simplify
// copying data to and from the host
//
// 0 1 2 3 4 5 6 7 8 9 10 11
//
// 0  1  2  3
// 4  5  6  7
// 8  9  10 11

#include <vector>
#include <iostream>

__global__
void mult_by_ones_vec(int* mat, int* out, size_t rows, size_t cols) {
  int sum = 0;
  for (size_t i = 0; i < rows; i++) {
    sum += mat[threadIdx.x + (i * cols)];
  }
  
  out[threadIdx.x] = sum;
};

int main() {
  // Initialize 3x4 Matrix
  size_t rows = 3;
  size_t cols = 4;
  std::vector<int> mat(rows * cols, 1); 

  // Copy matrix to device
  int* d_mat; 
  size_t mat_size = rows*cols*sizeof(int); 
  cudaMalloc(&d_mat, mat_size);
  cudaMemcpy(d_mat, mat.data(), mat_size, cudaMemcpyHostToDevice);
  
  // Get results from device
  int* d_out;
  cudaMalloc(&d_out, cols*sizeof(int));
  mult_by_ones_vec<<<1, cols>>>(d_mat, d_out, rows, cols);
  
  cudaDeviceSynchronize();
  std::vector<int> res_vec(cols);
  cudaMemcpy(res_vec.data(), d_out, cols*sizeof(int), cudaMemcpyDeviceToHost);
  
  int sum = 0;
  for (size_t i = 0; i < res_vec.size(); i++) {
    sum += res_vec[i];
  }
  std::cout << "Final Sum: " << sum << std::endl;
  
  cudaFree();
};
