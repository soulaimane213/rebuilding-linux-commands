# rm

A low-level implementation of the Linux `rm` (remove) command, written from scratch in **pure C** and **raw x86_64 Assembly**.

This project demonstrates how files and directories are inspected and deleted at the kernel level using direct system calls (`sys_newfstatat`, `sys_unlink`, and `sys_rmdir`), including recursive tree walking, interactive confirmation prompts, and verbose logging.

---

## 📹 Video Walkthroughs

This project was built and explained across two dedicated YouTube deep-dives:

| Part | Description | Link |
| :--- | :--- | :--- |
| **Part 1 (C Language)** | Core logic, recursion, directory streams, and flag parsing | [![Watch C Part](https://img.shields.io/badge/YouTube-Watch%20Part%201%20(C)-blue?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=uPilRYZx2Ps) |
| **Part 2 (x86_64 Assembly)** | Raw syscall implementation, `fstatat` struct parsing, and memory checks | [![Watch ASM Part](https://img.shields.io/badge/YouTube-Watch%20Part%202%20(ASM)-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=O5mN1RTcryI) |

---

## 📂 Project Structure

```
rm/
├── c/
│   ├── main.c
│   └── Makefile
├── asm/
│   ├── main.asm
│   └── Makefile
└── README.md
```

* **c/**: Full recursive implementation in C using POSIX directory APIs (`opendir`, `readdir`, `closedir`, `lstat`, `unlink`, `rmdir`).
* **asm/**: Pure x86_64 Assembly implementation using kernel syscalls without libc.

---

## ✨ Features

* **File Deletion:** Removes regular files using `unlink` / `sys_unlink`.
* **Recursive Deletion (`-r`):** Traverses and removes directories and their contents.
* **Interactive Mode (`-i`):** Prompts for user confirmation before deleting each entry.
* **Verbose Mode (`-v`):** Prints status confirmation messages for deleted files and directories.
* **Kernel File Type Detection:** In Assembly, inspects `struct stat` file mode bits (`0x8000` for regular file, `0x4000` for directory) using `sys_newfstatat`.

---

## 🛠️ Compilation

### C Version

```bash
cd c
make
```

### Assembly Version

```bash
cd asm
make
```

---

## 🚀 Usage

Remove regular files:
```bash
./rm file1.txt file2.txt
```

Interactive verbose deletion:
```bash
./rm -i -v file.txt
```

Recursively delete a directory:
```bash
./rm -r -v target_directory
```

---

## 🔬 Under the Hood

| Mechanism | Syscall Number | Purpose |
| :--- | :--- | :--- |
| **`sys_newfstatat`** | `262` | Inspect file metadata and mode (`AT_FDCWD = -100`, `AT_SYMLINK_NOFOLLOW = 0x100`) |
| **`sys_unlink`** | `87` | Remove a file link from the filesystem directory entry |
| **`sys_rmdir`** | `84` | Delete an empty directory |

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
