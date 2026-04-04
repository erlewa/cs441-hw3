// [X] Host should generate a 8,000,000 element array of random integers from 0 to 1,000,000,000.
// [ ] Assign 8 threads to find the minimum of their assigned portion, ie thread 0 does 1st 1/8th and so on.
// [ ] Send the results to the host which should then find the overall minimum
// [ ] Have the host validate this answer by sequentially searching the entire array.
#include <cstddef>
#include <iostream>
#include <ostream>
#include <stdlib.h>
#include <vector>

__global__
void minimum() {

};

int main() {
  // Initialize array, stored as vector to avoid running out of space on the stack
  size_t n = 8'000'000;
  int max_val = 1'000'000'000;
  std::vector<int> vec(n); 
  for (size_t i = 0; i < vec.size(); i++) {
    vec[i] = rand() % max_val;
  }
  
  // Copy array from host to device
  int* d_vec; 
  size_t vec_size = vec.size() * sizeof(int);
  cudaMalloc(&d_vec, vec_size);
  cudaMemcpy(d_vec, vec.data(), vec_size, cudaMemcpyHostToDevice);
  
  // Compute minimum on device 
  
  // Compute minimum on host
  int running_min = max_val; 
  for (size_t i = 0; i < vec.size(); i++) {
  if (vec[i] < running_min) {
      running_min = vec[i];
    }
  }
  std::cout << "Host Minimum: " << running_min << std::endl;
}
