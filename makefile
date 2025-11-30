# Variables to make things easier to change
CC = i386-elf-gcc
LD = i386-elf-ld
CFLAGS = -ffreestanding -c
LDFLAGS = -Ttext 0x1000 --oformat binary

all: os-image.bin

run: os-image.bin
	qemu-system-i386 -fda kernel/os-image.bin

os-image.bin: kernel/bootsect.bin kernel/kernel.bin
	cat kernel/bootsect.bin kernel/kernel.bin > kernel/os-image.bin

# STEP 16: Link screen.o AND ports.o
kernel/kernel.bin: kernel/kernel_entry.o kernel/kernel.o drivers/ports.o drivers/screen.o
	$(LD) -o $@ $(LDFLAGS) $^

kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) $< -o $@

drivers/ports.o: drivers/ports.c
	$(CC) $(CFLAGS) $< -o $@

drivers/screen.o: drivers/screen.c
	$(CC) $(CFLAGS) $< -o $@

kernel/kernel_entry.o: boot/kernel_entry.asm
	nasm $< -f elf -o $@ -I boot/

kernel/bootsect.bin: boot/bootsect.asm
	nasm $< -f bin -o $@ -I boot/

clean:
	rm -f kernel/.bin kernel/.o drivers/*.o