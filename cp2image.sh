mkdir media/ && mount -t vfat -o loop build/boot.img media/ && cp build/*.bin media/ && cp src/kernel/*.bin media/ && sync && umount media/ && rm -rf media/

