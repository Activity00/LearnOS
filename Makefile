all: bootloader dd_to_img cp_to_img

bootloader : src/bootloader/boot.asm src/bootloader/loader.asm
	nasm src/bootloader/boot.asm -o build/boot.bin
	nasm src/bootloader/loader.asm -o build/loader.bin

dd_to_img:
	dd if=build/boot.bin of=build/boot.img bs=512 count=1 conv=notrunc

cp_to_img:
	mkdir media/ && sudo mount build/boot.img media/ -t vfat -o loop  && sudo cp build/*.bin media/ && sudo cp src/kernel/*.bin media/ && sync && sudo umount media/ && rm -rf media/

upload:
	rsync -zvrtopg --progress --delete . -e ssh wmh@192.168.1.8:/home/wmh/LearnOS

download:
	rsync -zvrtopg --progress -e 'ssh -p 22' wmh@192.168.1.8:/home/wmh/LearnOS/build/ ./build/

clean:
	rm build/*.bin
