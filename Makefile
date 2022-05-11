all: build/boot.bin build/loader.bin

build/boot.bin : src/bootloader/boot.asm
	nasm src/bootloader/boot.asm -o build/boot.bin

build/loader.bin: src/bootloader/loader.asm
	nasm src/bootloader/loader.asm -o build/loader.bin

upload:
	rsync -zvrtopg --progress --delete . -e ssh wmh@192.168.1.8:/home/wmh/LearnOS

download:
	rsync -zvrtopg --progress -e 'ssh -p 22' wmh@192.168.1.8:/home/wmh/LearnOS/build/ ./build/

clean:
	rm build/*.bin
