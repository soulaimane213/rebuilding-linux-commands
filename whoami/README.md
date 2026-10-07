# whoami

A low-level implementation of the Linux `whoami` command, written in **pure C** and **x86_64 Assembly**.

This project demonstrates how Linux retrieves identity and credentials for the current process by fetching the user ID via the kernel's `sys_getuid` system call (`102`) and querying user account database entries (`struct passwd`) to extract the username, home directory, and default shell.

---

## 📹 Video Walkthrough

Watch the full tutorial and line-by-line coding explanation on YouTube:

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20Video-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=nfrvYzEjEV8)

---

## 📂 Project Structure

```
whoami/
├── c/
│   ├── main.c
│   └── Makefile
├── asm/
│   ├── main.asm
│   └── Makefile
└── README.md
```

* **c/**: Implementation using C and the POSIX `getuid()` and `getpwuid()` APIs.
* **asm/**: Low-level x86_64 Assembly implementation using kernel syscall `102` (`sys_getuid`) and manual `struct passwd` memory offset dereferencing.

---

## ✨ Features

* **Username Resolution:** Prints the current user account name.
* **Home Directory Flag (`-h` / `--home`):** Extends output to display the user's home directory (`pw_dir`).
* **Shell Flag (`-s` / `--shell`):** Extends output to display the user's login shell (`pw_shell`).
* **Clean Formatting:** Ensures trailing newlines are always output so shell prompts remain uncorrupted.

---

## 🛠️ Compilation

### C Version

```bash
cd c
make
./whoami
```

### Assembly Version

```bash
cd asm
make
./whoami
```

---

## 🚀 Usage

Standard identity lookup:
```bash
./whoami
```

Inspect home directory or login shell:
```bash
./whoami -h
./whoami -s
```

---

## 🔬 Under the Hood (`struct passwd` Offsets in x86_64)

The Assembly version invokes `sys_getuid` (Syscall `102`) and navigates the 64-bit `struct passwd` memory layout directly:

| Field | Type | Struct Byte Offset | Description |
| :--- | :--- | :--- | :--- |
| `pw_name` | `char *` | `+0` | Username string pointer |
| `pw_passwd` | `char *` | `+8` | Hashed password pointer |
| `pw_uid` | `uid_t` | `+16` | User ID |
| `pw_gid` | `gid_t` | `+20` | Group ID |
| `pw_gecos` | `char *` | `+24` | Real name / comment pointer |
| `pw_dir` | `char *` | `+32` | Home directory path pointer |
| `pw_shell` | `char *` | `+40` | Initial shell program pointer |

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
