[BITS 64]

section .data
    ; Flag variables (0 = disabled, 1 = enabled)
    flag_v      db 0
    flag_i      db 0
    flag_f      db 0

    ; Messages
    msg_usage   db "usage: ./ft_cp [-vif] source dest", 10
    len_usage   equ $ - msg_usage

    msg_err_open db "ft_cp: cannot open file", 10
    len_err_open equ $ - msg_err_open

    msg_err_create db "ft_cp: cannot create file", 10
    len_err_create equ $ - msg_err_create

    msg_prompt1 db "ft_cp: overwrite '"
    len_prompt1 equ $ - msg_prompt1

    msg_prompt2 db "'? (y/n) "
    len_prompt2 equ $ - msg_prompt2

    msg_quote   db "'"
    msg_arrow   db "' -> '"
    len_arrow   equ $ - msg_arrow
    newline     db 10

section .bss
    buffer      resb 4096
    input_buf   resb 2

section .text
global _start

; Print null-terminated string: rdi = pointer to string
print_str:
    xor     rdx, rdx
.len_loop:
    cmp     byte [rdi + rdx], 0
    je      .print
    inc     rdx
    jmp     .len_loop
.print:
    mov     rsi, rdi
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    syscall
    ret

; Print fixed length bytes: rsi = buffer, rdx = length
print_bytes:
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    syscall
    ret

_start:
    ; argc and argv
    mov     r8, [rsp]           ; argc
    lea     r9, [rsp + 8]       ; argv pointer

    cmp     r8, 3
    jl      usage_error

    mov     r10, 1              ; argv index = 1

; Loop over arguments looking for flags
parse_flags:
    cmp     r10, r8
    jge     done_parsing

    mov     rdi, [r9 + r10 * 8] ; argv[i]
    cmp     byte [rdi], '-'
    jne     done_parsing
    cmp     byte [rdi + 1], 0
    je      done_parsing

    lea     rsi, [rdi + 1]

.flag_loop:
    mov     al, byte [rsi]
    test    al, al
    jz      .next_arg

    cmp     al, 'v'
    je      .set_v
    cmp     al, 'i'
    je      .set_i
    cmp     al, 'f'
    je      .set_f
    jmp     usage_error

.set_v:
    mov     byte [flag_v], 1
    inc     rsi
    jmp     .flag_loop

.set_i:
    mov     byte [flag_i], 1
    inc     rsi
    jmp     .flag_loop

.set_f:
    mov     byte [flag_f], 1
    inc     rsi
    jmp     .flag_loop

.next_arg:
    inc     r10
    jmp     parse_flags

done_parsing:
    ; Check if we have at least 2 remaining arguments (src and dest)
    mov     rax, r8
    sub     rax, r10
    cmp     rax, 2
    jl      usage_error

    mov     r15, [r9 + r10 * 8]         ; r15 = src filename
    mov     rbx, [r9 + r10 * 8 + 8]     ; rbx = dest filename

    ; Check if destination already exists using sys_access
    mov     rax, 21             ; sys_access
    mov     rdi, rbx            ; dest path
    xor     rsi, rsi            ; F_OK (0)
    syscall

    test    rax, rax
    jnz     do_copy             ; File does not exist, go straight to copy

    ; If dest exists, check flags:
    cmp     byte [flag_f], 1
    je      do_force

    cmp     byte [flag_i], 1
    je      do_interactive

    jmp     do_copy

do_force:
    mov     rax, 87             ; sys_unlink
    mov     rdi, rbx
    syscall
    jmp     do_copy

do_interactive:
    ; Print overwrite question
    mov     rsi, msg_prompt1
    mov     rdx, len_prompt1
    call    print_bytes

    mov     rdi, rbx
    call    print_str

    mov     rsi, msg_prompt2
    mov     rdx, len_prompt2
    call    print_bytes

    ; Read 1 character from stdin
    mov     rax, 0              ; sys_read
    xor     rdi, rdi            ; stdin (0)
    mov     rsi, input_buf
    mov     rdx, 1
    syscall

    cmp     byte [input_buf], 'y'
    je      do_copy
    cmp     byte [input_buf], 'Y'
    je      do_copy

    ; Exit if answer is not 'y' or 'Y'
    mov     rax, 60
    xor     rdi, rdi
    syscall

do_copy:
    ; Open source file (O_RDONLY = 0)
    mov     rax, 2              ; sys_open
    mov     rdi, r15
    xor     rsi, rsi
    syscall

    test    rax, rax
    js      error_open
    mov     r12, rax            ; r12 = fd_src

    ; Open or create destination file (O_WRONLY | O_CREAT | O_TRUNC = 577, mode 0644o)
    mov     rax, 2              ; sys_open
    mov     rdi, rbx
    mov     rsi, 577
    mov     rdx, 0644o
    syscall

    test    rax, rax
    js      error_create
    mov     r13, rax            ; r13 = fd_dest

; Core read/write loop
copy_loop:
    mov     rax, 0              ; sys_read
    mov     rdi, r12            ; fd_src
    mov     rsi, buffer
    mov     rdx, 4096
    syscall

    test    rax, rax
    jle     copy_done           ; rax <= 0 means EOF or error

    mov     rdx, rax            ; bytes read
    mov     rax, 1              ; sys_write
    mov     rdi, r13            ; fd_dest
    mov     rsi, buffer
    syscall

    jmp     copy_loop

copy_done:
    ; Close both files
    mov     rax, 3              ; sys_close
    mov     rdi, r12
    syscall

    mov     rax, 3              ; sys_close
    mov     rdi, r13
    syscall

    ; If verbose flag is set (flag_v == 1)
    cmp     byte [flag_v], 1
    jne     exit_success

    mov     rsi, msg_quote
    mov     rdx, 1
    call    print_bytes

    mov     rdi, r15
    call    print_str

    mov     rsi, msg_arrow
    mov     rdx, len_arrow
    call    print_bytes

    mov     rdi, rbx
    call    print_str

    mov     rsi, msg_quote
    mov     rdx, 1
    call    print_bytes

    mov     rsi, newline
    mov     rdx, 1
    call    print_bytes

exit_success:
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi            ; code 0
    syscall

usage_error:
    mov     rax, 1              ; sys_write
    mov     rdi, 2              ; stderr
    mov     rsi, msg_usage
    mov     rdx, len_usage
    syscall
    mov     rax, 60
    mov     rdi, 1
    syscall

error_open:
    mov     rax, 1
    mov     rdi, 2
    mov     rsi, msg_err_open
    mov     rdx, len_err_open
    syscall
    mov     rax, 60
    mov     rdi, 1
    syscall

error_create:
    mov     rax, 3              ; close src
    mov     rdi, r12
    syscall

    mov     rax, 1
    mov     rdi, 2
    mov     rsi, msg_err_create
    mov     rdx, len_err_create
    syscall
    mov     rax, 60
    mov     rdi, 1
    syscall