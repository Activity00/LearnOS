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
