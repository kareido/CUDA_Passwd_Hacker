#ifndef HASH_H
#define HASH_H

#include <string>
#include <openssl/sha.h>

typedef void (*hash_func)(char*, int, char*&);

// hashing functions
// @args:
//  orig: original string
//  orig_len: original string length (including null character)
//  hashed: hashed string

inline void identity_mapping(char* orig, int orig_len, char*& hashed) {
    hashed = orig;
}

// inline void sha_256(char* orig, int orig_len, char* hashed) {
//     // @TODO
//     SHA256_CTX sha256;
//     SHA256_Init(&sha256);
//     SHA256_Update(&sha256, orig, orig_len);
//     SHA256_Final((unsigned char*)hashed, &sha256);
// }

// inline void sha_1(char* orig, int orig_len, char* hashed) {
//     // @TODO
//     SHA1((unsigned char*)orig, orig_len, (unsigned char*)hashed);
// }

__device__ void md5(const uint8_t *initial_msg, size_t initial_len, uint8_t *digest);

#endif
