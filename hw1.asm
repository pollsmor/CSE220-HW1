.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"
ValidOps: .asciiz "OSTIECXM"
HexChars: .asciiz "0123456789ABCDEF"

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
	
	# Loop to check whether operator is valid ===================================================
	li $t0, 0			# int i = 0
	li $t1, 8			# exit condition: i = 8
	la $t2, ValidOps
	check_op_loop:
		lbu $t3, 0($t2)			# get character from ValidOps string
		beq $s0, $t3, part1_1		# if character matches, move on
		
		addi $t2, $t2, 1		# increment $t2 address so 0($t2) still works
		addi $t0, $t0, 1		# i++
		bne $t0, $t1, check_op_loop	# go back to start of loop as conditional is not met
	# ===========================================================================================
	
	j err_msg			# beq in loop never satisfied so invalid operator supplied
	
part1_1:
	# Check first character of arg2 is 'O'
	lbu $t0, 0($s2)
	li $t1, '0'
	bne $t0, $t1, err_msg
	# Check second character of arg2 is 'x'
	lbu $t0, 1($s2)
	li $t1, 'x'
	bne $t0, $t1, err_msg
	
	# Loop through all 8 remaining characters of arg2 ===========================================
	addi $s2, $s2, 2		# increment $s2 (arg2) address by 2 (skip '0' and 'x')
	li $t0, 0			
	li $t1, 8
	loop1: 
		beq $t0, $t1, operations
		addi $t0, $t0, 1		# i++
		
		lbu $t2, 0($s2)			# get character from arg2
		beqz $t2, err_msg		# if a null terminator is found, arg2 is invalid
		addi $s2, $s2, 1		# increment $s2 so 0($s2) still works
		li $t3, 0			# int j = 0
		li $t4, 16			# exit condition: j = 16
		la $t5 HexChars		
		loop2:
			lbu $t6, 0($t5)			# get character from HexChars string
			beq $t2, $t6, loop1		# if character is valid hex char, move on
			
			addi $t5, $t5, 1		# increment HexChars 
			addi $t3, $t3, 1		# j++
			bne $t3, $t4, loop2
	# ===========================================================================================	
	
	j err_msg 			# didn't jump to part2_a in loop1 so arg2 must be invalid
			
operations:
	lw $s2, arg2_addr		# Modified initial address of $s2 earlier so reset it
	addi $s2, $s2, 2		# Skip over 0x

	li $t0, 'O'	
	beq $s0, $t0, opcode

	li $t0, 'S'	
	beq $s0, $t0, rs
	
	li $t0, 'T'	
	beq $s0, $t0, rt
	
	li $t0, 'I'	
	beq $s0, $t0, immediate
	
	li $t0, 'E'	
	beq $s0, $t0, odd_even
	
	li $t0, 'C'	
	beq $s0, $t0, count_ones
	
	li $t0, 'X'	
	beq $s0, $t0, exponent
	
	j mantissa 			# only possible character remaining
	
# The eight operations ============================================================================
opcode: # We want the 1st-6th digits.
	lbu $t0, 0($s2)
	addi $t0, $t0, -48		# -48 since 48 is 'A'
	li $t1, 9			# After subtraction $t0 still > 9, must be a letter
	bgt $t0, $t1, else_opcode
	j endif_opcode		
	
	else_opcode: 				# character is one of 'ABCDEF', subtract another 7
		addi $t0, $t0, -7	
	endif_opcode:
	# This entire block above this line is for ohbtaining the integer value of 1 character -
	# ASCII value is not what I want. i.e. 'A' would become 10. I will do the same for a second 
	# character right now, so that I have 8 bits (need 6 for opcode).
	
	lbu $t1, 1($s2)
	addi $t1, $t1, -48		
	li $t2, 9			
	bgt $t1, $t2, else2_opcode
	j endif2_opcode	
	
	else2_opcode: 	
		addi $t1, $t1, -7	
	endif2_opcode:
	
	# By now, $t0 and $t1 both contain the numerical equivalents of the 1st and 2nd characters.
	sll $s0, $t0, 4			# Move 4 left to make room for $t1's binary representation
	or $s0, $s0, $t1		# Use or to get rightmost 4 digits into $s0
	srl $s0, $s0, 2			# Get rid of rightmost 2 digits since we only want 6
	andi $s0, $s0, 0x003F		# This bitmask should obtain the 6 digits necessary.
	
	li $v0, 1
	move $a0, $s0
	syscall

	li $v0, 10
	syscall

