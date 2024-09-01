org	10000h

dw 0123h, 0456h, 0789h, 0abch, 0defh, 0ffedh, 0cbah, 0987h
dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

jmp	Label_Start

Label_Start:
   mov ax, cs
   mov ss, ax
   mov sp, 30h

   mov bx, 0
   mov cx, 8

s: push word [cs:bx]
   add ax, 2
   loop s

   mov bx, 0
   mov cx, 8

s0: pop word [cs:bx]
    add bx, 2
    loop s0

    jmp $

