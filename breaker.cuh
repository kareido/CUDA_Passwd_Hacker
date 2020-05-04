// Author: Nic Olsen

#ifndef BREAKER_CUH
#define BREAKER_CUH

#include "hash.cuh"

// cracking password by brute force
// @args:
//  dict: dictionary containing ASCII characters that might have been used in the password.
//  goal: correct password
//  goal_len: length of the non-hashed correct password
//  hash: hash function typically used in cryptography
__global__ void breaker_kernel(const char* dict, const uint8_t* hashed, const int max_len, hash_func hash, const int hash_len);

__device__ int strlen_d(const char* str);

__device__ bool arrcmp_d(const uint8_t *arr1, const uint8_t *arr2, const int len);

__device__ bool strcmp_d(const char* str1, const char* str2);

#endif
