#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#define BUFFER_SIZE 4096

// Flag variables (0 = disabled, 1 = enabled)
int flag_v = 0;
int flag_i = 0;
int flag_f = 0;

int copy_file(char *src, char *dest)
{
    char buffer[BUFFER_SIZE];
    int fd_src, fd_dest;
    int bytes_read;

    // If destination file already exists
    if (access(dest, F_OK) == 0)
    {
        if (flag_f == 1)
        {
            unlink(dest);
        }
        else if (flag_i == 1)
        {
            printf("ft_cp: overwrite '%s'? (y/n) ", dest);
            char ans = 0;
            read(0, &ans, 1);
            if (ans != 'y' && ans != 'Y')
                return 0;
        }
    }

    // Open source file
    fd_src = open(src, O_RDONLY);
    if (fd_src < 0)
    {
        printf("ft_cp: cannot open '%s'\n", src);
        return 1;
    }

    // Open or create destination file
    fd_dest = open(dest, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd_dest < 0)
    {
        printf("ft_cp: cannot create '%s'\n", dest);
        close(fd_src);
        return 1;
    }

    // Copy loop: read chunk -> write chunk
    while ((bytes_read = read(fd_src, buffer, BUFFER_SIZE)) > 0)
    {
        write(fd_dest, buffer, bytes_read);
    }

    close(fd_src);
    close(fd_dest);

    // If verbose flag was set
    if (flag_v == 1)
    {
        printf("'%s' -> '%s'\n", src, dest);
    }

    return 0;
}

int main(int argc, char **argv)
{
    int i = 1;

    if (argc < 3)
    {
        printf("usage: ./ft_cp [-vif] source dest\n");
        return 1;
    }

    // Parse flags
    while (i < argc && argv[i][0] == '-' && argv[i][1] != '\0')
    {
        for (int j = 1; argv[i][j]; j++)
        {
            if (argv[i][j] == 'v')
                flag_v = 1;
            else if (argv[i][j] == 'i')
                flag_i = 1;
            else if (argv[i][j] == 'f')
                flag_f = 1;
            else
            {
                printf("ft_cp: invalid option -- '%c'\n", argv[i][j]);
                return 1;
            }
        }
        i++;
    }

    // Need source and destination
    if (argc - i < 2)
    {
        printf("usage: ./ft_cp [-vif] source dest\n");
        return 1;
    }

    char *src = argv[i];
    char *dest = argv[i + 1];

    return copy_file(src, dest);
}