build/boot.bin : src/bootloader/boot.asm
	nasm src/bootloader/boot.asm -o build/boot.bin

build/loader.bin: src/bootloader/loader.asm
	nasm src/bootloader/loader.asm -o build/loader.bin

all: boot.bin loader.bin

clean:
	rm build/*.bin
