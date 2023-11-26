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

# Player Variables
.data 0x10004000
.word 0 # X position
.word 7 # Y position
.word 0 # Score

# Text prompts
.data 0x10005000
.asciiz "Score: "
.align 5
.asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

.text
.globl main


#####################
#                   #
#     Main Code     #
#                   #
##################### 


# Name: main
# Description: Initializes game and begins game loop
# Arguments: None
# Return: None
main:
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


# Name: initialize_game
# Description: Prepares initial game map
# Arguments: None
# Return: None
initialize_game:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal update_map
    or $0, $0, $0

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0


# Name: game_loop
# Description: Runs game logic
# Arguments: None
# Return: None
game_loop:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)

    add $s0, $0, $0 # Termination register
    game_loop_start:
        # Display screen elements like map and score
        jal display_screen
        or $0, $0, $0

        # Wait for user input
        jal get_user_input
        or $0, $0, $0
        add $s1, $0, $v0

        # Is it w?
        addi $t0, $0, 119 # 'w' ASCII code
        bne $s1, $t0, skip_not_w
        or $0, $0, $0
        # Move player up 1 unit
        addi $a0, $0, 0
        addi $a1, $0, -1
        jal move_player
        or $0, $0, $0
    skip_not_w:
        # Is it a?
        addi $t0, $0, 97 # 'a' ASCII code
        bne $s1, $t0, skip_not_a
        or $0, $0, $0
        # Move player left 1 unit
        addi $a0, $0, -1
        addi $a1, $0, 0
        jal move_player
        or $0, $0, $0
    skip_not_a:
        # Is it s?
        addi $t0, $0, 115 # 's' ASCII code
        bne $s1, $t0, skip_not_s
        or $0, $0, $0
        # Move player down 1 unit
        addi $a0, $0, 0
        addi $a1, $0, 1
        jal move_player
        or $0, $0, $0
    skip_not_s:
        # Is it d?
        addi $t0, $0, 100 # 'd' ASCII code
        bne $s1, $t0, skip_not_d
        or $0, $0, $0
        # Move player right 1 unit
        addi $a0, $0, 1
        addi $a1, $0, 0
        jal move_player
        or $0, $0, $0
    skip_not_d:
        # Is it q?
        addi $t0, $0, 113 # q ASCII code
        bne $s1, $t0, skip_none
        or $0, $0, $0
        addi $s0, $0, 1
    skip_none:
        # Update map
        jal update_map
        or $0, $0, $0
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


#####################
#                   #
#     Game Code     #
#                   #
##################### 


# Name: move_player
# Description: Change the player's position by given amounts if new position is clear
# Arguments: a0 - Delta-X, a1 - Delta-Y
# Return: None
move_player:
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)

    addi $sp, $sp, -4
    sw $s2, 0($sp)

    addi $sp, $sp, -4
    sw $s3, 0($sp)

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Address of player data
    lui $s0, 0x1000
    addi $s0, $s0, 0x4000

    # Load X Position
    lw $s1, 0($s0)
    or $0, $0, $0
    # Load Y Position
    lw $s2, 4($s0)
    or $0, $0, $0

    # Apply change
    # X-Position
    add $s1, $s1, $a0
    # Y-Position
    add $s2, $s2, $a1

    # Is the new player location open?
    # If not, don't move player
    # Get character at position
    add $a0, $0, $s1
    add $a1, $0, $s2
    jal position_to_offset
    or $0, $0, $0
    add $t0, $0, $v0

    # Construct address of map
    lui $t2, 0x1000
    addi $t2, $t2, 0x3000

    # Get character at position
    add $t2, $t2, $t0
    lb $s3, 0($t2)
    or $0, $0, $0

    # If its not a wall, change position
    # Otherwise, don't change position
    addi $t3, $0, 35 # '#' ASCII code
    beq $s3, $t3, skip_wall
    or $0, $0, $0
    sw $s1, 0($s0)
    sw $s2, 4($s0)

    skip_wall:

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    lw $s3, 0($sp)
    addi $sp, $sp, 4

    lw $s2, 0($sp)
    addi $sp, $sp, 4

    lw $s1, 0($sp)
    addi $sp, $sp, 4

    lw $s0, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0


