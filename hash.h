#ifndef HASH_H
#define HASH_H

#include <string>
#include <openssl/sha.h>

typedef void (*hash_func)(char*, int, char*);

// hashing functions
// @args:
//  orig: original string
//  orig_len: original string length (including null character)
//  hashed: hashed string

inline void identity_mapping(char* orig, int orig_len, char* hashed) {
    hashed = orig;
}

inline void sha_256(char* orig, int orig_len, char* hashed) {
    // @TODO
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, orig, orig_len);
    SHA256_Final(hashed, &sha256);
}

inline void sha_1(char* orig, int orig_len, char* hashed) {
    // @TODO
    SHA1(orig, orig_len, hashed);
}

#endif
