#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static inline uint64_t now_ns() {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
  return (uint64_t)ts.tv_sec * 1000000000ULL + ts.tv_nsec;
}

#define ITER 50000

#define Ti 4
#define Tk 8
#define Tj 4

#define LOGICAL(i, j, STRIDE) ((i) * (STRIDE) + (j))

#define A_VIRTUAL(i, k, K) \
  (((i) / Ti) * ((K) / Tk) * (Ti * Tk) + \
   ((k) / Tk) * (Ti * Tk) + \
   ((i) % Ti) * Tk + \
   ((k) % Tk))

#define B_VIRTUAL_TRANSPOSED(k, n, N) \
  (((k) / Tk) * ((N) / Tj) * (Tk * Tj) + \
   ((n) / Tj) * (Tk * Tj) + \
   ((n) % Tj) * Tk + \
   ((k) % Tk))

// =========================================================================
// 1. Scalar Naive Row-Major (Baseline)
// =========================================================================
void Gemm_Pure_Scalar_Naive(size_t M, size_t N, size_t K, 
                            const int8_t *A, const int8_t *B, int32_t *C) {
  for (size_t m = 0; m < M; ++m) {
    for (size_t n = 0; n < N; ++n) {
      int32_t acc = 0;
      for (size_t k = 0; k < K; ++k) {
        acc += A[LOGICAL(m, k, K)] * B[LOGICAL(k, n, N)];
      }
      C[LOGICAL(m, n, N)] = acc;
    }
  }
}

// =========================================================================
// 2. Tiled Row-Major (No VD, pure C)
// =========================================================================
void Gemm_Pure_Tiled_RowMajor(size_t M, size_t N, size_t K, 
                              const int8_t *A, const int8_t *B, int32_t *C) {
  size_t num_I = M / Ti;
  size_t num_J = N / Tj;
  size_t num_K = K / Tk;

  for (size_t I = 0; I < num_I; ++I) {
    for (size_t J = 0; J < num_J; ++J) {
      int32_t C_tile[Ti][Tj] = {0};

      for (size_t K_tile = 0; K_tile < num_K; ++K_tile) {
        // Pure C implementation of the tile multiplication
        for (size_t i = 0; i < Ti; ++i) {
          for (size_t j = 0; j < Tj; ++j) {
            int32_t acc = 0;
            // PRAGMA GCC ivdep / unroll could be applied here
            for (size_t k = 0; k < Tk; ++k) {
              acc += A[LOGICAL(I * Ti + i, K_tile * Tk + k, K)] * 
                     B[LOGICAL(K_tile * Tk + k, J * Tj + j, N)];
            }
            C_tile[i][j] += acc;
          }
        }
      }

      for (size_t i = 0; i < Ti; ++i) {
        for (size_t j = 0; j < Tj; ++j) {
          C[LOGICAL(I * Ti + i, J * Tj + j, N)] = C_tile[i][j];
        }
      }
    }
  }
}

// =========================================================================
// 3. Tiled VD Transposed (Pure C, leveraging layout for auto-vec)
// =========================================================================
void Gemm_Pure_Tiled_VD(size_t M, size_t N, size_t K, 
                        const int8_t *A_vd, const int8_t *B_vd, int32_t *C) {
  size_t num_I = M / Ti;
  size_t num_J = N / Tj;
  size_t num_K = K / Tk;

  for (size_t I = 0; I < num_I; ++I) {
    for (size_t J = 0; J < num_J; ++J) {
      int32_t C_tile[Ti][Tj] = {0};

      for (size_t K_tile = 0; K_tile < num_K; ++K_tile) {
        // Points to the start of the current 4x8 / 8x4 tiles in contiguous memory
        const int8_t *A_tile = &A_vd[I * num_K * (Ti * Tk) + K_tile * (Ti * Tk)];
        const int8_t *B_tile = &B_vd[K_tile * num_J * (Tk * Tj) + J * (Tk * Tj)];

        // Pure C loop, but memory access is completely contiguous within the tiles
        for (size_t i = 0; i < Ti; ++i) {
          for (size_t j = 0; j < Tj; ++j) {
            int32_t acc = 0;
            for (size_t k = 0; k < Tk; ++k) {
              // A is stored as 4x8 row-major internally
              // B is stored as 4x8 row-major internally (Transposed)
              acc += A_tile[i * Tk + k] * B_tile[j * Tk + k];
            }
            C_tile[i][j] += acc;
          }
        }
      }

      for (size_t i = 0; i < Ti; ++i) {
        for (size_t j = 0; j < Tj; ++j) {
          C[LOGICAL(I * Ti + i, J * Tj + j, N)] = C_tile[i][j];
        }
      }
    }
  }
}

