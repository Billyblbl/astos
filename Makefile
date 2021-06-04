x86_64_asm := $(shell find src/x86_64/boot -name *.asm)
x86_64_asm_obj := $(patsubst src/x86_64/boot/%.asm, build/x86_64/%.o, $(x86_64_asm))

build-x86_64 : $(x86_64_asm_obj)
	mkdir -p build/x86_64/iso/boot/grub && \
	x86_64-elf-ld -n -o build/x86_64/iso/boot/kernel.bin -T src/x86_64/linker.ld $^ && \
	cp src/x86_64/boot/grub.cfg build/x86_64/iso/boot/grub/grub.cfg && \
	grub-mkrescue /usr/lib/grub/i386-pc -o build/x86_64/kernel.iso build/x86_64/iso

$(x86_64_asm_obj) : build/x86_64/%.o : src/x86_64/boot/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst src/x86_64/%.o, build/x86_64/%.asm, $^) -o $@

.PHONY: build-x86_64




