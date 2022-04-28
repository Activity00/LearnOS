mount -t vfat -o loop build/boot.img media/  # -o loop 把文件描述成磁盘分区
cp loader.bin media/
sync
umount media/
