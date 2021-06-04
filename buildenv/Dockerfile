FROM randomdude/gcc-cross-x86_64-elf

RUN apt update
RUN apt upgrade -y
RUN apt install -y nasm xorriso grub-pc-bin grub-common

VOLUME /root/env
WORKDIR /root/env
