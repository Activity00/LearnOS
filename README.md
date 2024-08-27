# LearnOS
## 环境
### MacOS
brew install bochs

bochs -f bachsrc

### 基于ubuntu
基于ubuntu18.04 包括bochs2.6.9 以及nasm、dd等基本命令
```
docker pull activity00/osenv:latest
```
运行：
如果是linux系统宿主机执行 xhost + 允许容器共享显示
```
docker run -it --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/LearnOS -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE activity00/osenv:latest bash 
```

cd LearnOS && bochs -f bachsrc
enter c to continue

## bochs 常用调试命令
| 指令 | 说明 | 举例 |
|------|------|------|
| b address | 物理地址设置断点 | b 0x7c00 
| c | 继续执行直到遇到断点 | c
| s | 单步执行 | s
| info cpu | 查看寄存器信息 | info cpu
| r | ... | r
sreg| ... | sreg
creg| ... | creg
xp /nuf addr | 查看内存物理地址内容 | xp /10bx 0x100000
x /nuf addr | 查看线性地址内容 | x  /40wd 0x90000
u /start end | 反编译一段内存 | u 0x100000 0x100010

注： n: 显示单元格式； u:显示单元大小[b:Byte, h:Word, w:dword, g: QWord(四字节)]； f:显示格式(x: 十六进制、d:十进制、t: 二进制、c:字符)
