# Single GEMM Evaluation (`2mm`)

This directory contains incremental implementations of a single General Matrix Multiplication (GEMM, `C = A x B`) tailored for the SpacemiT K1's RISC-V IME extension (`vmadot` instruction). The files are numbered in the order of optimization evolution, demonstrating the critical impact of memory layout on hardware acceleration.

## Execution
To compile, deploy, and run all benchmarks on the Banana Pi board, simply run:
```bash
make run
```
To generate assembly codes (`.s` files):
```bash
make s
```

## Optimization Evolution

### 1. `0_vmadot.c` (Baseline Packing)
- **Concept**: Demonstrates the baseline performance when standard row-major matrices are fed to the `vmadot` instruction.
- **Implementation**: The input matrix B is packed "on-the-fly" inside the GEMM loop (`Gemm_nonpackB_vmadot`) right before the inline assembly call.
- **Takeaway**: Even though hardware acceleration is used, the runtime data reorganization (packing) penalty severely bottlenecks the overall performance.

### 2. `1_vmadot_vd.c` (Virtual Dimension Prototype)
- **Concept**: Introduces the concept of **Virtual Dimension (VD)** layout to eliminate the packing overhead.
- **Implementation**: Matrix B is initialized using a `B_VIRTUAL_TRANSPOSED` layout macro. The data is pre-twisted in memory to perfectly match the hardware's expected vector format.
- **Takeaway**: Achieves **Zero-overhead** `vmadot` execution by skipping the packing loop. This serves as a Proof of Concept (PoC) that memory layout transformations can drastically improve hardware utilization.

### 3. `2_vmadot_tiled_vd.c` (Fully Tiled VD)
- **Concept**: The ultimate, mature optimization for a single GEMM operation.
- **Implementation**: Combines **Block Tiling** (to handle matrices larger than the register file capacity) with the **Virtual Dimension** layout (`A_VIRTUAL` and `B_VIRTUAL_TRANSPOSED`).
- **Takeaway**: Memory access becomes perfectly contiguous for the hardware. This allows the `vmadot` pipeline to run at 100% efficiency without cache misses or packing delays. This file represents the ideal target performance that the compiler's MLIR lowering passes should aim to generate automatically.
