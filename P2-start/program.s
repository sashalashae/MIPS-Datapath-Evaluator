	.text		
main:			# execution starts here

	#Group 4
	sll $zero, $zero, 0
	sub $s3, $s3, $s3
	sub $s2, $s2, $s2
	addi $s1, $s1, 0
	addi $ra, $ra, 0
	test1: addi $s1, $zero, 1
	addi $s2, $zero, 1
	addi $s3, $zero, 2
	j test1
	lui $s4, 0x0004
	jr $ra