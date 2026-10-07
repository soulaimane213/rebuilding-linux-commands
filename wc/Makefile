CC     = gcc
CFLAGS = -Wall -Wextra -g
SRCS   = main.c parsing.c ft_wc.c utils.c
NAME   = wc

all: $(NAME)

$(NAME): $(SRCS) wc.h
	$(CC) $(CFLAGS) $(SRCS) -o $(NAME)

clean:
	rm -f $(NAME) my_wc wc.h.gch

.PHONY: all clean