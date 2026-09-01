.data
    num1:   .word 10
    num2:   .word 5
    result: .word 0

.text
    .globl main

main:
    lw  $t0, num1     # Load num1 into $t0
    lw  $t1, num2     # Load num2 into $t1

    # Arithmetic instructions
    add $t2, $t0, $t1 # $t2 = $t0 + $t1
    sub $t3, $t0, $t1 # $t3 = $t0 - $t1
    addi $t2, $t2, 8 # $t2 = $t2 + 8
    subi $t3, $t3, 9 # $t3 = $t3 - 9

    # Logical instructions
    and $t5, $t0, $t1 # $t5 = $t0 & $t1
    or  $t6, $t0, $t1 # $t6 = $t0 | $t1
    xor $t7, $t0, $t1 # $t7 = $t0 ^ $t1
    nor $t8, $t0, $t1 # $t8 = ~($t0 | $t1)

    # Shift instructions
    sll $t9, $t0, 2   # $t9 = $t0 << 2
    srl $t0, $t0, 1   # $t0 = $t0 >> 1
    sra $t1, $t1, 1   # $t1 = $t1 >> 1

    # Set on less than instruction
    slt $t2, $t0, $t1 # $t2 = 1 if $t0 < $t1, else 0

    # Store result
    sw  $t2, result   # Store the result in 'result'

    # Exit
    halt

