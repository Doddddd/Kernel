#!/bin/bash

set -e

TIME=$(date +%s)

if [[ -d "$HOME/tool/Clang/r383902b1" ]]; then
    export PATH=$HOME/tool/Clang/r383902b1/bin:$PATH
else
    echo "缺少 Clang r383902b1"
    exit 1
fi

if [[ "$*" =~ "lto" ]]; then
    LOCALVERSION=-lto
elif [[ "$*" =~ "thin" ]]; then
    LOCALVERSION=-lto-thin
fi

ARGS=(LOCALVERSION="$LOCALVERSION" LLVM=1 LLVM_IAS=1 DTC_EXT="$(pwd)/tools/dtc" CONFIG_BUILD_ARM64_DT_OVERLAY=y ARCH=arm64 CROSS_COMPILE="$HOME/tool/GCC/bin/aarch64-linux-android-" REAL_CC="ccache clang" CLANG_TRIPLE=aarch64-linux-gnu-)

if [[ "$*" =~ "clean" ]]; then
    make "${ARGS[@]}" mrproper
    rm out -rf
fi

make -j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" "${ARGS[@]}" vendor/o1q_chn_hkx_defconfig

if [[ "$*" =~ "lto" ]]; then
    ./scripts/config --file out/.config -e LTO_CLANG_FULL -d CONFIG_LTO_NONE
elif [[ "$*" =~ "thin" ]]; then
    ./scripts/config --file out/.config -e LTO_CLANG_THIN -d CONFIG_LTO_NONE
fi

make -j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" "${ARGS[@]}"

OUTPUT=../output/$(basename "$(pwd)")
OUTPUT_NAME=$(basename "$(pwd)")_$(date +%F_%H-%M-%S)
mkdir "$OUTPUT/old" -p

find "$OUTPUT" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.tar" \) -exec mv {} "$OUTPUT/old/" \;

cp ./out/arch/arm64/boot/Image ../AnyKernel3/zImage
cd ../AnyKernel3
zip -r "$OUTPUT/$OUTPUT_NAME.zip" ./*

if [[ -f "$OUTPUT/origin_boot.img" ]]; then
    magiskboot unpack "$OUTPUT/origin_boot.img"
    mv zImage kernel
    magiskboot repack -n "$OUTPUT/origin_boot.img" boot.img
    tar cf "$OUTPUT/$OUTPUT_NAME.tar" boot.img
fi

rm zImage kernel boot.img -rf

echo -e "\e[32m   用时: $((($(date +%s) - TIME) / 60))m$((($(date +%s) - TIME) % 60))s\e[0m"