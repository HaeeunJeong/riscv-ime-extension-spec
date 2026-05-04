#include "common.h"
#include "params.h"
#include "timer.h"

/* #define N_SIZE (1024) */
/* #define M_SIZE N_SIZE */
/* #define K_SIZE N_SIZE */

#define DBG() printf("%s[%d]\n", __FILE__, __LINE__)

int main(int argc, char* argv[])
{
  Timer timer;

  struct Params p = input_params(argc, argv);
  uint32_t N_SIZE = p.N_SIZE;
  uint32_t M_SIZE = p.M_SIZE;
  uint32_t K_SIZE = p.K_SIZE;
  partition_t split = { p.n, p.m, p.k };

  uint32_t rows;
  uint32_t cols;

  rows = N_SIZE;
  cols = K_SIZE;

  array_t A_linear, A_tiled;

  meta_t A_init_meta = { rows, cols, 1, 1, 1, 1, false, false };

  set_meta(&(A_linear.meta), A_init_meta);
  A_linear.array = construct_array(A_linear.meta, true);

  set_meta(&A_tiled.meta, A_init_meta);
  A_tiled.array = construct_array(A_tiled.meta, false);

  config_t A_transform_config = { split.n, split.k, 0, 0, false };
  transform_array(&A_linear, &A_tiled, A_transform_config);

  rows = K_SIZE;
  cols = M_SIZE;

  meta_t B_init_meta = { rows, cols, 1, 1, 1, 1, false, false };

  array_t B_linear, B_tiled, B_linear_trans, B_tiled_trans;
  set_meta(&B_linear.meta, B_init_meta);
  B_linear.array = construct_array(B_linear.meta, true);

  set_meta(&B_tiled.meta, B_init_meta);
  B_tiled.array = construct_array(B_tiled.meta, false);

  config_t B_transform_config = { split.k, split.m, 0, 0, false };
  transform_array(&B_linear, &B_tiled, B_transform_config);

  meta_t B_trans_meta = { cols, rows, 1, 1, 1, 1, false, false };
  set_meta(&B_linear_trans.meta, B_trans_meta);
  B_linear_trans.array = construct_array(B_linear_trans.meta, false);

  set_meta(&B_tiled_trans.meta, B_trans_meta);
  B_tiled_trans.array = construct_array(B_tiled_trans.meta, false);

  config_t B_trans_transform_config = { split.m, split.k, 0, 0, false };
  uint32_t B_tile_size = (M_SIZE * K_SIZE) / (split.m * split.k);
  transpose(B_linear.array, B_linear_trans.array, rows, cols);
  transform_array(&B_linear_trans, &B_tiled_trans, B_trans_transform_config);

  rows = N_SIZE;
  cols = M_SIZE;

  meta_t C_init_meta = { rows, cols, 1, 1, 1, 1, false, false };
  array_t C_linear;
  set_meta(&C_linear.meta, C_init_meta);
  C_linear.array = construct_array(C_linear.meta, false);

  meta_t C_tiled_meta = { rows, cols, 1, 1, 1, 1, false, false };
  config_t C_transform_config = { split.n, split.m, 0, 0, false };
  T* C_tiled = construct_array(C_tiled_meta, false);
  meta_transform(C_linear.meta, C_transform_config, &C_tiled_meta);

  meta_t C_linear_from_tiled_meta = { rows, cols, 1, 1, 1, 1, false, false };
  meta_t C_linear_tiled_meta = { rows, cols, 1, 1, 1, 1, false, false };
  T* C_linear_from_tiled = construct_array(C_linear_from_tiled_meta, false);
  T* C_linear_tiled = construct_array(C_linear_tiled_meta, false);

  uint32_t param_N = N_SIZE;
  uint32_t param_K = K_SIZE;
  uint32_t param_M = M_SIZE;
  uint32_t param_p = A_tiled.meta.stride_row;
  uint32_t param_q = A_tiled.meta.stride_col;
  uint32_t param_r = B_tiled.meta.stride_col;
  start(&timer, 0, 0);
  linear_matmul_linear_omp(A_linear.array, B_linear.array, C_linear.array, param_N, param_K, param_M);
  stop(&timer, 0);

  /* start(&timer, 1, 0); */
  /* tiled_matmul_linear_omp(A_linear.array, B_linear.array, C_linear_tiled, param_N, param_K, param_M, param_p, param_q, param_r); */
  /* stop(&timer, 1); */

  /* start(&timer, 2, 0); */
  /* tiled_matmul_tiled_omp(A_tiled.array, B_tiled.array, C_tiled, param_N, param_K, param_M, param_p, param_q, param_r); */
  /* stop(&timer, 2); */

  /* start(&timer, 3, 0); */
  /* itransform_data(C_tiled, C_linear_from_tiled, C_tiled_meta, &C_linear_from_tiled_meta); */
  /* stop(&timer, 3); */

  T* C_linear_B = (T*)malloc(rows * cols * sizeof(T));

  start(&timer, 4, 0);
  linear_matmul_transposed_omp(A_linear.array, B_linear_trans.array, C_linear_B, param_N, param_K, param_M);
  stop(&timer, 4);
  /* transpose_i(C_linear_B, N_SIZE); */

  printf("%d\t", N_SIZE);
  printf("%d\t", M_SIZE);
  printf("%d\t", K_SIZE);
  print_timer(&timer, 0, "linear_linear");
  /* print_timer(&timer, 1, "tiled_linear"); */
  /* print_timer(&timer, 2, "tiled_tiled"); */
  /* print_timer(&timer, 3, "itransform"); */
  print_timer(&timer, 4, "linear_transposed");

  write_array(gen_array_name(A_linear, "A_linear_"), &A_linear);
  /* write_array(gen_array_name(A_tiled, "A_tiled_"), &A_tiled); */
  write_array(gen_array_name(B_linear_trans, "B_linear_trans_"), &B_linear_trans);
  write_array(gen_array_name(C_linear, "C_linear_"), &C_linear);

  free(A_linear.array);
  free(A_tiled.array);
  free(B_linear.array);
  free(B_tiled.array);
  free(B_tiled_trans.array);
  free(B_linear_trans.array);
  free(C_linear_B);
  free(C_tiled);
  free(C_linear_from_tiled);
  free(C_linear_tiled);
  free(C_linear.array);

  return 0;
}
