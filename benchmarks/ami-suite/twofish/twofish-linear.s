	.text
	.file	"twofish.c"
	.globl	twofish_key_schedule
	.p2align	2
	.type	twofish_key_schedule,@function
twofish_key_schedule:
	addi	sp, sp, -144
	sw	ra, 140(sp)
	sw	s0, 136(sp)
	sw	s1, 132(sp)
	sw	s2, 128(sp)
	sw	s3, 124(sp)
	sw	s4, 120(sp)
	sw	s5, 116(sp)
	sw	s6, 112(sp)
	sw	s7, 108(sp)
	sw	s8, 104(sp)
	sw	s9, 100(sp)
	sw	s10, 96(sp)
	sw	s11, 92(sp)
	beqz	a1, .LBB0_20
	li	a2, 0
	li	a3, 0
	lui	a4, %hi(POLY_TO_EXP)
	addi	a4, a4, %lo(POLY_TO_EXP)
	lui	a5, %hi(RS)
	addi	a5, a5, %lo(RS)
	lui	a6, 8
	addi	a6, a6, 129
	lui	a7, 16
	addi	a7, a7, -1
	lui	t0, %hi(EXP_TO_POLY)
	addi	t0, t0, %lo(EXP_TO_POLY)
	lui	t1, 262144
	addi	t1, t1, -4
	addi	t2, sp, 76
	j	.LBB0_3
.LBB0_2:
	addi	a3, a3, 1
	addi	a2, a2, 4
	beq	a1, a3, .LBB0_5
.LBB0_3:
	add	t3, a0, a3
	lbu	t3, 0(t3)
	beqz	t3, .LBB0_2
	andi	t4, a2, 28
	add	t4, t4, a5
	lbu	t5, 0(t4)
	add	t3, t3, a4
	lbu	t3, -1(t3)
	add	t5, t5, a4
	lbu	t5, -1(t5)
	lbu	t6, 1(t4)
	add	t5, t5, t3
	mul	s0, t5, a6
	srli	s0, s0, 23
	slli	s1, s0, 8
	sub	s0, s0, s1
	add	t5, t5, s0
	and	t5, t5, a7
	add	t5, t5, t0
	lb	t5, 0(t5)
	srli	s0, a3, 1
	and	s1, s0, t1
	add	s1, t2, s1
	lb	s2, 0(s1)
	add	t6, t6, a4
	lbu	t6, -1(t6)
	xor	t5, s2, t5
	add	t6, t6, t3
	mul	s2, t6, a6
	srli	s2, s2, 23
	slli	s3, s2, 8
	sub	s2, s2, s3
	lbu	s3, 2(t4)
	add	t6, t6, s2
	and	t6, t6, a7
	add	t6, t6, t0
	lb	t6, 0(t6)
	lb	s2, 1(s1)
	add	s3, s3, a4
	lbu	s3, -1(s3)
	lbu	t4, 3(t4)
	sb	t5, 0(s1)
	xor	t5, s2, t6
	add	t6, s3, t3
	mul	s2, t6, a6
	srli	s2, s2, 23
	slli	s3, s2, 8
	sub	s2, s2, s3
	add	t6, t6, s2
	and	t6, t6, a7
	add	t6, t6, t0
	lb	t6, 0(t6)
	lb	s2, 2(s1)
	add	t4, t4, a4
	lbu	t4, -1(t4)
	sb	t5, 1(s1)
	xor	t5, s2, t6
	sb	t5, 2(s1)
	add	t3, t4, t3
	mul	t4, t3, a6
	srli	t4, t4, 23
	slli	t5, t4, 8
	sub	t4, t4, t5
	add	t3, t3, t4
	and	t3, t3, a7
	add	t3, t3, t0
	lb	t3, 0(t3)
	ori	t4, s0, 3
	add	t4, t2, t4
	lb	t5, 0(t4)
	xor	t3, t5, t3
	sb	t3, 0(t4)
	j	.LBB0_2
.LBB0_5:
	li	a2, 16
	beq	a1, a2, .LBB0_12
	li	a2, 24
	beq	a1, a2, .LBB0_16
	li	a2, 32
	bne	a1, a2, .LBB0_20
	li	a1, 0
	lbu	a2, 76(sp)
	sw	a2, 72(sp)
	lbu	a3, 80(sp)
	lbu	a4, 84(sp)
	lbu	a5, 88(sp)
	lbu	a6, 77(sp)
	lbu	a7, 81(sp)
	lbu	t0, 85(sp)
	lbu	t1, 89(sp)
	lbu	t2, 78(sp)
	lbu	t3, 82(sp)
	lbu	t4, 86(sp)
	lbu	t5, 90(sp)
	lbu	t6, 79(sp)
	lbu	s0, 83(sp)
	lbu	s1, 87(sp)
	lbu	s2, 91(sp)
	lui	s3, %hi(Q1)
	addi	s3, s3, %lo(Q1)
	lui	s4, %hi(Q0)
	addi	s4, s4, %lo(Q0)
	lui	s5, %hi(MDS0)
	addi	s5, s5, %lo(MDS0)
	lui	s6, %hi(dummy)
	lui	s7, %hi(MDS1)
	addi	s7, s7, %lo(MDS1)
	lui	s8, %hi(MDS2)
	addi	s8, s8, %lo(MDS2)
	lui	s9, %hi(MDS3)
	addi	s9, s9, %lo(MDS3)
