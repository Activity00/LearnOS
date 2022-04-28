org	0x7c00 ;伪指令说明其后面程序的目标代码在内存中存放的起始地址是0x7C00

BaseOfStack	equ	0x7c00

BaseOfLoader equ 0x1000 ; loader程序起始物理地址 需由实模式的地址变换公式才能生成物理地址 即 << 4 + OffsetOfLoader = 0x10000
OffsetOfLoader equ 0x00

RootDirSectors	equ	14   ; 定义了根目录占用扇区数 由FAT12 提供信息计算(BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / BPB_BytesPerSec = (224 * 32 + 512 -1) / 512 = 14
SectorNumOfRootDirStart	equ	19 ; 根目录其实扇区号
SectorNumOfFAT1Start	equ	1   ; FAT1表起始扇区号
SectorBalance	equ	17  ; 平衡文件、目录其实扇区号与数据区其实簇号差值

; FAT12文件系统 名称            偏移  长度     内容                     描述
jmp	short Label_Start        ; 0   3       跳转指定                  因为下面描述信息不是执行程序
nop
BS_OEMName	db	'MINEboot'   ; 3   8       生产厂名称
BPB_BytesPerSec	dw	512      ; 11  2       每扇区字节数
BPB_SecPerClus	db	1        ; 13  1       每簇扇区数                过小的扇区容量可能会频繁读写、从而引入簇、2……n扇区作为FAT最小存储单元
BPB_RsvdSecCnt	dw	1        ; 14  2       保留扇区数                不能0，FAT12为1、即保留1扇区作为引导 FAT表从第二扇区开始
BPB_NumFATs	db	2            ; 16  1       FAT表份数                FAT12推荐保留一个备份表
BPB_RootEntCnt	dw	224      ; 17  2       根目录可容纳目录项数        对于FAT12乘以32必须是BPB_BytesPerSec 偶数倍
BPB_TotSec16	dw	2880     ; 19  2       总扇区数                  如果0BPB_TotSec32必须有值
BPB_Media	db	0xf0         ; 21  1       介质描述符                对于不可移动介质0xf8 对于可移动设备通常0xf0、且FAT[0]低字节写入相同值
BPB_FATSz16	dw	9            ; 22  2       每FAT扇区数               FAT表1和表2 用户相同容量，所以都有该值记录
BPB_SecPerTrk	dw	18       ; 24  2       每磁道扇区数
BPB_NumHeads	dw	2        ; 26  2       磁头数
BPB_HiddSec	dd	0            ; 28  4       隐藏扇区数
BPB_TotSec32	dd	0        ; 32  4       如果BPB_TotSec16 0 生效
BS_DrvNum	db	0            ; 36  1       int 13h 的驱动器号
BS_Reserved1	db	0        ; 37  1       未使用
BS_BootSig	db	0x29         ; 38  1       扩展引导标记
BS_VolID	dd	0            ; 39  4       卷序列号
BS_VolLab	db	'boot loader'; 43  11      卷标                     window、linux中的磁盘名
BS_FileSysType	db	'FAT12   ';54  8       文件系统类型               只是个字符串，系统不以他作为文件系统识别
                             ; 62  448     引导代码数据以及其他信息
                             ; 510 2       结束标记0xaa55

Label_Start:
	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	sp,	BaseOfStack

;=======	clear screen
; AH: 06 指定范围滚动窗口  如果AL0清屏功能 BX CX DX寄存器将不起作用
; AL: 指定滚动列数,如果是0则清屏
; BH: 滚动后空出位置放入的属性  bit0~2字体颜色 0 黑 1 蓝 2 绿 3 青 4 红 5 紫 6 棕 7 白  bit3 字体亮度 0 正常 1 高亮 bit4-6 背景颜色(同字体颜色)  bit7 字体闪烁 0 闪烁 1 不闪烁
; CH: 滚动范围的左上角坐标列号
; CL: 滚动范围的左上角坐标行号
; DH: 滚动范围的右下角坐标列号
; DL: 滚动范围的右下角坐标行号
	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	0
	mov	dx,	0184fh
	int	10h

;=======	set focus
; BH 页码
; DH 游标列数 DL 游标行数目
	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......
; AH=13h 显示一行字符串
; AL=写入模式
;   = 00h: 字符串属性由BL寄存器提供, CX寄存器提供字符串长度(B为单位), 显示后光标位置不变
;   = 01h: 同00h,但光标会移动至字符串末尾
;   = 02h: 字符串属性由每个字符后面仅跟的字节提供,故CX寄存器提供的字符串长度改成以Word为单位,显示后光标位置不变
;   = 03h: 同02h, 但是光标会移动到子字符串尾端位置.
; CX=字符传长度
; DH=游标坐标行号
; DL=游标坐标列号
; ES:BP=要显示字符串的内存地址
; BH=页码
; BL=字体属性/颜色属性 同AH=06 int 10h 功能
	mov	ax,	1301h
	mov	bx,	000fh
	mov	dx,	0000h
	mov	cx,	10   ;  StartBootMessage 字符长度
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	StartBootMessage
	int	10h

;=======	reset floppy
; INT 13h, AH=00h 功能: 重置磁盘驱动器,从而将软盘驱动器的磁头移动至默认位置
; DL=驱动器号, 00H~7FH: 软盘; 80H~0FFH: 硬盘
;   =00h 代表第一个软盘驱动器（"driver A:"）
;   =01h 代表第二个软盘驱动器（"driver B:"）
;   =80h 代表第一个硬盘驱动器
;   =81h 代表第二个硬盘驱动器
	xor	ah,	ah
	xor	dl,	dl
	int	13h

	jmp	$

;======= read one sector from floppy 软盘读取功能
; 介绍: AX=待读取磁盘起始扇区号  CL: 读入的扇区数量  ES:BX => 目标缓冲区起始地址

Func_ReadOneSector:
    push bp
    mov bp, sp
    sub esp, 2
    mov byte[bp - 2], cl
    push bx
    mov bl, [BPB_SecPerTrk]
    div bl
    inc ah
    mov cl, ah               ; CL=扇区号1~63(bit 0~5), 磁道号的高2位（bit 6~7只对硬盘有效）
    mov dh, al               ; DH=磁头号
    shr al, 1
    mov ch, al               ; CH=磁道号(柱面号)的低八位
    and dh, 1
    pop bx                   ; ES:BX=>数据缓冲区
    mov dl, [BS_DrvNum]      ; DL=驱动器号
Label_Go_On_Reading:
    mov ah, 2                ; AH=02H int13h 软盘扇区读取
    mov al, byte [bp - 2]    ; AL=读入的扇区数，必须为非0
    int 13h
    jc Label_Go_On_Reading
    add esp, 2
    pop bp
    ret

;======= search loader.bin
    mov word [SectorNo], SectorNumOfRootDirStart
Label_Search_In_Root_Dir_Begin:
    cmp word [RootDirSizeForLoop], 0
    jz Label_No_LoaderBin
    dec word [RootDirSizeForLoop]
    mov ax, 00h
    mov es, ax
    mov bx, 8000h
    mov ax, [SectorNo]
    mov cl, 1
    call Func_ReadOneSector
    mov si, LoaderFileName
    mov di, 8000h
    cld
    mov dx, 10h

Label_Search_For_LoaderBin:
    cmp dx, 0
    jz Label_Goto_Next_Sector_In_Root_Dir
    dec dx
    mov cx, 11

Label_Cmp_FileName:
    cmp cx, 0
    jz Label_FileName_Found
    dec cx
    lodsb
    cmp al, byte [es:di]
    jz Label_Go_On
    jmp Label_Different

Label_Go_On:
    inc di
    jmp Label_Cmp_FileName

Label_Different:
    and di, 0ffe0h
    add di, 20h
    mov si, LoaderFileName
    jmp Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
    add word [SectorNo], 1
    jmp Label_Search_In_Root_Dir_Begin

Label_No_LoaderBin:
    mov ax, 1301h
    mov bx, 008ch
    mov dx, 0100h
    mov cx, 21
    push ax
    mov ax, ds
    mov es, ax
    pop ax
    mov bp, NoLoaderMessage
    int 10h
    jmp $


;====== get FAT Entry

Func_GetFATEntry:
    push es
    push bx
    push ax
    mov ax, 00
    mov es, ax
    pop ax
    mov byte [Odd], 0
    mov bx, 3
    mul bx
    mov bx, 2
    div bx
    cmp dx, 0
    jz Label_Even
    mov byte [Odd], 1

Label_Even:
    xor dx, dx
    mov bx, [BPB_BytesPerSec]
    div bx
    push dx
    mov bx, 8000h
    add ax, SectorNumOfFAT1Start
    mov cl, 2
    call Func_ReadOneSector

    pop dx
    add bx, dx
    mov ax, [es:bx]
    cmp byte [Odd], 1
    jnz Label_Even_2
    shr ax, 4

Label_Even_2:
    and ax, 0fffh
    pop bx
    pop es
    ret

;======= found loader.bin name in root dir struct

Label_FileName_Found:
    mov ax, RootDirSectors
    and di, 0ffe0h
    add di, 01ah
    mov cx, word [es:di]
    push cx
    add cx, ax
    add cx, SectorBalance
    mov ax, BaseOfLoader
    mov es, ax
    mov bx, OffsetOfLoader
    mov ax, cx

Label_Go_On_Loading_File:
    push ax
    push bx
    mov ah, 0eh
    mov al, '.'
    mov bl, 0fh
    int 10h
    pop bx
    pop ax

    mov cl, 1
    call Func_ReadOneSector
    pop ax
    call Func_GetFATEntry
    cmp ax, 0fffh
    jz Label_File_Loaded
    push ax
    mov dx, RootDirSectors
    add ax, dx
    add ax, SectorBalance
    add bx, [BPB_BytesPerSec]
    jmp Label_Go_On_Loading_File

Label_File_Loaded:
    jmp BaseOfLoader:OffsetOfLoader

;======= tmp variable
RootDirSizeForLoop dw RootDirSectors
SectorNo dw 0
Odd db 0
;====== display messages
NoLoaderMessage: db "ERROR:NO LOADER FOUND"
LoaderFileName: db "LOADER BIN", 0




StartBootMessage:	db	"Start Boot"
;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0   ; $-$$编译后地址-本节程序起始地址
	dw	0xaa55  ;Intel 处理器采用小端模式存储数据 所以扇区存储顺序是0x55、 0xaa
