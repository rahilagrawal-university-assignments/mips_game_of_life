# board.s ... Game of Life on a 10x10 grid

   .data

N: .word 15  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225

#######################################################################
# Written by Rahil Agrawal, August 2017								  #
# Last Edited, 24 August 2017										  #
# Game of Life on a 10x10 grid										  #
#																	  #
#																	  #
#######################################################################

#######################################################################
#						Main										  #
#######################################################################
    .data
n_t0:
    .word 0
n_a0:
    .word 0

	.align 4
main_ret_save:
	.space 4

	.align 4
maxiters:
	.word 0

iterations:
	.asciiz "# Iterations: "

msg1:
	.asciiz "=== After iteration "

msg2:
	.asciiz " ==="
#######################################################################
   .text
   .globl main

main:
    sw   $ra, main_ret_save

	loop1_initial:                 #       n = 1
		li    $s5, 1

	loop1:                         #       n <= maxiters
		j loop2_initial

	loop2_initial:                #        i = 0
		li	  $s6, 0
		j loop2_condition

	loop2_condition:              #        i < n
		lw	  $t3, N
		bne   $s6, $t3, loop3_initial #    loop3_initial
		#la    $a0, eol            #        printf("\n")
		#li    $v0, 4
		#syscall

        jal mydelay
        jal print_newlines
        la    $a0, msg1           #        printf("=== After iteration);
		li    $v0, 4
		syscall

		move  $a0, $s5            #        printf("$d", n)
		li    $v0, 1
		syscall

		la    $a0, msg2           #        printf("===")
		li    $v0, 4
		syscall

        la    $a0, eol
        li     $v0,4
        syscall
		jal copyBackAndShow        #       copyBackAndShow()

		addi  $s5, $s5, 1
                                #       n++
		j 	  loop1

	loop3_initial:
		li	  $s7, 0               #       j = 0
		j loop3_condition

	loop3_condition:               #       j < N
		bne   $s7, $t3, loop3
		addi  $s6, $s6, 1
		j loop2_condition

	loop3:                         #       if (board[i][j] == 1) {

		if_1_start:
			mul   $t5, $t3, $s6
			add   $t5, $t5, $s7
			la	  $t6, board
			add	  $t6, $t6, $t5
			lb    $t6, ($t6)
			bnez  $t6, if_2_start
			j     else_if_1

		if_2_start:                #      if (nn < 2)
			move  $a3, $s6
			move  $a1, $s7
			jal   neighbours
			move  $s4, $v0
			li    $t7, 3
			bgt	  $s4, $t7, else_2
			beq   $s4, $t7, else_if_2
			li    $t7, 2
			beq   $s4, $t7, else_if_2
			######################
			lw	  $t3, N
			mul   $s1, $t3, $s6
			add   $s1, $s1, $s7
			li    $t6, 0
			la    $s3, newBoard
			add   $s3, $s3, $s1
			sb    $t6, ($s3)
			######################
			# newBoard[i][j] = 0 #
			######################
			j loop3_next
		else_if_2:                #      else if (nn ==2 || nn == 3) newboard[i][j] = 1;
			lw	  $t3, N
			mul   $s1, $t3, $s6
			add   $s1, $s1, $s7
			li    $t6, 1
			la    $s3, newBoard
			add   $s3, $s3, $s1
			sb    $t6, ($s3)
			######################
			# newBoard[i][j] = 1 #
			######################
			j loop3_next

		else_2:                   #     else newboard[i][j] = 0;
			lw	  $t3, N
			mul   $s1, $t3, $s6
			add   $s1, $s1, $s7
			li    $t6, 0
			la    $s3, newBoard
			add   $s3, $s3, $s1
			sb    $t6, ($s3)
			######################
			# newBoard[i][j] = 0 #
			######################
			j loop3_next


		else_if_1:                #    else if (nn == 3) newboard[i][j] = 1;
			move  $a3, $s6
			move  $a1, $s7
			jal   neighbours
			move  $s4, $v0
			li	  $t7, 3
			bne   $s4, $t7, else_1
			#######################
			lw	  $t3, N
			mul   $s1, $t3, $s6
			add   $s1, $s1, $s7
			li    $t6, 1
			la    $s3, newBoard
			add   $s3, $s3, $s1
			sb    $t6, ($s3)
			######################
			# newBoard[i][j] = 1 #
			######################
			j loop3_next

		else_1:                   #    else newboard[i][j] = 0;
			######################
			lw	  $t3, N
			mul   $s1, $t3, $s6
			add   $s1, $s1, $s7
			li    $t6, 0
			la    $s3, newBoard
			add   $s3, $s3, $s1
			sb    $t6, ($s3)
			######################
			# newBoard[i][j] = 0 #
			######################
			j loop3_next



	loop3_next:                  #    j++
		addi  $s7, $s7, 1
		j loop3_condition

end_main:
   lw   $ra, main_ret_save
   jr   $ra

#######################################################################
#							Neighbours								  #
#######################################################################

	.data

	.align 4
neighbours_ret_save:
	 .space 4

	.align 4
nn:
	.word  0

#######################################################################
#############
#  $a3 = i  #
#  $a1 = j  #
#############

	.text

