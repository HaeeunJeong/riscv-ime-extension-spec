	.file	"pure_c_vd.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_v1p0_zicsr2p0_zifencei2p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"
	.attribute unaligned_access, 1
	.attribute stack_align, 16
	.text
	.align	1
	.globl	Gemm_Pure_Scalar_Naive
	.type	Gemm_Pure_Scalar_Naive, @function
Gemm_Pure_Scalar_Naive:
.LFB40:
	.cfi_startproc
	mv	t2,a0
	beq	a0,zero,.L18
	mv	a0,a1
	beq	a1,zero,.L18
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	mv	t4,a2
	sd	s0,8(sp)
	.cfi_offset 8, -8
	mv	t5,a4
	mv	s0,a5
	mv	t3,a3
	add	a6,a3,a2
	li	t0,0
	li	t6,0
.L3:
	slli	t1,t0,2
	li	a7,0
	add	t1,s0,t1
.L8:
	add	a3,t5,a7
	mv	a5,t3
	li	a2,0
	beq	t4,zero,.L7
.L4:
	lb	a4,0(a5)
	addi	a5,a5,1
	lb	a1,0(a3)
	add	a3,a3,a0
	mulw	a4,a4,a1
	addw	a2,a4,a2
	bne	a6,a5,.L4
.L7:
	sw	a2,0(t1)
	addi	a7,a7,1
	addi	t1,t1,4
	bne	a0,a7,.L8
	addi	t6,t6,1
	add	t0,t0,a0
	add	t3,t3,t4
	add	a6,a6,t4
	bne	t2,t6,.L3
	ld	s0,8(sp)
	.cfi_restore 8
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
.L18:
	ret
	.cfi_endproc
.LFE40:
	.size	Gemm_Pure_Scalar_Naive, .-Gemm_Pure_Scalar_Naive
	.align	1
	.globl	Gemm_Pure_Tiled_RowMajor
	.type	Gemm_Pure_Tiled_RowMajor, @function
Gemm_Pure_Tiled_RowMajor:
.LFB41:
	.cfi_startproc
	addi	sp,sp,-528
	.cfi_def_cfa_offset 528
	sd	s0,512(sp)
	.cfi_offset 8, -16
	mv	s0,a2
	sd	s9,440(sp)
	.cfi_offset 25, -88
	mv	s9,a1
	sd	a2,104(sp)
	srli	a2,a0,2
	sd	ra,520(sp)
	lui	a0,%hi(__stack_chk_guard)
	ld	a1, %lo(__stack_chk_guard)(a0)
	sd	a1, 408(sp)
	li	a1, 0
	.cfi_offset 1, -8
	beq	a2,zero,.L22
	mv	t3,a4
	mv	a4,a5
	srli	a5,s9,2
	beq	a5,zero,.L22
	slli	t1,s9,2
	slli	a5,a5,2
	sd	s10,432(sp)
	.cfi_offset 26, -96
	srli	s10,s0,3
	add	t5,a4,t1
	slli	t0,a2,2
	add	a2,t3,a5
	slli	a5,s10,3
	sd	s5,472(sp)
	li	t4,0
	sd	s6,464(sp)
	slli	t6,s0,2
	sd	s11,424(sp)
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 27, -104
	mv	s6,a2
	sd	a3,192(sp)
	slli	a7,s9,3
	sd	a5,200(sp)
	add	t2,t3,t1
	li	a5,-1
	sd	s1,504(sp)
	sd	s2,496(sp)
	srli	s11,a5,32
	sd	s3,488(sp)
	mv	s5,s10
	sd	s4,480(sp)
	mv	a4,t5
	sd	s7,456(sp)
	mv	a3,t1
	sd	s8,448(sp)
	mv	a2,t4
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 23, -72
	.cfi_offset 24, -80
.L25:
	add	s7,a3,a4
	sub	s8,a4,a3
	add	a0,a3,s7
	mv	t4,t3
	mv	a1,a0
	sd	a0,256(sp)
	sd	t2,208(sp)
	mv	a0,a4
	sd	t2,216(sp)
	sd	a3,224(sp)
	sd	a2,232(sp)
	sd	t6,240(sp)
	sd	t0,248(sp)
	sd	t3,264(sp)
.L30:
	sd	zero,344(sp)
	sd	zero,352(sp)
	sd	zero,360(sp)
	sd	zero,368(sp)
	sd	zero,376(sp)
	sd	zero,384(sp)
	sd	zero,392(sp)
	sd	zero,400(sp)
	beq	s5,zero,.L44
	ld	t3,208(sp)
	add	a5,s9,t4
	add	a3,s9,a5
	mv	s3,a5
	li	t6,0
	add	a6,s9,a3
	add	a4,s9,t3
	sd	s5,272(sp)
	add	a2,s9,a4
	mv	s0,t4
	add	t1,s9,a2
	mv	a5,t6
	sd	s8,280(sp)
	sd	a0,288(sp)
	sd	s7,296(sp)
	sd	a1,304(sp)
	sd	t4,312(sp)
	sd	s6,320(sp)
	sd	s9,328(sp)
.L29:
	lb	s1,1(a6)
	addi	t6,sp,344
	lb	a1,0(s3)
	lb	a0,0(a4)
	sw	s1,8(sp)
	lb	s1,1(t3)
	sw	a1,84(sp)
	ld	a1,192(sp)
	lb	t4,0(a2)
	sw	s1,20(sp)
	lb	s1,1(a4)
	add	t5,a5,a1
	lb	a1,0(s0)
	lb	s6,1(s0)
	sw	s1,32(sp)
	lb	s1,1(a2)
	sw	a1,80(sp)
	lb	a1,0(a3)
	lb	s7,1(s3)
	sw	s1,44(sp)
	lb	s1,2(s3)
	sw	a1,88(sp)
	lb	a1,0(a6)
	lb	s9,2(s0)
	sw	s1,0(sp)
	lb	s1,2(a3)
	sw	a1,92(sp)
	lb	a1,0(t3)
	sw	s1,12(sp)
	lb	s1,2(a6)
	sw	a1,96(sp)
	lb	a1,1(a3)
	sw	s1,24(sp)
	lb	s1,2(t3)
	sw	s1,36(sp)
	lb	s1,2(a4)
	sd	a5,112(sp)
	lb	t2,0(t1)
	sd	s0,120(sp)
	sw	s1,48(sp)
	lb	s1,2(a2)
	sd	s3,128(sp)
	sd	a3,136(sp)
	sw	s1,56(sp)
	lb	s1,3(s0)
	sd	a6,144(sp)
	sd	t3,152(sp)
	sw	s1,4(sp)
	lb	s1,3(s3)
	sd	a4,160(sp)
	sw	s1,16(sp)
	lb	s1,3(a3)
	sw	s1,28(sp)
	lb	s1,3(a6)
	sw	s1,40(sp)
	lb	s1,3(t3)
	sw	s1,52(sp)
	lb	s1,3(a4)
	sw	s1,60(sp)
	lb	s1,3(a2)
	sw	s1,68(sp)
	lb	s1,2(t1)
	sw	s1,72(sp)
	lb	s1,3(t1)
	sw	s1,76(sp)
	lb	s1,1(t1)
	sw	s1,64(sp)
	sd	a2,168(sp)
	sd	a7,184(sp)
	mv	a7,a0
	sd	t1,176(sp)
	sw	a1,100(sp)
