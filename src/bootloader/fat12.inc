RootDirSectors	equ	14   ; 定义了根目录占用扇区数 由FAT12 提供信息计算(BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / BPB_BytesPerSec = (224 * 32 + 512 -1) / 512 = 14
SectorNumOfRootDirStart	equ	19 ; 根目录其实扇区号
SectorNumOfFAT1Start	equ	1   ; FAT1表起始扇区号
SectorBalance	equ	17  ; 平衡文件、目录其实扇区号与数据区其实簇号差值

; FAT12文件系统 名称            偏移  长度     内容                     描述
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
