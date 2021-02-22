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
	li $t1, 10			# Used for comparison
	li $s3, 0			# $s3 will combine 4 digits from all 8 characters.
	
	# Obtain binary representation of the nth character (not ASCII value) and store into $s3 =====
	lbu $t0, 0($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue		
	addi $t0, $t0, -7		# Only subtract 7 if ASCII value - 48 is >= 10
	continue:
	sll $s3, $t0, 28
	
	lbu $t0, 1($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_2		
	addi $t0, $t0, -7		
	continue_2:
	sll $t0, $t0, 24	
	or $s3, $s3, $t0		# Add 2nd character to $s3's 5th-8th digits
	
	lbu $t0, 2($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_3		
	addi $t0, $t0, -7		
	continue_3:
	sll $t0, $t0, 20
	or $s3, $s3, $t0		# Add 3rd character to $s3's 9th-12th digits
	
	lbu $t0, 3($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_4	
	addi $t0, $t0, -7		
	continue_4:
	sll $t0, $t0, 16
	or $s3, $s3, $t0		# Add 4th character to $s3's 13th-16th digits
	
	lbu $t0, 4($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_5		
	addi $t0, $t0, -7		
	continue_5:
	sll $t0, $t0, 12
	or $s3, $s3, $t0		# Add 5th character to $s3's 17th-20th digits
	
	lbu $t0, 5($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_6		
	addi $t0, $t0, -7		
	continue_6:
	sll $t0, $t0, 8
	or $s3, $s3, $t0		# Add 6th character to $s3's 21st-24th digits
	
	lbu $t0, 6($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_7		
	addi $t0, $t0, -7		
	continue_7:
	sll $t0, $t0, 4
	or $s3, $s3, $t0		# Add 7th character to $s3's 25th-28th digits
	
	lbu $t0, 7($s2)
	addi $t0, $t0, -48					
	blt $t0, $t1, continue_8		
	addi $t0, $t0, -7		
	continue_8:
	or $s3, $s3, $t0		# Add 8th character to $s3's last 4 digits
	# ===========================================================================================

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
opcode:
	srl $s3, $s3, 26		# Only want first 6 digits, don't even need a bitmask.
	
	move $a0, $s3
	li $v0, 1
	syscall
	j end_program

rs: 
	srl $s3, $s3, 21		# Now the 5 relevant digits should be as far right as possible
	andi $s3, $s3, 0x001F

	move $a0, $s3
	li $v0, 1
	syscall
	j end_program

rt:
	srl $s3, $s3, 16	
	andi $s3, $s3, 0x001F
	
	move $a0, $s3
	li $v0, 1
	syscall
	j end_program

immediate:
	sll $s3, $s3, 16		# Get rid of first 16 digits
	srl $s3, $s3, 16		# Move digits back into correct place

	# Check if MSB is 1 and perform operations as necessary
	srl $t0, $s3, 15
	li $t1, 1
	bne $t0, $t1, skip_negative_check	
	
	lui $t0, 0xFFFF 		# When flipping bits I don't want the upper 16 bits,
	or $s3, $s3, $t0		# so I flip them to 1 in advance
	not $s3, $s3			# Two's complement.
	addi $s3, $s3, 1
	
	li $v0, 11
	li $a0, '-'			# Manually add negative symbol
	syscall
	
	skip_negative_check:
	move $a0, $s3
	li $v0, 1
	syscall
	j end_program

odd_even: 
	sll $s3, $s3, 31			# Only want last digit
	srl $s3, $s3, 31
	
	li $t0, 1
	bne $s3, $t0, even_msg		# Is even, jump ahead
	
	# Is odd
	li $v0, 4
	la $a0 OddMsg
	syscall
	j end_program
	
	even_msg:
		li $v0, 4
		la $a0 EvenMsg
		syscall
		j end_program
	

count_ones: 
	li $t0, 0			# int count = 0
	li $t1, 32			# Start off shifting 31 times to the right and decrease
	li $t2, 0			# exit condition: i = 0, to shift 0 times
	count_loop:
		beq $t1, $t2, exit_loop		# If rightmost digit was a 0, the program won't stop w/o this.
		addi $t1, $t1, -1		# Which is why I set $t1 to 32 initially
		move $t3, $s3			# Copy $s3 into $t3 for shifting
		srlv $t3, $t3, $t1		# Shift n times to right (n is stored in $t1)
		andi $t3, $t3, 0x0001		# Only care about rightmost bit
		beq $t2, $t3, count_loop	# if value equals 0, restart loop
		
		addi $t0, $t0, 1		# count++
		bne $t1, $t2, count_loop	# go back to start of loop as conditional is not met
	
	exit_loop:
	move $a0, $t0
	li $v0, 1
	syscall
	j end_program

exponent: 
	sll $s3, $s3, 1			# Get digits 2-9 for the exponent
	srl $s3, $s3, 24
	addi $s3, $s3, -127		# Excess-127

	move $a0, $s3
	li $v0, 1
	syscall
	j end_program

mantissa: 	
	li $v0, 11
	li $a0, '1'
	syscall
	li $a0, '.'
	syscall

	sll $a0, $s3, 9			# Get digits 10-32 for the mantissa, move them to the front
	li $v0, 35			# Print binary representation
	syscall
	
	j end_program

end_program: 
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