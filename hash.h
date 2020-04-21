#ifndef HASH_H
#define HASH_H

#include <string>

typedef std::string (*hash_func)(std::string str);

inline std::string identity_mapping(std::string str) {
    return str;
}

inline std::string sha_0(std::string str) {
    // @TODO
}

inline std::string sha_1(std::string str) {
    // @TODO
}

#endif
