print:
    pusha

;while (string[i] !=0) {print string[i]; i++}
start:
    mov al, [bx] ;base address for the string 
    cmp al,0
    je done ;jump if equal/zero

    mov ah, 0x0e
    int 0x10

    add bx,1
    jmp start

done:
    popa
    ret

print_nl:
    pusha
    mov ah,0x0e
    mov al,0x0a ;newline 
    int 0x10
    mov al, 0x0d ;return
    int 0x10
    
    popa 
    ret