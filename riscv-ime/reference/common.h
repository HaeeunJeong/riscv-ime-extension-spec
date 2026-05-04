#ifndef _COMMON_HEADER_
#define _COMMON_HEADER_
#include <assert.h>
#include <errno.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#ifndef T
#define T uint32_t
#endif

#define wlog 10
#define WIDTH (1 << wlog)
#define BUFFER_SIZE (WIDTH << wlog)

#define ALIGN(x, b) (x + x % b)

const char file_dir[] = "./dataset";

//  input arrays
static inline void split_large_files(char file_name[60], uint32_t data_width, uint32_t block_width)
{
  uint32_t data_size = data_width * data_width;

  T* data = (T*)malloc(sizeof(T) * data_size);

  FILE* ifp = fopen(file_name, "rb");
  fread((void*)data, sizeof(T), data_size, ifp);
  fflush(ifp);
  if (fclose(ifp) != 0) {
    perror(file_name);
    return;
  }

  char *prev_name, *post_name;
  char dir[90] = "";
  char temp_dir[10] = "";

  sprintf(temp_dir, "./%u/", data_width);
  if (mkdir(temp_dir, 0776) == -1 && errno != EEXIST) {
    fprintf(stderr, "%s directory create error: %s\n", temp_dir, strerror(errno));
    return;
  }
  uint32_t num_block = data_width / block_width;
  for (uint32_t p = 0; p < num_block; p++) {
    for (uint32_t q = 0; q < num_block; q++) {
      sprintf(dir, "%s%u_%u_", temp_dir, p, q);
      strcat(dir, file_name);
      FILE* ofp = fopen(dir, "wb");
      if (ofp == NULL) {
        printf("FILE open error\n");
        return;
      }
      uint32_t offset = p * block_width * data_width + q * block_width;
      for (uint32_t i = 0; i < block_width; i++) {
        fwrite((void*)&data[offset + i * data_width], sizeof(T), block_width, ofp);
        fflush(ofp);
      }
      fclose(ofp);
    }
  }
  free(data);
}

// write matrix to file
static inline void write_data_to_file(char file_name[60], T* data, uint32_t data_size)
{
  FILE* fp = fopen(file_name, "wb");
  fwrite((void*)data, sizeof(T), data_size, fp);

  fflush(fp);
  if (fclose(fp) != 0) {
    perror(file_name);
    return;
  }
}
// read matrix from file
static inline void read_data_from_file(char file_name[60], T* data, uint32_t data_size)
{
  FILE* fp = fopen(file_name, "rb");
  fread((void*)data, sizeof(T), data_size, fp);

  fflush(fp);
  if (fclose(fp) != 0) {
    perror(file_name);
    return;
  }
}

static void transpose_i(T* A, uint32_t width)
{
  for (uint32_t i = 0; i < width; i++) {
    for (uint32_t j = i + 1; j < width; j++) {
      T temp = A[i * width + j];
      A[i * width + j] = A[j * width + i];
      A[j * width + i] = temp;
    }
  }
}

static inline double my_clock(void)
{
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC_RAW, &t);
  return (1.0e-9 * t.tv_nsec + t.tv_sec);
}

