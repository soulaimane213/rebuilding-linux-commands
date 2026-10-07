#include "wc.h"

void ft_wc(s_opt *flags, s_counts *counts, char **args) {
    int i = 1;

    flags->files_n = 0; // reset to count successfully processed files
    while (args[i] != NULL) {
        if (args[i][0] != '-') {
            clear_counts(counts);
            int ret = process_file(flags, counts, args[i]);
            if (ret < 0) {
                i++;
                continue;
            }

            counts->total_lines += counts->lines;
            counts->total_words += counts->words;
            counts->total_chars += counts->chars;

            if (counts->max_line > counts->total_max_line) {
                counts->total_max_line = counts->max_line;
            }
            flags->files_n++;
        }
        i++;
    }

    if (flags->files_n > 1) {
        print_total_data(flags, counts);
    }
}

int handle_file_from(s_opt *flags, s_counts *counts, char *file_name) {
    struct stat st;
    if (stat(file_name, &st) == -1) {
        fprintf(stderr, "wc: cannot open '%s' for reading: No such file or directory\n", file_name);
        return -1;
    }

    if (S_ISDIR(st.st_mode)) {
        fprintf(stderr, "wc: %s: read error: Is a directory\n", file_name);
        return -1;
    }

    int fd = open(file_name, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "wc: cannot open '%s' for reading: No such file or directory\n", file_name);
        return -1;
    }

    char *buffer = malloc(st.st_size + 1);
    if (!buffer) {
        perror("wc: malloc error");
        close(fd);
        return -1;
    }

    ssize_t bytes = read(fd, buffer, st.st_size);
    close(fd);

    if (bytes <= 0) {
        free(buffer);
        return -1;
    }
    buffer[bytes] = '\0';

    flags->files_n = 0;
    ssize_t i = 0;
    char *start = buffer;

    while (i <= bytes) {
        if (buffer[i] == '\0') {
            if (start < &buffer[i]) {
                clear_counts(counts);
                int ret = process_file(flags, counts, start);
                if (ret == 0) {
                    counts->total_lines += counts->lines;
                    counts->total_words += counts->words;
                    counts->total_chars += counts->chars;

                    if (counts->max_line > counts->total_max_line) {
                        counts->total_max_line = counts->max_line;
                    }
                    flags->files_n++;
                }
            }
            start = &buffer[i + 1];
        }
        i++;
    }

    free(buffer);

    if (flags->files_n > 1) {
        print_total_data(flags, counts);
    }

    return 0;
}

void ft_stdin_wc(s_opt *flags, s_counts *counts) {
    (void)flags;
    char buffer[BUFFER_SIZE];
    ssize_t bytes;
    int in_word = 0;
    int current_line_len = 0;

    clear_counts(counts);

    while ((bytes = read(STDIN_FILENO, buffer, sizeof(buffer))) > 0) {
        count_words(buffer, bytes, &(counts->words), &in_word);
        count_lines(buffer, bytes, &(counts->lines), &(counts->max_line), &current_line_len);
        counts->chars += bytes;
    }

    // Check last line if missing trailing newline
    if (current_line_len > counts->max_line) {
        counts->max_line = current_line_len;
    }
}
