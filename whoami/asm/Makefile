NAME = whoami

all:
	nasm -f elf64 main.asm -o main.o
	gcc -no-pie main.o -o $(NAME)

clean:
	rm -f main.o $(NAME)