section .data
    v_flag_str          db "-v", 0
    i_flag_str          db "-i", 0
    usage_msg           db "usage: rm [-i] [-v] <file...>", 10
    usage_msg_len       equ $ - usage_msg
    deleted_msg         db "removed '", 0
    deleted_msg_len     equ $ - deleted_msg
    quote_newline       db "'", 10
    fstat_fail_msg      db "rm: cannot access file", 10
    fstat_fail_len      equ $ - fstat_fail_msg
    question_msg        db "rm: remove file '", 0
    question_msg_len    equ $ - question_msg
    prompt_tail         db "'? (y/n) ", 0
    prompt_tail_len     equ $ - prompt_tail

section .bss
    response            resb 4
    v_flag              resb 1
    i_flag              resb 1
    stat_buf            resb 256

section .text
global _start

_start:
    mov rdi, [rsp]                      ; argc
    cmp rdi, 1
    jle print_usage

    lea rsi, [rsp + 16]                 ; argv[1]
    call main_entry

    mov rax, 60                         ; sys_exit
    xor rdi, rdi
    syscall

main_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rbp - 8], rdi                  ; argc
    mov [rbp - 16], rsi                 ; argv

    ; parse CLI flags (-i, -v)
    mov rdi, [rbp - 8]
    mov rsi, [rbp - 16]
    call parse_flags

    mov r12, [rbp - 16]
    shl rax, 3                          ; rax * 8 bytes offset for skipped flags
    add r12, rax

delete_loop:
    mov rsi, [r12]
    test rsi, rsi
    jz delete_done

    ; sys_newfstatat(dfd = AT_FDCWD (-100), path, statbuf, flags = AT_SYMLINK_NOFOLLOW (0x100))
    mov rax, 262                        ; sys_newfstatat
    mov rdi, -100                       ; AT_FDCWD
    mov rsi, [r12]                      ; filename path
    mov rdx, stat_buf                   ; stat buffer pointer
    mov r10, 0x100                      ; AT_SYMLINK_NOFOLLOW
    syscall

    cmp rax, 0
    jne fstat_error

    ; check st_mode at offset 24
    mov eax, dword [stat_buf + 24]
    and eax, 0xF000                     ; mask file type bits
    cmp eax, 0x4000                     ; S_IFDIR (directory)
    je handle_dir
    cmp eax, 0x8000                     ; S_IFREG (regular file)
    je handle_file

handle_dir:
    cmp byte [i_flag], 1
    je .check_prompt_dir
    jmp .do_rmdir

.check_prompt_dir:
    call prompt_user
    cmp rax, 1
    jne skip_entry

.do_rmdir:
    mov rax, 84                         ; sys_rmdir
    mov rdi, [r12]
    syscall
    cmp byte [v_flag], 1
    je print_deleted_report
    jmp skip_entry

handle_file:
    cmp byte [i_flag], 1
    je .check_prompt_file
    jmp .do_unlink

.check_prompt_file:
    call prompt_user
    cmp rax, 1
    jne skip_entry

.do_unlink:
    mov rax, 87                         ; sys_unlink
    mov rdi, [r12]
    syscall
    cmp byte [v_flag], 1
    je print_deleted_report
    jmp skip_entry

print_deleted_report:
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, deleted_msg
    mov rdx, deleted_msg_len
    syscall

    mov rdi, [r12]
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, [r12]
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, quote_newline
    mov rdx, 2
    syscall

skip_entry:
    add r12, 8
    jmp delete_loop

fstat_error:
    mov rax, 1
    mov rdi, 2                          ; stderr
    mov rsi, fstat_fail_msg
    mov rdx, fstat_fail_len
    syscall
    jmp skip_entry

delete_done:
    add rsp, 32
    pop rbp
    ret

prompt_user:
    mov rax, 1
    mov rdi, 1
    mov rsi, question_msg
    mov rdx, question_msg_len
    syscall

    mov rdi, [r12]
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    mov rsi, [r12]
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_tail
    mov rdx, prompt_tail_len
    syscall

    ; read response
    mov rax, 0                          ; sys_read
    mov rdi, 0                          ; stdin
    mov rsi, response
    mov rdx, 4
    syscall

    cmp byte [response], 'y'
    je .yes
    cmp byte [response], 'Y'
    je .yes
    xor rax, rax
    ret
.yes:
    mov rax, 1
    ret

parse_flags:
    push rbp
    mov rbp, rsp
    xor r14, r14                        ; processed flags count
    mov r12, rsi                        ; argv pointer
    mov r9, rdi                         ; argc
    dec r9

.loop:
    test r9, r9
    jz .done

    mov rdi, [r12]
    mov rsi, i_flag_str
    call strcmp
    test eax, eax
    jz .set_i

    mov rdi, [r12]
    mov rsi, v_flag_str
    call strcmp
    test eax, eax
    jz .set_v
    jmp .done

.set_i:
    mov byte [i_flag], 1
    inc r14
    add r12, 8
    dec r9
    jmp .loop

.set_v:
    mov byte [v_flag], 1
    inc r14
    add r12, 8
    dec r9
    jmp .loop

.done:
    mov rax, r14                        ; return count of flags parsed
    pop rbp
    ret

print_usage:
    mov rax, 1
    mov rdi, 2
    mov rsi, usage_msg
    mov rdx, usage_msg_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

; embedded strlen (no libc)
strlen:
    xor rax, rax
.len_loop:
    cmp byte [rdi + rax], 0
    je .len_done
    inc rax
    jmp .len_loop
.len_done:
    ret

; embedded strcmp (no libc)
strcmp:
.cmp_loop:
    mov al, [rdi]
    mov cl, [rsi]
    cmp al, cl
    jne .not_eq
    test al, al
    je .eq
    inc rdi
    inc rsi
    jmp .cmp_loop
.not_eq:
    mov eax, -1
    ret
.eq:
    xor eax, eax
    ret