.LBB0_9:
	add	s11, a1, s3
	lb	s11, 0(s11)
	lw	a2, 72(sp)
	xor	ra, a2, s11
	andi	ra, ra, 255
	add	ra, ra, s3
	lbu	ra, 0(ra)
	xor	ra, a3, ra
	add	ra, ra, s4
	lbu	ra, 0(ra)
	add	s10, a1, s4
	lb	s10, 0(s10)
	xor	ra, a4, ra
	add	ra, ra, s4
	lbu	ra, 0(ra)
	xor	a2, a6, s10
	andi	a2, a2, 255
	add	a2, a2, s3
	lbu	a2, 0(a2)
	xor	ra, a5, ra
	xor	a2, a7, a2
	add	a2, a2, s3
	lbu	a2, 0(a2)
	slli	ra, ra, 2
	add	ra, ra, s5
	lw	ra, 0(ra)
	xor	a2, t0, a2
	add	a2, a2, s4
	lbu	a2, 0(a2)
	xor	s10, t2, s10
	andi	s10, s10, 255
	add	s10, s10, s4
	lbu	s10, 0(s10)
	sw	ra, %lo(dummy)(s6)
	xor	a2, t1, a2
	slli	a2, a2, 2
	xor	s10, t3, s10
	add	s10, s10, s4
	lbu	s10, 0(s10)
	xor	s11, t6, s11
	andi	s11, s11, 255
	add	s11, s11, s4
	lbu	s11, 0(s11)
	xor	s10, t4, s10
	add	s10, s10, s3
	lbu	s10, 0(s10)
	xor	s11, s0, s11
	add	s11, s11, s3
	lbu	s11, 0(s11)
	add	a2, a2, s7
	lw	a2, 0(a2)
	xor	s10, t5, s10
	xor	s11, s1, s11
	add	s11, s11, s3
	lbu	s11, 0(s11)
	slli	s10, s10, 2
	add	s10, s10, s8
	lw	s10, 0(s10)
	xor	s11, s2, s11
	slli	s11, s11, 2
	add	s11, s11, s9
	lw	s11, 0(s11)
	sw	a2, %lo(dummy)(s6)
	sw	s10, %lo(dummy)(s6)
	addi	a1, a1, 1
	sw	s11, %lo(dummy)(s6)
	li	a2, 256
	bne	a1, a2, .LBB0_9
	li	t5, 0
	lbu	a1, 24(a0)
	sw	a1, 72(sp)
	lbu	a1, 16(a0)
	sw	a1, 68(sp)
	lbu	a1, 8(a0)
	sw	a1, 64(sp)
	lbu	a1, 0(a0)
	sw	a1, 60(sp)
	lbu	a1, 25(a0)
	sw	a1, 56(sp)
	lbu	a1, 17(a0)
	sw	a1, 52(sp)
	lbu	a1, 9(a0)
	sw	a1, 48(sp)
	lbu	a1, 1(a0)
	sw	a1, 44(sp)
	lbu	a1, 26(a0)
	sw	a1, 40(sp)
	lbu	a1, 18(a0)
	sw	a1, 36(sp)
	lbu	a1, 10(a0)
	sw	a1, 32(sp)
	lbu	a1, 2(a0)
	sw	a1, 28(sp)
	lbu	a1, 27(a0)
	sw	a1, 24(sp)
	lbu	a1, 19(a0)
	sw	a1, 20(sp)
	lbu	a1, 11(a0)
	sw	a1, 16(sp)
	lbu	a1, 3(a0)
	sw	a1, 12(sp)
	lbu	a1, 28(a0)
	sw	a1, 8(sp)
	lbu	a1, 20(a0)
	sw	a1, 4(sp)
	lbu	a1, 12(a0)
	sw	a1, 0(sp)
	lbu	s5, 4(a0)
	lbu	s6, 29(a0)
	lbu	s7, 21(a0)
	lbu	s8, 13(a0)
	lbu	s9, 5(a0)
	lbu	s10, 30(a0)
	lbu	s11, 22(a0)
	lbu	ra, 14(a0)
	lbu	a1, 6(a0)
	lbu	a2, 31(a0)
	lbu	a3, 23(a0)
	lbu	a4, 15(a0)
	lbu	a0, 7(a0)
	lui	a5, %hi(Q1)
	addi	a5, a5, %lo(Q1)
	lui	a6, %hi(Q0)
	addi	a6, a6, %lo(Q0)
	lui	a7, %hi(MDS0)
	addi	a7, a7, %lo(MDS0)
	lui	t0, %hi(MDS1)
	addi	t0, t0, %lo(MDS1)
	lui	t1, %hi(MDS2)
	addi	t1, t1, %lo(MDS2)
	lui	t2, %hi(MDS3)
	addi	t2, t2, %lo(MDS3)
	lui	t3, %hi(dummy)
.LBB0_11:
	mv	t4, t5
	add	t5, t5, a5
	lb	s0, 0(t5)
	lw	t6, 72(sp)
	xor	t6, t6, s0
	andi	t6, t6, 255
	add	t6, t6, a5
	lbu	t6, 0(t6)
	lw	s1, 68(sp)
	xor	t6, s1, t6
	add	t6, t6, a6
	lbu	s1, 0(t6)
	add	t6, t4, a6
	lb	s2, 0(t6)
	lw	s3, 64(sp)
	xor	s1, s3, s1
	add	s1, s1, a6
	lbu	s1, 0(s1)
	lw	s3, 56(sp)
	xor	s3, s3, s2
	andi	s3, s3, 255
	add	s3, s3, a5
	lbu	s3, 0(s3)
	lw	s4, 60(sp)
	xor	s1, s4, s1
	slli	s1, s1, 2
	add	s1, s1, a7
	lw	s4, 52(sp)
	xor	s3, s4, s3
	add	s3, s3, a5
	lbu	s3, 0(s3)
	lw	s4, 40(sp)
	xor	s2, s4, s2
	andi	s2, s2, 255
	add	s2, s2, a6
	lbu	s2, 0(s2)
	lw	s4, 48(sp)
	xor	s3, s4, s3
	add	s3, s3, a6
	lbu	s3, 0(s3)
	lw	s4, 36(sp)
	xor	s2, s4, s2
	add	s2, s2, a6
	lbu	s2, 0(s2)
	lw	s1, 0(s1)
	lw	s4, 44(sp)
	xor	s3, s4, s3
	slli	s3, s3, 2
	lw	s4, 32(sp)
	xor	s2, s4, s2
	add	s2, s2, a5
	lbu	s2, 0(s2)
	lw	s4, 24(sp)
	xor	s0, s4, s0
	andi	s0, s0, 255
	add	s0, s0, a6
	lbu	s0, 0(s0)
	add	s3, s3, t0
	lw	s3, 0(s3)
	lw	s4, 28(sp)
	xor	s2, s4, s2
	lw	s4, 20(sp)
	xor	s0, s4, s0
	add	s0, s0, a5
	lbu	s0, 0(s0)
	slli	s2, s2, 2
	add	s2, s2, t1
	lw	s2, 0(s2)
	lw	s4, 16(sp)
	xor	s0, s4, s0
	add	s0, s0, a5
	lbu	s0, 0(s0)
	xor	s1, s3, s1
	lb	s3, 1(t5)
	xor	t5, s1, s2
	lw	s1, 12(sp)
	xor	s0, s1, s0
	slli	s0, s0, 2
	lw	s1, 8(sp)
	xor	s1, s1, s3
	andi	s1, s1, 255
	add	s1, s1, a5
	lbu	s1, 0(s1)
	add	s0, s0, t2
	lw	s0, 0(s0)
	lb	t6, 1(t6)
	lw	s2, 4(sp)
	xor	s1, s2, s1
	add	s1, s1, a6
	lbu	s1, 0(s1)
	xor	s2, s6, t6
	andi	s2, s2, 255
	add	s2, s2, a5
	lbu	s2, 0(s2)
	lw	s4, 0(sp)
	xor	s1, s4, s1
	add	s1, s1, a6
	lbu	s1, 0(s1)
	xor	s2, s7, s2
	add	s2, s2, a5
	lbu	s2, 0(s2)
	xor	s1, s5, s1
	slli	s1, s1, 2
	add	s1, s1, a7
	xor	s2, s8, s2
	add	s2, s2, a6
	lbu	s2, 0(s2)
	xor	t6, s10, t6
	andi	t6, t6, 255
	add	t6, t6, a6
	lbu	t6, 0(t6)
	lw	s1, 0(s1)
	xor	s2, s9, s2
	slli	s2, s2, 2
	xor	t6, s11, t6
	add	t6, t6, a6
	lbu	t6, 0(t6)
	xor	s3, a2, s3
	andi	s3, s3, 255
	add	s3, s3, a6
	lbu	s3, 0(s3)
	xor	t6, ra, t6
	add	t6, t6, a5
	lbu	t6, 0(t6)
	xor	s3, a3, s3
	add	s3, s3, a5
	lbu	s3, 0(s3)
	add	s2, s2, t0
	lw	s2, 0(s2)
	xor	t6, a1, t6
	xor	s3, a4, s3
	add	s3, s3, a5
	lbu	s3, 0(s3)
	slli	t6, t6, 2
	add	t6, t6, t1
	lw	t6, 0(t6)
	xor	s3, a0, s3
	slli	s3, s3, 2
	add	s3, s3, t2
	lw	s3, 0(s3)
	xor	t5, t5, s0
	xor	s0, s2, s1
	xor	t6, s0, t6
	xor	t6, t6, s3
	srli	s0, t6, 24
	slli	t6, t6, 8
	or	t6, t6, s0
	add	t5, t6, t5
	add	t6, t5, t6
	sw	t5, %lo(dummy)(t3)
	srli	t5, t6, 23
	slli	t6, t6, 9
	or	t5, t6, t5
	sw	t5, %lo(dummy)(t3)
	addi	t5, t4, 2
	li	t6, 38
	bltu	t4, t6, .LBB0_11
	j	.LBB0_20
