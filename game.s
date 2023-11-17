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

    addi $sp, $sp, -4
    sw $s0, 0($sp)

    addi $sp, $sp, -4
    sw $s1, 0($sp)
    # Copy static map data to dynamic map
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

    jr $ra
    or $0, $0, $0

print_map:
    jr $ra
    or $0, $0, $0
