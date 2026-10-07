#include <pwd.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char **av) {
    int h_flag = 0;
    int s_flag = 0;

    if (argc > 1) {
        if (strcmp(av[1], "-h") == 0 || strcmp(av[1], "--home") == 0) {
            h_flag = 1;
        } else if (strcmp(av[1], "-s") == 0 || strcmp(av[1], "--shell") == 0) {
            s_flag = 1;
        }
    }

    uid_t user_id = getuid();
    struct passwd *user_info = getpwuid(user_id);

    if (!user_info) {
        perror("whoami: cannot find username for UID");
        return 1;
    }

    if (h_flag) {
        printf("%s: %s\n", user_info->pw_name, user_info->pw_dir);
    } else if (s_flag) {
        printf("%s: %s\n", user_info->pw_name, user_info->pw_shell);
    } else {
        printf("%s\n", user_info->pw_name);
    }

    return 0;
}