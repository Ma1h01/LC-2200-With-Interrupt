! Fall 2023 Revisions 

! This program executes pow as a test program using the LC 2222 calling convention
! Check your registers ($v0) and memory to see if it is consistent with this program

! vector table
vector0:
        .fill 0x00000000                        ! device ID 0
        .fill 0x00000000                        ! device ID 1
        .fill 0x00000000                        ! ...
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000
        .fill 0x00000000                        ! device ID 7
        ! end vector table

main:	lea $sp, initsp                         ! initialize the stack pointer
        lw $sp, 0($sp)                          ! finish initialization

        lea $t0, vector0

        lea $t1, timer_handler                 ! TODO FIX ME: Install timer interrupt handler into vector table
        sw $t1, 0($t0)



        lea $t1, distance_tracker_handler                 ! TODO FIX ME: Install distance tracker interrupt handler into vector table
        sw $t1, 1($t0)


        lea $t0, minval
        lw $t0, 0($t0)
	lea $t1, INT_MAX 			! store 0x7FFFFFFF into minval (to initialize)
	lw $t1, 0($t1)	                  		
        sw $t1, 0($t0)

        ei                                      ! Enable interrupts

        lea $a0, BASE                           ! load base for pow
        lw $a0, 0($a0)
        lea $a1, EXP                            ! load power for pow
        lw $a1, 0($a1)
        lea $at, POW                            ! load address of pow
        jalr $at, $ra                           ! run pow
        lea $a0, ANS                            ! load base for pow
        sw $v0, 0($a0)

        halt                                    ! stop the program here
        addi $v0, $zero, -1                     ! load a bad value on failure to halt

BASE:   .fill 2
EXP:    .fill 8
ANS:	.fill 0                                 ! should come out to 256 (BASE^EXP)

INT_MAX: .fill 0x7FFFFFFF

POW:    addi $sp, $sp, -1                       ! allocate space for old frame pointer
        sw $fp, 0($sp)

        addi $fp, $sp, 0                        ! set new frame pointer

        bgt $a1, $zero, BASECHK                 ! check if $a1 is zero
        beq $zero, $zero, RET1                  ! if the exponent is 0, return 1

BASECHK:bgt $a0, $zero, WORK                    ! if the base is 0, return 0
        beq $zero, $zero, RET0

WORK:   addi $a1, $a1, -1                       ! decrement the power
        lea $at, POW                            ! load the address of POW
        addi $sp, $sp, -2                       ! push 2 slots onto the stack
        sw $ra, -1($fp)                         ! save RA to stack
        sw $a0, -2($fp)                         ! save arg 0 to stack
        jalr $at, $ra                           ! recursively call POW
        add $a1, $v0, $zero                     ! store return value in arg 1
        lw $a0, -2($fp)                         ! load the base into arg 0
        lea $at, MULT                           ! load the address of MULT
        jalr $at, $ra                           ! multiply arg 0 (base) and arg 1 (running product)
        lw $ra, -1($fp)                         ! load RA from the stack
        addi $sp, $sp, 2

        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET1:   add $v0, $zero, $zero                   ! return a value of 0
	addi $v0, $v0, 1                        ! increment and return 1
        beq $zero, $zero, FIN                   ! unconditional branch to FIN

RET0:   add $v0, $zero, $zero                   ! return a value of 0

FIN:	lw $fp, 0($fp)                          ! restore old frame pointer
        addi $sp, $sp, 1                        ! pop off the stack
        jalr $ra, $zero

MULT:   add $v0, $zero, $zero                   ! return value = 0
        addi $t0, $zero, 0                      ! sentinel = 0
AGAIN:  add $v0, $v0, $a0                       ! return value += argument0
        addi $t0, $t0, 1                        ! increment sentinel
        blt $t0, $a1, AGAIN                     ! while sentinel < argument, loop again
        jalr $ra, $zero                         ! return from mult

timer_handler:
        addi $sp, $sp, -1                 ! TODO FIX ME
        sw $k0, 0($sp)
        ei
        addi $sp, $sp, -15
        sw $zero, 14($sp)
        sw $at, 13($sp)
        sw $v0, 12($sp)
        sw $a0, 11($sp)
        sw $a1, 10($sp)
        sw $a2, 9($sp)
        sw $t0, 8($sp)
        sw $t1, 7($sp)
        sw $t2, 6($sp)
        sw $s0, 5($sp)
        sw $s1, 4($sp)
        sw $s2, 3($sp)
        sw $sp, 2($sp)
        sw $fp, 1($sp)
        sw $ra, 0($sp)

        lea $t0, ticks
        lw $t0, 0($t0)
        lw $t1, 0($t0)
        addi $t1, $t1, 1
        sw $t1, 0($t0)

        lw $zero, 14($sp)
        lw $at, 13($sp)
        lw $v0, 12($sp)
        lw $a0, 11($sp)
        lw $a1, 10($sp)
        lw $a2, 9($sp)
        lw $t0, 8($sp)
        lw $t1, 7($sp)
        lw $t2, 6($sp)
        lw $s0, 5($sp)
        lw $s1, 4($sp)
        lw $s2, 3($sp)
        lw $sp, 2($sp)
        lw $fp, 1($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 15
        di
        lw $k0, 0($sp)
        addi $sp, $sp, 1
        reti


distance_tracker_handler:
        addi $sp, $sp, -1                 ! TODO FIX ME
        sw $k0, 0($sp)
        ei
        addi $sp, $sp, -5
        sw $t0, 0($sp)
        sw $t1, 1($sp)
        sw $t2, 2($sp)
        sw $a0, 3($sp)
        sw $s0, 4($sp)

        in $a0, 1       
        lea $t0, maxval
        lw $t0, 0($t0)  ! t0 = max address
        lw $t0, 0($t0) ! t0 = max value 
        lea $t1, minval
        lw $t1, 0($t1)  ! t1 = min address
        lw $t1, 0($t1) ! t1 = min value 


        bgt $a0, $t0, set_max
        check_min:
        blt $a0, $t1, set_min
        beq $zero, $zero, finish ! in the middle, do nothing

        set_max:
        lea $t0, maxval
        lw $t0, 0($t0)  ! t0 = max address
        sw $a0, 0($t0)
        !bgt $a0, $t1, finish ! if a0 greater curr max and min, no need to update min
        beq $zero, $zero,check_min

        set_min:
        lea $t0, minval
        lw $t0, 0($t0)  ! t0 = min address
        sw $a0, 0($t0)

        finish:
        lea $t0, minval
        lw $t0, 0($t0)
        lw $t0, 0($t0)
        lea $t1, maxval
        lw $t1, 0($t1)
        lw $t1, 0($t1)
        nand $t0, $t0, $t0
        addi $t0, $t0, 1
        add $t2, $t1, $t0
        lea $s0, range
        lw $s0, 0($s0)
        sw $t2, 0($s0)

        lw $t0, 0($sp)
        lw $t1, 1($sp)
        lw $t2, 2($sp)
        lw $a0, 3($sp)
        lw $s0, 4($sp)
        addi $sp, $sp, 5
        di
        lw $k0, 0($sp)
        addi $sp, $sp, 1
        reti


initsp: .fill 0xA000
ticks:  .fill 0xFFFF
range:  .fill 0xFFFE
maxval: .fill 0xFFFD
minval: .fill 0xFFFC