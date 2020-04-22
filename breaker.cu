#include <iostream>
#include <cstring>
#include "breaker.cuh"
#include "hash.h"

using std::endl;
using std::cout;

__global__ void breaker_kernel(char* dict, char* goal, int goal_len, hash_func hash, int hash_len) {
    int tid_x = threadIdx.x;
    int tid_y = threadIdx.y;
    int gid_x = blockIdx.x;
    int gid_y = blockIdx.y;
    int tid = tid_x * blockDim.x + tid_y;
    int gid = gid_x * gridDim.x + gid_y;
    int idx = threads_per_block * gid + tid;
    int threads_per_block = blockDim.x * blockDim.y;
    int total_num_threads = gridDim.x * gridDim.y + threads_per_block;
    
    int dict_len = strlen(dict) + 1; // including '/0'
    int N = pow(goal_len - 1, dict_len - 1);
    int round = (N + total_num_threads - 1) / total_num_threads;
    
    for (int r = 0; r < round; r++) {
        num = tid + r * total_num_threads;
        if (num > N) return;
        int base = 1;
        char orig_pwd[goal_len] = {0};
        // gen
        for (int j = 0; j < goal_len - 1; j++) {
            orig_pwd[j] = dict[num / base % (dict_len - 1)];
            base *= dict_len - 1;
        }
        // hashing
        char hashed_pwd[hash_len] = {0};
        hash(pwd, hashed_pwd);
        // cmp
        if (!strcmp(hashed_pwd, goal)) {
            cout << "Password Hacked: " << orig_pwd << endl;
            assert(0);
        }
    }
}