.LBB0_12:
	li	a1, 0
	lbu	a2, 76(sp)
	lbu	a3, 80(sp)
	lbu	a4, 77(sp)
	lbu	a5, 81(sp)
	lbu	a6, 78(sp)
	lbu	a7, 82(sp)
	lbu	t0, 79(sp)
	lbu	t1, 83(sp)
	lui	t2, %hi(Q0)
	addi	t2, t2, %lo(Q0)
	lui	t3, %hi(MDS0)
	addi	t3, t3, %lo(MDS0)
	lui	t4, %hi(dummy)
	lui	t5, %hi(Q1)
	addi	t5, t5, %lo(Q1)
	lui	t6, %hi(MDS1)
	addi	t6, t6, %lo(MDS1)
	lui	s0, %hi(MDS2)
	addi	s0, s0, %lo(MDS2)
	lui	s1, %hi(MDS3)
	addi	s1, s1, %lo(MDS3)
	li	s2, 256
.LBB0_13:
	add	s3, a1, t2
	lb	s3, 0(s3)
	xor	s4, a2, s3
	andi	s4, s4, 255
	add	s4, s4, t2
	lbu	s4, 0(s4)
	xor	s4, a3, s4
	add	s5, a1, t5
	lb	s5, 0(s5)
	slli	s4, s4, 2
	add	s4, s4, t3
	lw	s4, 0(s4)
	xor	s6, a4, s5
	andi	s6, s6, 255
	add	s6, s6, t2
	lbu	s6, 0(s6)
	sw	s4, %lo(dummy)(t4)
	xor	s4, a5, s6
	xor	s3, a6, s3
	andi	s3, s3, 255
	add	s3, s3, t5
	lbu	s3, 0(s3)
	slli	s4, s4, 2
	add	s4, s4, t6
	lw	s4, 0(s4)
	xor	s3, a7, s3
	xor	s5, t0, s5
	andi	s5, s5, 255
	add	s5, s5, t5
	lbu	s5, 0(s5)
	slli	s3, s3, 2
	add	s3, s3, s0
	lw	s3, 0(s3)
	xor	s5, t1, s5
	slli	s5, s5, 2
	add	s5, s5, s1
	lw	s5, 0(s5)
	sw	s4, %lo(dummy)(t4)
	sw	s3, %lo(dummy)(t4)
	addi	a1, a1, 1
	sw	s5, %lo(dummy)(t4)
	bne	a1, s2, .LBB0_13
	li	s10, 0
	lbu	a1, 8(a0)
	sw	a1, 72(sp)
	lbu	a1, 0(a0)
	sw	a1, 68(sp)
	lbu	a3, 9(a0)
	lbu	a4, 1(a0)
	lbu	a5, 10(a0)
	lbu	a6, 2(a0)
	lbu	a7, 11(a0)
	lbu	t0, 3(a0)
	lbu	t1, 12(a0)
	lbu	t2, 4(a0)
	lbu	t3, 13(a0)
	lbu	t4, 5(a0)
	lbu	t5, 14(a0)
	lbu	t6, 6(a0)
	lbu	s0, 15(a0)
	lbu	a0, 7(a0)
	lui	s1, %hi(Q0)
	addi	s1, s1, %lo(Q0)
	lui	s2, %hi(MDS0)
	addi	s2, s2, %lo(MDS0)
	lui	s3, %hi(Q1)
	addi	s3, s3, %lo(Q1)
	lui	s4, %hi(MDS1)
	addi	s4, s4, %lo(MDS1)
	lui	s5, %hi(MDS2)
	addi	s5, s5, %lo(MDS2)
	lui	s6, %hi(MDS3)
	addi	s6, s6, %lo(MDS3)
	lui	s7, %hi(dummy)
.LBB0_15:
	mv	s9, s10
	add	s10, s10, s1
	lb	s11, 0(s10)
	lw	a1, 72(sp)
	xor	ra, a1, s11
	andi	ra, ra, 255
	add	ra, ra, s1
	lbu	ra, 0(ra)
	add	s8, s9, s3
	lb	a1, 0(s8)
	lw	a2, 68(sp)
	xor	ra, a2, ra
	xor	a2, a3, a1
	andi	a2, a2, 255
	add	a2, a2, s1
	lbu	a2, 0(a2)
	slli	ra, ra, 2
	add	ra, ra, s2
	lw	ra, 0(ra)
	xor	a2, a4, a2
	xor	s11, a5, s11
	andi	s11, s11, 255
	add	s11, s11, s3
	lbu	s11, 0(s11)
	slli	a2, a2, 2
	add	a2, a2, s4
	lw	a2, 0(a2)
	xor	s11, a6, s11
	slli	s11, s11, 2
	add	s11, s11, s5
	lw	s11, 0(s11)
	xor	a1, a7, a1
	andi	a1, a1, 255
	add	a1, a1, s3
	lbu	a1, 0(a1)
	xor	a2, a2, ra
	lb	s10, 1(s10)
	xor	a2, a2, s11
	xor	a1, t0, a1
	slli	a1, a1, 2
	xor	s11, t1, s10
	andi	s11, s11, 255
	add	s11, s11, s1
	lbu	s11, 0(s11)
	lb	s8, 1(s8)
	add	a1, a1, s6
	lw	a1, 0(a1)
	xor	s11, t2, s11
	xor	ra, t3, s8
	andi	ra, ra, 255
	add	ra, ra, s1
	lbu	ra, 0(ra)
	slli	s11, s11, 2
	add	s11, s11, s2
	lw	s11, 0(s11)
	xor	ra, t4, ra
	xor	s10, t5, s10
	andi	s10, s10, 255
	add	s10, s10, s3
	lbu	s10, 0(s10)
	slli	ra, ra, 2
	add	ra, ra, s4
	lw	ra, 0(ra)
	xor	s10, t6, s10
	xor	s8, s0, s8
	andi	s8, s8, 255
	add	s8, s8, s3
	lbu	s8, 0(s8)
	slli	s10, s10, 2
	add	s10, s10, s5
	lw	s10, 0(s10)
	xor	s8, a0, s8
	slli	s8, s8, 2
	add	s8, s8, s6
	lw	s8, 0(s8)
	xor	a1, a2, a1
	xor	a2, ra, s11
	xor	a2, a2, s10
	xor	a2, a2, s8
	srli	s8, a2, 24
	slli	a2, a2, 8
	or	a2, a2, s8
	add	a1, a2, a1
	add	a2, a1, a2
	sw	a1, %lo(dummy)(s7)
	srli	a1, a2, 23
	slli	a2, a2, 9
	or	a1, a2, a1
	sw	a1, %lo(dummy)(s7)
	addi	s10, s9, 2
	li	a1, 38
	bltu	s9, a1, .LBB0_15
	j	.LBB0_20