///* reshape block-ordered matrix into ordinary sequenced matrix */
void reshape(T* from, T* to, uint32_t width, uint32_t block_width_a, uint32_t block_width_b)
{
  for (uint32_t m = 0; m < width / block_width_a; m++) {
    for (uint32_t n = 0; n < width / block_width_b; n++) {
      for (uint32_t i = 0; i < block_width_a; i++) {
        for (uint32_t j = 0; j < block_width_b; j++) {
          to[m * block_width_a * width + n * block_width_b + width * i + j] = from[m * (width * block_width_a) + n * block_width_a * block_width_b + i * block_width_a + j];
        }
      }
    }
  }
}
///* reshape block-ordered matrix into ordinary sequenced matrix */
void reshape2(T* from, T* to, uint32_t width, uint32_t block_width_a, uint32_t block_width_b)
{
  for (uint32_t m = 0; m < width / block_width_a; m++) {
    for (uint32_t n = 0; n < width / block_width_b; n++) {
      for (uint32_t i = 0; i < block_width_a; i++) {
        for (uint32_t j = 0; j < block_width_b; j++) {
          to[m * block_width_a * width + n * block_width_b + width * i + j] = from[m * (block_width_a * block_width_b) + n * width * block_width_b + i * block_width_b + j];
        }
      }
    }
  }
}
///* reshape block-ordered matrix into ordinary sequenced matrix */
void reshape3(T* source, uint32_t width, uint32_t block_width)
{
  T* temp = malloc(width * width * sizeof(T));
  for (uint32_t m = 0; m < width / block_width; m++) {
    for (uint32_t n = 0; n < width / block_width; n++) {
      for (uint32_t i = 0; i < block_width; i++) {
        for (uint32_t j = 0; j < block_width; j++) {
          temp[m * (block_width * width) + n * block_width * block_width + i * block_width + j] = source[m * block_width * width + n * block_width + width * i + j];
        }
      }
    }
  }
  for (uint32_t i = 0; i < width; i++) {
    for (uint32_t j = 0; j < width; j++) {
      source[i * width + j] = temp[i * width + j];
    }
  }
  free(temp);
}

// Compute output in the host
static void matmul_host(T* C, T* A, T* B, uint32_t width)
{
  for (uint32_t i = 0; i < width * width; i++) {
    C[i] = 0;
  }

  for (uint32_t i = 0; i < width; i++) {
    for (uint32_t j = 0; j < width; j++) {
      T temp = 0;
      for (uint32_t k = 0; k < width; k++) {
        temp += A[i * width + k] * B[k * width + j];
      }
      C[i * width + j] = temp;
    }
  }
}

uint32_t correctness_check(T* res, T* ans, uint32_t size)
{
  T err = 0;
  for (uint32_t i = 0; i < size; i++) {
    err += (res[i] == ans[i] ? 0 : 1);
    /* printf("%u:%u\n", res[i], ans[i]); */
  }
  return err;
}

void print_mat(T* mat, uint32_t width)
{
  for (uint32_t i = 0; i < width; i++) {
    for (uint32_t j = 0; j < width; j++) {
      printf("%u\t", mat[i * width + j]);
    }
    printf("\n");
  }
}

void init_data(T* A, uint32_t size)
{
  srand(0);
  for (uint32_t i = 0; i < size; i++) {
    A[i] = i >> 4;
  }
}

void init_array(T* A, uint32_t rows, uint32_t cols)
{
  int mask = 0x0000000000000011;
  for (uint32_t i = 0; i < rows; i++) {
    for (uint32_t j = 0; j < cols; j++) {
      A[i * cols + j] = rand() & mask;
    }
  }
}

typedef struct meta_t {
  uint32_t num_row;
  uint32_t num_col;
  uint32_t num_part_row; // 1;
  uint32_t num_part_col; // 1;
  uint32_t stride_row;   // 1;
  uint32_t stride_col;   // 1;
  bool transposed;       // false;
  bool transformed;      // false;
} meta_t;

typedef struct config_t {
  uint32_t num_part_row; // 0;
  uint32_t num_part_col; // 0;
  uint32_t stride_row;   // 0;
  uint32_t stride_col;   // 0;
  bool transpose;        // false;
} config_t;

typedef struct partition_t {
  uint32_t n; // 1;
  uint32_t m; // 1;
  uint32_t k; // 1;
} partition_t;

typedef struct tuple_t {
  uint32_t a; // 1;
  uint32_t b; // 1;
} tuple_t;

typedef struct array_t {
  T* array;
  meta_t meta;
} array_t;

void set_meta(meta_t* meta, meta_t data)
{
  meta->num_row = data.num_row;
  meta->num_col = data.num_col;
  meta->num_part_row = data.num_part_row;
  meta->num_part_col = data.num_part_col;
  meta->stride_row = data.stride_row;
  meta->stride_col = data.stride_col;
  meta->transposed = data.transposed;
  meta->transformed = data.transformed;
}

