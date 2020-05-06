#include <cassert>
#include "breaker.cuh"
#include <stdio.h>

__device__ int strlen_d(const char *str) {
    int len = 0;
    while (*str) {
        len++;
        str++;
    }

    return len;
}

__device__ bool strcmp_d(const char *str1, const char *str2) {
    while (*str1 && *str2) {
        if (*str1 != *str2) return false;
        str1++;
        str2++;
    }

    return bool(*str1 == *str2);
}

__device__ bool arrcmp_d(const uint8_t *arr1, const uint8_t *arr2, const int len) {
    for(int i = 0 ; i < len ; i ++, arr1++, arr2++){
        if (*arr1 != *arr2) return false;
    }

    return true;
}

__global__ void breaker_kernel(const char *dict, const uint8_t *hashed, const int max_len,
                               hash_func hash, const int hash_len) {
    int tid_x = threadIdx.x;
    int tid_y = threadIdx.y;
    int gid_x = blockIdx.x;
    int gid_y = blockIdx.y;
    int tid = tid_y * blockDim.y + tid_x;
    int gid = gid_y * gridDim.y + gid_x;
    int threads_per_block = blockDim.x * blockDim.y;
    int idx = threads_per_block * gid + tid;
    int total_num_threads = gridDim.x * gridDim.y * threads_per_block;

    int dict_len = strlen_d(dict) + 1;  // including '/0'

    // int goal_len = 5;
    for (int goal_len = 2; goal_len <= max_len ; goal_len ++){
        int N = pow(dict_len - 1, goal_len - 1);
        int round = (N + total_num_threads - 1) / total_num_threads;
        char *orig_pwd = new char[goal_len];
        // printf("%s %d\n", dict, strlen_d(dict));
        for (int r = 0; r < round; r++) {
            // printf("stat %d\n", tid);
            int num = idx + r * total_num_threads;
            if (num > N) break;
            int base = 1;
            memset(orig_pwd, 0, goal_len);
            // gen
            for (int j = 0; j < goal_len - 1; j++) {
                orig_pwd[j] = dict[num / base % (dict_len - 1)];
                base *= dict_len - 1;
            }
            
            // hashing
            uint8_t hashed_pwd_int[16];
            md5((uint8_t *)orig_pwd, goal_len - 1, hashed_pwd_int);

            // printf("The orig_pwd is [%s].\n", orig_pwd);

            if (arrcmp_d(hashed, hashed_pwd_int,hash_len )) {
                printf("Password Hacked: %s\n", orig_pwd);
                delete[] orig_pwd;
                asm("trap;");
                return;
            }
            // if (strcmp_d(orig_pwd, hashed_str)) {
            //     printf("\nThe cracked password is [%s].\n", orig_pwd);
            //     // asm("trap;");
            //     return;
            // }
        }
        delete[] orig_pwd;
    }
}