.LBB0_16:
	li	a1, 0
	lbu	a2, 76(sp)
	lbu	a3, 80(sp)
	lbu	a4, 84(sp)
	lbu	a5, 77(sp)
	lbu	a6, 81(sp)
	lbu	a7, 85(sp)
	lbu	t0, 78(sp)
	lbu	t1, 82(sp)
	lbu	t2, 86(sp)
	lbu	t3, 79(sp)
	lbu	t4, 83(sp)
	lbu	t5, 87(sp)
	lui	t6, %hi(Q1)
	addi	t6, t6, %lo(Q1)
	lui	s0, %hi(Q0)
	addi	s0, s0, %lo(Q0)
	lui	s1, %hi(MDS0)
	addi	s1, s1, %lo(MDS0)
	lui	s2, %hi(dummy)
	lui	s3, %hi(MDS1)
	addi	s3, s3, %lo(MDS1)
	lui	s4, %hi(MDS2)
	addi	s4, s4, %lo(MDS2)
	lui	s5, %hi(MDS3)
	addi	s5, s5, %lo(MDS3)
	li	s6, 256
.LBB0_17:
	add	s7, a1, t6
	lb	s7, 0(s7)
	xor	s8, a2, s7
	andi	s8, s8, 255
	add	s8, s8, s0
	lbu	s8, 0(s8)
	xor	s8, a3, s8
	add	s8, s8, s0
	lbu	s8, 0(s8)
	xor	s8, a4, s8
	slli	s8, s8, 2
	add	s8, s8, s1
	xor	s7, a5, s7
	andi	s7, s7, 255
	add	s7, s7, t6
	lbu	s7, 0(s7)
	lw	s8, 0(s8)
	add	s9, a1, s0
	lb	s9, 0(s9)
	xor	s7, a6, s7
	add	s7, s7, s0
	lbu	s7, 0(s7)
	xor	s10, t0, s9
	andi	s10, s10, 255
	add	s10, s10, s0
	lbu	s10, 0(s10)
	sw	s8, %lo(dummy)(s2)
	xor	s7, a7, s7
	slli	s7, s7, 2
	xor	s8, t1, s10
	add	s8, s8, t6
	lbu	s8, 0(s8)
	xor	s9, t3, s9
	andi	s9, s9, 255
	add	s9, s9, t6
	lbu	s9, 0(s9)
	add	s7, s7, s3
	lw	s7, 0(s7)
	xor	s8, t2, s8
	xor	s9, t4, s9
	add	s9, s9, t6
	lbu	s9, 0(s9)
	slli	s8, s8, 2
	add	s8, s8, s4
	lw	s8, 0(s8)
	xor	s9, t5, s9
	slli	s9, s9, 2
	add	s9, s9, s5
	lw	s9, 0(s9)
	sw	s7, %lo(dummy)(s2)
	sw	s8, %lo(dummy)(s2)
	addi	a1, a1, 1
	sw	s9, %lo(dummy)(s2)
	bne	a1, s6, .LBB0_17
	li	a4, 0
	lbu	a1, 16(a0)
	sw	a1, 72(sp)
	lbu	a1, 8(a0)
	sw	a1, 68(sp)
	lbu	a1, 0(a0)
	sw	a1, 64(sp)
	lbu	a1, 17(a0)
	sw	a1, 60(sp)
	lbu	a1, 9(a0)
	sw	a1, 56(sp)
	lbu	a1, 1(a0)
	sw	a1, 52(sp)
	lbu	a1, 18(a0)
	sw	a1, 48(sp)
	lbu	a1, 10(a0)
	sw	a1, 44(sp)
	lbu	a1, 2(a0)
	sw	a1, 40(sp)
	lbu	a1, 19(a0)
	sw	a1, 36(sp)
	lbu	a1, 11(a0)
	sw	a1, 32(sp)
	lbu	t4, 3(a0)
	lbu	t5, 20(a0)
	lbu	t6, 12(a0)
	lbu	s0, 4(a0)
	lbu	s1, 21(a0)
	lbu	s2, 13(a0)
	lbu	s3, 5(a0)
	lbu	s4, 22(a0)
	lbu	s5, 14(a0)
	lbu	s6, 6(a0)
	lbu	s7, 23(a0)
	lbu	s8, 15(a0)
	lbu	a0, 7(a0)
	lui	a1, %hi(Q1)
	addi	s9, a1, %lo(Q1)
	lui	a1, %hi(Q0)
	addi	s10, a1, %lo(Q0)
	lui	a1, %hi(MDS0)
	addi	s11, a1, %lo(MDS0)
	lui	a1, %hi(MDS1)
	addi	ra, a1, %lo(MDS1)
	lui	a1, %hi(MDS2)
	addi	a1, a1, %lo(MDS2)
	lui	a2, %hi(MDS3)
	addi	a2, a2, %lo(MDS3)
	lui	a3, %hi(dummy)
.LBB0_19:
	mv	a5, a4
	add	a4, a4, s9
	lb	a6, 0(a4)
	lw	a7, 72(sp)
	xor	a7, a7, a6
	andi	a7, a7, 255
	add	a7, a7, s10
	lbu	a7, 0(a7)
	lw	t0, 68(sp)
	xor	a7, t0, a7
	add	a7, a7, s10
	lbu	a7, 0(a7)
	lw	t0, 64(sp)
	xor	a7, t0, a7
	lw	t0, 60(sp)
	xor	a6, t0, a6
	andi	a6, a6, 255
	add	a6, a6, s9
	lbu	a6, 0(a6)
	slli	a7, a7, 2
	add	t0, a5, s10
	lb	t1, 0(t0)
	lw	t2, 56(sp)
	xor	a6, t2, a6
	add	a6, a6, s10
	lbu	a6, 0(a6)
	lw	t2, 48(sp)
	xor	t2, t2, t1
	andi	t2, t2, 255
	add	t2, t2, s10
	lbu	t2, 0(t2)
	add	a7, a7, s11
	lw	a7, 0(a7)
	lw	t3, 52(sp)
	xor	a6, t3, a6
	lw	t3, 44(sp)
	xor	t2, t3, t2
	add	t2, t2, s9
	lbu	t2, 0(t2)
	slli	a6, a6, 2
	add	a6, a6, ra
	lw	a6, 0(a6)
	lw	t3, 40(sp)
	xor	t2, t3, t2
	slli	t2, t2, 2
	lw	t3, 36(sp)
	xor	t1, t3, t1
	andi	t1, t1, 255
	add	t1, t1, s9
	lbu	t1, 0(t1)
	add	t2, t2, a1
	lw	t2, 0(t2)
	lb	a4, 1(a4)
	lw	t3, 32(sp)
	xor	t1, t3, t1
	add	t1, t1, s9
	lbu	t1, 0(t1)
	xor	t3, t5, a4
	andi	t3, t3, 255
	add	t3, t3, s10
	lbu	t3, 0(t3)
	xor	a6, a6, a7
	xor	a6, a6, t2
	xor	a7, t4, t1
	xor	t1, t6, t3
	add	t1, t1, s10
	lbu	t1, 0(t1)
	slli	a7, a7, 2
	add	a7, a7, a2
	lw	a7, 0(a7)
	xor	t1, s0, t1
	xor	a4, s1, a4
	andi	a4, a4, 255
	add	a4, a4, s9
	lbu	a4, 0(a4)
	slli	t1, t1, 2
	add	t1, t1, s11
	lb	t0, 1(t0)
	xor	a4, s2, a4
	add	a4, a4, s10
	lbu	a4, 0(a4)
	xor	t2, s4, t0
	andi	t2, t2, 255
	add	t2, t2, s10
	lbu	t2, 0(t2)
	lw	t1, 0(t1)
	xor	a4, s3, a4
	slli	a4, a4, 2
	xor	t2, s5, t2
	add	t2, t2, s9
	lbu	t2, 0(t2)
	xor	t0, s7, t0
	andi	t0, t0, 255
	add	t0, t0, s9
	lbu	t0, 0(t0)
	add	a4, a4, ra
	lw	a4, 0(a4)
	xor	t2, s6, t2
	xor	t0, s8, t0
	add	t0, t0, s9
	lbu	t0, 0(t0)
	slli	t2, t2, 2
	add	t2, t2, a1
	lw	t2, 0(t2)
	xor	t0, a0, t0
	slli	t0, t0, 2
	add	t0, t0, a2
	lw	t0, 0(t0)
	xor	a6, a6, a7
	xor	a4, a4, t1
	xor	a4, a4, t2
	xor	a4, a4, t0
	srli	a7, a4, 24
	slli	a4, a4, 8
	or	a4, a4, a7
	add	a6, a4, a6
	add	a4, a6, a4
	sw	a6, %lo(dummy)(a3)
	srli	a6, a4, 23
	slli	a4, a4, 9
	or	a4, a4, a6
	sw	a4, %lo(dummy)(a3)
	addi	a4, a5, 2
	li	a6, 38
	bltu	a5, a6, .LBB0_19