T* construct_array(meta_t array_meta, bool init)
{
  uint32_t rows = array_meta.num_row;
  uint32_t cols = array_meta.num_col;
  T* array_ptr = (T*)malloc(rows * cols * sizeof(T));
  memset(array_ptr, 0, rows * cols * sizeof(T));
  if (init)
    /* init_data(array_ptr, rows * cols); */
    init_array(array_ptr, rows, cols);
  return array_ptr;
}

inline static void print_tuple(tuple_t tuple)
{
  printf("a : %5d\t b:%5d\n", tuple.a, tuple.b);
}

void print_meta(meta_t meta)
{
  printf("printing metadata\n");
  printf("num_row : %d\n", meta.num_row);
  printf("num_col : %d\n", meta.num_col);
  printf("num_part_row : %d\n", meta.num_part_row);
  printf("num_part_col : %d\n", meta.num_part_col);
  printf("stride_row : %d\n", meta.stride_row);
  printf("stride_col : %d\n", meta.stride_col);
  printf("transposed : %d\n", meta.transposed);
  printf("transformed : %d\n", meta.transformed);
}

void print_config(config_t config)
{
  printf("printing config\n");
  printf("num_part_row : %d\n", config.num_part_row);
  printf("num_part_col : %d\n", config.num_part_col);
  printf("stride_row : %d\n", config.stride_row);
  printf("stride_col : %d\n", config.stride_col);
  printf("transpose : %d\n", config.transpose);
}

void meta_transform(meta_t src_meta, config_t transform_config, meta_t* dest_meta)
{
  dest_meta->num_row = src_meta.num_row;
  dest_meta->num_col = src_meta.num_col;
  dest_meta->num_part_row = transform_config.num_part_row == 0 ? src_meta.num_row / transform_config.stride_row : transform_config.num_part_row;
  dest_meta->num_part_col = transform_config.num_part_col == 0 ? src_meta.num_col / transform_config.stride_col : transform_config.num_part_col;
  dest_meta->stride_row = transform_config.stride_row == 0 ? src_meta.num_row / transform_config.num_part_row : transform_config.stride_row;
  dest_meta->stride_col = transform_config.stride_col == 0 ? src_meta.num_col / transform_config.num_part_col : transform_config.stride_col;
  dest_meta->transposed = transform_config.transpose;
  dest_meta->transformed = false; //true;
}

void linear_to_tile(
    T* arr_linear, T* arr_tiled,
    uint32_t rows, uint32_t cols,
    uint32_t tile_height, uint32_t tile_width,
    uint32_t num_tiles_row, uint32_t num_tiles_col)
{
  uint32_t tile_size = tile_height * tile_width;

  for (uint32_t t_row = 0; t_row < num_tiles_row; t_row++) {
    for (uint32_t t_col = 0; t_col < num_tiles_col; t_col++) {
      uint32_t tile_offset = (t_row * num_tiles_col + t_col) * tile_size;

      for (uint32_t tile_row = 0; tile_row < tile_height; tile_row++) {
        uint32_t arr_linear_row_index = (t_row * tile_height + tile_row) * cols + (t_col * tile_width);
        uint32_t arr_tiled_row_index = tile_offset + tile_row * tile_width;
        memcpy(&arr_tiled[arr_tiled_row_index], &arr_linear[arr_linear_row_index], tile_width * sizeof(T));
      }
    }
  }
}

void tile_to_linear(
    T* arr_tiled, T* arr_linear,
    uint32_t rows, uint32_t cols,
    uint32_t tile_height, uint32_t tile_width,
    uint32_t num_tiles_row, uint32_t num_tiles_col)
{
  uint32_t tile_size = tile_height * tile_width;

  for (uint32_t t_row = 0; t_row < num_tiles_row; t_row++) {
    for (uint32_t t_col = 0; t_col < num_tiles_col; t_col++) {
      uint32_t tile_offset = (t_row * num_tiles_col + t_col) * tile_size;

      for (uint32_t tile_row = 0; tile_row < tile_height; tile_row++) {
        uint32_t arr_linear_row_index = (t_row * tile_height + tile_row) * cols + (t_col * tile_width);
        uint32_t arr_tiled_row_index = tile_offset + tile_row * tile_width;
        memcpy(&arr_linear[arr_linear_row_index], &arr_tiled[arr_tiled_row_index], tile_width * sizeof(T));
      }
    }
  }
}