#####################
#                   #
#      Utility      #
#                   #
##################### 


# Name: get_user_input
# Description: Gets character from user
# Arguments: None
# Return: v0 - User Character
get_user_input:
    # Get character
    addi $v0, $0, 12
    syscall

    jr $ra
    or $0, $0, $0


# Name: position_to_offset
# Description: Covert memory offset from (x, y) position
# Arguments: a0 - X, a1 - Y
# Return: v0 - Offset
position_to_offset:
    # Offset = Y * 8 + X
    addi $t0, $0, 8
    mult $a1, $t0
    mflo $t0
    or $0, $0, $0
    add $v0, $a0, $t0

    jr $ra
    or $0, $0, $0


#####################
#                   #
#      Display      #
#                   #
##################### 


# Name: update_map
# Description: Wipe map data and recreate with new dynamic object states
# Arguments: None
# Return: None
update_map:
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)

    addi $sp, $sp, -4
    sw $s2, 0($sp)

    addi $sp, $sp, -4
    sw $s3, 0($sp)

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Copy static elements into the dynamic map (Walls and Exit Gate)
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

        # What is the character?
        # If its not static, place a space
        # Otherwise, just place the given character
        addi $t4, $0, 83 # 'S' ASCII code
        bne $t4, $t3, skip_static
        or $0, $0, $0
        addi $t3, $0, 32 # ' ' ASCII code

    skip_static:
        add $t2, $s1, $t0 # Construct full character address
        sb $t3, 0($t2) # Put character into dynamic map

        addi $t0, $t0, 1 # Increment byte index

        # Exit loop if index reaches 64
        addi $t4, $0, 64
        bne $t0, $t4, copy_static_to_dyn_loop
        or $0, $0, $0

    # Place player into map
    # Address of player data
    lui $t0, 0x1000 
    ori $t0, 0x4000
    lb $s2, 0($t0) # X-Position
    or $0, $0, $0
    lb $s3, 4($t0) # Y-Position
    or $0, $0, $0

    add $a0, $0, $s2
    add $a1, $0, $s3
    jal position_to_offset
    or $0, $0, $0
    add $t1, $0, $v0

    # Place player at this address
    lui $t0, 0x1000 
    ori $t0, 0x3000
    add $t0, $t0, $t1
    addi $t2, $0, 83 # 'S' ASCII code
    sb $t2, 0($t0)

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    lw $s3, 0($sp)
    addi $sp, $sp, 4
    
    lw $s2, 0($sp)
    addi $sp, $sp, 4

    lw $s1, 0($sp)
    addi $sp, $sp, 4
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0


# Name: display_screen
# Description: Displays map and score
# Arguments: None
# Return: None
display_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal clear_screen
    or $0, $0, $0

    jal print_map
    or $0, $0, $0

    jal print_score
    or $0, $0, $0

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    or $0, $0, $0


# Name: clear_screen
# Description: Blank out console, so game is easily readable
# Arguments: None
# Return: None
clear_screen:
    addi $v0, $0, 4
    lui $a0, 0x1000
    addi $a0, $a0, 0x5000
    addi $a0, $a0, 32
    syscall

    jr $ra
    or $0, $0, $0


# Name: print_map
# Description: Print dynamic map data to console
# Arguments: None
# Return: None 
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

    # Move cursor down with new line character
    addi $v0, $0, 11
    addi $a0, $0, 10
    syscall
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    or $0, $0, $0


# Name: print_score
# Description: Print current score
# Arguments: None
# Return: None
print_score:
    # Print score prompt
    addi $v0, $0, 4
    lui $a0, 0x1000
    addi $a0, $a0, 0x5000
    syscall

    # Print score number
    addi $v0, $0, 1
    lui $t0, 0x1000
    addi $t0, $t0, 0x4000
    lw $a0, 8($t0)
    or $0, $0, $0
    syscall

    # Move cursor down with new line character
    addi $v0, $0, 11
    addi $a0, $0, 10
    syscall

    jr $ra
    or $0, $0, $0