.LBB0_20:
	lw	ra, 140(sp)
	lw	s0, 136(sp)
	lw	s1, 132(sp)
	lw	s2, 128(sp)
	lw	s3, 124(sp)
	lw	s4, 120(sp)
	lw	s5, 116(sp)
	lw	s6, 112(sp)
	lw	s7, 108(sp)
	lw	s8, 104(sp)
	lw	s9, 100(sp)
	lw	s10, 96(sp)
	lw	s11, 92(sp)
	addi	sp, sp, 144
	ret
.Lfunc_end0:
	.size	twofish_key_schedule, .Lfunc_end0-twofish_key_schedule

	.type	POLY_TO_EXP,@object
	.section	.rodata,"a",@progbits
POLY_TO_EXP:
	.ascii	"\000\001\027\002.\030S\003j/\223\0314TE\004\\k\2660\246\224K\032\2145\201U\252F\r\005$]\207l\233\267\3011+\247\243\225\230L\312\033\346\215s6\315\202\022Vb\253\360GO\016\275\006\324%\322^'\210fm\326\234y\270\b\302\3372h,\375\250\212\244Z\226)\231\"M`\313\344\034{\347;\216\236t\3647\330\316\371\203o\023\262W\341c\334\254\304\361\257H\nPB\017\272\276\307\007\336\325x&e\323\321_\343(!\211Yg\374n\261\327\370\235\363z:\271\306\tA\303\256\340\3333Di\222-R\376\026\251\f\213\200\245J[\265\227\311*\242\232\300#\206N\274a\357\314\021\345r\035=|\353\350\351<\352\217}\237\354u\036\365>8\366\331?\317v\372\037\204\240p\355\024\220\263~X\373\342 d\320\335w\255\332\305@\3629\260\367I\264\013\177Q\025C\221\020q\273\356\277\205\310\241"
	.size	POLY_TO_EXP, 255

	.type	RS,@object
	.section	.rodata.cst32,"aM",@progbits,32
RS:
	.ascii	"\001\244\002\244\244V\241UU\202\374\207\207\363\301ZZ\036GXX\306\256\333\333h=\236\236\345\031\003"
	.size	RS, 32

	.type	EXP_TO_POLY,@object
	.section	.rodata,"a",@progbits
EXP_TO_POLY:
	.ascii	"\001\002\004\b\020 @\200M\232y\362\251\037>|\370\2757n\334\365\247\003\006\f\0300`\300\315\327\343\213[\266!B\204E\212Y\262)R\244\005\n\024(P\240\r\0324h\320\355\227c\306\301\317\323\353\233{\366\241\017\036<x\360\255\027.\\\270=z\364\245\007\016\0348p\340\215W\256\021\"D\210]\2729r\344\205G\216Q\242\t\022$H\220m\332\371\2773f\314\325\347\203K\226a\302\311\337\363\253\0336l\330\375\267#F\214U\252\0312d\310\335\367\243\013\026,X\260-Z\264%J\224e\312\331\377\263+V\254\025*T\250\035:t\350\235w\356\221o\336\361\257\023&L\230}\372\271?~\374\265'N\234u\352\231\177\376\261/^\2745j\324\345\207C\206A\202I\222i\322\351\237s\346\201O\236q\342\211_\2761b\304\305\307\303\313\333\373\273;v\354\225g\316\321\357\223k\326\341\217S\246"
	.size	EXP_TO_POLY, 255

	.type	MDS0,@object
	.p2align	2
