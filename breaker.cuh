// Author: Nic Olsen

#ifndef SCAN_CUH
#define SCAN_CUH

#include <string>

// cracking password by brute force
// @args:
//  dict: dictionary containing ASCII characters that might have been used in the password.
//  goal: correct password
//  hash: hash function typically used in cryptography
// @ret:
//  a non-hashed password string on success, if failed return empty string
__global__ std::string breaker_kernel(std::string dict, std::string goal, hash_func hash_func);

#endif
