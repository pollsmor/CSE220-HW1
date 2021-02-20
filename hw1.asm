.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"
ValidOps: .asciiz "OSTIECXM"

arg1_addr : .word 0
arg2_addr : .word 0
num_args : .word 0

.text:
.globl main
main:
	sw $a0, num_args

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr

	lw $t1, 4($a1)
	sw $t1, arg2_addr
	lw $s2, arg2_addr

	j start_coding_here

# do not change any line of code above this section
# you can add code to the .data section
start_coding_here:
	li $t0, 2			# bne doesn't compare via immediates so load 2 into temp register	
	bne $a0, $t0, wrong_arg		# If num_args and 2 don't match, jump to wrong_arg label
	
	lbu $s0, 0($s1)			# get just first character from first argument, store into $s0
	
	# Checks that the argument provided is valid. I don't use bne for comparison because 
	# while one conditional may not be met, a later one might. Instead, if none of the beq
	# conditionals are met by the end, simply end the function by jumping to err_msg.
	# =========================
	li $t0, 'O'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'S'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'T'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'I'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'E'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'C'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'X'
	beq $s0, $t0, part1_1
	# =========================
	li $t0, 'M'
	beq $s0, $t0, part1_1
 	# =========================
 	
	j err_msg
	
part1_1:
	# Testing purposes: print operator
	li $v0, 11
	move $a0, $s0			# Reminder: $s0 contains single character operator
	syscall

	li $v0, 10
	syscall

# Error message labels ==============================================================================
wrong_arg: 
	li $v0, 4			# syscall 4 is to print string
	la $a0 WrongArgMsg		# load address of WrongArgMsg global variable
	syscall
	
	# Program should end when wrong number of args are provided
	li $v0, 10			
	syscall

err_msg:
	li $v0, 4 			# syscall 4 is to print string
	la $a0 ErrMsg			# load address of ErrMsg global variable
	syscall
	
	# Program should end when invalid of args are provided
	li $v0, 10
	syscall