MDS0:
	.word	3166450293
	.word	3974898163
	.word	538985414
	.word	3014904308
	.word	3671720923
	.word	33721211
	.word	3806473211
	.word	2661219016
	.word	3385453642
	.word	3570665939
	.word	404253670
	.word	505323371
	.word	2560101957
	.word	2998024317
	.word	2795950824
	.word	640071499
	.word	1010587606
	.word	2475919922
	.word	2189618904
	.word	1381144829
	.word	2071712823
	.word	3149608817
	.word	1532729329
	.word	1195869153
	.word	606354480
	.word	1364320783
	.word	3132802808
	.word	1246425883
	.word	3216984199
	.word	218984698
	.word	2964370182
	.word	1970658879
	.word	3537042782
	.word	2105352378
	.word	1717973422
	.word	976921435
	.word	1499012234
	.word	0
	.word	3452801980
	.word	437969053
	.word	2930650221
	.word	2139073473
	.word	724289457
	.word	3200170254
	.word	3772817536
	.word	2324303965
	.word	993743570
	.word	1684323029
	.word	3638069408
	.word	3890718084
	.word	1600120839
	.word	454758676
	.word	741130933
	.word	4244419728
	.word	825304876
	.word	2155898275
	.word	1936927410
	.word	202146163
	.word	2037997388
	.word	1802191188
	.word	1263207058
	.word	1397975412
	.word	2492763958
	.word	2206408529
	.word	707409464
	.word	3301219504
	.word	572704957
	.word	3587569754
	.word	3183330300
	.word	1212708960
	.word	4294954594
	.word	1280051094
	.word	1094809452
	.word	3351766594
	.word	3958056183
	.word	471602192
	.word	1566401404
	.word	909517352
	.word	1734852647
	.word	3924406156
	.word	1145370899
	.word	336915093
	.word	4126522268
	.word	3486456007
	.word	1061104932
	.word	3233866566
	.word	1920129851
	.word	1414818928
	.word	690572490
	.word	4042274275
	.word	134807173
	.word	3334870987
	.word	4092808977
	.word	2358043856
	.word	2762234259
	.word	3402274488
	.word	1751661478
	.word	3099086211
	.word	943204384
	.word	3857002239
	.word	2913818271
	.word	185304183
	.word	3368558019
	.word	2577006540
	.word	1482222851
	.word	421108335
	.word	235801096
	.word	2509602495
	.word	1886408768
	.word	4160172263
	.word	1852755755
	.word	522153698
	.word	3048553849
	.word	151588620
	.word	1633760426
	.word	1465325186
	.word	2678000449
	.word	2644344890
	.word	286352618
	.word	623234489
	.word	2947538404
	.word	1162152090
	.word	3755969956
	.word	2745392279
	.word	3941258622
	.word	892688602
	.word	3991785594
	.word	1128528919
	.word	4177054566
	.word	4227576212
	.word	926405537
	.word	4210704413
	.word	3267520573
	.word	3031747824
	.word	842161630
	.word	2627498419
	.word	1448535819
	.word	3823360626
	.word	2273796263
	.word	353704732
	.word	4193860335
	.word	1667481553
	.word	875866451
	.word	2593817918
	.word	2981184143
	.word	2088554803
	.word	2290653990
	.word	1027450463
	.word	2711738348
	.word	3840204662
	.word	2172752938
	.word	2442199369
	.word	252705665
	.word	4008618632
	.word	370565614
	.word	3621221153
	.word	2543318468
	.word	2779097114
	.word	4278075371
	.word	1835906521
	.word	2021174981
	.word	3318050105
	.word	488498585
	.word	1987486925
	.word	1044307117
	.word	3419105073
	.word	3065399179
	.word	4025441025
	.word	303177240
	.word	1616954659
	.word	1785376989
	.word	1296954911
	.word	3469666638
	.word	3739122733
	.word	1431674361
	.word	2122209864
	.word	555856463
	.word	50559730
	.word	2694850149
	.word	1583225230
	.word	1515873912
	.word	1701137244
	.word	1650609752
	.word	4261233945
	.word	101119117
	.word	1077970661
	.word	4075994776
	.word	859024471
	.word	387420263
	.word	84250239
	.word	3907542533
	.word	1330609508
	.word	2307484335
	.word	269522275
	.word	1953771446
	.word	168457726
	.word	1549570805
	.word	2610656439
	.word	757936956
	.word	808507045
	.word	774785486
	.word	1229556201
	.word	1179021928
	.word	2004309316
	.word	2829637856
	.word	2526413901
	.word	673758531
	.word	2846435689
	.word	3654908201
	.word	2256965934
	.word	3520169900
	.word	4109650453
	.word	2374833497
	.word	3604382376
	.word	3115957258
	.word	1111625118
	.word	4143366510
	.word	791656519
	.word	3722249951
	.word	589510964
	.word	3435946549
	.word	4059153514
	.word	3250655951
	.word	2240146396
	.word	2408554018
	.word	1903272393
	.word	2425417920
	.word	2863289243
	.word	16904585
	.word	2341200340
	.word	1313770733
	.word	2391699371
	.word	2880152082
	.word	1869561506
	.word	3873854477
	.word	3688624722
	.word	2459073467
	.word	3082270210
	.word	1768540719
	.word	960092585
	.word	3553823959
	.word	2812748641
	.word	2728570142
	.word	3284375988
	.word	1819034704
	.word	117900548
	.word	67403766
	.word	656885442
	.word	2896996118
	.word	3503322661
	.word	1347425158
	.word	3705468758
	.word	2223250005
	.word	3789639945
	.word	2054825406
	.word	320073617
	.size	MDS0, 1024

	.type	Q0,@object
Q0:
	.ascii	"\251g\263\350\004\375\243v\232\222\200x\344\335\3218\r\3065\230\030\367\354lCu7&\372\023\224H\362\320\2130\204T\337#\031[=Y\363\256\242\202c\001\203.\331Q\233|\246\353\245\276\026\f\343a\300\214:\365s,%\013\273N\211kSj\264\361\341\346\275E\342\364\266f\314\225\003V\324\034\036\327\373\303\216\265\351\317\277\272\352w9\2573\311bq\201y\t\255$\315\371\330\345\305\271MD\b\206\347\241\035\252\355\006p\262\322A{\240\0211\302'\220 \366`\377\226\\\261\253\236\234R\033_\223\n\357\221\205I\356-O\217;G\207mF\326>id*\316\313/\374\227\005z\254\177\325\032K\016\247Z(\024?)\210<L\002\270\332\260\027U\037\212}W\307\215t\267\304\237r~\025\"\022X\007\2314nP\336he\274\333\370\310\250+@\334\3762\244\312\020!\360\323]\017\000o\2356BJ^\301\340"
	.size	Q0, 256

	.type	dummy,@object
	.section	.sbss,"aw",@nobits
	.p2align	2
dummy:
	.word	0
	.size	dummy, 4

	.type	MDS1,@object
	.section	.rodata,"a",@progbits
	.p2align	2
MDS1:
	.word	2849585465
	.word	1737496343
	.word	3010567324
	.word	3906119334
	.word	67438343
	.word	4254618194
	.word	2741338240
	.word	1994384612
	.word	2584233285
	.word	2449623883
	.word	2158026976
	.word	2019973722
	.word	3839733679
	.word	3719326314
	.word	3518980963
	.word	943073834
	.word	223667942
	.word	3326287904
	.word	895667404
	.word	2562650866
	.word	404623890
	.word	4146392043
	.word	3973554593
	.word	1819754817
	.word	1136470056
	.word	1966259388
	.word	936672123
	.word	647727240
	.word	4201647373
	.word	335103044
	.word	2494692347
	.word	1213890174
	.word	4068082435
	.word	3504639116
	.word	2336732854
	.word	809247780
	.word	2225465319
	.word	1413573483
	.word	3741769181
	.word	600137824
	.word	424017405
	.word	1537423930
	.word	1030275778
	.word	1494584717
	.word	4079086828
	.word	2922473062
	.word	2722000751
	.word	2182502231
	.word	1670713360
	.word	22802415
	.word	2202908856
	.word	781289094
	.word	3652545901
	.word	1361019779
	.word	2605951658
	.word	2086886749
	.word	2788911208
	.word	3946839806
	.word	2782277680
	.word	3190127226
	.word	380087468
	.word	202311945
	.word	3811963120
	.word	1629726631
	.word	3236991120
	.word	2360338921
	.word	981507485
	.word	4120009820
	.word	1937837068
	.word	740766001
	.word	628543696
	.word	199710294
	.word	3145437842
	.word	1323945678
	.word	2314273025
	.word	1805590046
	.word	1403597876
	.word	1791291889
	.word	3029976003
	.word	4053228379
	.word	3783477063
	.word	3865778200
	.word	3184009762
	.word	1158584472
	.word	3798867743
	.word	4106859443
	.word	3056563316
	.word	1724643576
	.word	3439303065
	.word	2515145748
	.word	65886296
	.word	1459084508
	.word	3571551115
	.word	471536917
	.word	514695842
	.word	3607942099
	.word	4213957346
	.word	3273509064
	.word	2384027230
	.word	3049401388
	.word	3918088521
	.word	3474112961
	.word	3212744085
	.word	3122691453
	.word	3932426513
	.word	2005142283
	.word	963495365
	.word	2942994825
	.word	869366908
	.word	3382800753
	.word	1657733119
	.word	1899477947
	.word	2180714255
	.word	2034087349
	.word	156361185
	.word	2916892222
	.word	606945087
	.word	3450107510
	.word	4187837781
	.word	3639509634
	.word	3850780736
	.word	3316545656
	.word	3117229349
	.word	1292146326
	.word	1146451831
	.word	134876686
	.word	2249412688
	.word	3878746103
	.word	2714974007
	.word	490797818
	.word	2855559521
	.word	3985395278
	.word	112439472
	.word	1886147668
	.word	2989126515
	.word	3528604475
	.word	1091280799
	.word	2072707586
	.word	2693322968
	.word	290452467
	.word	828885963
	.word	3259377447
	.word	666920807
	.word	2427780348
	.word	539506744
	.word	4135519236
	.word	1618495560
	.word	4281263589
	.word	2517060684
	.word	1548445029
	.word	2982619947
	.word	2876214926
	.word	2651669058
	.word	2629563893
	.word	1391647707
	.word	468929098
	.word	1604730173
	.word	2472125604
	.word	180140473
	.word	4013619705
	.word	2448364307
	.word	2248017928
	.word	1224839569
	.word	3999340054
	.word	763158238
	.word	1337073953
	.word	2403512753
	.word	1004237426
	.word	1203253039
	.word	2269691839
	.word	1831644846
	.word	1189331136
	.word	3596041276
	.word	1048943258
	.word	1764338089
	.word	1685933903
	.word	714375553
	.word	3460902446
	.word	3407333062
	.word	801794409
	.word	4240686525
	.word	2539430819
	.word	90106088
	.word	2060512749
	.word	2894582225
	.word	2140013829
	.word	3585762404
	.word	447260069
	.word	1270294054
	.word	247054014
	.word	2808121223
	.word	1526257109
	.word	673330742
	.word	336665371
	.word	1071543669
	.word	695851481
	.word	2292903662
	.word	1009986861
	.word	1281325433
	.word	45529015
	.word	3096890058
	.word	3663213877
	.word	2963064004
	.word	402408259
	.word	1427801220
	.word	536235341
	.word	2317113689
	.word	2100867762
	.word	1470903091
	.word	3340292047
	.word	2381579782
	.word	1953059667
	.word	3077872539
	.word	3304429463
	.word	2673257901
	.word	1926947811
	.word	2127948522
	.word	357233908
	.word	580816783
	.word	312650667
	.word	1481532002
	.word	132669279
	.word	2581929245
	.word	876159779
	.word	1858205430
	.word	1346661484
	.word	3730649650
	.word	1752319558
	.word	1697030304
	.word	3163803085
	.word	3674462938
	.word	4173773498
	.word	3371867806
	.word	2827146966
	.word	735014510
	.word	1079013488
	.word	3706422661
	.word	4269083146
	.word	847942547
	.word	2760761311
	.word	3393988905
	.word	269753372
	.word	561240023
	.word	4039947444
	.word	3540636884
	.word	1561365130
	.word	266490193
	.word	0
	.word	1872369945
	.word	2648709658
	.word	915379348
	.word	1122420679
	.word	1257032137
	.word	1593692882
	.word	3249241983
	.word	3772295336
	.size	MDS1, 1024

	.type	Q1,@object
