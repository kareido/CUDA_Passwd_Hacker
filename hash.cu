#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__device__ uint32_t k[64] = {0};

// K specifies the per-round shift amounts
__device__ const uint32_t K[] = {
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5, 9,  14, 20, 5, 9,  14, 20, 5, 9,  14, 20, 5, 9,  14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

// leftrotate function definition
__device__ uint32_t leftrotate(uint32_t x, uint32_t C) {
    return (((x) << (C)) | ((x) >> (32 - (C))));
}

__device__ void append_bytes(uint32_t val, uint8_t *outputs) {
    outputs[0] = (uint8_t)val;
    outputs[1] = (uint8_t)(val >> 8);
    outputs[2] = (uint8_t)(val >> 16);
    outputs[3] = (uint8_t)(val >> 24);
}

__device__ uint32_t append_int(const uint8_t *inputs) {
    return (uint32_t)inputs[0] | ((uint32_t)inputs[1] << 8) |
           ((uint32_t)inputs[2] << 16) | ((uint32_t)inputs[3] << 24);
}

__device__ void md5(const uint8_t *orig_msg, size_t orig_len,
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

    size_t new_len, offset;
    uint32_t M[16];
    uint32_t A, B, C, D, F, g;

    // append "0" bit until message length in bits ≡ 448 (mod 512)
    for (new_len = orig_len + 1; new_len % (512 / 8) != 448 / 8; new_len++);
    uint8_t *message = (uint8_t *)malloc(new_len + 8);
    memcpy(message, orig_msg, orig_len);
    // Pre-processing: adding a single 1 bit
    message[orig_len] = 0x80;
    // Pre-processing: padding with zeros
    for (offset = orig_len + 1; offset < new_len; offset++){
        message[offset] = 0;
    }

    // append length mod (2^64) to message
    append_bytes(orig_len * 8, message + new_len);
    // address the overflow part
    append_bytes(orig_len >> 29, message + new_len + 4);

    // Process the message in successive 512-bit chunks:
    // for each 512-bit chunk of message:
    for (offset = 0; offset < new_len; offset += (512 / 8)) {
        // break chunk into sixteen 32-bit words w[j], 0 ≤ j ≤ 15
        for (int i = 0; i < 16; i++) {
            M[i] = append_int(message + offset + i * 4);
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
            // Be wary of the below definitions of a,b,c,d
            F = A + F + k[i] + M[g];  // M[g] must be a 32-bits block
            A = D;
            D = C;
            C = B;
            B = B + leftrotate(F, K[i]);
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
    append_bytes(a0, digest);
    append_bytes(b0, digest + 4);
    append_bytes(c0, digest + 8);
    append_bytes(d0, digest + 12);
}
