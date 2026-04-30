// riscv64-unknown-linux-gnu-gcc  -march=rv64gcv vmadot-gemm-demo.c -o gemm-vmadot-4x8x4

/*
 *
 * simple demo, using vmadot to calclate matrix multi.
 * data type of matrix A and B is int8_t.
 * data type of matrix C and CRef is int32_t.
 * A_{MxK} * B_{KxN} -> C_{MxN}
 * in this case, M fixed to 4. N fixed to 4. K fixed to 8.
 * 
 */


#include <assert.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static inline uint64_t now_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + ts.tv_nsec;
}
#define ITER 1000000

void Referece_Gemm(size_t M,
        size_t N,
        size_t K,
        const int8_t* A,
        const int8_t* B,
        int32_t* C) {

    for (size_t m = 0; m < M; ++m) {
        for (size_t n = 0; n < N; ++n) {
            int32_t acc = 0;
            for (size_t k = 0; k < K; ++k) {
                int8_t a = A[m * K + k];
                int8_t b = B[k * N + n];
                acc += a * b;
            }
            C[m * N + n] = acc;
        }
    }
}

void Gemm_packB(size_t ROW,
        size_t COL,
        const int8_t* B,
        int8_t* packedB) {

    __asm__ volatile (
            "addi         t6, zero, 8             \n\t"
            "vsetvli      t0, zero, e8, mf8       \n\t"

            "LOOP_ROW%=:                          \n\t"
            "addi         %[ROW], %[ROW], -1      \n\t"

            "LOOP_COL%=:                          \n\t"
            "vle8.v       v0, (%[SRC])            \n\t"
            "addi         %[SRC], %[SRC], 4       \n\t"
            "vsse8.v      v0, (%[DST]), t6        \n\t"
            "addi         %[DST], %[DST], 1       \n\t"

            "bnez         %[ROW], LOOP_ROW%=      \n\t"

            : [SRC] "+r"(B), [DST] "+r"(packedB), [ROW] "+r"(ROW)
            : [COL] "r"(COL)
            : "cc", "t6", "t0");
}

void Gemm_vmadot(size_t M,
        size_t N,
        size_t K,
        const int8_t* A,
        const int8_t* B,
        int32_t* C) {

    __asm__ volatile(
            "vsetvli      t0, zero, e32, m2       \n\t"
            "vxor.vv      v28, v28, v28           \n\t"

            "vsetvli      t0, zero, e8, m1        \n\t"
            "LOOP_K%=:                            \n\t"
            "vle8.v       v0, (%[A])              \n\t"
            "addi         %[A], %[A], 32          \n\t"

            "vle8.v       v1, (%[B])              \n\t"
            "addi         %[B], %[B], 32          \n\t"

            "vmadot       v28, v0, v1             \n\t"

            "vsetvli      t0, zero, e32, m2       \n\t"
            "vse32.v      v28, (%[C])             \n\t"
            : [A] "+r"(A), [B] "+r"(B), [C] "+r"(C), [M] "+r"(M)
            : [K] "r"(K), [N] "r"(N)
            : "cc");
}

void Gemm_nonpackB_vmadot(size_t M,
        size_t N,
        size_t K,
        const int8_t* A,
        const int8_t* B,
        int32_t* C) {

    __asm__ volatile(
            // accumulator = 0
            "vsetvli      t0, zero, e32, m2       \n\t"
            "vxor.vv      v28, v28, v28           \n\t"

            // int8 mode
            "vsetvli      t0, zero, e8, m1        \n\t"

            // load A (4x8 = 32 elements)
            "vle8.v       v0, (%[A])              \n\t"

            // B에서 column 4개를 각각 strided load
            // stride = 4 (N)
            "addi         t1, zero, 4             \n\t"

            // col0
            "mv           t2, %[B]                \n\t"
            "vlse8.v      v1, (t2), t1            \n\t"

            // col1
            "addi         t2, %[B], 1             \n\t"
            "vlse8.v      v2, (t2), t1            \n\t"

            // col2
            "addi         t2, %[B], 2             \n\t"
            "vlse8.v      v3, (t2), t1            \n\t"

            // col3
            "addi         t2, %[B], 3             \n\t"
            "vlse8.v      v4, (t2), t1            \n\t"

            // vmadot 수행 (각 column별)
            "vmadot       v28, v0, v1             \n\t"
            "vmadot       v28, v0, v2             \n\t"
            "vmadot       v28, v0, v3             \n\t"
            "vmadot       v28, v0, v4             \n\t"

            // store
            "vsetvli      t0, zero, e32, m2       \n\t"
            "vse32.v      v28, (%[C])             \n\t"

            : [A] "+r"(A), [B] "+r"(B), [C] "+r"(C)
            : [M] "r"(M), [K] "r"(K), [N] "r"(N)
               : "cc", "t0", "t1", "t2");
}