Q1:
	.ascii	"u\363\306\364\333{\373\310J\323\346kE}\350K\3262\330\3757q\361\3410\017\370\033\207\372\006?^\272\256[\212\000\274\235m\301\261\016\200]\322\325\240\204\007\024\265\220,\243\262sLT\222t6Q8\260\275Z\374`b\226lB\367\020|('\214\023\225\234\307$F;p\312\343\205\313\021\320\223\270\246\203 \377\237w\303\314\003o\b\277@\347+\342y\f\252\202A:\352\271\344\232\244\227~\332z\027f\224\241\035=\360\336\263\013r\247\034\357\321S>\2173&_\354v*I\201\210\356!\304\032\353\331\3059\231\315\2551\213\001\030#\335\037N-\371HO\362e\216x\\X\031\215\345\230Wg\177\005d\257c\266\376\365\267<\245\316\351hD\340MCi).\254\025Y\250\n\236nG\33745j\317\334\"\311\300\233\211\324\355\253\022\242\rR\273\002/\251\327a\036\264P\004\366\302\026%\206VU\t\276\221"
	.size	Q1, 256

	.type	MDS2,@object
	.p2align	2
MDS2:
	.word	3161832498
	.word	3975408673
	.word	549855299
	.word	3019158473
	.word	3671841283
	.word	41616011
	.word	3808158251
	.word	2663948026
	.word	3377121772
	.word	3570652169
	.word	417732715
	.word	510336671
	.word	2554697742
	.word	2994582072
	.word	2800264914
	.word	642459319
	.word	1020673111
	.word	2469565322
	.word	2195227374
	.word	1392333464
	.word	2067233748
	.word	3144792887
	.word	1542544279
	.word	1205946243
	.word	607134780
	.word	1359958498
	.word	3136862918
	.word	1243302643
	.word	3213344584
	.word	234491248
	.word	2953228467
	.word	1967093214
	.word	3529429757
	.word	2109373728
	.word	1722705457
	.word	979057315
	.word	1502239004
	.word	0
	.word	3451702675
	.word	446503648
	.word	2926423596
	.word	2143387563
	.word	733031367
	.word	3188637369
	.word	3766542496
	.word	2321386000
	.word	1003633490
	.word	1691706554
	.word	3634419848
	.word	3884246949
	.word	1594318824
	.word	454302481
	.word	750070978
	.word	4237360308
	.word	824979751
	.word	2158198885
	.word	1941074730
	.word	208866433
	.word	2035054943
	.word	1800694593
	.word	1267878658
	.word	1400132457
	.word	2486604943
	.word	2203157279
	.word	708323894
	.word	3299919004
	.word	582820552
	.word	3579500024
	.word	3187457475
	.word	1214269560
	.word	4284678094
	.word	1284918279
	.word	1097613687
	.word	3343042534
	.word	3958893348
	.word	470817812
	.word	1568431459
	.word	908604962
	.word	1730635712
	.word	3918326191
	.word	1142113529
	.word	345314538
	.word	4120704443
	.word	3485978392
	.word	1059340077
	.word	3225862371
	.word	1916498651
	.word	1416647788
	.word	701114700
	.word	4041470005
	.word	142936318
	.word	3335243287
	.word	4078039887
	.word	2362477796
	.word	2761139289
	.word	3401108118
	.word	1755736123
	.word	3095640141
	.word	941635624
	.word	3858752814
	.word	2912922966
	.word	192351108
	.word	3368273949
	.word	2580322815
	.word	1476614381
	.word	426711450
	.word	235408906
	.word	2512360830
	.word	1883271248
	.word	4159174448
	.word	1848340175
	.word	534912878
	.word	3044652349
	.word	151783695
	.word	1638555956
	.word	1468159766
	.word	2671877899
	.word	2637864320
	.word	300552548
	.word	632890829
	.word	2951000029
	.word	1167738120
	.word	3752124301
	.word	2744623964
	.word	3934186197
	.word	903492952
	.word	3984256464
	.word	1125598204
	.word	4167497931
	.word	4220844977
	.word	933312467
	.word	4196268608
	.word	3258827368
	.word	3035673804
	.word	853422685
	.word	2629016689
	.word	1443583719
	.word	3815957466
	.word	2275903328
	.word	354161947
	.word	4193253690
	.word	1674666943
	.word	877868201
	.word	2587794053
	.word	2978984258
	.word	2083749073
	.word	2284226715
	.word	1029651878
	.word	2716639703
	.word	3832997087
	.word	2167046548
	.word	2437517569
	.word	260116475
	.word	4001951402
	.word	384702049
	.word	3609319283
	.word	2546243573
	.word	2769986984
	.word	4276878911
	.word	1842965941
	.word	2026207406
	.word	3308897645
	.word	496573925
	.word	1993176740
	.word	1051541212
	.word	3409038183
	.word	3062609479
	.word	4009881435
	.word	303567390
	.word	1612931269
	.word	1792895664
	.word	1293897206
	.word	3461271273
	.word	3727548028
	.word	1442403741
	.word	2118680154
	.word	558834098
	.word	66192250
	.word	2691014694
	.word	1586388505
	.word	1517836902
	.word	1700554059
	.word	1649959502
	.word	4246338885
	.word	109905652
	.word	1088766086
	.word	4070109886
	.word	861352876
	.word	392632208
	.word	92210574
	.word	3892701278
	.word	1331974013
	.word	2309982570
	.word	274927765
	.word	1958114351
	.word	184420981
	.word	1559583890
	.word	2612501364
	.word	758918451
	.word	816132310
	.word	785264201
	.word	1240025481
	.word	1181238898
	.word	2000975701
	.word	2833295576
	.word	2521667076
	.word	675489981
	.word	2842274089
	.word	3643398521
	.word	2251196049
	.word	3517763975
	.word	4095079498
	.word	2371456277
	.word	3601389186
	.word	3104487868
	.word	1117667853
	.word	4134467265
	.word	793194424
	.word	3722435846
	.word	590619449
	.word	3426077794
	.word	4050317764
	.word	3251618066
	.word	2245821931
	.word	2401406878
	.word	1909027233
	.word	2428539120
	.word	2862328403
	.word	25756145
	.word	2345962465
	.word	1324174988
	.word	2393607791
	.word	2870127522
	.word	1872916286
	.word	3859670612
	.word	3679640562
	.word	2461766267
	.word	3070408630
	.word	1764714954
	.word	967391705
	.word	3554136844
	.word	2808194851
	.word	2719916717
	.word	3283403673
	.word	1817209924
	.word	117704453
	.word	83231871
	.word	667035462
	.word	2887167143
	.word	3492139126
	.word	1350979603
	.word	3696680183
	.word	2220196890
	.word	3775521105
	.word	2059303461
	.word	328274927
	.size	MDS2, 1024

	.type	MDS3,@object
	.p2align	2
