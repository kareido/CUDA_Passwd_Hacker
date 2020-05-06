#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Constants are the integer part of the sines of integers (in radians) * 2^32.
__device__ uint32_t k[64] = {0};

// r specifies the per-round shift amounts
__device__ const uint32_t r[] = {
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9,  14, 20, 5, 9,  14, 20, 5, 9,  14, 20, 5, 9,  14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

// leftrotate function definition
__device__ uint32_t leftrotate(uint32_t x, uint32_t C) {
    return (((x) << (C)) | ((x) >> (32 - (C))));
}

__device__ void to_bytes(uint32_t val, uint8_t *bytes) {
    bytes[0] = (uint8_t)val;
    bytes[1] = (uint8_t)(val >> 8);
    bytes[2] = (uint8_t)(val >> 16);
    bytes[3] = (uint8_t)(val >> 24);
}

__device__ uint32_t to_int32(const uint8_t *bytes) {
    return (uint32_t)bytes[0] | ((uint32_t)bytes[1] << 8) |
           ((uint32_t)bytes[2] << 16) | ((uint32_t)bytes[3] << 24);
}

__device__ void md5(const uint8_t *initial_msg, size_t initial_len,
                    uint8_t *digest) {
    // Use binary integer part of the sines of integers (Radians) as constants:
    for (int i = 0; i < 64; i++) {
        k[i] = (uint32_t)(abs(sin(i + 1.0)) * ((long long)1 << 32));
    }

    // Initialize variables:
    uint32_t a0 = 0x67452301;
    uint32_t b0 = 0xefcdab89;
    uint32_t c0 = 0x98badcfe;
    uint32_t d0 = 0x10325476;

    uint8_t *message = NULL;

    size_t new_len, offset;
    uint32_t M[16];
    uint32_t A, B, C, D, F, g;

    // Pre-processing:
    // append "1" bit to message
    // append "0" bits until message length in bits ≡ 448 (mod 512)
    // append length mod (2^64) to message
    for (new_len = initial_len + 1; new_len % (512 / 8) != 448 / 8; new_len++);

    message = (uint8_t *)malloc(new_len + 8);
    memcpy(message, initial_msg, initial_len);
    message[initial_len] = 0x80;  // append the "1" bit
    for (offset = initial_len + 1; offset < new_len; offset++){
        message[offset] = 0;  // append "0" bits
    }

    // append the len in bits at the end of the buffer.
    to_bytes(initial_len * 8, message + new_len);
    // address the overflow part
    to_bytes(initial_len >> 29, message + new_len + 4);

    // Process the message in successive 512-bit chunks:
    // for each 512-bit chunk of message:
    for (offset = 0; offset < new_len; offset += (512 / 8)) {
        // break chunk into sixteen 32-bit words w[j], 0 ≤ j ≤ 15
        for (int i = 0; i < 16; i++) {
            M[i] = to_int32(message + offset + i * 4);
        }

        // Initialize hash value for this chunk:
        A = a0;
        B = b0;
        C = c0;
        D = d0;

        // Main loop:
        for (int i = 0; i < 64; i++) {
            if (i < 16) {
                F = (B & C) | ((~B) & D);
                g = i;
            } else if (i < 32) {
                F = (D & B) | ((~D) & C);
                g = (5 * i + 1) % 16;
            } else if (i < 48) {
                F = B ^ C ^ D;
                g = (3 * i + 5) % 16;
            } else {
                F = C ^ (B | (~D));
                g = (7 * i) % 16;
            }

            F = A + F + k[i] + M[g];  // M[g] must be a 32-bits block
            A = D;
            D = C;
            C = B;
            B = B + leftrotate(F, r[i]);
        }

        // Add this chunk's hash to result so far:
        a0 += A;
        b0 += B;
        c0 += C;
        d0 += D;
    }

    // cleanup
    free(message);

    // var char digest[16] := a0 append b0 append c0 append d0 //(Output is in
    // little-endian)
    to_bytes(a0, digest);
    to_bytes(b0, digest + 4);
    to_bytes(c0, digest + 8);
    to_bytes(d0, digest + 12);
}
