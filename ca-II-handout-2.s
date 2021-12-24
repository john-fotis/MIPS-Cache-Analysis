.text
.globl main

main:
    la 		$s0, array
	la		$s7, POS
	addi	$t7, $zero, 2
    add 	$s1, $s0, $zero     # copy array index to s1
    add 	$a0, $s0, $zero     # a0 => arrayPtr = *array
    addi	$a1, $zero, 0       # a1 => low = array[0]
    addi	$a2, $zero, 49      # a2 => high = array[arraySize-1]
    jal quicksort				# sort array

    li 		$t1, 0              # array start
    li 		$t2, 50             # array end
printArray:
    beq 	$t1, $t2, nextStep	# for (int i = 0; i < arraySize; i++)
    lb 		$a0, 0($s1)
    jal 	print_int
    la 		$a0, space
    jal 	print_string
    addi 	$t1, $t1, 1
    add 	$s1, $s1, 1
    j 		printArray

	################# Part B - Search #################
nextStep:
	add		$a0, $s0, $zero		# a0 = arrayPtr
	addi	$a1, $s0, 49		# a1 = &array[arraySize]
	addi 	$a2, $zero, 92		# a2 = x
	jal		binarySearch
	lw		$a0, 0($s7)
	jal		print_int
	la		$a0, newLine
	jal		print_string

exit:
    #break
    li $v0, 10
    syscall

quicksort:
	addi	$sp, $sp, -24       # push down the stack
	sw		$ra, 0($sp)	   		# store return address
	sw		$a1, 4($sp)	    	# store a1
	sw		$a2, 8($sp)	    	# store a2
	sw		$s0, 12($sp)		# store s0
	sw		$s1, 16($sp)		# store s1
	sw		$s2, 20($sp)		# store s2
	add		$s0, $a1, $zero		# s0 = low
	add		$s1, $a2, $zero		# s1 = high
	#sub		$s2, $s1, $s0		# find the pivot index
	#div		$s2, $t7			# which is in the middle of the array
	#mflo	$s2
	#addi	$s2, $s2, 1			# finally, s2 = pivot = [(high - low) / 2 + 1]
	add		$s2, $a1, $zero		# s2 = pivot (starting with low)

partition:                      # while low < high
    slt 	$t9, $s0, $s1
    beq 	$t9, $zero endPartition

checkIllegalPivot:              # if (array[pivot] <= 0) exit
    add     $t8, $a0, $s2       # find current pivot address
    lb      $t8, 0($t8)         # load current pivot value
    beq     $t8, $zero, exit
    slt     $t9, $t8, $zero
    bne     $t9, $zero, exit

partitionRight:
	add		$t0, $s1, $a0	    # t0 = *array + high or t0 = &array[high]
	lb		$t0, 0($t0)         # t0 = array[high]
	add		$t1, $s2, $a0	    # t1 = *array + pivot or t1 = &array[pivot]
	lb		$t1, 0($t1)         # t1 = array[pivot]
    # if (array[pivot] > array[high] || low >= high) exit partitionRight
    slt     $t9, $t0, $t1
    bne     $t9, $zero, exitPartitionRight
    slt     $t9, $a1, $s1
    beq     $t9, $zero, exitPartitionRight
	addi	$s1, $s1, -1        # high--
	j		partitionRight
exitPartitionRight:

partitionLeft:
	add		$t0, $s0, $a0	    # t0 = *array + low or t0 = &array[low]
	lb		$t0, 0($t0)         # t0 = array[low]
	add		$t1, $s2, $a0	    # t1 = *array + pivot or t1 = &array[pivot]
	lb		$t1, 0($t1)         # t1 = array[pivot]
    # if (array[low] > array[pivot] || low >= high) exit partitionLeft
    slt     $t9, $t1, $t0
    beq     $t9, $zero, exitPartitionLeft
    slt     $t9, $s0, $a2
    beq     $t9, $zero, exitPartitionLeft
	addi	$s0, $s0, 1         # low++
	j		partitionLeft
exitPartitionLeft:

