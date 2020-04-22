#ifndef HASH_H
#define HASH_H

#include <string>

typedef void (*hash_func)(char*, int, char*);

// hashing functions
// @args:
//  orig: original string
//  orig_len: original string length (including null character)
//  hashed: hashed string

inline void identity_mapping(char* orig, int orig_len, char* hashed) {
    hashed = orig;
}

inline void sha_0(char* orig, int orig_len, char* hashed) {
    // @TODO
}

inline void sha_1(char* orig, int orig_len, char* hashed) {
    // @TODO
}

#endif
