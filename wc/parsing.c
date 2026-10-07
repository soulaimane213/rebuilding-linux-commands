#include "wc.h"

// Check long options like --files0-from=
static int check_flag(s_opt *flags, char *flag) {
    const char *F_flag = "--files0-from=";

    if (strncmp(flag, F_flag, 14) == 0) {
        char *start = flag + 14;

        if (*start == '\0') {
            fprintf(stderr, "wc: cannot open '' for reading: No such file or directory\n");
            return -1;
        }

        flags->file_F = 1;
        flags->files_F_name = strdup(start);
        if (!flags->files_F_name) {
            perror("wc: memory allocation failed");
            return -1;
        }
    } else {
        fprintf(stderr, "wc: unrecognized option '%s'\n", flag);
        fprintf(stderr, "Try 'wc --help' for more information.\n");
        return -1;
    }
    return 0;
}

int parsing_args(s_opt *flags, char **args) {
    int i = 1;

    while (args[i] != NULL) {
        // GNU Long options (--version, --help, --files0-from=)
        if (args[i][0] == '-' && args[i][1] == '-') {
            if (strcmp(args[i], "--version") == 0) {
                flags->v = 1;
            } else if (strcmp(args[i], "--help") == 0) {
                flags->h = 1;
            } else if (strcmp(args[i], "--lines") == 0) {
                flags->l = 1;
            } else if (strcmp(args[i], "--words") == 0) {
                flags->w = 1;
            } else if (strcmp(args[i], "--bytes") == 0) {
                flags->c = 1;
            } else if (strcmp(args[i], "--max-line-length") == 0) {
                flags->L = 1;
            } else {
                if (check_flag(flags, args[i]) < 0) {
                    return -1;
                }
            }
        }
        // Short options (-l, -w, -c, -L)
        else if (args[i][0] == '-' && args[i][1] != '\0') {
            for (int j = 1; args[i][j] != '\0'; j++) {
                if (args[i][j] == 'l') {
                    flags->l = 1;
                } else if (args[i][j] == 'w') {
                    flags->w = 1;
                } else if (args[i][j] == 'c') {
                    flags->c = 1;
                } else if (args[i][j] == 'L') {
                    flags->L = 1;
                } else {
                    fprintf(stderr, "wc: invalid option -- '%c'\n", args[i][j]);
                    fprintf(stderr, "Try 'wc --help' for more information.\n");
                    return -1;
                }
            }
        } else {
            // Positional argument: filename
            flags->files_n++;
        }
        i++;
    }

    return 0;
}
