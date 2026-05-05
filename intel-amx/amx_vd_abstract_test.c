#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <immintrin.h>
#include <unistd.h>
#include <sys/syscall.h>

#define ARCH_REQ_XCOMP_PERM     0x1023
#define XFEATURE_XTILEDATA      18

// 타일 팔레트 구조체
typedef struct __attribute__((packed)) {
    uint8_t palette_id;
    uint8_t start_row;
    uint8_t reserved[14];
    uint16_t colbytes[16];
    uint8_t rows[16];
} tile_config_t;

// 1개의 AMX 타일 연산(C = A * B)을 위한 행렬 크기
// int8 데이터의 경우 K 차원은 64바이트(64개 요소)까지 1개 타일로 커버 가능
#define M 16
#define N 16
#define K 64

int main() {
    // 1. 커널에서 AMX 사용 권한 획득
    if (syscall(SYS_arch_prctl, ARCH_REQ_XCOMP_PERM, XFEATURE_XTILEDATA)) {
        printf("Failed to enable AMX.\n");
        return 1;
    }

    // 2. 타일 팔레트 설정 (LLVM 내장 함수 사용 전 초기화 필수)
    tile_config_t tc = {0};
    tc.palette_id = 1;
    for (int i = 0; i < 8; i++) {
        tc.rows[i] = 16;
        tc.colbytes[i] = 64; // 최대 16x64 bytes
    }
    __builtin_ia32_tile_loadconfig(&tc);

    // 3. 메모리 할당 (Virtual Dimension의 중요성을 보여주는 핵심 부분)
    int8_t A[M][K];
    int8_t B[K][N]; // 원본 수학적 행렬 B (검증용)
    int32_t C[M][N]; // 메모리 초기값에 의존하지 않음을 보여주기 위해 초기화 생략
    int32_t C_ref[M][N] = {0}; // 검증을 위한 레퍼런스(스칼라) 결과

    // 일반적인 B 행렬은 B[K][N] 이지만, AMX (vmadot와 유사한 tdpbssd) 명령어를 쓰기 위해서는
    // 하드웨어가 요구하는 "Virtual Dimension" (VNNI packed 포맷)으로 메모리 레이아웃이 사전에 재배치되어 있어야 합니다.
    // K차원의 4개 요소가 연속된 메모리에 위치해야 합니다. (zero-overhead packing을 위한 수동 레이아웃 작업)
    int8_t B_packed[K/4][N*4];

    // 행렬 데이터 초기화 (난수 대신 확인하기 쉬운 패턴 사용)
    for (int i = 0; i < M; i++) {
        for (int k = 0; k < K; k++) {
            A[i][k] = (i + k) % 10;
        }
    }

    for (int k = 0; k < K; k++) {
        for (int n = 0; n < N; n++) {
            B[k][n] = (k - n) % 10;
            // 사용자가 수동으로 Virtual Dimension(VNNI 포맷)에 맞춰 Packing 수행
            int row = k / 4;
            int col = n * 4 + (k % 4);
            B_packed[row][col] = B[k][n];
        }
    }

    // 레퍼런스 3-nested loop 연산 (C_ref = A * B)
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            C_ref[i][j] = 0;
            for (int k = 0; k < K; k++) {
                C_ref[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    // 4. LLVM AMX 사용자용 C API (추상화 계층)
    // LLVM 17은 `__tile1024i` 라는 구조체를 통해 '물리적 타일 레지스터(tmm0 등)'의 할당을 컴파일러가 대신해주는 추상화를 제공합니다.
    // 하지만, 여전히 메모리 레이아웃(Virtual Dimension)이나 Stride는 사용자가 직접 계산해서 넣어주어야 합니다.
    __tile1024i tile_a = {M, K};
    __tile1024i tile_b = {K/4, N*4};
    __tile1024i tile_c = {M, N*4}; // int32_t 이므로 N*4 바이트

    // 타일 로드 (레지스터 할당은 컴파일러가 알아서 함)
    __tile_loadd(&tile_a, A, K);
    __tile_loadd(&tile_b, B_packed, N*4);
    
    // C의 메모리 초기값에 의존하지 않고 타일(Accumulator)을 직접 0으로 초기화
    __tile_zero(&tile_c);

    // 타일 행렬 곱셈 (C += A * B)
    // 참고: dpbssd는 signed int8 x signed int8 -> signed int32 accumulation 명령어입니다.
    // 만약 데이터가 uint8_t 라면 dpbuud, dpbusd 등 signedness가 맞는 명령어를 사용해야 합니다.
    __tile_dpbssd(&tile_c, tile_a, tile_b);

    // 결과 저장
    __tile_stored(C, N*4, tile_c);

    // AMX 상태 해제
    __builtin_ia32_tilerelease();

    // 5. 검증 (모든 원소 비교)
    printf("LLVM AMX API Test Completed!\n");
    
    int match = 1;
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            if (C[i][j] != C_ref[i][j]) {
                printf("Mismatch at [%d][%d]: AMX = %d, Reference = %d\n", i, j, C[i][j], C_ref[i][j]);
                match = 0;
                break;
            }
        }
        if (!match) break;
    }

    if (match) {
        printf("Success: All %d elements perfectly match the reference 3-nested loop GEMM!\n", M * N);
    } else {
        printf("Failed: AMX output does not match the reference.\n");
    }

    return 0;
}
