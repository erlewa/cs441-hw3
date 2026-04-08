// [X] Host should generate a 8,000,000 element array of random integers from 0 to 1,000,000,000.
// [X] Assign 8 threads to find the minimum of their assigned portion, ie thread 0 does 1st 1/8th and so on.
// [X] Send the results to the host which should then find the overall minimum
// [X] Have the host validate this answer by sequentially searching the entire array.
#include <cstddef>
#include <ctime>
#include <iostream>
#include <ostream>
#include <stdlib.h>
#include <vector>

__global__
void minimum(size_t n, int max_val, int* d_vec, int* res_vec) {
  int running_min = max_val; 
  int chunks = n / 8;
  for (size_t i = chunks * threadIdx.x; i < chunks * (1 + threadIdx.x); i++) {
  if (d_vec[i] < running_min) {
      running_min = d_vec[i];
    }
  }
  res_vec[threadIdx.x] = running_min;
};

int main() {
  // Initialize array, stored as vector to avoid running out of space on the stack
  size_t n = 8'000'000;
  int max_val = 1'000'000'000;
  std::vector<int> vec(n); 
  
  std::srand(std::time(0));
  for (size_t i = 0; i < vec.size(); i++) {
    vec[i] = rand() % max_val;
  }
  
  // Copy array from host to device
  int* d_vec; 
  size_t vec_size = vec.size() * sizeof(int);
  cudaMalloc(&d_vec, vec_size);
  cudaMemcpy(d_vec, vec.data(), vec_size, cudaMemcpyHostToDevice);
  
  // Compute minimum on device 
  int* d_min;
  cudaMalloc(&d_min, 8 * sizeof(int));
  minimum<<<1, 8>>>(n, max_val, d_vec, d_min);
  
  cudaDeviceSynchronize();
  
  std::vector<int> device_minimum(8);
  cudaMemcpy(device_minimum.data(), d_min, 8 * sizeof(int), cudaMemcpyDeviceToHost);
  int running_device_min = max_val;
  for (size_t i = 0; i < device_minimum.size(); i++) {
    std::cout << "Mimimum from thread " << i << " is " << device_minimum[i] << std::endl;
    if (device_minimum[i] < running_device_min) {
      running_device_min = device_minimum[i]; 
    }
  }
  std::cout << "Minimum found on device is: " << running_device_min << std::endl;
  

  // Compute minimum on host
  int running_min = max_val; 
  for (size_t i = 0; i < vec.size(); i++) {
  if (vec[i] < running_min) {
      running_min = vec[i];
    }
  }
  std::cout << "Host Minimum: " << running_min << std::endl;
  
  cudaFree(d_vec);
  cudaFree(d_min);
}
