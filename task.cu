#include <iostream>
#include <cstdlib>
#include <cstring>
#include "breaker.cuh"
#include "hash.h"

using std::cout;
using std::endl;

int main(int argc, char** argv) {
    unsigned int num_grids = atoi(argv[1]);
    unsigned int num_threads = atoi(argv[2]);
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    
    cout << "Device Name: " << prop.name << endl;
    cout << "Max Threads Per Block: " << prop.maxThreadsPerBlock << endl;

    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // setting up dictionary, goal & hash function
    char *dict = "1234567890";
    char *goal = "759";
    int goal_len = strlen(goal) + 1;
    hash_func hash = identity_mapping;
    int hash_len = goal_len + 1;
    
    cudaEventRecord(start);
    // call the kernel
    breaker_kernel<<<num_grids, num_threads>>>(dict, goal, goal_len, hash, hash_len);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    // Get the elapsed time in milliseconds
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    
    cout << ms << endl;

    return 0;
}
