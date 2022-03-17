# Authors: Fotis Ioannis, Gianopoulou Aikaterini
# ===================================================================================
# Description:
# This program takes an input of 40K 1-byte positive integers in range [1,127]
# 1. Checks if all its elements are inside the desired range
# 2. Sorts the array using the Dutch-National-Flag Quicksort implementation
#    More information here: https://en.wikipedia.org/wiki/Dutch_national_flag_problem
# 3. Searches for a specific number's index in the sorted array with Binary-Search
# ===================================================================================
#
# QuickSort pseudocode:
# algorithm qSort(&array, low, high)
# 	if (low < high) then
# 		left, right <= threeWayPartition(&array, low, high)
# 		quicksort(&array, low, left - 1)
# 		quicksort(&array, right, high)
# end qSort
# 
# procedure threeWayPartition (&array, low, high)
# 	pivot <= array[high]
# 	left, right <= low
# 	bound <= high
# 
# 	while (right <= bound)
# 		if (array[right] < array[pivot])
# 			swap (array[left], array[right])
# 			left++
# 			right++
# 		else if (array[right] > array[pivot])
# 			swap (array[right], array[bound])
# 			bound--
# 		else right++
# 	return left, right
# end threeWayPartition
#
# ===================================================================================
#
# Binary Search pseudocode:
# algorithm bSearch (&array, low, high, x)
# 	index = mid(low, high)
# 	if (array[index] == x) return index
# 	if (array[index] < x) bSearch (&array, low, index-1, x)
# 	if (array[index] > x) bSearch (&array, index+1, high, x)
# 	return 0
# end bSearch

.text
.globl main

main:
	la	$a0,	array		# a0 => arrayPtr = *array
	add	$a1,	$zero,	$zero	# a1 => low = 0
	li	$a2,	39999		# a2 => high = arraySize - 1

	############## Part A - Check input numbers ##############
	add	$t0,	$a0,	$zero	# t0 => arrayPtr = *array
	add	$t1,	$t0,	$a2	# t1 = *array + arraySize - 1
scan:
	lb	$t2,	0($t0)		# t2 = array[i]
	addi	$t0,	$t0,	1	# i++
	blez	$t2,	exit		# if (array[i] <= 0) abort execution
	beq	$t0,	$t1,	sort	# while *array < array[arraySize]
	j	scan
sort:
	################### Part B - QuickSort ###################
	jal	qSort			# sort array

	################# Part C - Binary Search #################
	la	$s7,	POS		# s7 = &POS
	addi	$t8,	$zero,	2	# divisor to calculate middle of array
	addi	$a3,	$zero,	92	# a3 = x
	jal	bSearch			# call bSearch(&array, low, high, x)
	lw	$a0,	0($s7)
	jal	print_int
	la	$a0,	newLine
	jal	print_string

	#la	$t0,	array		# t0 => arrayPtr = *array
	#add	$t1,	$t0,	$a2	# t1 = *array + arraySize - 1
printArray:
	#lb	$a0,	0($t0)		# a0 = array[i]
	#jal	print_int
	#la	$a0,	space
	#jal	print_string
	#beq	$t0,	$t1,	exit	# while *array < array[arraySize]
	#addi	$t0,	$t0,	1	# i++
	#j	printArray

exit:
	li	$v0,	10
	syscall

qSort:					# void (int *array, int low, int high)
	addi	$sp,	$sp,	-20	# push down the stack
	sw	$ra,	0($sp)		# store return address
	sw	$a1,	4($sp)		# store a1 = low
	sw	$a2,	8($sp)		# store a2 = high
	sw	$s0,	12($sp)		# store s0 = index of left partition
	sw	$s1,	16($sp)		# store s1 = index of right partition

	slt	$t9,	$a1,	$a2	# check low < high
	beq	$t9,	$zero,	return	# if (low >= high) return

	jal partition

recursiveLeft:
	lw	$a1,	4($sp)		# restore a1
	addi	$a2,	$s0,	-1	# new high = left - 1
	jal	qSort			# call quicksort(&array, low, left - 1)

