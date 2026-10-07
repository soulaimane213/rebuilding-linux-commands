# Rebuilding Linux Commands from Scratch

A collection of standard Linux core utilities rebuilt from the ground up in **pure C** and **raw x86_64 Assembly**.

This repository explores operating system internals, Linux kernel system calls, memory management, and file descriptor manipulation without relying on high-level abstractions.

[![YouTube Channel](https://img.shields.io/badge/YouTube-Zero2Segfault-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/@Zero2Segfault)

---

## 🛠️ Implemented Commands

| Command | Languages | Key Syscalls / APIs | Video Tutorial |
| :--- | :--- | :--- | :--- |
| **[`cat`](./cat)** | C + Assembly | `sys_open`, `sys_read`, `sys_write`, `sys_close` | [Watch Video](https://www.youtube.com/watch?v=vnOmlCR9Zso) |
| **[`mkdir`](./mkdir)** | C + Assembly | `sys_mkdir` (83), permissions (`0755`) | [Watch Video](https://www.youtube.com/watch?v=H8Wxo7Vb1lE) |
| **[`pwd`](./pwd)** | C + Assembly | `sys_getcwd` (79), `PATH_MAX` buffers | [Watch Video](https://www.youtube.com/watch?v=pFezwS6QEqs) |
| **[`rm`](./rm)** | C + Assembly | `sys_newfstatat` (262), `sys_unlink` (87), `sys_rmdir` (84) | [Part 1 (C)](https://www.youtube.com/watch?v=uPilRYZx2Ps) / [Part 2 (ASM)](https://www.youtube.com/watch?v=O5mN1RTcryI) |
| **[`wc`](./wc)** | Pure Modular C | POSIX file streams, word boundary state machine | [Watch Stream](https://www.youtube.com/watch?v=a-QUzPSvCUg) |
| **[`whoami`](./whoami)** | C + Assembly | `sys_getuid` (102), `struct passwd` memory layout | [Watch Video](https://www.youtube.com/watch?v=nfrvYzEjEV8) |

---

## 📂 Project Organization

Each command is self-contained with its own tests, source code, and build files:

```text
rebuilding-linux-commands/
├── README.md               # Master documentation and roadmap
├── .gitignore              # Ignores build artifacts (*.o, binaries)
├── cat/                    # C & ASM implementations of cat
├── mkdir/                  # C & ASM implementations of mkdir
├── pwd/                    # C & ASM implementations of pwd
├── rm/                     # C & ASM implementations of rm (-r, -i, -v)
├── wc/                     # Modular C implementation of wc (-l, -w, -c, -L)
└── whoami/                 # C & ASM implementations of whoami (-h, -s)
```

---

## 🚀 How to Build

Each subdirectory provides a clean `Makefile`.

To compile any command:
```bash
# Example: Compile and run 'pwd'
cd pwd/c && make
./pwd

cd ../asm && make
./pwd
```

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
