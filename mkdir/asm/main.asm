section .data
    create_error_msg     db "mkdir: cannot create directory => ", 0
    create_error_msg_len equ $ - create_error_msg
    
    usage_error_msg      db "usage: mkdir [-v] <directory...>", 10
    usage_error_msg_len  equ $ - usage_error_msg

    success_msg          db "mkdir: created directory => ", 0
    success_msg_len      equ $ - success_msg
    
    v_flag               db "-v", 0
    newline              db 10 

section .text
global _start

_start:
    mov rdi, [rsp]                      ; argc
    cmp rdi, 1
    jle usage_label

    lea rsi, [rsp + 16]                 ; rsi = argv[1]
    dec rdi                             ; remaining args count
    call _main

    ; exit with status in rdi
    mov rax, 60
    syscall

; strlen: returns length of null-terminated string in rax
strlen:
    mov rax, rdi
.loop:
    cmp byte [rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    sub rax, rdi
    ret

; strcmp: compares rdi and rsi, returns 0 in rax if equal
strcmp:
.loop:
    mov al, [rdi]
    mov cl, [rsi]
    cmp al, cl
    jne .not_equal
    test al, al
    je .equal
    inc rdi
    inc rsi
    jmp .loop
.not_equal:
    mov eax, -1
    ret
.equal:
    xor eax, eax
    ret

_main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp - 8], rdi                  ; remaining args count
    mov [rbp - 16], rsi                 ; argv pointer
    mov byte [rbp - 24], 0              ; verbose flag (0 = off, 1 = on)

    mov r12, [rbp - 16]                 ; r12 = current arg pointer
    mov r9, 0                           ; r9 = loop index

    ; check if argv[1] is "-v"
    mov rdi, [r12]
    mov rsi, v_flag
    call strcmp
    cmp rax, 0
    jne main_loop

    ; enable verbose flag and skip "-v"
    mov byte [rbp - 24], 1
    add r12, 8
    inc r9

main_loop:
    cmp r9, [rbp - 8]
    jge main_loop_done

    ; sys_mkdir(pathname, mode)
    mov rax, 83                         ; sys_mkdir syscall
    mov rdi, [r12]                      ; directory path
    mov rsi, 493                        ; mode 0755 (octal) = 493 (decimal)
    syscall

    cmp rax, 0
    jl create_error_label

    ; if success and -v is active, print success
    cmp byte [rbp - 24], 1
    je print_success_msg

.next:
    add r12, 8
    inc r9
    jmp main_loop

print_success_msg:
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, success_msg
    mov rdx, success_msg_len
    syscall

    ; print directory name
    mov rdi, [r12]
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, [r12]
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    jmp main_loop.next

create_error_label:
    mov rax, 1                          ; sys_write
    mov rdi, 2                          ; stderr
    mov rsi, create_error_msg
    mov rdx, create_error_msg_len
    syscall

    ; print directory name that failed
    mov rdi, [r12]
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 2                          ; stderr
    mov rsi, [r12]
    syscall

    ; print newline after error
    mov rax, 1
    mov rdi, 2
    mov rsi, newline
    mov rdx, 1
    syscall

    ; continue to the next directory
    jmp main_loop.next

main_loop_done:
    xor rdi, rdi                        ; return 0
    add rsp, 32
    pop rbp
    ret

usage_label:
    mov rax, 1                          ; sys_write
    mov rdi, 2                          ; stderr
    mov rsi, usage_error_msg
    mov rdx, usage_error_msg_len
    syscall
    mov rdi, 1                          ; exit code 1
    mov rax, 60
    syscall