# Variables to make things easier to change
CC = i386-elf-gcc
LD = i386-elf-ld
# Flags: Freestanding means "no standard library"
CFLAGS = -ffreestanding -c
# Link at 0x1000, output raw binary
LDFLAGS = -Ttext 0x1000 --oformat binary

all: os-image.bin

# 1. Run QEMU
run: os-image.bin
# Usar tabulación
	qemu-system-i386 -fda kernel/os-image.bin

# 2. Create the final disk image
os-image.bin: kernel/bootsect.bin kernel/kernel.bin
# Usar tabulación
	cat kernel/bootsect.bin kernel/kernel.bin > kernel/os-image.bin

# 3. Build the Kernel Binary (AQUÍ ESTÁ LA CORRECCIÓN CLAVE)
kernel/kernel.bin: kernel/kernel_entry.o kernel/kernel.o drivers/ports.o
# Usar tabulación
	$(LD) -o $@ $(LDFLAGS) $^

# 4. Compile C code
kernel/kernel.o: kernel/kernel.c
# Usar tabulación
	$(CC) $(CFLAGS) $< -o $@

# 4b. Compile Drivers C code
drivers/ports.o: drivers/ports.c
# Usar tabulación
	$(CC) $(CFLAGS) $< -o $@

# 5. Compile Assembly (Entry)
kernel/kernel_entry.o: boot/kernel_entry.asm
# Usar tabulación
	nasm $< -f elf -o $@ -I boot/

# 6. Compile Assembly (Bootloader)
kernel/bootsect.bin: boot/bootsect.asm
# Usar tabulación
	nasm $< -f bin -o $@ -I boot/

clean:
# Usar tabulación
	rm -f kernel/*.bin kernel/*.o drivers/*.o