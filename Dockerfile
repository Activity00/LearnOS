#TODO
FROM Busybox:latest

WORKDIR /opt/

COPY . .
RUN  mkdir /opt/media/ && mount -t vfat -o loop /opt/build/boot.img /opt/media/ && cp /opt/build/loader.bin /opt/media/ && sync && umount /opt/media/