void Test(size_t M,
        size_t N,
        const int32_t* Ref, 
        const int32_t* Real) {
    for (size_t m = 0; m < M; ++m) {
        for (size_t n = 0; n < N; ++n) {
            assert(Ref[m * N + n] == Real[m * N + n]);
        }
    }
    printf("Test successful. CRef equal to C.\n");

}

void display(size_t row, size_t col, void* output, size_t t) {
    if (t == 1) {
        int8_t* C = (int8_t*) output;
        for (size_t i = 0; i < row; ++i) {
            for (size_t j = 0; j < col; ++j) {
                printf("%5d ", C[i * col + j]);
            }
            printf("\n");
        }
    } else if(t == 4){
        int32_t* C = (int32_t*) output;
        for (size_t i = 0; i < row; ++i) {
            for (size_t j = 0; j < col; ++j) {
                printf("%7d ", C[i * col + j]);
            }
            printf("\n");
        }
    }
}

int main(){
    int8_t A[32] = {0, 1, 2, 3, 4, 5, 6, 7,
        0, 1, 2, 3, 4, 5, 6 ,7,
        0, 1, 2, 3, 4, 5, 6 ,7,
        0, 1, 2, 3, 4, 5, 6 ,7};

    int8_t B[32] = {0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3,
        0, 1, 2, 3};

    srand((uint32_t) time(NULL));
    for (size_t index = 0; index < 32; ++index) {
        A[index] = rand() % 256 - 128;
        B[index] = rand() % 256 - 128;
    }


    int8_t packB[32] = {0};
    int32_t C[16] = {0};
    int32_t CRef[16] = {0};

    uint64_t t0, t1; 

    t0 = now_ns();
    for (int i = 0; i < ITER; ++i){
        Gemm_packB(8, 4, B, packB);
    }
    t1 = now_ns();
    printf("packB time: %.3f ns\n", (double)(t1-t0)/ITER);

    t0 = now_ns();
    for (int i = 0; i < ITER; ++i){
        Referece_Gemm(4, 4, 8, A, B, CRef);
    }
    t1 = now_ns();
    printf("Reference_Gemm time: %.3f ns\n", (double)(t1-t0)/ITER);

    t0 = now_ns();
    for (int i = 0; i < ITER; ++i){
        Referece_Gemm(4, 4, 8, A, packB, C);
    }
    t1 = now_ns();
    printf("PackB_Scalar_Gemm time: %.3f ns\n", (double)(t1-t0)/ITER);

    t0 = now_ns();
    for (int i = 0; i < ITER; ++i){
        Gemm_vmadot(4, 4, 8, A, packB, C);
    }
    t1 = now_ns();
    printf("Gemm_vmadot time: %.3f ns\n", (double)(t1-t0)/ITER);

    t0 = now_ns();
    for (int i = 0; i < ITER; ++i){
        Gemm_nonpackB_vmadot(4, 4, 8, A, B, C);
    }
    t1 = now_ns();
    printf("Gemm_nonpackB_vmadot time: %.3f ns\n", (double)(t1-t0)/ITER);

    Test(4, 4, CRef, C);
    printf("*********************************\n");
    printf("matrix A: \n");
    display(4, 8, A, 1);
    printf("matrix B: \n");
    display(8, 4, B, 1);
    printf("matrix packB: \n");
    display(4, 8, packB, 1);

    printf("matrix CRef: \n");
    display(4, 4, CRef, 4);

    printf("matrix C: \n");
    display(4, 4, C, 4);
    printf("*********************************\n");
    return 0;
}
