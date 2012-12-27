# Name and section: Peter Collins, section 2
# Partner's Name and section: Brennan Schmidt, section 2

.data
str_prompt1:    .asciiz "Typing test. Enter the string:\n"
str_prompt2:    .asciiz "The quick brown fox jumped over the lazy dog.\n"
str_prompt3:    .asciiz "Number of incorrect characters:  "
str_prompt4:    .asciiz "Take the test again? Enter 'y' to try again.  "
newline:        .byte "\n"	
negative:       .byte "-"
correct_str:    .asciiz "The quick brown fox jumped over the lazy dog."
char_array: .byte 0:144
integer_array: .word 0:32

.text
__start:   
    sub  $sp, $sp, 8            # 2 parameters (max) passed from main()
                                #   so allocate stack space for them  
begin_program:
    la $4 str_prompt1            # print intial prompts
    addi $2, $0, 4
    syscall
    la $4 str_prompt2
    addi $2, $0, 4
    syscall
    
    la $8, char_array           # load and save out going parameter array address
    sw $8, 4($sp)
    jal user_test               # call the user testing function

    la $4 str_prompt3           # print incorrect number prompt
    addi $2, $0, 4
    syscall

    la $8, char_array           # load and save out going parameter array addresses
    sw $8, 4($sp)
    la $9, correct_str
    sw $9, 8($sp)
    jal compare_strings         # call the compare string functions

    sw    $v0, 4($sp)           # print the result of compare string function
    li    $9, 10                # set base of integer to 10
    sw    $9, 8($sp)
    jal print_integer           # call print integer

    lb $4, newline             # print a new line after integer
    addi $2, $0, 11
    syscall


    la $8, char_array           # load and save out going parameter array address
    sw $8, 4($sp)
    jal clear_array             # call to clear the user entered char 
                                # array incase they want to test


    la $4 str_prompt4           # prompt user to test again
    addi $2, $0, 4
    syscall

    addi $2, $0, 12
    syscall
	add  $8, $2, $0
    li $9, 121                  # load ascii character 'y' to test against
    lb $4, newline             # print new line after response
    addi $2, $0, 11
    syscall
    beq $8, $9, begin_program   # restart of yes, otherwise finish
    b    end_program

end_program:    
   done

##################################
#user_test:
# recieves the address of array to put user character in as input
# and returns nothing
user_test:
#prologue
	sub $sp, 16
	sw  $ra, 16($sp)
    sw  $8,  4($sp)
    sw  $9,  8($sp)
    sw  $10, 12($sp)
    lw $10, 20($sp)         # address of user entered character array

    lb $9, newline          # load ascii newline character to test against
test_loop:
    addi $2, $0, 12
    syscall
    add  $8, $2, $0                 # get user character
    beq $8, $9, end_test    # if it is newline break out of test loop
    sb $8, ($10)            # store user entered character in array
    add $10, $10, 1         # increment the array address pointer
    b test_loop
end_test:
    add $10, $10, 1         # always terminate the user string with a null 
    li $8, 0                # character
    sb $8, ($10)                
#epilogue
	li   $v0, 0
	lw   $8,  4($sp)          # restore register values
    lw   $9,  8($sp)
    lw   $10, 12($sp)
    lw   $ra, 16($sp)
    add  $sp, $sp, 16 
	jr $ra


##################################
#compare_strings:
# receives two parameters, the address of array of characters entered by the user, and the address of array of the correct character string
# and returns the number of incorrect characters
compare_strings:
#prologue
	sub $sp, 24
	sw $ra, 24($sp)
    sw $8,  4($sp)
    sw $9,  8($sp)
    sw $10, 12($sp)
    sw $11, 16($sp)
    sw $12, 20($sp)
    lw $10, 28($sp)         # user entered string
    lw $9, 32($sp)          # string to compare against

    li $8, 0                # counter for incorrect characters
compare_loop:
    lb $11, ($9)            # load current character for correct string
    lb $12, ($10)           # load current character for user string
    beq $11, $12, skip_increment_counter # if character are equal, skip incrementing counter
    add $8, $8, 1           # increment the counter
skip_increment_counter:    
    beqz $11, skip_increment_correct_str    # skip loading past end of correct array
    add $9, $9, 1           # increment correct array address pointer
skip_increment_correct_str:
    add $10, $10, 1         # increment user entered array address pointer
    beqz $11, check_user_char   # if correct string is ended, check if user string is ended
    b compare_loop          # else check the next character
check_user_char:            # if user entered string is ended, break out of the loop
    beqz $12, end_compare   # else check the next character
    b compare_loop 
end_compare:
#epilogue
	move  $v0, $8           # return the number in the incorrect counter
	lw   $8,  4($sp)        # restore register values
    lw   $9,  8($sp)
    lw   $10, 12($sp)
    lw   $11, 16($sp)
    lw   $12, 20($sp)
    lw   $ra, 24($sp)
    add  $sp, $sp, 24 
	jr $ra

##################################
#clear_array:
# receives one parameter, the address of array of characters to be cleared
# and returns nothing
clear_array:
#prologue
	sub $sp, 16
	sw $ra, 16($sp)
    sw $8,  4($sp)
    sw $9,  8($sp)
    sw $10,  12($sp)
    lw $8, 20($sp)          # address of array of characters to clear
    li $10, 0               # value to clear array with
clear_loop:
    lb $9, ($8)             # load current character of array
    sb $10, ($8)            # clear that character
    beqz $9, end_clear      # if original character was null break out of the loop
    add $8, $8, 1           # else check and clear the next character
    b clear_loop
end_clear:
#epilogue
	li  $v0, 0
	lw   $8,  4($sp)          # restore register values
    lw   $9,  8($sp)
    lw   $10,  12($sp)
    lw   $ra, 16($sp)
    add  $sp, $sp, 16
	jr $ra


##################################
#print_integer:
# receives two parameters, an integer to be printed, and a base radix to print out,
# and prints it out
print_integer:
#prologue
	sub $sp, 24
	sw  $ra, 24($sp)
    sw   $8,  4($sp)
    sw   $9,  8($sp)
    sw   $10, 12($sp)
    sw   $11, 16($sp)
    sw   $12, 20($sp)

	la $11 integer_array
	li $12, 0	    # $12 is the digit counter
	lw $8, 28($sp)  #loads first parameter, integer to be printed
	lw $9, 32($sp)  # loads second parameter, base radix of integer
	bgez $8, format_integer # if the number is positive, don't print a '-'
	lb $4, negative
    addi $2, $0, 11
    syscall
	mul $8, $8, -1  # convert to positive number after printing minus sign
format_integer:
	rem $10, $8, $9 # get last digit of integer, depending on what base is
	sw $10, ($11)   # store the digit in the integer array
	add $11, 4      # increment address of array
	add $12, 1      # increment digit counter
	div $8, $8, $9  # remove last digit
	bgtz $8, format_integer  # if there are more digits, loop back
	sub $11, 4      # adjust array pointer to point to last digit
output_integer:
	lw $8, ($11)    # load the new first digit
	add $8, 0x30    # convert to ascii value
    addi $2, $0, 11 # output digit
    add  $4, $8, $0
    syscall
	sub $11, 4      # decrement array pointer
	sub $12, 1      # decrement digit counter
	bgtz $12, output_integer  # if there are more digits, print them!

#epilogue
	li   $v0, 0
	lw   $8,  4($sp)          # restore register values
    lw   $9,  8($sp)
    lw   $10, 12($sp)
    lw   $11, 16($sp)
    lw   $12, 20($sp)
    lw   $ra, 24($sp)
    add  $sp, $sp, 24 
	jr $ra