void transform_array(
    array_t* arr_linear,
    array_t* arr_tiled,
    config_t transform_config)
{
  meta_transform(arr_linear->meta, transform_config, &(arr_tiled->meta));
  uint32_t num_row = arr_tiled->meta.num_row;
  uint32_t num_col = arr_tiled->meta.num_col;
  uint32_t num_part_row = arr_tiled->meta.num_part_row;
  uint32_t num_part_col = arr_tiled->meta.num_part_col;
  uint32_t tile_stride_row = arr_tiled->meta.stride_row;
  uint32_t tile_stride_col = arr_tiled->meta.stride_col;

  linear_to_tile(arr_linear->array, arr_tiled->array, num_row, num_col, tile_stride_row, tile_stride_col, num_part_row, num_part_col);

  arr_tiled->meta.transformed = true;
}

void transform_data(
    T* arr_linear,
    T* arr_tiled,
    meta_t arr_linear_meta,
    config_t transform_config,
    meta_t* arr_tiled_meta)
{
  meta_transform(arr_linear_meta, transform_config, arr_tiled_meta);

  uint32_t num_row = arr_tiled_meta->num_row;
  uint32_t num_col = arr_tiled_meta->num_col;
  uint32_t num_part_row = arr_tiled_meta->num_part_row;
  uint32_t num_part_col = arr_tiled_meta->num_part_col;
  uint32_t tile_stride_row = arr_tiled_meta->stride_row;
  uint32_t tile_stride_col = arr_tiled_meta->stride_col;
  linear_to_tile(arr_linear, arr_tiled, num_row, num_col, tile_stride_row, tile_stride_col, num_part_row, num_part_col);

  arr_tiled_meta->transformed = true;
}

void itransform_data(
    T* arr_tiled,
    T* arr_linear,
    meta_t arr_tiled_meta,
    meta_t* arr_linear_meta)
{
  uint32_t num_row = arr_tiled_meta.num_row;
  uint32_t num_col = arr_tiled_meta.num_col;
  uint32_t num_part_row = arr_tiled_meta.num_part_row;
  uint32_t num_part_col = arr_tiled_meta.num_part_col;
  uint32_t tile_stride_row = arr_tiled_meta.stride_row;
  uint32_t tile_stride_col = arr_tiled_meta.stride_col;

  tile_to_linear(arr_tiled, arr_linear, num_row, num_col, tile_stride_row, tile_stride_col, num_part_row, num_part_col);

  arr_linear_meta->num_part_row = 1;
  arr_linear_meta->num_part_col = 1;
  arr_linear_meta->stride_row = arr_linear_meta->num_row;
  arr_linear_meta->stride_col = arr_linear_meta->num_col;
  arr_linear_meta->transposed = false;
  arr_linear_meta->transformed = false;
}

void print_array(T* arr, uint32_t rows, uint32_t cols)
{
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      printf("%5u ", arr[i * cols + j]);
    }
    printf("\n");
  }
  printf("\n");
}

void print_dup_array(T* arr, uint32_t rows, uint32_t cols, partition_t split)
{
  uint32_t tile_height = rows / split.n;
  uint32_t tile_width = cols / split.m;
  uint32_t tile_size = tile_height * tile_width;

  printf("------------------------------------------------\n");
  for (int k = 0; k < split.k; k++) {
    for (int i = 0; i < split.n; i++) {
      for (int j = 0; j < split.m; j++) {
        for (int ii = 0; ii < tile_height; ii++) {
          for (int jj = 0; jj < tile_width; jj++) {
            printf("%5u ", arr[k * cols * rows + i * cols + j * tile_size + ii * tile_width + jj]);
          }
          printf("\n");
        }
        printf("\n");
      }
      printf("\n");
    }
    printf("\n");
  }
  printf("\n");
}

