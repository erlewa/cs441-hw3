// Compute the sum off all values in a square Matrix
// Assign a block to each row and a thread to each column in that row 
// Use a reduction algorithm to get O(log(n)) time complexity
// Sum the results of the blocks on the host

// I store the matrix in a 1 dimensional array to simplify
// copying data to and from the host
//
// 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
//
// 0  1  2  3
// 4  5  6  7
// 8  9  10 11
// 12 13 14 15

#include <cstddef>
#include <cstdio>
#include <ostream>
#include <vector>
#include <iostream>

__global__
void sum_reduction(int* mat, int* out, size_t edge) {
  __shared__ int s_mem[8]; 
  unsigned int tid = threadIdx.x;
  unsigned int i = blockDim.x;

  while(i > 0) {
    // On first loop have each thread load its value into memory
    if (i == blockDim.x) {
      s_mem[tid] = mat[tid + (blockIdx.x * 8)];
    }
    // Body of reduction
    else if(tid < i) {
      s_mem[tid] += s_mem[tid + i];
    }
    __syncthreads();
    i /= 2;
  }
  
  if (tid == 0) {
    out[blockIdx.x] = s_mem[tid];
  }
};

int main() {
  // Initialize 3x4 Matrix
  size_t edge = 8;
  std::vector<int> mat(edge * edge, 1); 

  // Copy matrix to device
  int* d_mat; 
  size_t mat_size = edge*edge*sizeof(int); 
  cudaMalloc(&d_mat, mat_size);
  cudaMemcpy(d_mat, mat.data(), mat_size, cudaMemcpyHostToDevice);
  
  // Make call to kernel 
  int* d_out;
  cudaMalloc(&d_out, edge*sizeof(int));
  sum_reduction<<<edge, edge>>>(d_mat, d_out, edge);
  
  cudaDeviceSynchronize();
  
  // Copy results back to host
  std::vector<int> res_vec(edge);
  cudaMemcpy(res_vec.data(), d_out, edge*sizeof(int), cudaMemcpyDeviceToHost);

  // Add up kernel results sequentially
  int sum = 0;
  for (size_t i = 0; i < res_vec.size(); i++) {
    sum += res_vec[i];
  }
  std::cout << "Final Sum: " << sum << std::endl;
};
