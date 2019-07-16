org 0x7c00 ; program entry

BaseOfStack equ 0x7c00

; init registers
mov     ax, cs
mov     ds, ax
mov     es, ax
mov     ss, ax
mov     sp, BaseOfStack

; clear screen
; AH = 06h roll pages
; AL = page num (0 to clear screen)
; BH = color attributes
; CL = left row, CH = left column
; DL = right row, DH = right column
mov     ax, 0600h
mov     bx, 0700h
mov     cx, 0
mov     dx, 184Fh
int     10h

; set focus
; AH = 02h set focus
; DL = row
; DH = column
; BH = page num
mov     ax, 0200h
mov     bx, 0000h
mov     dx, 0000h
int     10h

; display boot string (int 10h)
; AH = 13h display a string
; AL = 01h display mode
; CX = StringLen
; DH = row, DL = column
; ES:BP = String adress
; BH = page num
; BL = text attributes

; Print a string on screen
; Parms:
; Stack: StringAddress, StringLength, ColRow
; Return:
; No return
Func_PrintString:

; construct stack frame
push    bp
mov     bp, sp

; StringAddress     = [bp + 4]
; StringLength      = [bp + 6]
; ColRow            = [bp + 8]

; protect registers
push    ax
push    bx
push    cx

; protect BP
push bp

; print string
mov     ax, 1301h
mov     bx, 000fh
mov     cx, [bp + 6]
mov     dx, [bp + 8]
mov     bp, [bp + 4]
int     10h

; recover bp
pop bp

; recover registers
pop     cx
pop     bx
pop     ax

; close stack frame
mov     sp, bp
pop     bp
; return
ret     6h

; print boot message
push    0000h
push    16
push    StartBootMessage
call    Func_PrintString

; loop wait
jmp $

; message string
StartBootMessage:   db  "Start Booting..."

; padding zero and set flag
times   510 - ($ - $$) db 0
dw      0xaa55

