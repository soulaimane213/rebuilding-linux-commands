#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int ac, char **av) {
    if (ac == 2) {
        if (strcmp(av[1], "-h") == 0 || strcmp(av[1], "--help") == 0) {
            printf("usage: pwd [-h | --help] [-v | --version]\n");
            return 0;
        }

        if (strcmp(av[1], "-v") == 0 || strcmp(av[1], "--version") == 0) {
            printf("pwd version 1.0.0\n");
            return 0;
        }
    }

    char buffer[PATH_MAX];

    if (getcwd(buffer, sizeof(buffer)) != NULL) {
        printf("%s\n", buffer);
    } else {
        perror("pwd: getcwd failed");
        return 1;
    }

    return 0;
}