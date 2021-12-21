.text
.globl main

main:
    la $s0, array
    add $s1, $s0, $zero         # copy array index to s1
    add $a0, $s0, $zero         # a0 => arrayPtr = *array
    addiu $a1, $zero, 0         # a1 => low = array[0]
    addiu $a2, $zero, 49        # a2 => high = array[arraySize-1]
    jal quicksort               # sort array

    li $t1, 0                   # array start
    li $t2, 50                  # array end
printArray:
    beq $t1, $t2, exit          # for (int i = 0; i < arraySize; i++)
    lb $a0, 0($s1)
    jal print_int
    la $a0, space
    jal print_string
    addiu $t1, $t1, 1
    add $s1, $s1, 1
    j printArray

exit:
    #break
    li $v0, 10
    syscall

quicksort:
	addi	$sp, $sp, -24       # push down the stack
	sw		$s0, 0($sp)		    # save s0
	sw		$s1, 4($sp)		    # save s1
	sw		$s2, 8($sp)		    # save s2
	sw		$a1, 12($sp)	    # save a1
	sw		$a2, 16($sp)	    # save a2
	sw		$ra, 20($sp)	    # save return address
	addu	$s0, $a1, $zero		# s0 = low
	addu	$s1, $a2, $zero		# s1 = high
	addu	$s2, $a1, $zero		# s2 = pivot (starting with low)

partition:                      # while low < high
    slt $t9, $s0, $s1
    beq $t9, $zero endPartition

checkIllegalPivot:              # if (array[pivot] <= 0) exit
    add     $t8, $a0, $s2       # find current pivot address
    lb      $t8, 0($t8)         # load current pivot value
    beq     $t8, $zero, exit
    slt     $t9, $t8, $zero
    bne     $t9, $zero, exit

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

# if (low < high) swap_pivot_high(array[pivot], array[high]) else swap(array[low, array[high]])
    slt     $t9, $s0, $s1
    bne     $t9, $zero, swap_pivot_high
swap_low_high:
	add		$t0, $s0, $a0	    # t0 = *array + low or t0 = &array[low]
	add		$t1, $s1, $a0	    # t1 = *array + high or t1 = &array[high]
	lb		$t2, 0($t0)
	lb		$t3, 0($t1)
	sb		$t3, 0($t0)
	sb		$t2, 0($t1)
	
recursiveLeft:
	addu	$a2, $s1, $zero
	addi	$a2, $a2, -1	    # high--
	jal		quicksort           # call quicksort(&array, low, high-1)
	lw		$ra, 20($sp)    	# retrieve return address
	lw		$a2, 16($sp)    	# retrieve a2
	lw		$a1, 12($sp)	    # retrieve a1
	
recursiveRight:
	addu	$a1, $s1, $zero
	addi	$a1, $a1, 1	    	# low++
	jal		quicksort           # call quicksort(&array, low+1, high)
	lw		$ra, 20($sp)	    # retrieve return address
	lw		$a2, 16($sp)	    # retrieve a2
	lw		$a1, 12($sp)	    # retrieve a1
	
return:
	lw		$s2, 8($sp)		    # retrieve s2
	lw		$s1, 4($sp)		    # retrieve s1
	lw		$s0, 0($sp)		    # retrieve s0
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
	lw		$s2, 8($sp)		    # retrieve s2
	lw		$s1, 4($sp)		    # retrieve s1
    lw		$s0, 0($sp)		    # retrieve s0
	addi	$sp, $sp, 24	    # pull up the stack
	jr		$ra

########### System calls
print_int:
	li $v0, 1
	syscall         		    # move to $a0 to print
	jr $ra

print_string:
	li $v0, 4		            # print a0 (address of string)
	syscall
	jr $ra

.data
array:					        # 40.000 1-byte positive integers
.byte 19 111 32 121 51 46 62 94 65 60 101 37 16 92 21 91 78 108 58 101 59 107 57 121 11 20 15 97 74 3 39 92 16 19 110 23 106 73 75 40 124 94 58 52 68 105 75 28 25 90
search:                         # Binary search result
.byte 0

space: .asciiz " "