.L28:
	lb	a5,0(t5)
	addi	t6,t6,16
	lw	a4,80(sp)
	lb	s5,1(t5)
	mulw	s10,s6,a5
	lw	s1,0(sp)
	mulw	a6,a4,a5
	lw	a4,84(sp)
	mulw	a3,s7,s5
	lb	s0,2(t5)
	mulw	s1,s1,s5
	lw	a1,28(sp)
	mulw	s4,a4,s5
	lb	t0,3(t5)
	mulw	a2,s9,a5
	lb	t3,4(t5)
	addw	s10,s10,a3
	lw	a3,88(sp)
	lb	t1,5(t5)
	addw	s4,s4,a6
	lw	a6,4(sp)
	addw	a2,a2,s1
	lw	s1,12(sp)
	lb	a0,6(t5)
	mulw	a5,a6,a5
	lw	a6,16(sp)
	mulw	s8,s1,s0
	lb	a4,7(t5)
	lw	s1,-16(t6)
	mulw	s5,a6,s5
	lw	s3,-8(t6)
	mulw	a6,a3,s0
	lw	a3,100(sp)
	addw	a2,s8,a2
	lw	s2,-4(t6)
	mulw	a3,a3,s0
	addw	a5,a5,s5
	mulw	s0,a1,s0
	lw	a1,92(sp)
	addw	a6,a6,s4
	mulw	s5,a1,t0
	lw	a1,8(sp)
	addw	a3,a3,s10
	addw	a5,s0,a5
	mulw	s4,a1,t0
	lw	a1,24(sp)
	addw	a6,s5,a6
	mulw	s10,a1,t0
	lw	a1,40(sp)
	addw	a3,s4,a3
	mulw	t0,a1,t0
	lw	a1,96(sp)
	addw	a2,s10,a2
	mulw	s0,a1,t3
	lw	a1,20(sp)
	addw	a5,t0,a5
	mulw	t0,a7,t1
	mulw	s5,a1,t3
	lw	a1,36(sp)
	addw	a6,s0,a6
	addw	t0,t0,a6
	mulw	s4,a1,t3
	lw	a1,52(sp)
	addw	a3,s5,a3
	mulw	t3,a1,t3
	lw	a1,32(sp)
	addw	a2,s4,a2
	lw	s4,-12(t6)
	mulw	s0,a1,t1
	lw	a1,48(sp)
	addw	a5,t3,a5
	mulw	t3,t4,a0
	mulw	s5,a1,t1
	lw	a1,60(sp)
	addw	a3,s0,a3
	addw	t3,t3,t0
	mulw	t0,t2,a4
	mulw	t1,a1,t1
	lw	a1,44(sp)
	addw	a2,s5,a2
	mulw	s8,a1,a0
	lw	a1,56(sp)
	addw	a5,t1,a5
	addw	t0,t0,t3
	addw	t0,t0,s1
	mulw	a6,a1,a0
	lw	a1,68(sp)
	addw	a3,s8,a3
	and	t0,s11,t0
	mulw	a0,a1,a0
	lw	a1,72(sp)
	addw	a6,a6,a2
	mulw	s0,a1,a4
	lw	a1,76(sp)
	addw	a0,a0,a5
	ld	a5,104(sp)
	mulw	t1,a1,a4
	lw	a1,64(sp)
	addw	s0,s0,a6
	add	t5,t5,a5
	addw	s0,s0,s3
	addi	a5,sp,408
	mulw	a4,a1,a4
	and	s0,s11,s0
	addw	t1,t1,a0
	addw	t1,t1,s2
	slli	t1,t1,32
	addw	a4,a4,a3
	or	s0,s0,t1
	addw	a4,a4,s4
	sd	s0,-8(t6)
	slli	a4,a4,32
	or	t0,t0,a4
	sd	t0,-16(t6)
	bne	t6,a5,.L28
	ld	a5,112(sp)
	ld	a7,184(sp)
	ld	s0,120(sp)
	ld	s3,128(sp)
	addi	a5,a5,8
	ld	a3,136(sp)
	ld	a6,144(sp)
	add	s0,s0,a7
	ld	t3,152(sp)
	add	s3,s3,a7
	ld	a4,160(sp)
	add	a3,a3,a7
	ld	a2,168(sp)
	add	a6,a6,a7
	ld	t1,176(sp)
	add	t3,t3,a7
	ld	a1,200(sp)
	add	a4,a4,a7
	lw	t0,344(sp)
	add	a2,a2,a7
	add	t1,t1,a7
	bne	a5,a1,.L29
	ld	s5,272(sp)
	ld	s8,280(sp)
	ld	a0,288(sp)
	ld	s7,296(sp)
	ld	a1,304(sp)
	ld	t4,312(sp)
	ld	s6,320(sp)
	ld	s9,328(sp)
	lw	s4,348(sp)
	lw	s3,352(sp)
	lw	s2,356(sp)
	lw	s1,360(sp)
	lw	s0,364(sp)
	lw	t2,368(sp)
	lw	t6,372(sp)
	lw	t5,376(sp)
	lw	t3,380(sp)
	lw	t1,384(sp)
	lw	a6,388(sp)
	lw	a2,392(sp)
	lw	a3,396(sp)
	lw	a4,400(sp)
	lw	a5,404(sp)
.L27:
	sw	t0,0(s8)
	addi	a0,a0,16
	sw	s4,4(s8)
	addi	s7,s7,16
	sw	s3,8(s8)
	addi	a1,a1,16
	sw	s2,12(s8)
	addi	t4,t4,4
	sw	s0,-12(a0)
	ld	s0,208(sp)
	sw	s1,-16(a0)
	addi	s8,s8,16
	sw	t2,-8(a0)
	sw	t6,-4(a0)
	addi	s0,s0,4
	sw	t5,-16(s7)
	sw	t3,-12(s7)
	sw	t1,-8(s7)
	sw	a6,-4(s7)
	sd	s0,208(sp)
	sw	a2,-16(a1)
	sw	a3,-12(a1)
	sw	a4,-8(a1)
	sw	a5,-4(a1)
	bne	t4,s6,.L30
	ld	a5,192(sp)
	ld	t6,240(sp)
	ld	a2,232(sp)
	ld	a0,256(sp)
	ld	t0,248(sp)
	add	a5,a5,t6
	addi	a2,a2,4
	sd	a5,192(sp)
	ld	t2,216(sp)
	add	a4,a7,a0
	ld	a3,224(sp)
	ld	t3,264(sp)
	bne	a2,t0,.L25
	ld	s1,504(sp)
	.cfi_restore 9
	ld	s2,496(sp)
	.cfi_restore 18
	ld	s3,488(sp)
	.cfi_restore 19
	ld	s4,480(sp)
	.cfi_restore 20
	ld	s5,472(sp)
	.cfi_restore 21
	ld	s6,464(sp)
	.cfi_restore 22
	ld	s7,456(sp)
	.cfi_restore 23
	ld	s8,448(sp)
	.cfi_restore 24
	ld	s10,432(sp)
	.cfi_restore 26
	ld	s11,424(sp)
	.cfi_restore 27
.L22:
	lui	a5,%hi(__stack_chk_guard)
	ld	a4, 408(sp)
	ld	a5, %lo(__stack_chk_guard)(a5)
	xor	a5, a4, a5
	li	a4, 0
	bne	a5,zero,.L45
	ld	ra,520(sp)
	.cfi_restore 1
	ld	s0,512(sp)
	.cfi_restore 8
	ld	s9,440(sp)
	.cfi_restore 25
	addi	sp,sp,528
	.cfi_def_cfa_offset 0
	jr	ra
.L44:
	.cfi_def_cfa_offset 528
	.cfi_offset 1, -8
	.cfi_offset 8, -16
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 25, -88
	.cfi_offset 26, -96
	.cfi_offset 27, -104
	li	a5,0
	li	a4,0
	li	a3,0
	li	a2,0
	li	a6,0
	li	t1,0
	li	t3,0
	li	t5,0
	li	t6,0
	li	t2,0
	li	s0,0
	li	s1,0
	li	s2,0
	li	s3,0
	li	s4,0
	li	t0,0
	j	.L27
.L45:
	.cfi_restore 9
	.cfi_restore 18
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 26
	.cfi_restore 27
	sd	s1,504(sp)
	sd	s2,496(sp)
	sd	s3,488(sp)
	sd	s4,480(sp)
	sd	s5,472(sp)
	sd	s6,464(sp)
	sd	s7,456(sp)
	sd	s8,448(sp)
	sd	s10,432(sp)
	sd	s11,424(sp)
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 26, -96
	.cfi_offset 27, -104
	call	__stack_chk_fail
	.cfi_endproc
.LFE41:
	.size	Gemm_Pure_Tiled_RowMajor, .-Gemm_Pure_Tiled_RowMajor
	.align	1
	.globl	Gemm_Pure_Tiled_VD
	.type	Gemm_Pure_Tiled_VD, @function
