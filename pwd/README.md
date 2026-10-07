# pwd

A low-level implementation of the Linux `pwd` (print working directory) command, written in **C** and **x86_64 Assembly**.

This project demonstrates how to query the current working directory directly from the Linux kernel using the `sys_getcwd` system call (`79`), format paths, and handle CLI flags (`-h`, `--help`, `-v`, `--version`).

---

## 📹 Video Walkthrough

Watch the full tutorial and line-by-line coding explanation on YouTube:

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20Video-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=pFezwS6QEqs)

---

## 📂 Project Structure

```
pwd/
├── c/
│   ├── main.c
│   └── Makefile
├── asm/
│   ├── main.asm
│   └── Makefile
└── README.md
```

* **c/**: Implementation using C and the POSIX `getcwd()` function.
* **asm/**: Pure x86_64 Assembly implementation using the `sys_getcwd` (syscall 79) kernel interface with zero standard library dependencies.

---

## ✨ Features

* **Absolute Path Resolution:** Queries and prints the exact working directory path.
* **Flag Support:** Handles `-h` / `--help` and `-v` / `--version` flags.
* **Direct Kernel Interface:** The Assembly version communicates directly with `sys_getcwd` (Syscall `79`).
* **Proper Newline Formatting:** Prints a trailing newline so terminal prompts render cleanly.
* **Memory Management:** Stack-allocated path buffer (4096 bytes / `PATH_MAX`).

---

## 🛠️ Compilation

### C Version

```bash
cd c
make
./pwd
```

### Assembly Version

```bash
cd asm
make
./pwd
```

---

## 🚀 Usage

Print the current directory:
```bash
./pwd
```

Display help or version:
```bash
./pwd --help
./pwd --version
```

---

## 🔬 Under the Hood

| Parameter | Details |
| :--- | :--- |
| **Syscall** | `sys_getcwd` (Syscall Number: `79`) |
| **Buffer Size** | `4096` bytes (`PATH_MAX` page size) |
| **Register ABI** | `RAX = 79`, `RDI = buffer_ptr`, `RSI = size` |
| **Return** | `RAX` = bytes written on success, negative on error |

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
