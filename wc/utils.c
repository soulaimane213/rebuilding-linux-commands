#include "wc.h"

int process_file(s_opt *flags, s_counts *counts, char *file) {
    struct stat st;

    if (stat(file, &st) == -1) {
        fprintf(stderr, "wc: %s: No such file or directory\n", file);
        return -1;
    }

    if (S_ISDIR(st.st_mode)) {
        fprintf(stderr, "wc: %s: read error: Is a directory\n", file);
        return -1;
    }

    // FIXED: O_RDONLY allows reading write-protected files
    int fd = open(file, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "wc: %s: Permission denied\n", file);
        return -1;
    }

    clear_counts(counts);
    char buffer[BUFFER_SIZE];
    ssize_t bytes;
    int in_word = 0;
    int current_line_len = 0;

    // Stream through the file in 64KB blocks
    while ((bytes = read(fd, buffer, sizeof(buffer))) > 0) {
        count_words(buffer, bytes, &(counts->words), &in_word);
        count_lines(buffer, bytes, &(counts->lines), &(counts->max_line), &current_line_len);
        counts->chars += bytes;
    }

    if (current_line_len > counts->max_line) {
        counts->max_line = current_line_len;
    }

    close(fd); // FIXED: Prevent file descriptor leak

    print_data(flags, counts, file);
    return 0;
}

void count_words(char *buffer, size_t bytes, int *word_count, int *in_word) {
    for (size_t i = 0; i < bytes; i++) {
        unsigned char c = (unsigned char)buffer[i];
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f' || c == '\v') {
            *in_word = 0;
        } else if (*in_word == 0) {
            (*word_count)++;
            *in_word = 1;
        }
    }
}

void count_lines(char *buffer, size_t bytes, int *lines, int *max_line, int *current_line_len) {
    for (size_t i = 0; i < bytes; i++) {
        if (buffer[i] == '\n') {
            (*lines)++;
            if (*current_line_len > *max_line) {
                *max_line = *current_line_len;
            }
            *current_line_len = 0;
        } else {
            (*current_line_len)++;
        }
    }
}

void clear_counts(s_counts *counts) {
    counts->lines = 0;
    counts->words = 0;
    counts->chars = 0;
    counts->max_line = 0;
}

void print_data(s_opt *flags, s_counts *counts, const char *file) {
    int any_flag = flags->l || flags->w || flags->c || flags->L;

    if (!any_flag) {
        // Default output: lines, words, bytes, filename
        printf("%7d %7d %7d %s\n", counts->lines, counts->words, counts->chars, file);
        return;
    }

    if (flags->l) printf("%7d ", counts->lines);
    if (flags->w) printf("%7d ", counts->words);
    if (flags->c) printf("%7d ", counts->chars);
    if (flags->L) printf("%7d ", counts->max_line);
    printf("%s\n", file);
}

void print_total_data(s_opt *flags, s_counts *counts) {
    int any_flag = flags->l || flags->w || flags->c || flags->L;

    if (!any_flag) {
        printf("%7d %7d %7d total\n", counts->total_lines, counts->total_words, counts->total_chars);
        return;
    }

    if (flags->l) printf("%7d ", counts->total_lines);
    if (flags->w) printf("%7d ", counts->total_words);
    if (flags->c) printf("%7d ", counts->total_chars);
    if (flags->L) printf("%7d ", counts->total_max_line);
    printf("total\n");
}

void print_stdin(s_opt *flags, s_counts *counts) {
    int any_flag = flags->l || flags->w || flags->c || flags->L;

    if (!any_flag) {
        printf("%7d %7d %7d\n", counts->lines, counts->words, counts->chars);
        return;
    }

    if (flags->l) printf("%7d ", counts->lines);
    if (flags->w) printf("%7d ", counts->words);
    if (flags->c) printf("%7d ", counts->chars);
    if (flags->L) printf("%7d ", counts->max_line);
    printf("\n");
}
