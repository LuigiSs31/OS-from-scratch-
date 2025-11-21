print_hex:
    pusha

    mov cx,0

hex_loop:
    cmp cx,4 ; loop 4 times
    je end
    
    ; convert last char of 'dx' to ASCII
    mov ax,dx 
    and ax,0x000f 
    add al,0x30 ; add 0x30 to N to convert into ASCII N
    cmp al,0x39 ; if > 9, add extra 8 to represent 'A' to 'F'
    jle step2
    add al,7 ; 'A' is ASCII 65, after adding 0x30 to 10 we get 58, so 65-58=7

step2:
    mov bx,HEX_OUT + 5 ; base +length
    sub bx, cx
    mov [bx], al 
    ror dx, 4
    
    add cx,1
    jmp hex_loop

end:
    mov bx,HEX_OUT
    call print
    popa
    ret

HEX_OUT:
    db '0x0000',0