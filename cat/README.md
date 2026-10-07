# cat — Rebuilt in C and x86_64 Assembly

A from-scratch implementation of the Unix `cat` utility in both **pure C** and **raw x86_64 Assembly**. 

Zero runtime overhead, no standard library dependencies in the assembly version — just raw Linux kernel syscalls (`sys_open`, `sys_read`, `sys_write`, `sys_close`).

## Features

- Reads multiple files sequentially passed via CLI arguments.
- Handles missing arguments and missing files gracefully.
- Buffered I/O (4096-byte chunks) to prevent excessive syscall context switching.

## Video Walkthrough

Watch the full build and logic walkthrough on YouTube:

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20Video-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=vnOmlCR9Zso)

## Build & Run

### Assembly Version
```bash
cd asm
make
./cat file1.txt file2.txt