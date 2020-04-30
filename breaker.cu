#include <cassert>
#include "breaker.cuh"

__device__ int strlen_d(char *str) {
    int len = 0;
    char *p = str;
    while (*p) {
        len++;
        p++;
    }

    return len;
}

__device__ bool strcmp_d(char *str1, char *str2) {
    char *p1 = str1;
    char *p2 = str2;
    
    while (*p1 && *p2) {
        if (*p1 != *p2) return false;
        p1++;
        p2++;
    }

    return bool(*p1 == *p2);
}

__global__ void breaker_kernel(char *dict, char *goal, int goal_len,
                               hash_func hash, int hash_len) {
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
    int N = pow(dict_len - 1, goal_len - 1);
    int round = (N + total_num_threads - 1) / total_num_threads;
    // printf("%s %d\n", dict, strlen_d(dict));
    for (int r = 0; r < round; r++) {
        // printf("stat %d\n", tid);
        int num = idx + r * total_num_threads;
        if (num > N) return;
        int base = 1;
        char *orig_pwd = new char[goal_len];
        memset(orig_pwd, 0, goal_len);
        // gen
        for (int j = 0; j < goal_len - 1; j++) {
            orig_pwd[j] = dict[num / base % (dict_len - 1)];
            base *= dict_len - 1;
        }
        // hashing
        // char *hashed_pwd = new char[hash_len];
        // memset(hashed_pwd, 0, hash_len);
        // hash(orig_pwd, goal_len, hashed_pwd);
        // cmp
        // if (strcmp_d(hashed_pwd, goal)) {
        //     printf("Password Hacked: %s", orig_pwd);
        // assert(0);
        // }
        if (strcmp_d(orig_pwd, goal)) {
            printf("\nThe cracked password is [%s].\n", orig_pwd);
            // asm("trap;");
            uint8_t result[16];
            md5((uint8_t *)orig_pwd, goal_len - 1, result);
            for (int i = 0; i < 16; i++) {
                printf("%2.2x", result[i]);
            }
            printf("\n");
            return;
        }
        delete[] orig_pwd;
        // delete [] hashed_pwd;
    }
}
