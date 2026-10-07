section .data
    error_msg       db "pwd: cannot determine current directory", 10
    error_msg_len   equ $ - error_msg

    help_msg        db "usage: pwd [-h | --help] [-v | --version]", 10
    help_msg_len    equ $ - help_msg

    version_msg     db "pwd version 1.0.0", 10
    version_msg_len equ $ - version_msg

    short_v         db "-v", 0
    long_v          db "--version", 0
    short_h         db "-h", 0
    long_h          db "--help", 0

    newline         db 10

section .bss
    buffer resb 4096

section .text
global _start

_start:
    mov r9, [rsp]                       ; argc
    lea r12, [rsp + 16]                 ; r12 = argv[1] pointer
    cmp r9, 2
    je check_flags

    ; sys_getcwd(buffer, size)
    mov rax, 79                         ; sys_getcwd syscall
    mov rdi, buffer                     ; buffer pointer
    mov rsi, 4096                       ; max size
    syscall

    cmp rax, 0                          ; negative return indicates error (-errno)
    jl print_error

    ; print path
    mov rdi, buffer
    call strlen
    mov rdx, rax                        ; string length
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, buffer
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    jmp exit_success

check_flags:
    mov rdi, [r12]                      ; argv[1]
    mov rsi, short_v
    call strcmp
    test eax, eax
    jz print_version

    mov rdi, [r12]
    mov rsi, long_v
    call strcmp
    test eax, eax
    jz print_version

    mov rdi, [r12]
    mov rsi, short_h
    call strcmp
    test eax, eax
    jz print_help

    mov rdi, [r12]
    mov rsi, long_h
    call strcmp
    test eax, eax
    jz print_help

    jmp exit_failure

print_version:
    mov rax, 1
    mov rdi, 1
    mov rsi, version_msg
    mov rdx, version_msg_len
    syscall
    jmp exit_success

print_help:
    mov rax, 1
    mov rdi, 1
    mov rsi, help_msg
    mov rdx, help_msg_len
    syscall
    jmp exit_success

print_error:
    mov rax, 1
    mov rdi, 2                          ; stderr
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall
    jmp exit_failure

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall

exit_failure:
    mov rax, 60
    mov rdi, 1
    syscall

; strlen: returns length of null-terminated string in rax
strlen:
    xor rax, rax
.loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .loop
.done:
    ret

; strcmp: returns 0 in eax if strings match
strcmp:
.loop:
    mov dl, [rdi]
    mov cl, [rsi]
    cmp dl, cl
    jne .not_equal
    test dl, dl
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