.data
    menu_head:     .asciiz "\n==========================================\n      CALCULADORA DIDATICA MIPS\n==========================================\n"
    menu_opt1:     .asciiz "1. Converter Base 10 (Bin, Oct, Hex, BCD)\n"
    menu_opt2:     .asciiz "2. Converter Base 10 para 16-bit Signed (Comp. 2)\n"
    menu_opt3:     .asciiz "3. Analise de Float e Double (IEEE 754)\n"
    menu_exit:     .asciiz "0. Sair\n"
    prompt_choice: .asciiz "Escolha uma opcao: "
    prompt_int:    .asciiz "\nDigite um numero inteiro (Base 10): "
    msg_not_impl:  .asciiz "\n[!] Funcionalidade em construcao.\n"
    
    str_bin:       .asciiz "\n--- [a] Binario (Base 2) ---\n"
    str_oct:       .asciiz "\n--- [b] Octal (Base 8) ---\n"
    str_hex:       .asciiz "\n--- [c] Hexadecimal (Base 16) ---\n"
    str_bcd:       .asciiz "\n--- [d] BCD (Binary Coded Decimal) ---\n"
    
    msg_space:     .asciiz " "
    msg_step:      .asciiz "\nPasso: "
    msg_div:       .asciiz "Div: "
    msg_quo:       .asciiz " | Quo: "
    msg_rem:       .asciiz " | Resto: "
    msg_res_final: .asciiz "\n>> Resultado Final: "
    
    hex_digits:    .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

.text
.globl main

main:
    main_loop:
        li $v0, 4
        la $a0, menu_head
        syscall
        la $a0, menu_opt1
        syscall
        la $a0, menu_opt2
        syscall
        la $a0, menu_opt3
        syscall
        la $a0, menu_exit
        syscall
        la $a0, prompt_choice
        syscall

        li $v0, 5
        syscall
        move $t0, $v0

        beq $t0, 0, exit_program
        beq $t0, 1, case_conversions
        beq $t0, 2, case_signed16
        beq $t0, 3, case_ieee754
        j main_loop

case_conversions:
    # Ler numero
    li $v0, 4
    la $a0, prompt_int
    syscall
    li $v0, 5
    syscall
    move $s0, $v0  
    
    # Base 2
    li $v0, 4
    la $a0, str_bin
    syscall
    move $a0, $s0  
    li $a1, 2      
    jal generic_base_converter
	
    # Base 8
    li $v0, 4
    la $a0, str_oct
    syscall
    move $a0, $s0  
    li $a1, 8      
    jal generic_base_converter
    
    # Base 16
    li $v0, 4
    la $a0, str_hex
    syscall
    move $a0, $s0
    li $a1, 16     
    jal generic_base_converter
    
    # BCD
    li $v0, 4
    la $a0, str_bcd
    syscall
    move $a0, $s0
    jal process_bcd
    
    j main_loop

case_signed16:
    li $v0, 4
    la $a0, msg_not_impl
    syscall
    j main_loop

case_ieee754:
    li $v0, 4
    la $a0, msg_not_impl
    syscall
    j main_loop

generic_base_converter:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0 
    move $s1, $a1 
    li $s2, 0     
    
    bne $s0, $zero, loop_div
    li $v0, 1
    li $a0, 0
    syscall
    j end_base_conv

    loop_div:
        beq $s0, 0, print_result_base
        
        div $s0, $s1
        mflo $t0 
        mfhi $t1 
        
        li $v0, 4
        la $a0, msg_step
        syscall
        li $v0, 1
        move $a0, $s0 
        syscall
        li $v0, 4
        la $a0, msg_div
        syscall
        li $v0, 1
        move $a0, $s1 
        syscall
        li $v0, 4
        la $a0, msg_quo
        syscall
        li $v0, 1
        move $a0, $t0 
        syscall
        li $v0, 4
        la $a0, msg_rem
        syscall
        li $v0, 1
        move $a0, $t1 
        syscall

        sub $sp, $sp, 4
        sw $t1, 0($sp)
        addi $s2, $s2, 1
        
        move $s0, $t0 
        j loop_div

    print_result_base:
        li $v0, 4
        la $a0, msg_res_final
        syscall

    pop_loop:
        beq $s2, 0, end_base_conv
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        addi $s2, $s2, -1
               
        bge $a0, 10, print_hex_char
        
        li $v0, 1      
        syscall
        j pop_loop
        
        print_hex_char:
        la $t8, hex_digits
        add $t8, $t8, $a0
        lb $a0, 0($t8)
        li $v0, 11     
        syscall
        j pop_loop

    end_base_conv:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        addi $sp, $sp, 16
        jr $ra

process_bcd:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    move $s0, $a0
    li $s1, 0
    li $t9, 10

    bcd_loop_div:
        div $s0, $t9
        mflo $s0
        mfhi $t0
        sub $sp, $sp, 4
        sw $t0, 0($sp)
        addi $s1, $s1, 1
        bgt $s0, 0, bcd_loop_div
    
    li $v0, 4
    la $a0, msg_res_final
    syscall

    bcd_pop_print:
        beq $s1, 0, end_bcd
        lw $a0, 0($sp)
        addi $sp, $sp, 4
        addi $s1, $s1, -1
        
        li $a1, 4         
        jal print_binary_n_bits
        
        li $v0, 4
        la $a0, msg_space
        syscall
        j bcd_pop_print

    end_bcd:
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        addi $sp, $sp, 12
        jr $ra

print_binary_n_bits:

    move $t8, $a0
    move $t9, $a1
    addi $t9, $t9, -1
    
    bit_loop:
        blt $t9, 0, end_print_bits
        srlv $a0, $t8, $t9
        andi $a0, $a0, 1
        li $v0, 1
        syscall
        addi $t9, $t9, -1
        j bit_loop
        
    end_print_bits:
        jr $ra
        
exit_program:
    li $v0, 10
    syscall