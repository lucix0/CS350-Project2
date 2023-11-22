# Static Map
.data 0x10002000    
.ascii " ##  ###"
.ascii "       *"
.ascii "       #"
.ascii "# ###  #"
.ascii "        "
.ascii "   #### "
.ascii "   #    "
.ascii "S ## ## "

# Dynamic Map
.data 0x10003000
.space 64 # Reserved space for the map

.text
.globl main
main:
    # Store return address on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal initialize_game
    or $0, $0, $0
    
    jal game_loop
    or $0, $0, $0

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0

initialize_game:
    # Store return address on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal copy_map
    or $0, $0, $0

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0

game_loop:
    # Store return address on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)

    add $s0, $0, $0 # Termination register
    game_loop_start:
        # Draw current map
        jal print_map
        or $0, $0, $0

        # Wait for user input
        jal get_user_input
        or $0, $0, $0
        add $s1, $0, $v0

        # Update game state

        # Should game terminate by keypress?
        addi $t0, $0, 113 # q ASCII code
        bne $s1, $t0, dont_terminate_from_key
        or $0, $0, $0
        addi $s0, $0, 1
    dont_terminate_from_key:
        # Run loop again if shouldn't terminate
        beq $s0, $0, game_loop_start
        or $0, $0, $0

    lw $s1, 0($sp)
    addi $sp, $sp, 4

    lw $s0, 0($sp)
    addi $sp, $sp, 4

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0

get_user_input:
    # Get character
    addi $v0, $0, 12
    syscall

    jr $ra
    or $0, $0, $0

copy_map:
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)
    
    # Address of static map byte array in data segment
    lui $s0, 0x1000
    ori $s0, 0x2000
    # Address of dynamic map byte array in data segment
    lui $s1, 0x1000
    ori $s1, 0x3000
    # Values
    add $t0, $0, $0 # Byte index
    copy_static_to_dyn_loop:
        add $t1, $s0, $t0 # Construct full character address
        lb $t3, 0($t1) # Pull character from static map
        or $0, $0, $0

        add $t2, $s1, $t0 # Construct full character address
        sb $t3, 0($t2) # Put character into dynamic map

        addi $t0, $t0, 1 # Increment byte index

        # Exit loop if index reaches 64
        addi $t4, $0, 64
        bne $t0, $t4, copy_static_to_dyn_loop
        or $0, $0, $0
        
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0

print_map:
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    
    # Address of dynamic map byte array in data segment
    lui $s0, 0x1000
    ori $s0, 0x3000
    
    # Values
    add $t0, $0, $0 # Byte index
    add $t5, $0, $0 # New line counter
    print_dyn_map_loop:
        add $t1, $s0, $t0 # Construct full character address
        lb $a0, 0($t1) # Pull character from dynamic map
        or $0, $0, $0
        
        # Print character
        addi $v0, $0, 11
        syscall
        
        # If its the 8th byte, print a new line character as well
        addi $t5, $t5, 1
        addi $t6, $0, 8
        bne $t5, $t6, skip_if_not_8th
        addi $v0, $0, 11
        addi $a0, $0, 10
        syscall
        
        add $t5, $0, $0
        
        skip_if_not_8th:
        
        # Increment index
        addi $t0, $t0, 1
        
        # Exit loop if index reaches 64
        addi $t4, $0, 64
        bne $t0, $t4, print_dyn_map_loop
        or $0, $0, $0
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    or $0, $0, $0
