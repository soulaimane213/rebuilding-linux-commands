section .data
    home_short      db "-h", 0
    home_long       db "--home", 0
    shell_short     db "-s", 0
    shell_long      db "--shell", 0
    separator       db ": ", 0
    separator_len   equ $ - separator
    newline         db 10

extern getpwuid
extern strcmp
extern strlen

section .text
global _start

_start:
    mov rdi, [rsp]                      ; argc
    lea rsi, [rsp + 16]                 ; argv[1] pointer

    call main_entry

    mov rax, 60                         ; sys_exit
    xor rdi, rdi
    syscall

main_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov [rbp - 8], rdi                  ; argc
    mov [rbp - 16], rsi                 ; argv
    mov qword [rbp - 24], 0             ; home flag
    mov qword [rbp - 32], 0             ; shell flag

    cmp rdi, 1
    jle get_user

    ; parse flags
    mov rdi, [rbp - 8]
    mov rsi, [rbp - 16]
    lea rdx, [rbp - 24]
    lea rcx, [rbp - 32]
    call check_flags

get_user:
    ; sys_getuid (syscall 102)
    mov rax, 102
    syscall

    ; call getpwuid(uid)
    mov rdi, rax
    call getpwuid
    test rax, rax
    jz main_done

    mov rbx, rax                        ; rbx = struct passwd*

    ; print username (pw_name at offset 0)
    mov rdi, [rbx]
    call strlen
    mov rdx, rax
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, [rbx]
    syscall

    ; check if home flag is set
    cmp qword [rbp - 24], 1
    je print_home

    ; check if shell flag is set
    cmp qword [rbp - 32], 1
    je print_shell

    ; no flags: print newline and finish
    jmp print_final_newline

print_home:
    ; print ": " separator
    mov rax, 1
    mov rdi, 1
    mov rsi, separator
    mov rdx, separator_len
    syscall

    ; print pw_dir (offset +32)
    mov rsi, [rbx + 32]
    mov rdi, rsi
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    jmp print_final_newline

print_shell:
    ; print ": " separator
    mov rax, 1
    mov rdi, 1
    mov rsi, separator
    mov rdx, separator_len
    syscall

    ; print pw_shell (offset +40)
    mov rsi, [rbx + 40]
    mov rdi, rsi
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall

print_final_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

main_done:
    add rsp, 48
    pop rbp
    ret

check_flags:
    push rbp
    mov rbp, rsp
    mov r12, rsi                        ; argv
    mov r14, rdx                        ; &home_flag
    mov r15, rcx                        ; &shell_flag

    mov rdi, [r12]
    test rdi, rdi
    jz .done

    mov rsi, home_short
    call strcmp
    test eax, eax
    jz .set_home

    mov rdi, [r12]
    mov rsi, home_long
    call strcmp
    test eax, eax
    jz .set_home

    mov rdi, [r12]
    mov rsi, shell_short
    call strcmp
    test eax, eax
    jz .set_shell

    mov rdi, [r12]
    mov rsi, shell_long
    call strcmp
    test eax, eax
    jz .set_shell
    jmp .done

.set_home:
    mov qword [r14], 1
    jmp .done

.set_shell:
    mov qword [r15], 1

.done:
    pop rbp
    ret