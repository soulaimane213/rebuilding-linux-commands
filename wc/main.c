#include "wc.h"

int main(int ac, char **av) {
    s_opt flags = {0};
    s_counts counts = {0};

    if (ac != 1) {
        if (parsing_args(&flags, av) < 0) {
            if (flags.files_F_name) free(flags.files_F_name);
            return 1;
        }

        // Handle version flag
        if (flags.v) {
            printf("wc version 1.0.0 (custom coreutils)\n");
            if (flags.files_F_name) free(flags.files_F_name);
            return 0;
        }

        // Handle help flag
        if (flags.h) {
            printf("Usage: wc [OPTION]... [FILE]...\n");
            printf("Print newline, word, and byte counts for each FILE, and a total line if\n");
            printf("more than one FILE is specified. A word is a non-zero-length sequence of\n");
            printf("characters delimited by white space.\n\n");
            printf("  -c, --bytes            print the byte counts\n");
            printf("  -l, --lines            print the newline counts\n");
            printf("  -w, --words            print the word counts\n");
            printf("  -L, --max-line-length  print the maximum display width\n");
            printf("      --files0-from=F    read input from the files specified by\n");
            printf("                           NUL-terminated names in file F\n");
            printf("      --help             display this help and exit\n");
            printf("      --version          output version information and exit\n");
            if (flags.files_F_name) free(flags.files_F_name);
            return 0;
        }

        // Handle --files0-from option
        if (flags.file_F) {
            int ret = handle_file_from(&flags, &counts, flags.files_F_name);
            free(flags.files_F_name);
            return (ret < 0) ? 1 : 0;
        }

        // If no files were passed after flags, read stdin
        if (flags.files_n == 0) {
            ft_stdin_wc(&flags, &counts);
            print_stdin(&flags, &counts);
        } else {
            ft_wc(&flags, &counts, av);
        }
    } else {
        // No arguments: default to reading from stdin
        ft_stdin_wc(&flags, &counts);
        print_stdin(&flags, &counts);
    }

    if (flags.files_F_name) {
        free(flags.files_F_name);
    }

    return 0;
}