rs: 	# We want the 7th-11th digits.
	lbu $t0, 1($s2)
	addi $t0, $t0, -48		
	li $t1, 9			
	bgt $t0, $t1, else_rs
	j endif_rs			
	
	else_rs: 				
		addi $t0, $t0, -7	
	endif_rs:
	
	lbu $t1, 2($s2)
	addi $t1, $t1, -48		
	li $t2, 9			
	bgt $t1, $t2, else2_rs
	j endif2_rs	
	
	else2_rs: 	
		addi $t1, $t1, -7	
	endif2_rs:
	
	# By now, $t0 and $t1 both contain the numerical equivalents of the 2nd and 3rd characters.
	sll $s0, $t0, 4			# Move 4 left to make room for $t1's binary representation
	or $s0, $s0, $t1		# Use or to get rightmost 4 digits into $s0
	srl $s0, $s0, 1			# Shift right once to get into correct digits.
	andi $s0, $s0, 0x001F		# This bitmask should obtain the 5 digits necessary.
	
	li $v0, 1
	move $a0, $s0
	syscall

	li $v0, 10
	syscall

rt: 	# We want the 12th-16th digits.
	lbu $t0, 2($s2)
	addi $t0, $t0, -48		
	li $t1, 9			
	bgt $t0, $t1, else_rt
	j endif_rt	
	
	else_rt: 				
		addi $t0, $t0, -7	
	endif_rt:
	
	lbu $t1, 3($s2)
	addi $t1, $t1, -48		
	li $t2, 9			
	bgt $t1, $t2, else2_rt
	j endif2_rt
	
	else2_rt: 	
		addi $t1, $t1, -7	
	endif2_rt:
	
	# By now, $t0 and $t1 both contain the numerical equivalents of the 3rd and 4th characters.
	sll $s0, $t0, 4			# Move 4 left to make room for $t1's binary representation
	or $s0, $s0, $t1		# Use or to get rightmost 4 digits into $s0
	andi $s0, $s0, 0x001F		# This bitmask should obtain the 5 digits necessary.
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 10
	syscall

immediate: 
	# We want the last 16 digits.
	lbu $t0, 4($s2)
	addi $t0, $t0, -48		
	li $t1, 9			
	bgt $t0, $t1, else_imm
	j endif_imm	
	
	else_imm: 				
		addi $t0, $t0, -7	
	endif_imm:
	
	lbu $t1, 5($s2)
	addi $t1, $t1, -48		
	li $t2, 9			
	bgt $t1, $t2, else2_imm
	j endif2_imm
	
	else2_imm: 	
		addi $t1, $t1, -7	
	endif2_imm:
	
	lbu $t2, 6($s2)
	addi $t2, $t2, -48		
	li $t3, 9			
	bgt $t2, $t3, else3_imm
	j endif3_imm
	
	else3_imm: 	
		addi $t2, $t2, -7	
	endif3_imm:
	
	lbu $t3, 7($s2)
	addi $t3, $t3, -48		
	li $t4, 9			
	bgt $t3, $t4, else4_imm
	j endif4_imm
	
	else4_imm: 	
		addi $t3, $t3, -7	
	endif4_imm:

	# By now, $t0, $t1, $t2, and $t3 contain the numerical equivalents of the 
	# 5th-8th characters.
	sll $s0, $t0, 12		# Move 12 left to make room for remaining 3 chars
	sll $s1, $t1, 8			# 8
	sll $s2, $t2, 4			# 4
	# Now use or to get all 4 characters into $s0.
	or $s0, $s0, $s1
	or $s0, $s0, $s2
	or $s0, $s0, $t3
	
	# Check if MSB is 1 and perform operations as necessary
	srl $t0, $s0, 15 
	li $t1, 1
	bne $t0, $t1, continue		
	
	lui $t0, 0xFFFF 		# When flipping bits I don't want the upper 16 bits
	or $s0, $s0, $t0		# to flip from 0 to 1
	not $s0, $s0			# two's complement!
	addi $s0, $s0, 1
	li $v0, 11
	li $a0, '-'			# manually add negative symbol
	syscall

	continue:
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 10
	syscall

odd_even: 
	li $v0, 10
	syscall

count_ones: 
	li $v0, 10
	syscall

exponent: 
	li $v0, 10
	syscall

mantissa: 
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