MDS3:
	.word	3644434905
	.word	2417452944
	.word	1906094961
	.word	3534153938
	.word	84345861
	.word	2555575704
	.word	1702929253
	.word	3756291807
	.word	138779144
	.word	38507010
	.word	2699067552
	.word	1717205094
	.word	3719292125
	.word	2959793584
	.word	3210990015
	.word	908736566
	.word	1424362836
	.word	1126221379
	.word	1657550178
	.word	3203569854
	.word	504502302
	.word	619444004
	.word	3617713367
	.word	2000776311
	.word	3173532605
	.word	851211570
	.word	3564845012
	.word	2609391259
	.word	1879964272
	.word	4181988345
	.word	2986054833
	.word	1518225498
	.word	2047079034
	.word	3834433764
	.word	1203145543
	.word	1009004604
	.word	2783413413
	.word	1097552961
	.word	115203846
	.word	3311412165
	.word	1174214981
	.word	2738510755
	.word	1757560168
	.word	361584917
	.word	569176865
	.word	828812849
	.word	1047503422
	.word	374833686
	.word	2500879253
	.word	1542390107
	.word	1303937869
	.word	2441490065
	.word	3043875253
	.word	528699679
	.word	1403689811
	.word	1667071075
	.word	996714043
	.word	1073670975
	.word	3593512406
	.word	628801061
	.word	2813073063
	.word	252251151
	.word	904979253
	.word	598171939
	.word	4036018416
	.word	2951318703
	.word	2157787776
	.word	2455565714
	.word	2165076865
	.word	657533991
	.word	1993352566
	.word	3881176039
	.word	2073213819
	.word	3922611945
	.word	4043409905
	.word	2669570975
	.word	2838778793
	.word	3304155844
	.word	2579739801
	.word	2539385239
	.word	2202526083
	.word	1796793963
	.word	3357720008
	.word	244860174
	.word	1847583342
	.word	3384014025
	.word	796177967
	.word	3422054091
	.word	4288269567
	.word	3927217642
	.word	3981968365
	.word	4158412535
	.word	3784037601
	.word	454368283
	.word	2913083053
	.word	215209740
	.word	736295723
	.word	499696413
	.word	425627161
	.word	3257710018
	.word	2303322505
	.word	314691346
	.word	2123743102
	.word	545110560
	.word	1678895716
	.word	2215344004
	.word	1841641837
	.word	1787408234
	.word	3514577873
	.word	2708588961
	.word	3472843470
	.word	935031095
	.word	4212097531
	.word	1035303229
	.word	1373702481
	.word	3695095260
	.word	759112749
	.word	2759249316
	.word	2639657373
	.word	4001552622
	.word	2252400006
	.word	2927150510
	.word	3441801677
	.word	76958980
	.word	1433879637
	.word	168691722
	.word	324044307
	.word	821552944
	.word	3543638483
	.word	1090133312
	.word	878815796
	.word	2353982860
	.word	3014657715
	.word	1817473132
	.word	712225322
	.word	1379652178
	.word	194986251
	.word	2332195723
	.word	2295898248
	.word	1341329743
	.word	1741369703
	.word	1177010758
	.word	3227985856
	.word	3036450996
	.word	674766888
	.word	2131031679
	.word	2018009208
	.word	786825006
	.word	122459655
	.word	1264933963
	.word	3341529543
	.word	1871620975
	.word	222469645
	.word	3153435835
	.word	4074459890
	.word	4081720307
	.word	2789040038
	.word	1503957849
	.word	3166243516
	.word	989458234
	.word	4011037167
	.word	4261971454
	.word	26298625
	.word	1628892769
	.word	2094935420
	.word	2988527538
	.word	1118932802
	.word	3681696731
	.word	3090106296
	.word	1220511560
	.word	749628716
	.word	3821029091
	.word	1463604823
	.word	2241478277
	.word	698968361
	.word	2102355069
	.word	2491493012
	.word	1227804233
	.word	398904087
	.word	3395891146
	.word	3284008131
	.word	1554224988
	.word	1592264030
	.word	3505224400
	.word	2278665351
	.word	2382725006
	.word	3127170490
	.word	2829392552
	.word	3072740279
	.word	3116240569
	.word	1619502944
	.word	4174732024
	.word	573974562
	.word	286987281
	.word	3732226014
	.word	2044275065
	.word	2867759274
	.word	858602547
	.word	1601784927
	.word	3065447094
	.word	2529867926
	.word	1479924312
	.word	2630135964
	.word	4232255484
	.word	444880154
	.word	4132249590
	.word	475630108
	.word	951221560
	.word	2889045932
	.word	416270104
	.word	4094070260
	.word	1767076969
	.word	1956362100
	.word	4120364277
	.word	1454219094
	.word	3672339162
	.word	3588914901
	.word	1257510218
	.word	2660180638
	.word	2729120418
	.word	1315067982
	.word	3898542056
	.word	3843922405
	.word	958608441
	.word	3254152897
	.word	1147949124
	.word	1563614813
	.word	1917216882
	.word	648045862
	.word	2479733907
	.word	64674563
	.word	3334142150
	.word	4204710138
	.word	2195105922
	.word	3480103887
	.word	1349533776
	.word	3951418603
	.word	1963654773
	.word	2324902538
	.word	2380244109
	.word	1277807180
	.word	337383444
	.word	1943478643
	.word	3434410188
	.word	164942601
	.word	277503248
	.word	3796963298
	.word	0
	.word	2585358234
	.word	3759840736
	.word	2408855183
	.word	3871818470
	.word	3972614892
	.word	4258422525
	.word	2877276587
	.word	3634946264
	.size	MDS3, 1024

	.section	".note.GNU-stack","",@progbits