# if (low < high) swap_pivot_high(array[pivot], array[high]) else swap(array[low, array[high]])
    slt     $t9, $s0, $s1
    bne     $t9, $zero, swap_pivot_high
swap_pivot_low:
	add		$t0, $s0, $a0	    # t0 = *array + low or t0 = &array[low]
	add		$t1, $s2, $a0	    # t1 = *array + high or t1 = &array[high]
	lb		$t2, 0($t0)
	lb		$t3, 0($t1)
	sb		$t3, 0($t0)
	sb		$t2, 0($t1)
	
recursiveLeft:
	addi	$a2, $s1, -1	    # new high = pivot - 1
	jal		quicksort           # call quicksort(&array, low, pivot - 1)
	lw		$a2, 8($sp)    		# restore a2
	lw		$a1, 4($sp)	    	# restore a1
	lw		$ra, 0($sp)    		# restore return address
	
recursiveRight:
	addi	$a1, $s1, 1	    	# new low = pivot + 1
	jal		quicksort           # call quicksort(&array, pivot + 1, high)
	lw		$a2, 8($sp)	    	# restore a2
	lw		$a1, 4($sp)	    	# restore a1
	lw		$ra, 0($sp)	    	# restore return address
	
return:
	lw		$s2, 20($sp)		# restore s2
	lw		$s1, 16($sp)		# restore s1
	lw		$s0, 12($sp)		# restore s0
	addi	$sp, $sp, 24	    # pull up the stack
	jr		$ra

swap_pivot_high:
	add		$t0, $s2, $a0	    # t0 = *array + pivot or t0 = &array[pivot]
	add		$t1, $s1, $a0	    # t1 = *array + high or t1 = &array[high]
	lb		$t2, 0($t0)
	lb		$t3, 0($t1)
	sb		$t3, 0($t0)
	sb		$t2, 0($t1)
	j		partition
	
endPartition:
	lw		$s2, 20($sp)		# restore s2
	lw		$s1, 16($sp)		# restore s1
	lw		$s0, 12($sp)		# restore s0
	addi	$sp, $sp, 24	    # pull up the stack
	jr		$ra

binarySearch:
	sub		$t0, $a1, $a0		# t0 = high - low
	slt		$t9, $t0, $zero		# if (high < low) exit
	bne		$t9, $zero, binaryExit
	div		$t0, $t7
	mflo	$t0					# t0 /= 2
	add		$t1, $a0, $t0		# t1 = index = &array[mid]
	lb		$t2, 0($t1)			# t2 = array[index]
	
	beq		$t2, $a2, binaryReturn	# if (array[index] == x) return index

	slt		$t9, $a2, $t2		# if (x < array[index])
	bne		$t9, $zero, searchLeft
	
searchRight:
	add		$a0, $a0, $t0
	addi	$a0, $a0, 1			# new low = index + 1
	j		binarySearch		# call binarySearch(*array + index + 1, high, x)

searchLeft:
	add		$a1, $a0, $t0
	addi	$a1, $a1, -1		# new high = index - 1
	j		binarySearch		# call binarySearch (*array, index - 1, x)

binaryReturn:
	sub		$t1, $t1, $s0		# calculate the final index of x
	addi	$t1, $t1, 1			# adding 1 to be in range [1,40.000]
	sw		$t1, 0($s7)			# overwrite index at POS
	jr		$ra

binaryExit:
	jr		$ra					# x not found, return without any further action

########### System calls
print_int:
	li 		$v0, 1
	syscall         		    # move to $a0 to print
	jr 		$ra

print_string:
	li 		$v0, 4		        # print a0 (address of string)
	syscall
	jr 		$ra

.data
array:					        # 40.000 1-byte positive integers
.byte 19 111 32 121 51 46 62 94 65 60 101 37 16 92 21 91 78 108 58 101 59 107 57 121 11 20 15 97 74 3 39 92 16 19 110 23 106 73 75 40 124 94 58 52 68 105 75 28 25 90
POS:                         # Binary search result
.word 0

space: .asciiz " "
newLine: .asciiz "\n"