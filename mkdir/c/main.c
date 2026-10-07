#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int ac, char **av) {
    if (ac < 2) {
        fprintf(stderr, "usage: mkdir [-v] <directory...>\n");
        return 1;
    }

    int i = 1;
    int v_flag = 0;

    if (strcmp(av[1], "-v") == 0) {
        v_flag = 1;
        i++;
    }

    if (i >= ac) {
        fprintf(stderr, "mkdir: missing operand\n");
        return 1;
    }

    int exit_status = 0;
    while (i < ac) {
        // 0755 = rwxr-xr-x permissions
        if (mkdir(av[i], 0755) < 0) {
            fprintf(stderr, "mkdir: cannot create directory '%s'\n", av[i]);
            exit_status = 1;
        } else if (v_flag) {
            printf("mkdir: created directory '%s'\n", av[i]);
        }
        i++;
    }

    return exit_status;
}