Gemm_Pure_Tiled_VD:
.LFB42:
	.cfi_startproc
	addi	sp,sp,-576
	.cfi_def_cfa_offset 576
	srli	t0,a0,2
	sd	s0,560(sp)
	.cfi_offset 8, -16
	lui	s0,%hi(__stack_chk_guard)
	sd	ra,568(sp)
	ld	a0, %lo(__stack_chk_guard)(s0)
	sd	a0, 456(sp)
	li	a0, 0
	sd	a3,240(sp)
	.cfi_offset 1, -8
	beq	t0,zero,.L46
	sd	s11,472(sp)
	.cfi_offset 27, -104
	srli	s11,a1,2
	beq	s11,zero,.L69
	slli	t4,a1,2
	sd	s10,480(sp)
	.cfi_offset 26, -96
	srli	s10,a2,3
	add	a7,a5,t4
	slli	t2,s10,5
	slli	a5,s11,5
	sd	s1,552(sp)
	li	t5,0
	sd	s3,536(sp)
	.cfi_offset 9, -24
	.cfi_offset 19, -40
	slli	s1,a1,3
	sd	s4,528(sp)
	mv	t3,t2
	sd	a5,232(sp)
	mv	s3,s11
	li	a5,-1
	sd	s2,544(sp)
	sd	s5,520(sp)
	.cfi_offset 20, -48
	.cfi_offset 18, -32
	.cfi_offset 21, -56
	srli	s4,a5,32
	sd	s6,512(sp)
	mv	a6,t5
	sd	s7,504(sp)
	mv	t1,t4
	sd	s8,496(sp)
	mv	a1,a4
	sd	s9,488(sp)
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 25, -88
.L49:
	add	a4,a7,t1
	slli	a2,a6,5
	add	a5,a4,t1
	sd	a2,256(sp)
	sd	a0,264(sp)
	sub	a3,a7,t1
	sd	a1,248(sp)
	mv	a0,s3
	sd	a1,320(sp)
	mv	a2,a4
	sd	t0,272(sp)
	mv	a1,a5
	sd	a5,280(sp)
	li	s7,0
	sd	s1,288(sp)
	sd	a6,296(sp)
	sd	t2,304(sp)
	sd	t1,312(sp)
.L53:
	sd	zero,392(sp)
	sd	zero,400(sp)
	sd	zero,408(sp)
	sd	zero,416(sp)
	sd	zero,424(sp)
	sd	zero,432(sp)
	sd	zero,440(sp)
	sd	zero,448(sp)
	beq	s10,zero,.L55
	ld	a4,256(sp)
	sd	a0,328(sp)
	ld	a5,248(sp)
	sd	s10,336(sp)
	sd	s7,344(sp)
	sd	t3,224(sp)
	sd	a7,352(sp)
	sd	a1,360(sp)
	sd	a2,368(sp)
	sd	a3,376(sp)
.L52:
	lb	a2,7(a5)
	addi	a6,sp,392
	ld	a3,240(sp)
	lb	s10,0(a5)
	sd	a2,0(sp)
	lb	a2,8(a5)
	lb	s9,1(a5)
	add	a0,a3,a4
	lb	s8,2(a5)
	sd	a2,8(sp)
	lb	a2,9(a5)
	lb	a3,6(a5)
	lb	s7,3(a5)
	sd	a2,16(sp)
	lb	a2,10(a5)
	lb	s6,4(a5)
	lb	s5,5(a5)
	sd	a2,24(sp)
	lb	a2,11(a5)
	sd	a2,32(sp)
	lb	a2,12(a5)
	sd	a2,40(sp)
	lb	a2,13(a5)
	sd	a2,48(sp)
	lb	a2,14(a5)
	sd	a2,56(sp)
	lb	a2,15(a5)
	sd	a2,64(sp)
	lb	a2,16(a5)
	sd	a2,72(sp)
	lb	a2,17(a5)
	sd	a2,80(sp)
	lb	a2,18(a5)
	sd	a2,88(sp)
	lb	a2,19(a5)
	sd	a3,200(sp)
	sd	a4,208(sp)
	sd	a2,96(sp)
	lb	a2,20(a5)
	sd	a5,216(sp)
	sd	a2,104(sp)
	lb	a2,21(a5)
	sd	a2,112(sp)
	lb	a2,22(a5)
	sd	a2,120(sp)
	lb	a2,23(a5)
	sd	a2,128(sp)
	lb	a2,24(a5)
	sd	a2,136(sp)
	lb	a2,25(a5)
	sd	a2,144(sp)
	lb	a2,26(a5)
	sd	a2,152(sp)
	lb	a2,27(a5)
	sd	a2,160(sp)
	lb	a2,28(a5)
	sd	a2,168(sp)
	lb	a2,29(a5)
	sd	a2,176(sp)
	lb	a2,30(a5)
	sd	a2,184(sp)
	lb	a2,31(a5)
	sd	a2,192(sp)
.L51:
	lb	a5,0(a0)
	addi	a0,a0,8
	ld	a4,8(sp)
	addi	a6,a6,16
	lb	s2,-7(a0)
	ld	s0,80(sp)
	mulw	s1,a5,s10
	mulw	s11,a5,a4
	ld	a4,16(sp)
	mulw	t1,s2,s9
	lb	t6,-6(a0)
	mulw	t0,s2,s0
	ld	a3,152(sp)
	mulw	a2,s2,a4
	ld	a4,72(sp)
	lb	t5,-5(a0)
	addw	s1,s1,t1
	ld	t1,144(sp)
	mulw	a1,a5,a4
	ld	s0,136(sp)
	addw	s11,s11,a2
	ld	a2,24(sp)
	mulw	s2,s2,t1
	lb	t4,-4(a0)
	mulw	t1,t6,s8
	lb	t3,-3(a0)
	addw	a1,a1,t0
	ld	t0,88(sp)
	mulw	a2,t6,a2
	lb	a7,-2(a0)
	mulw	a5,a5,s0
	lb	a4,-1(a0)
	mulw	s3,t6,t0
	addw	t1,t1,s1
	mulw	t6,t6,a3
	ld	a3,32(sp)
	addw	a2,a2,s11
	lw	s0,-8(a6)
	addw	a5,a5,s2
	mulw	s2,t5,s7
	mulw	s1,t5,a3
	ld	a3,96(sp)
	addw	a5,t6,a5
	mulw	t6,t4,s6
	addw	a1,s3,a1
	lw	t0,-16(a6)
	mulw	s11,t5,a3
	ld	a3,160(sp)
	addw	t1,s2,t1
	addw	a2,s1,a2
	addw	t1,t6,t1
	lw	t2,-4(a6)
	mulw	t5,t5,a3
	ld	a3,40(sp)
	addw	a1,s11,a1
	mulw	s2,t4,a3
	ld	a3,104(sp)
	addw	a5,t5,a5
	mulw	t5,t3,s5
	mulw	s1,t4,a3
	ld	a3,168(sp)
	addw	a2,s2,a2
	addw	t5,t5,t1
	mulw	t4,t4,a3
	ld	a3,48(sp)
	addw	a1,s1,a1
	lw	s1,-12(a6)
	mulw	t6,t3,a3
	ld	a3,112(sp)
	addw	a5,t4,a5
	mulw	s2,t3,a3
	ld	a3,176(sp)
	addw	a2,t6,a2
	mulw	t3,t3,a3
	ld	a3,200(sp)
	addw	a1,s2,a1
	mulw	t4,a7,a3
	ld	a3,56(sp)
	addw	a5,t3,a5
	mulw	s3,a7,a3
	ld	a3,120(sp)
	addw	t4,t4,t5
	mulw	t1,a7,a3
	ld	a3,184(sp)
	addw	a2,s3,a2
	mulw	a7,a7,a3
	ld	a3,128(sp)
	addw	t1,t1,a1
	mulw	t6,a4,a3
	ld	a3,192(sp)
	addw	a7,a7,a5
	addi	a5,sp,456
	mulw	t3,a4,a3
	ld	a3,0(sp)
	addw	t6,t6,t1
	addw	t6,t6,s0
	mulw	t5,a4,a3
	ld	a3,64(sp)
	addw	t3,t3,a7
	and	t6,s4,t6
	addw	t3,t3,t2
	mulw	a4,a4,a3
	slli	t3,t3,32
	addw	t5,t5,t4
	or	t6,t6,t3
	addw	t5,t5,t0
	sd	t6,-8(a6)
	and	t5,s4,t5
	addw	a4,a4,a2
	addw	a4,a4,s1
	slli	a4,a4,32
	or	t5,t5,a4
	sd	t5,-16(a6)
	bne	a5,a6,.L51
	ld	a3,232(sp)
	ld	a5,216(sp)
	ld	a4,208(sp)
	lw	t6,392(sp)
	add	a5,a5,a3
	ld	a3,224(sp)
	addi	a4,a4,32
	lw	t5,396(sp)
	lw	t4,400(sp)
	lw	t1,404(sp)
	bne	a3,a4,.L52
	mv	t3,a3
	ld	a0,328(sp)
	ld	s10,336(sp)
	ld	s7,344(sp)
	ld	a7,352(sp)
	ld	a1,360(sp)
	ld	a2,368(sp)
	ld	a3,376(sp)
	lw	s9,408(sp)
	lw	s8,412(sp)
	lw	s6,416(sp)
	lw	s5,420(sp)
	lw	s3,424(sp)
	lw	s2,428(sp)
	lw	s1,432(sp)
	lw	s0,436(sp)
	lw	t2,440(sp)
	lw	t0,444(sp)
	lw	a4,448(sp)
	lw	a5,452(sp)
