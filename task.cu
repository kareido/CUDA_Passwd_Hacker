#include <iostream>
#include <cstdlib>
#include <cstring>
#include "breaker.cuh"
#include "hash.cuh"

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
    char dict[] = "1234567890";
    char goal[] = "759";
    int dict_len = strlen(dict) + 1;
    int goal_len = strlen(goal) + 1;
    hash_func hash = identity_mapping;
    int hash_len = goal_len + 1;

    char *dict_d, *goal_d;
    cudaMallocManaged(&dict_d, dict_len * sizeof(char));
    cudaMallocManaged(&goal_d, goal_len * sizeof(char));

    for (int i = 0; i < dict_len; i++)
        dict_d[i] = dict[i];
    for (int i = 0; i < goal_len; i++)
        goal_d[i] = goal[i];
    
    cudaEventRecord(start);
    // call the kernel
    breaker_kernel<<<num_grids, num_threads>>>(dict_d, goal_d, goal_len, hash, hash_len);
    cudaError_t cudaerr = cudaDeviceSynchronize();
    if (cudaerr != cudaSuccess)
        printf(">>> kernel launch failed with error \"%s\".\n",
            cudaGetErrorString(cudaerr));
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    // Get the elapsed time in milliseconds
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    
    cout << "Password cracked in ["<< ms <<"] ms." << endl;

    return 0;
}
