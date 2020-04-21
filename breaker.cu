#include <iostream>
#include "breaker.cuh"
#include "hash.h"

using std::endl;
using std::cout;

__global__ void breaker_kernel(char* diction, char* goal, int goal_len, hash_func hash) {
   // @TODO
}