.L50:
	ld	a6,248(sp)
	sw	t6,0(a3)
	sw	t5,4(a3)
	addi	a7,a7,16
	sw	t4,8(a3)
	addi	a2,a2,16
	sw	t1,12(a3)
	addi	a1,a1,16
	sw	s9,-16(a7)
	addi	a6,a6,32
	sw	s8,-12(a7)
	addi	s7,s7,1
	sw	s6,-8(a7)
	addi	a3,a3,16
	sw	s5,-4(a7)
	sw	s3,-16(a2)
	sw	s2,-12(a2)
	sw	s1,-8(a2)
	sw	s0,-4(a2)
	sd	a6,248(sp)
	sw	t2,-16(a1)
	sw	t0,-12(a1)
	sw	a4,-8(a1)
	sw	a5,-4(a1)
	bne	a0,s7,.L53
	mv	s3,a0
	ld	a0,264(sp)
	ld	a5,280(sp)
	ld	s1,288(sp)
	ld	a6,296(sp)
	addi	a0,a0,1
	ld	t2,304(sp)
	ld	t0,272(sp)
	add	a7,a5,s1
	ld	t1,312(sp)
	add	a6,a6,s10
	ld	a1,320(sp)
	add	t3,t3,t2
	bne	t0,a0,.L49
	ld	s1,552(sp)
	.cfi_restore 9
	ld	s2,544(sp)
	.cfi_restore 18
	ld	s3,536(sp)
	.cfi_restore 19
	ld	s4,528(sp)
	.cfi_restore 20
	ld	s5,520(sp)
	.cfi_restore 21
	ld	s6,512(sp)
	.cfi_restore 22
	ld	s7,504(sp)
	.cfi_restore 23
	ld	s8,496(sp)
	.cfi_restore 24
	ld	s9,488(sp)
	.cfi_restore 25
	ld	s10,480(sp)
	.cfi_restore 26
.L69:
	ld	s11,472(sp)
	.cfi_restore 27
.L46:
	lui	a5,%hi(__stack_chk_guard)
	ld	a4, 456(sp)
	ld	a5, %lo(__stack_chk_guard)(a5)
	xor	a5, a4, a5
	li	a4, 0
	bne	a5,zero,.L70
	ld	ra,568(sp)
	.cfi_restore 1
	ld	s0,560(sp)
	.cfi_restore 8
	addi	sp,sp,576
	.cfi_def_cfa_offset 0
	jr	ra
.L55:
	.cfi_def_cfa_offset 576
	.cfi_offset 1, -8
	.cfi_offset 8, -16
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 25, -88
	.cfi_offset 26, -96
	.cfi_offset 27, -104
	li	a5,0
	li	a4,0
	li	t0,0
	li	t2,0
	li	s0,0
	li	s1,0
	li	s2,0
	li	s3,0
	li	s5,0
	li	s6,0
	li	s8,0
	li	s9,0
	li	t1,0
	li	t4,0
	li	t5,0
	li	t6,0
	j	.L50
.L70:
	.cfi_restore 9
	.cfi_restore 18
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 25
	.cfi_restore 26
	.cfi_restore 27
	sd	s1,552(sp)
	sd	s2,544(sp)
	sd	s3,536(sp)
	sd	s4,528(sp)
	sd	s5,520(sp)
	sd	s6,512(sp)
	sd	s7,504(sp)
	sd	s8,496(sp)
	sd	s9,488(sp)
	sd	s10,480(sp)
	sd	s11,472(sp)
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 25, -88
	.cfi_offset 26, -96
	.cfi_offset 27, -104
	call	__stack_chk_fail
	.cfi_endproc
.LFE42:
	.size	Gemm_Pure_Tiled_VD, .-Gemm_Pure_Tiled_VD
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"Mismatch Logical at (%zu, %zu)!\n"
	.align	3
.LC1:
	.string	"pure_c_vd.c"
	.align	3
.LC2:
	.string	"0"
	.text
	.align	1
	.globl	Test_Logical
	.type	Test_Logical, @function
Test_Logical:
.LFB43:
	.cfi_startproc
	beq	a0,zero,.L71
	slli	t4,a1,2
	mv	t1,a3
	mv	t3,a2
	li	a2,0
.L73:
	mv	a4,t1
	mv	a5,t3
	li	a3,0
	beq	a1,zero,.L76
.L75:
	lw	a7,0(a5)
	lw	a6,0(a4)
	bne	a7,a6,.L86
	addi	a3,a3,1
	addi	a5,a5,4
	addi	a4,a4,4
	bne	a1,a3,.L75
.L76:
	addi	a2,a2,1
	add	t3,t3,t4
	add	t1,t1,t4
	bne	a0,a2,.L73
.L71:
	ret
.L86:
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	lui	a1,%hi(.LC0)
	addi	a1,a1,%lo(.LC0)
	sd	ra,8(sp)
	.cfi_offset 1, -8
	li	a0,2
	call	__printf_chk
	lui	a3,%hi(.LANCHOR0)
	lui	a1,%hi(.LC1)
	lui	a0,%hi(.LC2)
	addi	a3,a3,%lo(.LANCHOR0)
	addi	a1,a1,%lo(.LC1)
	addi	a0,a0,%lo(.LC2)
	li	a2,136
	call	__assert_fail
	.cfi_endproc
.LFE43:
	.size	Test_Logical, .-Test_Logical
	.section	.rodata.str1.8
	.align	3
.LC3:
	.string	"=================================================================="
	.align	3
.LC4:
	.string	" Pure C VD Auto-vectorization Test | Size: M=%zu, N=%zu, K=%zu\n"
	.align	3
.LC5:
	.string	"Verification"
	.align	3
.LC6:
	.string	"Execution Time"
	.align	3
.LC7:
	.string	"Function Name"
	.align	3
.LC8:
	.string	" %-30s | %-14s | %s\n"
	.align	3
.LC9:
	.string	"------------------------------------------------------------------"
	.align	3
.LC10:
	.string	"Baseline"
	.align	3
.LC12:
	.string	"1. Pure_Scalar_Naive"
	.align	3
.LC13:
	.string	" %-30s | %10.3f ns   | %s\n"
	.align	3
.LC14:
	.string	"Passed"
	.align	3
.LC15:
	.string	"2. Pure_Tiled_RowMajor"
	.align	3
