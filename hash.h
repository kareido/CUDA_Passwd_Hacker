#ifndef HASH_H
#define HASH_H

#include <string>

typedef char* (*hash_func)(char*);

inline char* identity_mapping(char* str) {
    return str;
}

inline char* sha_0(char* str) {
    // @TODO
}

inline char* sha_1(char* str) {
    // @TODO
}

#endif