neighbours:
	sw	  $ra, neighbours_ret_save
	sw    $zero, nn 					#		nn  = 0
	lw    $t9, N						# 		$t9 = N
	addi  $t9, $t9, -1					#		$t9 = N - 1

	loop_1_initial:
		li   $t0, 2      			    #		$t0 -> x<=1
		li   $t1, -1					#		$t1 = x

	loop_1:
		bne  $t1, $t0, loop_2_initial 	# 		check x<=1
		j    end_neighbours

	loop_2_initial:
		li   $t2, 2						#		$t2 -> y<=1
		li   $t3, -1					#		$t3 = y
		j    loop_2_condition

	loop_2_condition:
		bne   $t3, $t2, loop_2 			# 		check y<=1
		add   $t1, $t1, 1				# 		x++
		j loop_1

	loop_2:
		add   $t7, $a3, $t1				#		$t7 = i+x
		bltz  $t7, loop_2_continue		#		i+x < 0     continue
		bgt   $t7, $t9, loop_2_continue #		i+x > N-1   continue
		add   $t8, $a1, $t3 		    #		$t8 = j+y
		bltz  $t8, loop_2_continue		#		j+y < 0     continue
		bgt   $t8, $t9, loop_2_continue #		j+y > N-1   continue

		li    $t5, 5
		li    $t6, 6
		mul   $t5, $t1, $t5				#		x=0 and y=0 continue
		mul   $t6, $t3, $t6
		add   $t5, $t5, $t6
		beq   $t5, $zero, loop_2_continue

										#		if (board[i+x][j+y] == 1)
		lw    $s2, N
		move  $t5, $t7					#		$t5 = i + x
		mul   $t5, $t5, $s2 			#		$t5 = 10(i+x)
		add   $t5, $t5, $t8				#		$t5 = 10(i + x) + (j+y)
		la    $t6, board				#       $t6 = board

		add   $t6, $t6, $t5				#		$t6 = board + $t5
		lb    $t5, ($t6)				#		$t5 = *board


		beq   $t5, $zero, loop_2_continue
		lw    $t6, nn
		addi  $t6, $t6, 1
		sw    $t6, nn					#		n++
		j     loop_2_continue

	loop_2_continue:
		addi $t3, $t3, 1				#		y++
		j loop_2_condition


end_neighbours:							#		return to main
	lb   $v0, nn
	lw   $ra, neighbours_ret_save
   	jr   $ra

#######################################################################
#						Copy_back_and_Show							  #
#######################################################################

	.data

copyBackAndShow_ret_save:
	 .space 4

eol:
	.asciiz "\n"						#		new line character
dot:
	.asciiz "."							#		print '.' if dead cell
hash:
	.asciiz "#"							#		print '#' if alive cell
#######################################################################
	.text

copyBackAndShow:
	sw    $ra, copyBackAndShow_ret_save

	loop_1__initial:
		li   $t0, 0						#		i = 0
		lw   $t1, N						#		i < N

	loop__1:
		bne  $t0, $t1, loop_2__initial	#		i < N , inner_loop
		j end_copyBackAndShow			#		else go to main()

	loop_2__initial:
		li   $t2, 0						#		j = 0
		lw   $t3, N						#		j < n

	loop_2__condition:
		bne  $t2, $t3, loop__2			#		if j < n, inner_loop_body
		add  $t0, $t0, 1				#		else, i++,
		la   $a0, eol					#		printf("\n");
		li   $v0, 4
		syscall
		j   loop__1						#		check outer_loop_condition

	loop__2:
		move $t4, $t0					#		$t4 = i
		lw   $t3, N						#		$s3 = 10
		mul  $t4, $t4, $t3				#		$t4 = 10*i
		add  $t4, $t4, $t2				#		$t4 = 10*i + j
		la   $t5, newBoard				#		$t5 -> newBoard

		add	 $t5, $t5, $t4				#		$t5 -> newBoard[i][j]
		lb   $t5, ($t5)					#		$t5 = newBoard[i][j]

		la   $s0, board					#		$s0 ->board
		add  $s0, $s0, $t4				#		$s0 -> board[i][j]
		sb   $t5, ($s0)					#		board[i][j] = newB0ard[i][j]

		beqz $t5, print_0				#		$t5 == 0 , print '.'
		j    print_1					#		$t5 == 1 , print '#'

		print_0:
			la $a0, dot 				#		printf(".");
			li $v0, 4
			syscall
			j loop_2_next

		print_1:						#		printf("#");
			la $a0, hash
			li $v0, 4
			syscall

	loop_2_next:						#		j++
		add  $t2, $t2, 1
		j    loop_2__condition			#		check inner loop condition


end_copyBackAndShow:					#		return to main
	lw   $ra, copyBackAndShow_ret_save
    jr   $ra

mydelay:
    sw      $t0, n_t0       #

    li      $t0, 500000
    loop_mydelay:
    addi    $t0, $t0, -1
    bgez    $t0, loop_mydelay

exit_mydelay:
    lw      $t0, n_t0        #
    jr      $ra

print_newlines:
    sw      $a0, n_a0
    sw      $t0, n_t0       #

    li      $t0, 0
    loop_print:
    bgt     $t0, 100, exit_print_newlines   #$a0 <50t     la      $a0, eol
    la      $a0, eol
    li      $v0, 4
    syscall
    addi    $t0, $t0, 1
    j  loop_print

    exit_print_newlines:
        lw $a0, n_a0
        lw $t0, n_t0
        jr $ra

         #
            #



#######################################################################