.LC16:
	.string	"3. Pure_Tiled_VD"
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
.LFB44:
	.cfi_startproc
	lui	a5,%hi(stdout)
	ld	a0,%lo(stdout)(a5)
	addi	sp,sp,-560
	.cfi_def_cfa_offset 560
	lui	a4,%hi(__stack_chk_guard)
	ld	a5, %lo(__stack_chk_guard)(a4)
	sd	a5, 440(sp)
	li	a5, 0
	sd	ra,552(sp)
	li	a1,0
	sd	s0,544(sp)
	sd	s1,536(sp)
	sd	s2,528(sp)
	sd	s3,520(sp)
	sd	s4,512(sp)
	sd	s6,496(sp)
	.cfi_offset 1, -8
	.cfi_offset 8, -16
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 22, -64
	li	s6,0
	sd	s7,488(sp)
	sd	s9,472(sp)
	.cfi_offset 23, -72
	.cfi_offset 25, -88
	li	s9,0
	sd	s10,464(sp)
	.cfi_offset 26, -96
	li	s10,16
	sd	s5,504(sp)
	sd	s8,480(sp)
	sd	s11,456(sp)
	.cfi_offset 21, -56
	.cfi_offset 24, -80
	.cfi_offset 27, -104
	call	setbuf
	li	a0,256
	call	malloc
	mv	s0,a0
	li	a0,256
	call	malloc
	sd	a0,8(sp)
	li	a1,1
	li	a0,1024
	call	calloc
	mv	s1,a0
	li	a0,256
	call	malloc
	mv	s7,a0
	li	a0,256
	call	malloc
	mv	s2,a0
	li	a1,1
	li	a0,1024
	call	calloc
	mv	s3,a0
	li	a1,1
	li	a0,1024
	call	calloc
	mv	s4,a0
	li	a0,0
	call	time
	sext.w	a0,a0
	call	srand
	sd	s4,16(sp)
	mv	s4,s3
	mv	s3,s2
	mv	s2,s1
	mv	s1,s0
.L88:
	srli	s8,s6,2
	andi	s0,s6,3
	slli	s8,s8,1
	add	s11,s1,s9
	li	s5,0
.L89:
	call	rand
	sraiw	a2,a0,31
	srliw	a2,a2,27
	srli	a4,s5,3
	addw	a5,a2,a0
	add	a4,a4,s8
	slli	a4,a4,2
	andi	a5,a5,31
	subw	a5,a5,a2
	add	a4,a4,s0
	slli	a4,a4,3
	addiw	a5,a5,-16
	andi	a1,s5,7
	add	a4,s7,a4
	slliw	a5,a5,24
	add	a2,s11,s5
	sraiw	a5,a5,24
	add	a4,a4,a1
	addi	s5,s5,1
	sb	a5,0(a2)
	sb	a5,0(a4)
	bne	s5,s10,.L89
	addi	s6,s6,1
	addi	s9,s9,16
	bne	s6,s5,.L88
	mv	s0,s1
	mv	s1,s2
	mv	s2,s3
	mv	s3,s1
	mv	s1,s0
	li	s9,0
	li	s6,0
	li	s10,16
.L90:
	ld	a5,8(sp)
	srli	s8,s6,3
	andi	s0,s6,7
	slli	s8,s8,2
	li	s5,0
	add	s11,a5,s9
.L91:
	call	rand
	sraiw	a2,a0,31
	srliw	a2,a2,27
	srli	a4,s5,2
	addw	a5,a2,a0
	add	a4,a4,s8
	andi	a1,s5,3
	slli	a4,a4,2
	andi	a5,a5,31
	add	a4,a4,a1
	subw	a5,a5,a2
	slli	a4,a4,3
	addiw	a5,a5,-16
	add	a4,s2,a4
	slliw	a5,a5,24
	add	a2,s11,s5
	sraiw	a5,a5,24
	add	a4,a4,s0
	addi	s5,s5,1
	sb	a5,0(a2)
	sb	a5,0(a4)
	bne	s5,s10,.L91
	addi	s6,s6,1
	addi	s9,s9,16
	bne	s6,s5,.L90
	mv	s0,s1
	li	a0,10
	mv	s1,s3
	mv	s3,s4
	ld	s4,16(sp)
	call	putchar
	lui	s5,%hi(.LC3)
	addi	a0,s5,%lo(.LC3)
	call	puts
	lui	a1,%hi(.LC4)
	addi	a1,a1,%lo(.LC4)
	li	a4,16
	li	a3,16
	li	a2,16
	li	a0,2
	call	__printf_chk
	addi	a0,s5,%lo(.LC3)
	call	puts
	lui	a4,%hi(.LC5)
	lui	a3,%hi(.LC6)
	addi	a4,a4,%lo(.LC5)
	addi	a3,a3,%lo(.LC6)
	lui	a2,%hi(.LC7)
	lui	a1,%hi(.LC8)
	addi	a2,a2,%lo(.LC7)
	addi	a1,a1,%lo(.LC8)
	li	a0,2
	call	__printf_chk
	lui	a0,%hi(.LC9)
	addi	a0,a0,%lo(.LC9)
	call	puts
	addi	a1,sp,360
	li	a0,4
	call	clock_gettime
	ld	s5,368(sp)
	ld	a3,360(sp)
	li	a4,1000001536
	addi	a4,a4,-1536
	li	a5,49152
	addi	a5,a5,848
	mul	s6,a3,a4
	ld	a4,8(sp)
	addi	a4,a4,16
	sd	a4,104(sp)
.L93:
	mv	a3,s1
	mv	a4,s0
	li	a7,0
.L97:
	lb	a1,5(a4)
	mv	t5,a3
	lb	s11,0(a4)
	sd	a5,112(sp)
	lb	s10,1(a4)
	sd	a1,16(sp)
	lb	a1,6(a4)
	ld	a2,8(sp)
	lb	s9,2(a4)
	sd	a1,24(sp)
	lb	a1,7(a4)
	lb	s8,3(a4)
	lb	ra,4(a4)
	sd	a1,32(sp)
	lb	a1,8(a4)
	sd	a1,40(sp)
	lb	a1,9(a4)
	sd	a1,48(sp)
	lb	a1,10(a4)
	sd	a1,56(sp)
	lb	a1,11(a4)
	sd	a1,64(sp)
	lb	a1,12(a4)
	sd	a1,72(sp)
	lb	a1,13(a4)
	sd	a1,80(sp)
	lb	a1,14(a4)
	sd	a1,88(sp)
	lb	a1,15(a4)
	sd	a1,96(sp)
.L94:
	lb	a6,0(a2)
	addi	t5,t5,4
	ld	a5,16(sp)
	addi	a2,a2,1
	lb	t0,79(a2)
	mulw	a6,a6,s11
	lb	t6,95(a2)
	lb	t1,15(a2)
	mulw	t0,t0,a5
	ld	a5,24(sp)
	lb	t4,111(a2)
	mulw	t1,t1,s10
	lb	a0,31(a2)
	mulw	t6,t6,a5
	ld	a5,32(sp)
	lb	t3,127(a2)
	mulw	a0,a0,s9
	lb	a1,47(a2)
	mulw	t4,t4,a5
	ld	a5,40(sp)
	addw	a6,a6,t1
	lb	t1,143(a2)
	mulw	a1,a1,s8
	lb	t2,63(a2)
	mulw	t3,t3,a5
	ld	a5,48(sp)
	addw	a0,a0,a6
	lb	a6,159(a2)
	mulw	t2,t2,ra
	mulw	t1,t1,a5
	ld	a5,56(sp)
	addw	a1,a1,a0
	lb	a0,175(a2)
	mulw	a6,a6,a5
	ld	a5,64(sp)
	addw	a1,t2,a1
	lb	t2,191(a2)
	addw	a1,t0,a1
	lb	t0,207(a2)
	mulw	a0,a0,a5
	ld	a5,72(sp)
	addw	a1,t6,a1
	lb	t6,223(a2)
	addw	a1,t4,a1
	lb	t4,239(a2)
	mulw	t2,t2,a5
	ld	a5,80(sp)
	addw	t3,t3,a1
	addw	t1,t1,t3
	mulw	t0,t0,a5
	ld	a5,88(sp)
	addw	a6,a6,t1
	addw	a0,a0,a6
	mulw	t6,t6,a5
	ld	a5,96(sp)
	addw	t2,t2,a0
	addw	a0,t0,t2
	mulw	a1,t4,a5
	ld	a5,104(sp)
	addw	a0,t6,a0
	addw	a1,a1,a0
	sw	a1,-4(t5)
	bne	a5,a2,.L94
	addi	a7,a7,16
	ld	a5,112(sp)
	addi	a4,a4,16
	addi	a3,a3,64
	li	a2,256
	bne	a7,a2,.L97
	addiw	a5,a5,-1
	bne	a5,zero,.L93
	addi	a1,sp,360
	li	a0,4
	call	clock_gettime
	li	s8,1000001536
	ld	a3,360(sp)
	addi	s8,s8,-1536
	lui	a5,%hi(.LC11)
	fld	fa5,%lo(.LC11)(a5)
	lui	a5,%hi(.LC13)
	addi	a1,a5,%lo(.LC13)
	mul	a3,a3,s8
	ld	a5,368(sp)
	lui	a4,%hi(.LC10)
	lui	a2,%hi(.LC12)
	addi	a4,a4,%lo(.LC10)
	addi	a2,a2,%lo(.LC12)
	li	a0,2
	sub	a3,a3,s5
	add	a5,a5,a3
	sub	a5,a5,s6
	fcvt.d.lu	fa4,a5
	fdiv.d	fa5,fa4,fa5
	fmv.x.d	a3,fa5
	call	__printf_chk
	addi	a1,sp,360
	li	a0,4
	call	clock_gettime
	ld	s5,368(sp)
	ld	a5,360(sp)
	li	a3,49152
	addi	a3,a3,848
	mul	s6,a5,s8
	li	a5,-1
	srli	t2,a5,32
