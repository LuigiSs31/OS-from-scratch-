
disk_load:
    pusha
    ; reading from the disk needs settings specific values in all of the registers
    ; we need to overwrite the parameters from 'dx'
    push dx

    mov ah, 0x02 ; ah <- int 0x13 functions. 0x02= 'read'
    mov al,dh ; al <- number of sectors to read (0x01 .. 0x00)
    mov cl, 0x02 ; cl <- sector (0x01 .. 0x11)
                 ; 0x01 is the boot sector, 0x02 is the first 'available' sector 
    mov ch, 0x00 ; ch <- cylinder (0x0 .. 0x03FF, upper 2 bits in 'cl')
    ; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
    ; (0=floppy, 1=floppy2, 0x80=hdd,0x81=hdd2 )
    mov dh ,0x00 ; dh head number 

    int 0x13 ; BIOS interrupt 
    jc disk_error ; if error (stored in the carry bit)
    
    pop dx
    cmp al,dh ; BIOS also sets 'al' to # sectors 
    jne sectors_error 
    popa 
    ret

disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh,ah
    call print_hex
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db"Disk read error",0
SECTORS_ERROR: db"Incorrect number of sectors read",0