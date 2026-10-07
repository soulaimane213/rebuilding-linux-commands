#ifndef WC_H
#define WC_H

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define BUFFER_SIZE 65536 // 64 KB streaming buffer

// Struct holding CLI option flags
typedef struct {
    int l;              // -l : count lines
    int w;              // -w : count words
    int c;              // -c : count bytes/chars
    int L;              // -L : max line length
    int file_F;         // 1 if --files0-from is set
    char *files_F_name; // target file for --files0-from
    int v;              // --version
    int h;              // --help
    int _flag_;         // tracks if any display filter is active
    int files_n;        // number of files processed
} s_opt;

// Struct tracking counts for current file and running totals
typedef struct {
    int lines;
    int words;
    int chars;
    int max_line;

    int total_lines;
    int total_words;
    int total_chars;
    int total_max_line;
} s_counts;

// Function prototypes
int  parsing_args(s_opt *flags, char **args);
int  handle_file_from(s_opt *flags, s_counts *counts, char *file_name);
int  process_file(s_opt *flags, s_counts *counts, char *file);
void count_words(char *buffer, size_t bytes, int *word_count, int *in_word);
void count_lines(char *buffer, size_t bytes, int *lines, int *max_line, int *current_line_len);
void clear_counts(s_counts *counts);
void print_data(s_opt *flags, s_counts *counts, const char *file);
void print_total_data(s_opt *flags, s_counts *counts);
void ft_stdin_wc(s_opt *flags, s_counts *counts);
void print_stdin(s_opt *flags, s_counts *counts);
void ft_wc(s_opt *flags, s_counts *counts, char **args);

#endif