void linear_matmul_linear(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M)
{
  for (uint32_t i = 0; i < N; i++) {     // A의 타일 row 블록
    for (uint32_t j = 0; j < M; j++) {   // B의 타일 column 블록
      for (uint32_t k = 0; k < K; k++) { // A와 B의 타일 곱셈을 수행
        C[i * M + j] += A[i * K + k] * B[k * M + j];
      }
    }
  }
}

void linear_matmul_transposed(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M)
{
  for (uint32_t i = 0; i < N; i++) {     // A의 타일 row 블록
    for (uint32_t j = 0; j < M; j++) {   // B의 타일 column 블록
      for (uint32_t k = 0; k < K; k++) { // A와 B의 타일 곱셈을 수행
        C[i * M + j] += A[i * K + k] * B[j * K + k];
      }
    }
  }
}

void tiled_matmul_linear(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M, uint32_t p, uint32_t q, uint32_t r)
{
  for (uint32_t i = 0; i < N; i += p) {
    for (uint32_t j = 0; j < M; j += r) {
      for (uint32_t k = 0; k < K; k += q) {

        for (uint32_t ii = 0; ii < p && i + ii < N; ii++) {
          for (uint32_t jj = 0; jj < r && j + jj < M; jj++) {
            for (uint32_t kk = 0; kk < q && k + kk < K; kk++) {
              // C[i+ii][j+jj] += A[i+ii][k+kk] * B[k+kk][j+jj]
              C[(i + ii) * M + (j + jj)] += A[(i + ii) * K + (k + kk)] * B[(k + kk) * M + (j + jj)];
            }
          }
        }
      }
    }
  }
}

void tiled_partial_matmul_linear(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M, uint32_t p, uint32_t q, uint32_t r)
{
  for (uint32_t i = 0; i < N; i += p) {
    for (uint32_t j = 0; j < M; j += r) {
      for (uint32_t k = 0; k < K; k += q) {

        for (uint32_t ii = 0; ii < p && i + ii < N; ii++) {
          for (uint32_t jj = 0; jj < r && j + jj < M; jj++) {
            for (uint32_t kk = 0; kk < q && k + kk < K; kk++) {
              // C[i+ii][j+jj] += A[i+ii][k+kk] * B[k+kk][j+jj]
              C[N * M * (k / q) + (i + ii) * M + (j + jj)] += A[(i + ii) * K + (k + kk)] * B[(k + kk) * M + (j + jj)];
            }
          }
        }
      }
    }
  }
}

void tiled_matmul_tiled(
    T* tiled_A, T* tiled_B, T* tiled_C,
    uint32_t N,
    uint32_t K,
    uint32_t M,
    uint32_t p,
    uint32_t q,
    uint32_t r)
{
  uint32_t num_tiles_row_A = N / p; // A row
  uint32_t num_tiles_col_A = K / q; // A column
  uint32_t num_tiles_row_B = K / q; // B row
  uint32_t num_tiles_col_B = M / r; // B column

  for (uint32_t tile_i = 0; tile_i < num_tiles_row_A; tile_i++) {
    for (uint32_t tile_j = 0; tile_j < num_tiles_col_B; tile_j++) {
      for (uint32_t tile_k = 0; tile_k < num_tiles_col_A; tile_k++) {
        uint32_t A_tile_offset = (tile_i * num_tiles_col_A + tile_k) * p * q;
        uint32_t B_tile_offset = (tile_k * num_tiles_col_B + tile_j) * q * r;
        uint32_t C_tile_offset = (tile_i * num_tiles_col_B + tile_j) * r * p;
        linear_matmul_linear(&tiled_A[A_tile_offset], &tiled_B[B_tile_offset], &tiled_C[C_tile_offset], p, q, r);
      }
    }
  }
}