// =========================================================================
// Testing Utilities
// =========================================================================
void Test_Logical(size_t M, size_t N, const int32_t *Ref, const int32_t *Real) {
  for (size_t i = 0; i < M; ++i) {
    for (size_t n = 0; n < N; ++n) {
      if (Ref[LOGICAL(i, n, N)] != Real[LOGICAL(i, n, N)]) {
          printf("Mismatch Logical at (%zu, %zu)!\n", i, n);
          assert(0);
      }
    }
  }
}

int main() {
  setbuf(stdout, NULL);

  size_t M = 16, N = 16, K = 16;

  int8_t *A = (int8_t *)malloc(M * K);
  int8_t *B = (int8_t *)malloc(K * N);
  int32_t *C_ref = (int32_t *)malloc(M * N * sizeof(int32_t));

  int8_t *A_vd = (int8_t *)malloc(M * K);
  int8_t *B_vd = (int8_t *)malloc(K * N);
  int32_t *C_rm = (int32_t *)malloc(M * N * sizeof(int32_t));
  int32_t *C_vd = (int32_t *)malloc(M * N * sizeof(int32_t));

  srand((uint32_t)time(NULL));
  
  for (size_t i = 0; i < M; ++i) {
    for (size_t k = 0; k < K; ++k) {
      int8_t val = rand() % 32 - 16;
      A[LOGICAL(i, k, K)] = val;
      A_vd[A_VIRTUAL(i, k, K)] = val;
    }
  }

  for (size_t k = 0; k < K; ++k) {
    for (size_t n = 0; n < N; ++n) {
      int8_t val = rand() % 32 - 16;
      B[LOGICAL(k, n, N)] = val;
      B_vd[B_VIRTUAL_TRANSPOSED(k, n, N)] = val;
    }
  }

  for (size_t i = 0; i < M * N; ++i) {
    C_ref[i] = 0; C_rm[i] = 0; C_vd[i] = 0;
  }

  uint64_t t0, t1;
  printf("\n");
  printf("==================================================================\n");
  printf(" Pure C VD Auto-vectorization Test | Size: M=%zu, N=%zu, K=%zu\n", M, N, K);
  printf("==================================================================\n");
  printf(" %-30s | %-14s | %s\n", "Function Name", "Execution Time", "Verification");
  printf("------------------------------------------------------------------\n");

  // 1. Scalar Naive Row-Major
  t0 = now_ns();
  for (int i = 0; i < ITER; ++i) {
    Gemm_Pure_Scalar_Naive(M, N, K, A, B, C_ref);
  }
  t1 = now_ns();
  printf(" %-30s | %10.3f ns   | %s\n", "1. Pure_Scalar_Naive",
         (double)(t1 - t0) / ITER, "Baseline");

  // 2. Tiled Row-Major
  t0 = now_ns();
  for (int i = 0; i < ITER; ++i) {
    Gemm_Pure_Tiled_RowMajor(M, N, K, A, B, C_rm);
  }
  t1 = now_ns();
  Test_Logical(M, N, C_ref, C_rm);
  printf(" %-30s | %10.3f ns   | %s\n", "2. Pure_Tiled_RowMajor",
         (double)(t1 - t0) / ITER, "Passed");

  // 3. Tiled VD Transposed
  t0 = now_ns();
  for (int i = 0; i < ITER; ++i) {
    Gemm_Pure_Tiled_VD(M, N, K, A_vd, B_vd, C_vd);
  }
  t1 = now_ns();
  Test_Logical(M, N, C_ref, C_vd);
  printf(" %-30s | %10.3f ns   | %s\n", "3. Pure_Tiled_VD",
         (double)(t1 - t0) / ITER, "Passed");

  printf("==================================================================\n");

  free(A); free(B); free(C_ref);
  free(A_vd); free(B_vd); free(C_rm); free(C_vd);

  return 0;
}
