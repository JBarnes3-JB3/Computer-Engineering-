.text
.globl main

main:
    li $t0, 5
    li $t1, 5
    li $t2, 0
    li $t3, 10

    # Test beq (Branch if Equal)
    beq $t0, $t1, equal_case

    # Test bne (Branch if Not Equal)
    bne $t0, $t1, not_equal_case

    # Test j (Jump)
    j jump_label

equal_case:
    li $t2, 1

not_equal_case:
    li $t2, 2

jump_label:
    # Test jr (Jump Register)
    jal jal_label
    jr $t3

jal_label:
    li $t2, 3

    # Exit program
    halt
