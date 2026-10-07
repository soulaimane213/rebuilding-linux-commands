#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

void check_flags(int *v_flag, int *r_flag, int *i_flag, char **av, int *i) {
    int j = 1;
    while (av[j] != NULL && av[j][0] == '-') {
        if (strcmp(av[j], "-i") == 0) {
            *i_flag = 1;
            (*i)++;
        } else if (strcmp(av[j], "-v") == 0) {
            *v_flag = 1;
            (*i)++;
        } else if (strcmp(av[j], "-r") == 0) {
            *r_flag = 1;
            (*i)++;
        }
        j++;
    }
}

void delete_file(const char *path, int i_flag, int v_flag) {
    if (i_flag) {
        char response;
        printf("rm: remove regular file '%s'? (y/n) ", path);
        if (scanf(" %c", &response) != 1 || (response != 'y' && response != 'Y')) {
            return;
        }
    }

    if (unlink(path) == 0) {
        if (v_flag) {
            printf("removed '%s'\n", path);
        }
    } else {
        perror("rm: cannot remove file");
    }
}

void delete_directory(const char *path, int r_flag, int i_flag, int v_flag) {
    if (!r_flag) {
        fprintf(stderr, "rm: cannot remove '%s': Is a directory (use -r)\n", path);
        return;
    }

    DIR *d = opendir(path);
    if (!d) {
        perror("rm: cannot open directory");
        return;
    }

    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (strcmp(e->d_name, ".") == 0 || strcmp(e->d_name, "..") == 0) {
            continue;
        }

        char subpath[1024];
        snprintf(subpath, sizeof(subpath), "%s/%s", path, e->d_name);

        struct stat st;
        if (lstat(subpath, &st) == -1) {
            continue;
        }

        if (S_ISDIR(st.st_mode)) {
            delete_directory(subpath, r_flag, i_flag, v_flag);
        } else {
            delete_file(subpath, i_flag, v_flag);
        }
    }
    closedir(d); // FIXED: Prevent file descriptor leak

    if (i_flag) {
        char response;
        printf("rm: remove directory '%s'? (y/n) ", path);
        if (scanf(" %c", &response) != 1 || (response != 'y' && response != 'Y')) {
            return;
        }
    }

    if (rmdir(path) == 0) {
        if (v_flag) {
            printf("removed directory '%s'\n", path);
        }
    } else {
        perror("rm: cannot remove directory");
    }
}

int main(int ac, char **av) {
    if (ac < 2) {
        fprintf(stderr, "usage: rm [-r] [-i] [-v] <file...>\n");
        return 1;
    }

    int r_flag = 0, v_flag = 0, i_flag = 0, i = 1;
    check_flags(&v_flag, &r_flag, &i_flag, av, &i);

    while (i < ac) {
        struct stat st;
        if (lstat(av[i], &st) == -1) {
            fprintf(stderr, "rm: cannot access '%s': No such file or directory\n", av[i]);
            i++;
            continue;
        }

        if (S_ISDIR(st.st_mode)) {
            delete_directory(av[i], r_flag, i_flag, v_flag);
        } else {
            delete_file(av[i], i_flag, v_flag);
        }
        i++;
    }

    return 0;
}