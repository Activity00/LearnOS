docker run  --rm -it --privileged -v $(pwd):/opt  busybox /bin/bash mkdir /opt/media/ && mount -t vfat -o loop /opt/build/boot.img /opt/media/ && cp /opt/build/loader.bin /opt/media/ && sync && umount /opt/media/ && rm -rf /opt/media/