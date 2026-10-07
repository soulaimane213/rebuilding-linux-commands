#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#define BUFFER_SIZE 4096

int main(int ac, char **av) {
    if (ac < 2) {
        fprintf(stderr, "cat: please specify a file\n");
        return 1;
    }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;

    for (int i = 1; i < ac; i++) {
        int fd = open(av[i], O_RDONLY);
        if (fd < 0) {
            fprintf(stderr, "cat: %s: No such file or directory\n", av[i]);
            continue;
        }

        while ((bytes_read = read(fd, buffer, sizeof(buffer))) > 0) {
            write(STDOUT_FILENO, buffer, bytes_read);
        }

        close(fd);
    }

    return 0;
}