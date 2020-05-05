#include <iostream>
#include <cstdlib>
#include <cstring>
#include <string.h>
#include "breaker.cuh"
#include "hash.cuh"

using std::cout;
using std::endl;

int main(int argc, char** argv) {
    unsigned int num_grids = atoi(argv[1]);
    unsigned int num_threads = atoi(argv[2]);
    char *tmp = argv[3];
    char _tmp[3] = {0};
    // print device info
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    
    cout << "Device Name: " << prop.name << endl;
    cout << "Max Threads Per Block: " << prop.maxThreadsPerBlock << endl;

    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // setting up dictionary, goal & hash function
    char dict[] = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const int dict_len = strlen(dict) + 1;
    int max_len = 4 + 1;
    hash_func hash = identity_mapping;
    int hash_len = 16; // MD5

    char *dict_d;
    uint8_t *hashed_d;

    cudaMallocManaged(&dict_d, dict_len * sizeof(char));
    cudaMallocManaged(&hashed_d, 16 * sizeof(uint8_t));

    memcpy(dict_d, dict, dict_len * sizeof(char));
    cout<<"The input hash string is: "<<tmp<<endl;
    for (int i = 0 ; i < 16 ; i ++){
        strncpy(_tmp, tmp+i*2, 2);
        sscanf(_tmp, "%x", &hashed_d[i]);
    }

    cudaEventRecord(start);
    // call the kernel
    breaker_kernel<<<num_grids, num_threads>>>(dict_d, hashed_d, max_len, hash, hash_len);
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
