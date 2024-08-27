all: build/boot.bin build/loader.bin image

build/boot.bin : src/bootloader/boot.asm
	nasm src/bootloader/boot.asm -o build/boot.bin

build/loader.bin: src/bootloader/loader.asm
	nasm src/bootloader/loader.asm -o build/loader.bin

image:
	mkdir media/ && mount -t vfat -o loop build/boot.img media/ && cp build/*.bin media/ && cp src/kernel/*.bin media/ && sync && umount media/ && rm -rf media/

upload:
	rsync -zvrtopg --progress --delete . -e ssh wmh@192.168.1.8:/home/wmh/LearnOS

download:
	rsync -zvrtopg --progress -e 'ssh -p 22' wmh@192.168.1.8:/home/wmh/LearnOS/build/ ./build/

clean:
	rm build/*.bin
