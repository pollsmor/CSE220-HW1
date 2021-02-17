.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"

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
	
	li $v0, 1			# syscall 1 is to print int
	syscall				# $a0 already loaded with num_args inside main

	# I need to end this otherwise the program continues on to the wrong_arg function regardless
	li $v0, 10			
	syscall
	
wrong_arg: 
	li $v0, 4			# syscall 4 is to print string
	la $a0 ErrMsg			# load address of ErrMsg global variable
	syscall
	
	# Program should end when wrong number of args are provided
	li $v0, 10			
	syscall