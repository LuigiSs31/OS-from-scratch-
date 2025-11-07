[org 0x7c00]       ;global offset

    mov ax, 0       ; Set up segment registers
    mov ds, ax
    mov es, ax
    mov ss, ax      ; Set up a valid stack
    mov sp, 0x7c00  ;    ...at 0x7c00 (it grows downwards)

    mov ah, 0x0e    ; TTY mode
    mov al, 'H'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'l'     
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, ' '
    int 0x10

   
    mov al, [the_secret]  
    int 0x10             ;Print the 'X' to the screen

    jmp $   ;infinite loop 

    the_secret:
        db "X"

; Fill with 510 zeros minus the size of the previous code
    times 510-($-$$) db 0
    dw 0xaa55 ; Magic number