.L98:
	mv	a6,s0
	mv	a1,a3
	li	a5,0
.L105:
	slli	a4,a5,6
	mv	a0,a5
	add	a4,s3,a4
	mv	a5,a1
	li	a3,0
.L102:
	ld	a2,8(sp)
	sd	s1,328(sp)
	sd	zero,376(sp)
	mv	t5,a0
	sd	zero,384(sp)
	mv	t0,a3
	add	a2,a2,a3
	sd	zero,392(sp)
	sd	zero,400(sp)
	mv	ra,a4
	sd	zero,408(sp)
	mv	s1,a5
	sd	zero,416(sp)
	li	a1,0
	sd	zero,424(sp)
	sd	zero,432(sp)
	sd	s5,336(sp)
.L99:
	lb	a5,16(a2)
	add	t3,a1,a6
	addi	t6,sp,376
	sw	a5,64(sp)
	lb	a5,0(a2)
	sw	a5,248(sp)
	lb	a5,32(a2)
	sw	a5,96(sp)
	lb	a5,48(a2)
	sw	a5,128(sp)
	lb	a5,64(a2)
	sw	a5,160(sp)
	lb	a5,80(a2)
	sw	a5,192(sp)
	lb	a5,96(a2)
	sw	a5,224(sp)
	lb	a5,1(a2)
	sw	a5,40(sp)
	lb	a5,17(a2)
	sw	a5,72(sp)
	lb	a5,33(a2)
	sw	a5,104(sp)
	lb	a5,49(a2)
	sw	a5,136(sp)
	lb	a5,65(a2)
	sw	a5,168(sp)
	lb	a5,81(a2)
	sw	a5,200(sp)
	lb	a5,97(a2)
	sw	a5,232(sp)
	lb	a5,2(a2)
	sw	a5,48(sp)
	lb	a5,18(a2)
	sw	a5,80(sp)
	lb	a5,34(a2)
	lb	a4,112(a2)
	sd	a1,16(sp)
	lb	s5,99(a2)
	sd	a2,24(sp)
	sw	a5,112(sp)
	lb	a5,50(a2)
	lb	a0,114(a2)
	sd	a6,32(sp)
	lb	a3,115(a2)
	sw	a4,256(sp)
	sw	a5,144(sp)
	lb	a5,66(a2)
	sw	a5,176(sp)
	lb	a5,82(a2)
	sw	a5,208(sp)
	lb	a5,98(a2)
	sw	a5,240(sp)
	lb	a5,3(a2)
	sw	a5,56(sp)
	lb	a5,19(a2)
	sw	a5,88(sp)
	lb	a5,35(a2)
	sw	a5,120(sp)
	lb	a5,51(a2)
	sw	a5,152(sp)
	lb	a5,67(a2)
	sw	a5,184(sp)
	lb	a5,83(a2)
	sw	a5,216(sp)
	lb	a5,113(a2)
	sw	a5,264(sp)
.L100:
	lb	s9,0(t3)
	addi	t3,t3,16
	lb	s8,-15(t3)
	addi	t6,t6,16
	lw	a2,248(sp)
	lw	a5,72(sp)
	lw	a4,80(sp)
	mulw	s10,a2,s9
	lw	a2,64(sp)
	mulw	a1,a5,s8
	lw	a5,48(sp)
	lb	a7,-14(t3)
	mulw	s11,a2,s8
	lw	a2,40(sp)
	mulw	a5,a5,s9
	lb	t1,-12(t3)
	sw	a1,280(sp)
	lb	a6,-11(t3)
	mulw	a2,a2,s9
	lb	a1,-10(t3)
	addw	s11,s11,s10
	lw	s10,88(sp)
	sw	a5,288(sp)
	mulw	a5,a4,s8
	lw	a4,56(sp)
	sw	a2,272(sp)
	mulw	s8,s10,s8
	lw	s10,272(sp)
	sw	a5,300(sp)
	lw	a5,280(sp)
	mulw	s9,a4,s9
	lw	a4,-8(t6)
	lb	t4,-13(t3)
	addw	s10,s10,a5
	lw	a5,104(sp)
	sd	a4,304(sp)
	lw	a4,-4(t6)
	sw	s10,272(sp)
	lb	a2,-9(t3)
	mulw	a5,a5,a7
	lw	s10,96(sp)
	sd	a4,312(sp)
	lw	a4,300(sp)
	addw	s8,s9,s8
	mulw	s10,s10,a7
	sw	a5,280(sp)
	lw	a5,288(sp)
	addw	a5,a5,a4
	addw	s10,s10,s11
	sw	a5,288(sp)
	lw	a5,112(sp)
	lw	a4,120(sp)
	lw	s9,128(sp)
	mulw	a5,a5,a7
	lw	s11,136(sp)
	mulw	a7,a4,a7
	lw	a4,280(sp)
	mulw	s9,s9,t4
	mulw	s11,s11,t4
	sw	a5,300(sp)
	lw	a5,-16(t6)
	addw	a7,a7,s8
	lw	s8,160(sp)
	addw	s9,s9,s10
	lw	s10,168(sp)
	sd	a5,320(sp)
	lw	a5,272(sp)
	mulw	s8,s8,t1
	mulw	s10,s10,t1
	addw	a5,a4,a5
	lw	a4,144(sp)
	sw	a5,272(sp)
	lw	a5,288(sp)
	addw	s8,s8,s9
	lw	s9,200(sp)
	mulw	a4,a4,t4
	mulw	s9,s9,a6
	sw	a4,280(sp)
	lw	a4,300(sp)
	addw	a5,a4,a5
	lw	a4,152(sp)
	mulw	t4,a4,t4
	mv	a4,t4
	lw	t4,272(sp)
	addw	a7,a4,a7
	addw	s11,s11,t4
	lw	t4,176(sp)
	addw	s10,s10,s11
	lw	s11,208(sp)
	addw	s9,s9,s10
	mulw	s10,s5,a1
	mulw	t4,t4,t1
	mulw	s11,s11,a6
	sw	t4,272(sp)
	lw	t4,280(sp)
	addw	t4,t4,a5
	lw	a5,184(sp)
	mulw	a5,a5,t1
	lw	t1,192(sp)
	mulw	t1,t1,a6
	addw	a7,a5,a7
	mv	a4,t1
	lw	t1,272(sp)
	addw	s8,a4,s8
	mv	a4,s10
	addw	t1,t1,t4
	lw	t4,216(sp)
	addw	s10,s11,t1
	mulw	s11,a0,a2
	mulw	t4,t4,a6
	lw	a6,224(sp)
	mulw	a6,a6,a1
	addw	a7,t4,a7
	mulw	t4,a3,a2
	addw	a7,a4,a7
	mv	a5,a6
	lw	a6,-12(t6)
	addw	s8,a5,s8
	addw	a7,t4,a7
	sd	a6,280(sp)
	lw	a6,232(sp)
	mulw	a6,a6,a1
	sw	a6,272(sp)
	lw	a6,240(sp)
	lw	a5,256(sp)
	ld	a4,304(sp)
	mulw	a6,a6,a1
	lw	a1,272(sp)
	mulw	t1,a5,a2
	ld	a5,320(sp)
	addw	s9,a1,s9
	lw	a1,264(sp)
	addw	s8,t1,s8
	mulw	a2,a1,a2
	addw	a1,a6,s10
	addw	s11,s11,a1
	ld	a6,280(sp)
	addw	s10,s11,a4
	ld	a4,312(sp)
	addw	s8,s8,a5
	and	s10,t2,s10
	addw	s9,a2,s9
	and	s8,t2,s8
	addw	a7,a7,a4
	addw	s9,s9,a6
	slli	a7,a7,32
	slli	s9,s9,32
	or	s10,s10,a7
	or	a7,s8,s9
	sd	s10,-8(t6)
	addi	a5,sp,440
	sd	a7,-16(t6)
	bne	t6,a5,.L100
	ld	a2,24(sp)
	li	a5,8
	ld	a1,16(sp)
	ld	a6,32(sp)
	lw	a7,376(sp)
	addi	a2,a2,128
	beq	a1,a5,.L101
	li	a1,8
	j	.L99
