################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
    
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

# The colours being used
MY_COLOURS:
    .word 0xff0000	# red
    .word 0x00ff00	# green
    .word 0xffa500	# orange
    .word 0xffff00	# yellow
    .word 0x008000	# dark green
    .word 0x0000ff	# blue    
    .word 0x4b0082	# purple
    .word 0xee82ee	# pink
    .word 0xffffff	# white
    .word 0x808080	# gray

##############################################################################
# Mutable Data
##############################################################################
BALL: # BALL for x value, BALL + 4 for y value
	.space 8
PADDLE: # PADDLE for x value, PADDLE + 4 for y value
	.space 8
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Knowing where to write (top-left unit): ADR_DSPL
    la $t1, ADDR_DSPL
    lw $t2, 0($t1) 	# $t2 = ADR_DSPL
    
    
    
    # Initializing the game walls
    lw $t4, MY_COLOURS + 36  
 
     top_wall:
    	sw  $t4, 0($t2)		# Displaying the pixel
    	addi $t2, $t2, 4	# Moving the display pixel over by one unit
    	addi $t5, $t5, 1	# Incrementing the counter
    	blt $t5, 32, top_wall	# Loop if conditions not met
    
    lw $t2, 0($t1) 		# Resetting address display pixel
    
    left_wall:
    	sw  $t4, 0($t2)
    	addi $t2, $t2, 128	# Moving the display pixel to the next row
    	addi $t6, $t6, 1
    	blt $t6, 32, left_wall
    
    lw $t2, 0($t1) 
    
    right_wall:	
    	sw  $t4, 252($t2)
    	addi $t2, $t2, 128	# Moving the display pixel to the next row
    	addi $t7, $t7, 1
    	blt $t7, 32, right_wall



    li $t2, 32
    li $t3, 0
    li $t8, 0
    
    lw $t1, 0($t1)
    la $t0, MY_COLOURS
    seven_line_loop:	# draws seven lines
	beq $t8, 7, draw_paddle
	lw $t2,0($t0)
        addi $t0,$t0, 4
	add $t8, $t8, 1
	li $t9, 0
	
    # Each line is 32 units -> 32 times drawing a line
    draw_line_loop:	# draws one line
    	bge $t9, 30, new_line	# 32 total pixels per row - 2 edge walls
    	sw  $t2, 132($t1)	# 132 - starts drawing at second row second pixel
    	addi $t1, $t1, 4
    	addi $t9, $t9, 1
    	b draw_line_loop
    
    new_line: 		# goes to a new line
	addi $t1, $t1, 8 	# sets display pixel to be second pixel of next line
	b seven_line_loop
	
    
    draw_paddle: 		#draws the paddle
    	li $t0, 14	
    	sw $t0, PADDLE 		#loads default paddle's x-value
    	li $t0, 24
    	sw $t0, PADDLE + 4 	#loads defalut paddle's y-value
    	lw $t0, MY_COLOURS + 36
    	lw $a0, PADDLE 		#function parameter - paddle's x-value
    	lw $a1, PADDLE + 4 	#function parameter - paddle's y-value
    	jal get_location_address
    	sw $t0, ($v0)		#store gray colour in address returned by function
    
    draw_paddle_loop:
    	beq $t3, 4, draw_ball
    	addi $v0, $v0, 4	#given address is the leftest pixel of the paddle, add 4 to move right
    	sw $t0, ($v0)		#store gray
    	addi $t3, $t3, 1	#loop 4 times (for paddle of length 4)
    	b draw_paddle_loop
    
    draw_ball:
    	li $t0, 16	
    	sw $t0, BALL 		#loads default ball's x-value
    	li $t0, 22
    	sw $t0, BALL + 4 	#loads default ball's y-value
    	lw $t0, MY_COLOURS + 32
    	lw $a0, BALL 		#function parameter - ball's x-value
    	lw $a1, BALL + 4 	#function parameter - ball's y-value
    	jal get_location_address
    	sw $t0, ($v0)		#store white colour in address returned by function (the ball)
    
game_loop:
	# 1a. Check if key has been pressed 
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
    
get_location_address:
    # Each unit is 4 bytes. Each row has 32 units (128 bytes)
	sll 	$a0, $a0, 2		# x = x * 4
	sll 	$a1, $a1, 7             # y = y * 128

    # Calculate return value
	la 	$v0, ADDR_DSPL 		# res = address of ADDR_DSPL
    	lw      $v0, 0($v0)             # res = address of (0, 0)
	add 	$v0, $v0, $a0			# res = address of (x, 0)
	add 	$v0, $v0, $a1           # res = address of (x, y)

    jr $ra
