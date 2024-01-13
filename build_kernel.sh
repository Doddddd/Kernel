#!/bin/bash

TIME=$(date +%s)
export ARCH=arm64

if [[ $@ =~ 'clean' ]]; then
    make clean
    make mrproper
    rm out -rf
fi

if [[ $@ =~ 'build' ]]; then
    mkdir out
    BUILD_CROSS_COMPILE=$(pwd)/toolchain/GCC/bin/aarch64-linux-android-
    KERNEL_LLVM_BIN=$(pwd)/toolchain/Clang/bin/clang
    CLANG_TRIPLE=aarch64-linux-gnu-
    KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"
    make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE vendor/o1q_chn_hkx_defconfig
    make -j8 CONFIG_SECTION_MISMATCH_WARN_ONLY=y -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE 
fi

VERSION=G9910ZHU6FWK7_$(TZ='Asia/Shanghai' date +"%Y-%-m-%-d_%-H-%-M")
cat ./out/arch/arm64/boot/dts/vendor/qcom/lahaina-v2.1.dtb ./out/arch/arm64/boot/dts/vendor/qcom/lahaina-v2.dtb ./out/arch/arm64/boot/dts/vendor/qcom/lahaina.dtb > dtb_$VERSION
mv ./out/arch/arm64/boot/Image Image_$VERSION
echo "Runtime: $(($(($(date +%s) - $TIME)) / 60))m$(($(($(date +%s) - $TIME)) % 60))s"