.L101:
	and	a2,a7,t2
	lwu	a7,380(sp)
	addi	a4,ra,16
	lwu	a1,384(sp)
	lwu	t1,388(sp)
	addi	a3,t0,4
	slli	a7,a7,32
	mv	a5,s1
	or	a2,a2,a7
	and	a1,a1,t2
	sd	a2,-16(a4)
	ld	a2,392(sp)
	slli	t1,t1,32
	ld	s5,336(sp)
	or	a1,a1,t1
	ld	s1,328(sp)
	sd	a2,48(a4)
	ld	a2,400(sp)
	sd	a1,-8(a4)
	mv	a0,t5
	sd	a2,56(a4)
	ld	a2,408(sp)
	sd	a2,112(a4)
	ld	a2,416(sp)
	sd	a2,120(a4)
	ld	a2,424(sp)
	sd	a2,176(a4)
	ld	a2,432(sp)
	sd	a2,184(a4)
	li	a2,16
	bne	a3,a2,.L102
	mv	a1,a5
	addi	a5,t5,4
	addi	a6,a6,64
	bne	a5,a3,.L105
	addiw	a3,a1,-1
	bne	a3,zero,.L98
	addi	a1,sp,360
	li	a0,4
	call	clock_gettime
	li	s9,1000001536
	ld	a5,360(sp)
	addi	s9,s9,-1536
	ld	s8,368(sp)
	mv	a3,s3
	mv	a2,s1
	li	a1,16
	mul	a5,a5,s9
	li	a0,16
	sub	s5,a5,s5
	call	Test_Logical
	add	a5,s8,s5
	lui	a4,%hi(.LC11)
	sub	a5,a5,s6
	fld	fa5,%lo(.LC11)(a4)
	fcvt.d.lu	fa4,a5
	lui	a5,%hi(.LC14)
	lui	a2,%hi(.LC15)
	addi	a4,a5,%lo(.LC14)
	addi	a2,a2,%lo(.LC15)
	lui	a5,%hi(.LC13)
	fdiv.d	fa5,fa4,fa5
	addi	a1,a5,%lo(.LC13)
	li	a0,2
	fmv.x.d	a3,fa5
	call	__printf_chk
	addi	a1,sp,360
	li	a0,4
	call	clock_gettime
	ld	s5,368(sp)
	li	a5,-1
	srli	a5,a5,32
	sd	a5,328(sp)
	ld	a5,360(sp)
	li	a2,49152
	mv	a6,s7
	addi	a2,a2,848
	mul	s6,a5,s9
.L106:
	li	a0,0
	li	a7,64
	li	t1,0
.L112:
	slli	a5,a0,7
	li	a3,0
	add	a4,s4,a5
	mv	a5,a2
.L109:
	slli	a2,a3,5
	mv	t0,s2
	add	a2,s2,a2
	sd	s4,344(sp)
	sd	zero,376(sp)
	mv	s4,s5
	sd	zero,384(sp)
	mv	a1,t1
	sd	zero,392(sp)
	mv	ra,a3
	sd	zero,400(sp)
	mv	s2,a4
	sd	zero,408(sp)
	mv	s5,t1
	sd	zero,416(sp)
	mv	s7,a0
	sd	zero,424(sp)
	mv	s8,a5
	sd	zero,432(sp)
.L108:
	lb	a5,0(a2)
	add	t5,a6,a1
	addi	t2,sp,376
	sd	a5,48(sp)
	lb	a5,1(a2)
	sd	a5,56(sp)
	lb	a5,2(a2)
	sd	a5,64(sp)
	lb	a5,3(a2)
	sd	a5,72(sp)
	lb	a5,4(a2)
	sd	a5,80(sp)
	lb	a5,5(a2)
	sd	a5,88(sp)
	lb	a5,6(a2)
	sd	a5,96(sp)
	lb	a5,7(a2)
	sd	a5,104(sp)
	lb	a5,8(a2)
	sd	a5,112(sp)
	lb	a5,9(a2)
	sd	a5,120(sp)
	lb	a5,10(a2)
	sd	a5,128(sp)
	lb	a5,11(a2)
	sd	a5,136(sp)
	lb	a5,12(a2)
	sd	a5,144(sp)
	lb	a5,13(a2)
	sd	a5,152(sp)
	lb	a5,14(a2)
	sd	a5,160(sp)
	lb	a5,15(a2)
	sd	a5,168(sp)
	lb	a5,16(a2)
	lb	a4,30(a2)
	sd	a6,16(sp)
	sd	a2,24(sp)
	lb	t1,27(a2)
	sd	a5,176(sp)
	lb	a5,17(a2)
	sd	a4,264(sp)
	lb	a0,28(a2)
	sd	a1,32(sp)
	lb	a3,29(a2)
	sd	a5,184(sp)
	lb	a5,18(a2)
	sd	a5,192(sp)
	lb	a5,19(a2)
	sd	a5,200(sp)
	lb	a5,20(a2)
	sd	a5,208(sp)
	lb	a5,21(a2)
	sd	a5,216(sp)
	lb	a5,22(a2)
	sd	a5,224(sp)
	lb	a5,23(a2)
	sd	a5,232(sp)
	lb	a5,24(a2)
	sd	a5,240(sp)
	lb	a5,25(a2)
	sd	a5,248(sp)
	lb	a5,26(a2)
	sd	a5,256(sp)
	lb	a5,31(a2)
	sd	a5,272(sp)
	sd	a7,40(sp)