/* void offset_calculation( */
void gen_id_offset_map(
    uint32_t* id_offset_map,
    meta_t tiled_array_meta,
    uint32_t num_proc, uint32_t type)
{
  uint32_t num_tiles_row = tiled_array_meta.num_part_row;
  uint32_t num_tiles_col = tiled_array_meta.num_part_col;
  uint32_t num_tiles = num_tiles_row * num_tiles_col;
  uint32_t dup = num_proc / num_tiles;

  uint32_t tile_height = tiled_array_meta.stride_row;
  uint32_t tile_width = tiled_array_meta.stride_col;
  uint32_t tile_size = tile_height * tile_width;

  for (uint32_t tile_i = 0; tile_i < num_tiles_row; tile_i++) {
    for (uint32_t tile_j = 0; tile_j < num_tiles_col; tile_j++) {
      uint32_t tile_offset = (tile_i * num_tiles_col + tile_j) * tile_size;
      uint32_t tile_offset_id = (tile_i * num_tiles_col + tile_j);
      for (uint32_t dup_it = 0; dup_it < dup; dup_it++) {
        if (type == 1)
          id_offset_map[(dup_it * num_tiles) + tile_i * num_tiles_col + tile_j] = tile_offset;
        else
          id_offset_map[dup_it + dup * (tile_i * num_tiles_col + tile_j)] = tile_offset;
      }
    }
  }
}
uint32_t* gen_tile_offset(
    /* void gen_tile_offset( */
    /* uint32_t* offset_table, */
    meta_t tiled_array_meta)
{
  uint32_t num_tiles_row = tiled_array_meta.num_part_row;
  uint32_t num_tiles_col = tiled_array_meta.num_part_col;
  uint32_t num_tiles = num_tiles_row * num_tiles_col;
  uint32_t tile_height = tiled_array_meta.stride_row;
  uint32_t tile_width = tiled_array_meta.stride_col;
  uint32_t tile_size = tile_height * tile_width;

  uint32_t* offset_table = (uint32_t*)malloc(num_tiles * sizeof(uint32_t));
  for (uint32_t tile_i = 0; tile_i < num_tiles_row; tile_i++) {
    for (uint32_t tile_j = 0; tile_j < num_tiles_col; tile_j++) {
      uint32_t tile_id = (tile_i * num_tiles_col + tile_j);
      uint32_t tile_offset = (tile_i * num_tiles_col + tile_j) * tile_size;
      offset_table[tile_id] = tile_offset;
    }
  }
  return offset_table;
}

void transpose(T* input, T* output, uint32_t rows, uint32_t cols)
{
  for (uint32_t i = 0; i < rows; i++) {
    for (uint32_t j = 0; j < cols; j++) {
      output[j * rows + i] = input[i * cols + j];
    }
  }
}

void matrix_accumulation(T* dup_array, T* acc_array, meta_t acc_array_meta, tuple_t* C_map, partition_t split)
{
  uint32_t rows = acc_array_meta.num_row;
  uint32_t cols = acc_array_meta.num_col;
  uint32_t size = rows * cols;
  uint32_t dup = split.k;
  if (dup == 1) {
    memcpy(acc_array, dup_array, size * sizeof(T));
    return;
  }
  memset(acc_array, 0, size * sizeof(T));
  for (uint32_t i = 0; i < rows; i++) {
    for (uint32_t j = 0; j < cols; j++) {
      for (uint32_t k = 0; k < dup; k++) {
        /* acc_array[i * cols + j] += dup_array[size * dup_it + i * cols + j]; */
        acc_array[i * cols + j] += dup_array[dup * size + (i * cols + j)];
      }
    }
  }
}