recursiveRight:
	lw	$a2,	8($sp)		# restore a2
	addi	$a1,	$s1,	0	# new low = right
	jal	qSort			# call quicksort(&array, right, high)

return:
	lw	$ra,	0($sp)		# restore return address
	lw	$a1,	4($sp)		# restore a1
	lw	$a2,	8($sp)		# restore a2
	lw	$s0,	12($sp)		# restore s0
	lw	$s1,	16($sp)		# restore s1
	addi	$sp,	$sp,	20	# pull up the stack
	jr	$ra

partition:				# [int, int] (int *array, int low, int high)
	add	$t0,	$a0,	$a2	# t0 = &array[pivot] => pivot = high
	lb	$t1,	0($t0)		# t1 = array[pivot]
	add	$t2,	$a0,	$a1	# t2 => left = &array[low]
	add	$t3,	$a0,	$a1	# t3 => right = &array[low]
	addi	$t0,	$t0,	1	# t4 => bound + 1 = &array[high + 1]

while:					# while (right <= bound)
	lb	$t5,	0($t3)		# t5 = array[right]
	slt	$t9,	$t3,	$t0	# check right < bound + 1
	beq	$t9,	$zero,	endPart

ifLess:
	slt	$t9,	$t5,	$t1	# check array[right] < array[pivot]
	beq	$t9,	$zero,	ifGreater
	# swap (array[left], array[right])
	lb	$t6,	0($t2)		# t6 = array[left]
	sb	$t5,	0($t2)
	sb	$t6,	0($t3)
	addi	$t2,	$t2,	1	# left++
	addi	$t3,	$t3,	1	# right++
	j	while

ifGreater:
	slt	$t9,	$t1,	$t5	# check array[right] > array[pivot]
	beq	$t9,	$zero,	ifEqual
	addi	$t0,	$t0,	-1	# bound--
	# swap(array[right], array[bound])
	lb	$t6,	0($t0)		# t6 = array[bound]
	sb	$t5,	0($t0)
	sb	$t6,	0($t3)
	j	while

ifEqual:
	addi	$t3,	$t3,	1	# right++
	j	while

endPart:
	sub	$s0,	$t2,	$a0	# return left
	sub	$s1,	$t3,	$a0	# return right
	jr	$ra

	############## Binary Search Implementation ##############
bSearch:				# void (int *array, int low, int high, int x)
	slt	$t9,	$a2,	$a1	# check low >= high
	bne	$t9,	$zero,	bExit	# if (high < low) exit
	add	$t0,	$a1,	$a2	# t0 = low + high
	div	$t0,	$t8		# t0 = (low + high) / 2
	mflo	$t0
	add	$t1,	$a0,	$t0	# t1 => index = &array[pivot]
	lb	$t2,	0($t1)		# t2 = array[index]

	beq	$t2,	$a3,	bReturn	# if (array[index] == x) return index

	slt	$t9,	$a3,	$t2	# if (x < array[index])
	bne	$t9,	$zero,	searchLeft

searchRight:
	addi	$a1,	$t0,	1	# new low = index + 1
	j	bSearch			# call bSearch(&array, index + 1, high, x)

searchLeft:
	addi	$a2,	$t0,	-1	# new high = index - 1
	j	bSearch			# call bSearch (&array, low, index - 1, x)

bReturn:
	sub	$t1,	$t1,	$a0	# calculate the final index of x
	addi	$t1,	$t1,	1	# + 1 to be in range [1,40.000]
	sw	$t1,	0($s7)		# overwrite index at POS
	jr	$ra			# return the index of x in array

bExit:
	jr	$ra			# x not found, return without any further action

########### System calls
print_int:
	li	$v0,	1
	syscall				# move to $a0 to print
	jr	$ra

print_string:
	li	$v0,	4		# print a0 (address of string)
	syscall
	jr	$ra

.data
space: .asciiz " "
newLine: .asciiz "\n"
POS: .word 0				# Binary search result
array:					# 40.000 1-byte positive integers
.byte ###### PASTE YOUR DATASET HERE ####################################
