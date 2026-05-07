#include <stdint.h>
#include <stdio.h>

static inline uint64_t read_cycle() {
    uint64_t cycles;
    asm volatile ("rdcycle %0" : "=r" (cycles));
    return cycles;
}

int main() {
    uint64_t start = read_cycle();
    uint64_t end = read_cycle();
    printf("rdcycle works! Diff: %lu\n", end - start);
    return 0;
}
