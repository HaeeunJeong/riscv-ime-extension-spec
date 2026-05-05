#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/syscall.h>

#define ARCH_GET_XCOMP_PERM     0x1022
#define ARCH_REQ_XCOMP_PERM     0x1023
#define XFEATURE_XTILEDATA      18

// Define the palette structure
typedef struct __attribute__((packed)) {
    uint8_t palette_id;
    uint8_t start_row;
    uint8_t reserved[14];
    uint16_t colbytes[16];
    uint8_t rows[16];
} tile_config_t;

int main() {
    unsigned long bitmask = 0;
    long rc = syscall(SYS_arch_prctl, ARCH_REQ_XCOMP_PERM, XFEATURE_XTILEDATA);
    if (rc) {
        printf("Failed to request AMX permission from kernel.\n");
        return 1;
    }
    
    rc = syscall(SYS_arch_prctl, ARCH_GET_XCOMP_PERM, &bitmask);
    if (rc) {
        printf("Failed to get AMX permission bitmask.\n");
        return 1;
    }
    
    if (bitmask & (1 << XFEATURE_XTILEDATA)) {
        printf("AMX is enabled by the kernel!\n");
    } else {
        printf("AMX is not enabled by the kernel.\n");
        return 1;
    }

    // Configure tile palette
    tile_config_t tc = {0};
    tc.palette_id = 1; // palette ID 1
    // configure a simple tile 0: 16 rows, 64 bytes per row
    tc.colbytes[0] = 64;
    tc.rows[0] = 16;
    
    // Load tile configuration using AMX builtins directly
    printf("Attempting to execute __builtin_ia32_tile_loadconfig...\n");
    __builtin_ia32_tile_loadconfig(&tc);
    printf("AMX tile configuration loaded successfully. AMX hardware works!\n");
    
    __builtin_ia32_tilerelease();
    printf("AMX tile released successfully.\n");
    
    return 0;
}
