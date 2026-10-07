NAME = mkdir

all:
	nasm -f elf64 main.asm -o main.o
	ld main.o -o $(NAME)

clean:
	rm -f main.o $(NAME)