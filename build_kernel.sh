#!/bin/bash
export ARCH=arm64
export RDIR="C:\Users\Admin\Desktop\android"
export KBUILD_BUILD_USER="ksu-build"

#init ksu next
git submodule init && git submodule update

#export toolchain paths
export BUILD_CROSS_COMPILE="/toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"
export BUILD_CC="/toolchains/clang-r383902/bin/clang"

#output dir
if [ ! -d "/out" ]; then
    mkdir -p "/out"
fi

#build dir
if [ ! -d "/build" ]; then
    mkdir -p "/build"
else
    rm -rf "/build" && mkdir -p "/build"
fi

#build options
export ARGS="
-C C:\Users\Admin\Desktop\android \
O=C:\Users\Admin\Desktop\android/out \
-j \
ARCH=arm64 \
CROSS_COMPILE= \
CC= \
CLANG_TRIPLE=aarch64-linux-gnu- \
KCFLAGS=-w \
CONFIG_SECTION_MISMATCH_WARN_ONLY=y \
"

#build kernel image only
build_kernel(){
    make  clean && make  mrproper
    make  a04e_defconfig custom.config
    make  || exit 1
    cp out/arch/arm64/boot/Image.gz /build/Image.gz
    cp out/arch/arm64/boot/Image /build/Image
}

#build boot.img with AIK (fallback)
build_boot() {    
    rm -f /AIK-Linux/split_img/boot.img-kernel /AIK-Linux/boot.img
    cp "/out/arch/arm64/boot/Image.gz" /AIK-Linux/split_img/boot.img-kernel
    mkdir -p /AIK-Linux/ramdisk/{debug_ramdisk,dev,metadata,mnt,proc,second_stage_resources,sys}
    cd /AIK-Linux && ./repackimg.sh --nosudo && mv image-new.img /build/boot.img
}

#build odin flashable tar
build_tar(){
    cd /build
    tar -cvf "KernelSU-Next-SM-A042F.tar" Image.gz Image boot.img && rm boot.img
    echo -e "\n[i] Build Finished..!\n" && cd 
}

build_kernel
build_boot
build_tar