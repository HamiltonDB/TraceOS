nasm -f bin boot.asm -o boot.bin
dd if=/dev/zero of=TabernacleOS.img bs=1024 count=5760
dd if=boot.bin of=TabernacleOS.img seek=0 count=1 conv=notrunc
qemu-system-x86_64 TabernacleOS.img