.L107:
	lb	s9,0(t5)
	addi	t5,t5,8
	lb	t4,-7(t5)
	addi	t2,t2,16
	ld	a2,48(sp)
	ld	a5,120(sp)
	ld	a4,184(sp)
	mulw	s11,s9,a2
	ld	a2,56(sp)
	mulw	a1,t4,a5
	ld	a5,176(sp)
	lb	t3,-6(t5)
	mulw	s10,t4,a2
	ld	a2,112(sp)
	mulw	a5,s9,a5
	lb	a7,-4(t5)
	sw	a1,288(sp)
	lb	a6,-3(t5)
	mulw	a2,s9,a2
	lb	a1,-2(t5)
	addw	s11,s11,s10
	ld	s10,248(sp)
	sw	a5,300(sp)
	mulw	a5,t4,a4
	ld	a4,240(sp)
	sw	a2,280(sp)
	mulw	t4,t4,s10
	lw	s10,280(sp)
	sw	a5,304(sp)
	lw	a5,288(sp)
	mulw	s9,s9,a4
	lw	a4,-8(t2)
	lb	t6,-5(t5)
	addw	s10,s10,a5
	ld	a5,128(sp)
	sd	a4,312(sp)
	lw	a4,-4(t2)
	sw	s10,280(sp)
	lb	a2,-1(t5)
	mulw	a5,t3,a5
	ld	s10,64(sp)
	sd	a4,320(sp)
	lw	a4,304(sp)
	addw	t4,s9,t4
	mulw	s10,t3,s10
	sw	a5,288(sp)
	lw	a5,300(sp)
	addw	a5,a5,a4
	addw	s10,s10,s11
	sw	a5,300(sp)
	ld	a5,192(sp)
	ld	a4,256(sp)
	ld	s9,72(sp)
	mulw	a5,t3,a5
	ld	s11,136(sp)
	mulw	t3,t3,a4
	lw	a4,288(sp)
	mulw	s9,t6,s9
	mulw	s11,t6,s11
	sw	a5,304(sp)
	lw	a5,-16(t2)
	addw	t3,t3,t4
	ld	t4,80(sp)
	addw	s9,s9,s10
	ld	s10,144(sp)
	sd	a5,336(sp)
	lw	a5,280(sp)
	mulw	t4,a7,t4
	mulw	s10,a7,s10
	addw	a5,a4,a5
	ld	a4,200(sp)
	sw	a5,280(sp)
	lw	a5,300(sp)
	addw	t4,t4,s9
	ld	s9,152(sp)
	mulw	a4,t6,a4
	mulw	t6,t6,t1
	mulw	s9,a6,s9
	sw	a4,288(sp)
	lw	a4,304(sp)
	addw	a5,a4,a5
	mv	a4,t6
	lw	t6,280(sp)
	addw	t3,a4,t3
	addw	s11,s11,t6
	ld	t6,208(sp)
	addw	s10,s10,s11
	ld	s11,216(sp)
	addw	s9,s9,s10
	mulw	t6,a7,t6
	mulw	s11,a6,s11
	sw	t6,280(sp)
	lw	t6,288(sp)
	addw	t6,t6,a5
	mulw	a5,a7,a0
	ld	a7,88(sp)
	mulw	a7,a6,a7
	addw	t3,a5,t3
	mv	a4,a7
	lw	a7,280(sp)
	addw	t4,a4,t4
	ld	a4,264(sp)
	addw	a7,a7,t6
	mulw	t6,a6,a3
	ld	a6,96(sp)
	mulw	s10,a1,a4
	mulw	a6,a1,a6
	addw	t3,t6,t3
	mv	a4,s10
	addw	s10,s11,a7
	ld	a7,232(sp)
	addw	t3,a4,t3
	mv	a5,a6
	lw	a6,-12(t2)
	mulw	s11,a2,a7
	addw	t4,a5,t4
	sd	a6,288(sp)
	ld	a6,160(sp)
	mulw	a6,a1,a6
	sw	a6,280(sp)
	ld	a6,224(sp)
	mulw	a6,a1,a6
	ld	a1,272(sp)
	ld	a7,104(sp)
	ld	a4,312(sp)
	mulw	t6,a2,a1
	lw	a1,280(sp)
	mulw	a7,a2,a7
	ld	a5,336(sp)
	addw	s9,a1,s9
	ld	a1,168(sp)
	addw	t3,t6,t3
	addw	t4,a7,t4
	mulw	a2,a2,a1
	addw	a1,a6,s10
	addw	s11,s11,a1
	ld	a6,288(sp)
	addw	s10,s11,a4
	ld	a4,320(sp)
	addw	t4,t4,a5
	addi	a5,sp,440
	addw	s9,a2,s9
	ld	a2,328(sp)
	addw	t3,t3,a4
	addw	s9,s9,a6
	slli	t3,t3,32
	slli	s9,s9,32
	and	s10,a2,s10
	and	t4,a2,t4
	or	s10,s10,t3
	or	t3,t4,s9
	sd	s10,-8(t2)
	sd	t3,-16(t2)
	bne	t2,a5,.L107
	ld	a1,32(sp)
	ld	a2,24(sp)
	ld	a7,40(sp)
	addi	a1,a1,32
	ld	a6,16(sp)
	ld	t4,376(sp)
	addi	a2,a2,128
	ld	t3,384(sp)
	bne	a1,a7,.L108
	ld	a2,400(sp)
	mv	a4,s2
	sd	t4,0(a4)
	addi	a4,a4,16
	sd	t3,-8(a4)
	addi	a3,ra,1
	sd	a2,56(a4)
	ld	a2,392(sp)
	mv	t1,s5
	mv	s2,t0
	mv	s5,s4
	mv	a0,s7
	sd	a2,48(a4)
	ld	a2,416(sp)
	ld	s4,344(sp)
	mv	a5,s8
	sd	a2,120(a4)
	ld	a2,408(sp)
	sd	a2,112(a4)
	ld	a2,432(sp)
	sd	a2,184(a4)
	ld	a2,424(sp)
	sd	a2,176(a4)
	li	a2,4
	bne	a3,a2,.L109
	addi	a0,s7,2
	mv	a2,s8
	addi	t1,t1,64
	addi	a7,a1,64
	li	a5,8
	bne	a0,a5,.L112
	addiw	a2,s8,-1
	bne	a2,zero,.L106
	addi	a1,sp,360
	mv	s7,a6
	li	a0,4
	call	clock_gettime
	ld	a5,360(sp)
	li	a4,1000001536
	addi	a4,a4,-1536
	ld	s8,368(sp)
	mv	a3,s4
	mv	a2,s1
	mul	a5,a5,a4
	li	a1,16
	li	a0,16
	sub	s5,a5,s5
	call	Test_Logical
	add	a5,s8,s5
	lui	a4,%hi(.LC11)
	sub	a5,a5,s6
	fld	fa5,%lo(.LC11)(a4)
	fcvt.d.lu	fa4,a5
	lui	a5,%hi(.LC14)
	lui	a2,%hi(.LC16)
	addi	a4,a5,%lo(.LC14)
	addi	a2,a2,%lo(.LC16)
	lui	a5,%hi(.LC13)
	fdiv.d	fa5,fa4,fa5
	addi	a1,a5,%lo(.LC13)
	li	a0,2
	fmv.x.d	a3,fa5
	call	__printf_chk
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	puts
	mv	a0,s0
	call	free
	ld	a0,8(sp)
	call	free
	mv	a0,s1
	call	free
	mv	a0,s7
	call	free
	mv	a0,s2
	call	free
	mv	a0,s3
	call	free
	mv	a0,s4
	call	free
	lui	a5,%hi(__stack_chk_guard)
	ld	a4, 440(sp)
	ld	a5, %lo(__stack_chk_guard)(a5)
	xor	a5, a4, a5
	li	a4, 0
	bne	a5,zero,.L124
	ld	ra,552(sp)
	.cfi_remember_state
	.cfi_restore 1
	li	a0,0
	ld	s0,544(sp)
	.cfi_restore 8
	ld	s1,536(sp)
	.cfi_restore 9
	ld	s2,528(sp)
	.cfi_restore 18
	ld	s3,520(sp)
	.cfi_restore 19
	ld	s4,512(sp)
	.cfi_restore 20
	ld	s5,504(sp)
	.cfi_restore 21
	ld	s6,496(sp)
	.cfi_restore 22
	ld	s7,488(sp)
	.cfi_restore 23
	ld	s8,480(sp)
	.cfi_restore 24
	ld	s9,472(sp)
	.cfi_restore 25
	ld	s10,464(sp)
	.cfi_restore 26
	ld	s11,456(sp)
	.cfi_restore 27
	addi	sp,sp,560
	.cfi_def_cfa_offset 0
	jr	ra
.L124:
	.cfi_restore_state
	call	__stack_chk_fail
	.cfi_endproc
.LFE44:
	.size	main, .-main
	.section	.srodata.cst8,"aM",@progbits,8
	.align	3
.LC11:
	.word	0
	.word	1088973312
	.section	.rodata
	.align	3
	.set	.LANCHOR0,. + 0
	.type	__PRETTY_FUNCTION__.0, @object
	.size	__PRETTY_FUNCTION__.0, 13
__PRETTY_FUNCTION__.0:
	.string	"Test_Logical"
	.ident	"GCC: (Bianbu 13.2.0-23ubuntu4bb3) 13.2.0"
	.section	.note.GNU-stack,"",@progbits