void matrix_accumulation_dup(T** dup_array, T* acc_array, meta_t acc_array_meta, partition_t split)
{
  const uint32_t cst_n = split.n;
  const uint32_t cst_m = split.m;
  const uint32_t cst_k = split.k;

  const uint32_t tile_rows = acc_array_meta.stride_row;
  const uint32_t tile_cols = acc_array_meta.stride_col;

  const uint32_t tile_size = tile_rows * tile_cols;

  const uint32_t rows = acc_array_meta.num_part_row;
  const uint32_t cols = acc_array_meta.num_part_col;
  const uint32_t size = rows * cols;

  memset(acc_array, 0, size * sizeof(T));
  for (uint32_t i = 0; i < cst_n; i++) {
    for (uint32_t j = 0; j < cst_m; j++) {

      uint32_t tile_offset = (i * cst_m + j) * tile_size;
      for (uint32_t k = 0; k < cst_k; k++) {
        uint32_t tile_id = i * cst_m * cst_k + j * cst_k + k;
        for (uint32_t ii = 0; ii < tile_rows; ii++) {
          for (uint32_t jj = 0; jj < tile_cols; jj++) {
            acc_array[tile_offset + ii * tile_cols + jj] += dup_array[tile_id][(ii * tile_cols + jj)];
            const uint32_t tile_size = tile_rows * tile_cols;
          }
        }
      }
    }
  }
}

void transpose_meta(
    meta_t arr_meta,
    meta_t* arr_trans_meta)
{
  arr_trans_meta->num_row = arr_meta.num_row;
  arr_trans_meta->num_col = arr_meta.num_col;
  arr_trans_meta->num_part_row = arr_meta.num_part_row;
  arr_trans_meta->num_part_col = arr_meta.num_part_col;
  arr_trans_meta->stride_row = arr_meta.stride_row;
  arr_trans_meta->stride_col = arr_meta.stride_col;
  arr_trans_meta->transposed = true;
}

void gen_id_offset_map_GEMM(
    tuple_t* C_map,
    uint32_t* A_offset,
    meta_t A_tiled_meta,
    uint32_t* B_offset,
    meta_t B_tiled_meta,
    partition_t split)
{
  uint32_t num_tiles_N = split.n;
  uint32_t num_tiles_M = split.m;
  uint32_t num_tiles_K = split.k;

  uint32_t A_tile_row = A_tiled_meta.num_part_row;
  uint32_t A_tile_col = A_tiled_meta.num_part_col;

  uint32_t B_tile_row = B_tiled_meta.num_part_row;
  uint32_t B_tile_col = B_tiled_meta.num_part_col;

  assert(num_tiles_N == A_tile_row && num_tiles_N);
  assert(num_tiles_M == B_tile_row && num_tiles_M);
  assert(num_tiles_K == A_tile_col && num_tiles_K == B_tile_col && num_tiles_K);

  for (uint32_t i = 0; i < num_tiles_N; i++) {
    for (uint32_t j = 0; j < num_tiles_M; j++) {
      //      c[i][j] = mac(a[i][k], b[j][k])
      //      c[i][j] = acc(mul(a[i][k], b[j][k]), k)
      //      c[i][j][k] = mul(a[i][k], b[j][k])
      for (uint32_t k = 0; k < num_tiles_K; k++) {
        //C_map[i][j][k] = (A[i][k], B[j][k])
        C_map[i * num_tiles_M * num_tiles_K + j * num_tiles_K + k].a = i * num_tiles_K + k;
        C_map[i * num_tiles_M * num_tiles_K + j * num_tiles_K + k].b = j * num_tiles_K + k;
      }
    }
  }
}

//generate array name from array metadata
const char* gen_array_name(array_t array, const char prefix[5])
{
  static char str[60];

  const uint32_t rows = array.meta.num_row;
  const uint32_t cols = array.meta.num_row;
  const uint32_t num_part_row = array.meta.num_part_row;
  const uint32_t num_part_col = array.meta.num_part_col;
  sprintf(str, "%s%u_%u_%u_%u.array", prefix, rows, cols, num_part_row, num_part_col);
  /* printf("array_name : %s\n", str); */
  return str;
}

