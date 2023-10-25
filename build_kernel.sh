#!/bin/bash

TIME=$(date +%s)
export ARCH=arm64
mkdir -p out

BUILD_CROSS_COMPILE=$(pwd)/toolchain/GCC/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=$(pwd)/toolchain/Clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE vendor/o1q_chn_openx_defconfig
make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE

echo -e "$(($(($(date +%s) - $TIME)) / 60))m$(($(($(date +%s) - $TIME)) % 60))s 编译成功！\n$(find ./ -name "Image")"