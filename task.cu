#include <iostream>
#include <cstdlib>
#include "breaker.cuh"

using std::cout;
using std::endl;

int main(int argc, char** argv) {
    unsigned int n = atoi(argv[1]);

    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    cudaEventRecord(start);
    // call the kernel
    kernel_placeholder()
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    // Get the elapsed time in milliseconds
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    
    cout << ms << endl;

    return 0;
}
