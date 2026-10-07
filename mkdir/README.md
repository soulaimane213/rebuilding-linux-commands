# mkdir

A low-level implementation of the Linux `mkdir` command, written in **C** and **x86_64 Assembly**.

This project demonstrates how to create directories by interacting directly with the Linux kernel using the `sys_mkdir` system call, providing an educational insight into how standard Linux utilities work internally.

---

## 📹 Video Walkthrough

Watch the full explanation and line-by-line coding on YouTube:

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20Video-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=H8Wxo7Vb1lE)

---

## 📂 Project Structure

```
mkdir/
├── c/
│   ├── main.c
│   └── Makefile
├── asm/
│   ├── main.asm
│   └── Makefile
└── README.md
```

* **c/**: Implementation of `mkdir` using C and standard POSIX system calls.
* **asm/**: Implementation using pure x86_64 Assembly with raw Linux syscalls (zero libc).

---

## ✨ Features

* Create single or multiple directories
* Verbose flag support (`-v`)
* Default `0755` permissions (`rwxr-xr-x`)
* Direct Linux kernel system call (`sys_mkdir = 83`)
* Error handling without stopping execution for subsequent directories

---

## 🛠️ Compilation

### C Version

```bash
cd c
make
```

Or manually:
```bash
gcc -Wall -Wextra main.c -o mkdir
```

### Assembly Version

```bash
cd asm
make
```

Or manually:
```bash
nasm -f elf64 main.asm -o main.o
ld main.o -o mkdir
```

---

## 🚀 Usage

```bash
./mkdir directory_name
```

With the verbose flag:
```bash
./mkdir -v dir1 dir2 dir3
```

---

## 🎯 Goals of This Project

* Learn how the `mkdir` command works internally
* Practice systems programming in C and Assembly side-by-side
* Understand Linux system calls and kernel interaction
* Practice argument and flag parsing in assembly

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