// write array to file
static inline void write_array(const char file_name[60], array_t* array)
{
  /* static inline void write_array(array_t* array) */
  /* { */
  /* char file_name[60] = gen_array_name(A_linear); */
  char file_path[256];
  sprintf(file_path, "%s/%s", file_dir, file_name);

/* printf("file dir : %s\n", file_path); */
  FILE* fp = fopen(file_path, "wb+");

  const uint32_t array_size = array->meta.num_row * array->meta.num_col;
  fwrite((void*)&(array->meta), sizeof(meta_t), 1, fp);
  fwrite((void*)(array->array), sizeof(T), array_size, fp);

  fflush(fp);
  if (fclose(fp) != 0) {
    perror(file_name);
    return;
  }
}

// read array from file
static inline void read_array(const char file_name[60], array_t* array)
{
  char file_path[256];
  sprintf(file_path, "%s/%s", file_dir, file_name);
/* printf("file dir : %s\n", file_path); */
  FILE* fp = fopen(file_path, "rb+");
  fread((void*)&(array->meta), sizeof(meta_t), 1, fp);
  const uint32_t array_size = array->meta.num_row * array->meta.num_col;
  fread((void*)(array->array), sizeof(T), array_size, fp);

  fflush(fp);
  if (fclose(fp) != 0) {
    perror(file_name);
    return;
  }
}

#include <omp.h>

static inline void linear_matmul_linear_omp(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M)
{
#pragma omp parallel for collapse(2)
  for (uint32_t i = 0; i < N; i++) {
    for (uint32_t j = 0; j < M; j++) {
      for (uint32_t k = 0; k < K; k++) {
        C[i * M + j] += A[i * K + k] * B[k * M + j];
      }
    }
  }
}

void linear_matmul_transposed_omp(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M)
{
#pragma omp parallel for collapse(2)
  for (uint32_t i = 0; i < N; i++) {
    for (uint32_t j = 0; j < M; j++) {
      for (uint32_t k = 0; k < K; k++) {
        C[i * M + j] += A[i * K + k] * B[j * K + k];
      }
    }
  }
}

void tiled_matmul_tiled_omp(
    T* tiled_A, T* tiled_B, T* tiled_C,
    uint32_t N,
    uint32_t K,
    uint32_t M,
    uint32_t p,
    uint32_t q,
    uint32_t r)
{
  uint32_t num_tiles_row_A = N / p; // A row
  uint32_t num_tiles_col_A = K / q; // A column
  uint32_t num_tiles_row_B = K / q; // B row
  uint32_t num_tiles_col_B = M / r; // B column

#pragma omp parallel for collapse(2)
  for (uint32_t tile_i = 0; tile_i < num_tiles_row_A; tile_i++) {
    for (uint32_t tile_j = 0; tile_j < num_tiles_col_B; tile_j++) {
      for (uint32_t tile_k = 0; tile_k < num_tiles_col_A; tile_k++) {
        uint32_t A_tile_offset = (tile_i * num_tiles_col_A + tile_k) * p * q;
        uint32_t B_tile_offset = (tile_k * num_tiles_col_B + tile_j) * q * r;
        uint32_t C_tile_offset = (tile_i * num_tiles_col_B + tile_j) * r * p;

        linear_matmul_linear_omp(&tiled_A[A_tile_offset], &tiled_B[B_tile_offset], &tiled_C[C_tile_offset], p, q, r);
      }
    }
  }
}

void tiled_matmul_linear_omp(T* A, T* B, T* C, uint32_t N, uint32_t K, uint32_t M, uint32_t p, uint32_t q, uint32_t r)
{
#pragma omp parallel for collapse(3)
  for (uint32_t i = 0; i < N; i += p) {
    for (uint32_t j = 0; j < M; j += r) {
      for (uint32_t k = 0; k < K; k += q) {

        for (uint32_t ii = 0; ii < p && i + ii < N; ii++) {
          for (uint32_t jj = 0; jj < r && j + jj < M; jj++) {
            for (uint32_t kk = 0; kk < q && k + kk < K; kk++) {
              C[(i + ii) * M + (j + jj)] += A[(i + ii) * K + (k + kk)] * B[(k + kk) * M + (j + jj)];
            }
          }
        }
      }
    }
  }
}
#endif
