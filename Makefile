all:
	nasm -f elf64 -o main.o main.asm
	ld -o exxx main.o

clean:
	rm exxx main.o
