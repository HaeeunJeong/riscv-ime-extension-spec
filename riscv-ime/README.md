# RISC-V IME Test Bench for BananaPi SpacemiT K1

## Introduction
This repository contains test codes and benchmarks for the RISC-V IME (Intelligent Matrix Extension) equipped on the **BananaPi SpacemiT K1** board. It demonstrates how to leverage the `vmadot` instruction through Virtual Dimension (VD) layout optimizations, highlighting the necessity of advanced compiler passes (like MLIR) over standard C auto-vectorization.

### IME Extension Features
This project builds upon the matrix extension proposal under the RISC-V IME extension standard, which features:
* **Low cost**
    - Reuse the vector registers and the related CSRs.
* **Compatibility**
    - Support VLEN of vector registers from 128 bit to 4096 bit
    - Almost binary portability
* **Rich data types**
    - Integer int4/int8/int16
    - float fp4/fp8/fp16/bf16

## How to Start

### Prerequisites
This project does **not** use emulators (like QEMU or Spike). It is designed to run directly on the physical Banana Pi K1 board.
1. Ensure your host machine is connected to the Banana Pi via SSH.
2. Set up SSH public key authentication (`pubkey`) to allow passwordless connections to the board, as the `Makefile` heavily relies on `scp` and `ssh` for remote deployment and execution.
3. Configure the SSH host alias as `bpi` (or modify the `Makefile` accordingly).

### Execution
Navigate to any of the test directories (`2mm`, `3mm`, `c_mm`) and use the following commands:
- `make run`: Automatically compiles the code, sends it to the Banana Pi via `scp`, executes it on the board using `taskset -c 0`, and prints the benchmark results.
- `make s`: Generates the RISC-V assembly (`.s` file) on the board and fetches it back to your host machine for instruction-level inspection.

## Test Benchmarks

### 1. `2mm` (Single GEMM Evaluation)
Evaluates a single Matrix Multiplication (`C = A x B`).
* **Purpose**: Demonstrates the sheer performance gain of the `vmadot` instruction when memory layout is optimized.
* **Comparisons**:
  * **Naive Scalar**: Standard 3-loop GEMM.
  * **Baseline HW vmadot**: Uses hardware acceleration but forces on-the-fly packing due to standard row-major memory layout.
  * **VD Tiled Transposed**: Achieves **Zero-overhead** hardware acceleration by pre-arranging memory into a Virtual Dimension layout (Tiling + Transpose aware).

### 2. `3mm` (Global Layout Propagation)
Evaluates two consecutive Matrix Multiplications (`C = A x B`, followed by `E = C x D`).
* **Purpose**: Proves the necessity of **Global Layout Propagation** across multiple layers.
* **Comparisons**:
  * **Local VD**: Optimizes the first GEMM but stores the intermediate matrix `C` in a standard format. This incurs a massive packing penalty in the second GEMM.
  * **Global VD**: Stores the intermediate matrix `C` directly into the next layer's required Virtual Dimension layout, eliminating all memory reorganization overheads across consecutive operations.

### 3. `c_mm` (Pure C Compiler Evaluation)
Evaluates the Virtual Dimension layout using purely standard C code, without inline assembly.
* **Purpose**: Tests if the standard GCC auto-vectorizer (`-ftree-vectorize`) can automatically utilize the IME extension or even standard RVV instructions when given a highly optimized memory layout.
* **Result**: Proves that traditional C compilers fail to vectorize complex VD matrix structures (running slower than naive scalar code). This definitively highlights why a dedicated **MLIR compiler backend** is required to map high-level tensor operations directly to custom instructions like `vmadot`.

---

<details>
<summary><b>Official Version & Legacy Build Information (For Reference Only)</b></summary>

## Build
This project was originally built using AsciiDoctor (Ruby). You can build by using the Docker Image, [RISC-V Docs Base Container Image repository](https://github.com/riscv/riscv-docs-base-container-image).

You can build like this:
```bash
# clone this project
https://github.com/spacemit-com/riscv-ime-extension-spec.git

# pull the docker
docker pull riscvintl/riscv-docs-base-container-image:latest

# run the container
docker run -it -v $(pwd)/riscv-ime-extension-spec:/build riscvintl/riscv-docs-base-container-image:latest /bin/bash

# within the container
cd ./build
make
```

## Official Version
- **Official versions** of the specifications are available at the [github release page](https://github.com/spacemit-com/riscv-ime-extension-spec/releases)

## Contributing
If you would like to contribute to this documentation, please refer to the [Documentation Developer's Guide](https://github.com/riscv/docs-dev-guide).

## Acknowledgement
This project refers to [riscv-isa-manual](https://github.com/riscv/riscv-isa-manual) and [riscv-matrix-extension-spec](https://github.com/T-head-Semi/riscv-matrix-extension-spec?tab=readme-ov-file). Thanks a lot.

</details>
