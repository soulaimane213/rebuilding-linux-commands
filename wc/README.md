# wc — Rebuilt from Scratch in C

A modular, from-scratch implementation of the standard POSIX `wc` (word count) utility in **pure C**.

This project supports multiple file inputs, standard input (`stdin`) streaming, line formatting, multi-file totals, and advanced GNU flags such as `--files0-from`. Zero external dependencies — built with direct POSIX file I/O.

---

## 📹 Video Walkthrough

Watch the full live development and architecture breakdown on YouTube:

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20Live%20Stream-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=a-QUzPSvCUg)

---

## 📂 Project Architecture

```
wc/
├── Makefile       # Multi-file build system with optimization flags
├── README.md
├── wc.h           # Core structs (s_opt, s_counts) & prototypes
├── main.c         # Entry point, flag validation, and stream dispatch
├── parsing.c      # Argument parsing for short/long GNU options
├── ft_wc.c        # File loop orchestration, --files0-from handler
└── utils.c        # Word counting, line counting, and formatted reporting
```

### Module Responsibilities:
* **`wc.h`**: Defines the `s_opt` flag options container and `s_counts` metrics struct (lines, words, characters, max line length).
* **`parsing.c`**: Extracts CLI switches (both short `-l -w -c` and long `--files0-from=FILE`, `--version`, `--help`).
* **`ft_wc.c`**: Manages file descriptors, sequential processing, and accumulated grand totals.
* **`utils.c`**: Implements the streaming state machine: word boundary detection (whitespace transitions), newline scanning (`\n`), and output column alignment.

---

## ✨ Supported Flags

| Flag | Long Option | Description |
| :--- | :--- | :--- |
| **`-l`** | `--lines` | Print newline count |
| **`-w`** | `--words` | Print word count (whitespace-delimited) |
| **`-c`** | `--bytes` | Print raw byte count |
| **`-L`** | `--max-line-length` | Print length of the longest line |
| | `--files0-from=FILE` | Read input from NUL-separated filenames specified in `FILE` |
| | `--help` | Display usage instructions |
| | `--version` | Display program version |

---

## 🛠️ Build & Run

### Compilation

```bash
make
```

### Usage Examples

#### 1. Single File Analysis
```bash
./wc -l -w -c file.txt
```

#### 2. Multi-File Processing with Totals
```bash
./wc -l file1.txt file2.txt file3.txt
# Output:
#   42 file1.txt
#   18 file2.txt
#   10 file3.txt
#   70 total
```

#### 3. Standard Input Pipeline
```bash
cat /var/log/syslog | ./wc -l
dmesg | ./wc -w
```

#### 4. Max Line Length Inspection
```bash
./wc -L source.c
```

---

## 👨‍💻 Author

**Soulaimane FADL**  
YouTube: [@Zero2Segfault](https://www.youtube.com/@Zero2Segfault)
