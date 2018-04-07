	.text		
main:			# execution starts here

	
#Group 3
	sub $s3, $s3, $s3
	sub $s2, $s2, $s2
	sub $s1, $s1, $s1
    lui $s2, 0x1000
	beq $zero, $zero, eq
	addi $s3, $zero, 7
	eq: addi $s3, $zero, 8
	bne $zero, $s2, noteq
	addi $s3, $zero, 0
	noteq: addi $s1, $zero, 1




