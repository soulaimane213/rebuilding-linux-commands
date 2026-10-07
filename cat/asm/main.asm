section .data
    missing_msg     db "cat: please specify a file", 10
    missing_len     equ $ - missing_msg

    cannot_open_msg db ": No such file or directory", 10
    cannot_open_len equ $ - cannot_open_msg

section .bss
    buffer resb 4096

section .text
global _start

_start:
    mov rbx, [rsp]                      ; argc
    cmp rbx, 1                          ; check if no files were passed
    jle missing_file

    lea r12, [rsp + 16]                 ; r12 = argv[1] pointer
    mov r13, 1                          ; r13 = argument index counter

process_args:
    cmp r13, rbx
    jge exit_clean

    ; open(argv[i], O_RDONLY, 0)
    mov rax, 2                          ; sys_open
    mov rdi, [r12]                      ; pathname = argv[i]
    xor rsi, rsi                        ; flags = O_RDONLY (0)
    xor rdx, rdx                        ; mode = 0
    syscall

    cmp rax, 0
    jl print_error

    mov r14, rax                        ; r14 = file descriptor
    call read_and_print

    ; close(fd)
    mov rax, 3                          ; sys_close
    mov rdi, r14
    syscall

next_arg:
    inc r13
    add r12, 8                          ; advance to next argv pointer
    jmp process_args

read_and_print:
.read_loop:
    ; read(fd, buffer, 4096)
    mov rax, 0                          ; sys_read
    mov rdi, r14
    mov rsi, buffer
    mov rdx, 4096
    syscall

    cmp rax, 0                          ; check EOF or error
    jle .done

    ; write(stdout, buffer, bytes_read)
    mov rdx, rax                        ; FIXED: rdx must be actual bytes read (rax)!
    mov rax, 1                          ; sys_write
    mov rdi, 1                          ; stdout
    mov rsi, buffer
    syscall
    jmp .read_loop
.done:
    ret

print_error:
    ; calculate length of filename in rdi
    mov rdi, [r12]
    xor rdx, rdx
.len_loop:
    cmp byte [rdi + rdx], 0
    je .len_done
    inc rdx
    jmp .len_loop
.len_done:
    ; print filename
    mov rax, 1                          ; sys_write
    mov rsi, rdi
    mov rdi, 2                          ; stderr
    syscall

    ; print ": No such file or directory\n"
    mov rax, 1
    mov rdi, 2                          ; stderr
    mov rsi, cannot_open_msg
    mov rdx, cannot_open_len
    syscall
    jmp next_arg

missing_file:
    mov rax, 1                          ; sys_write
    mov rdi, 2                          ; stderr
    mov rsi, missing_msg
    mov rdx, missing_len
    syscall

exit_clean:
    mov rax, 60                         ; sys_exit
    xor rdi, rdi
    syscall