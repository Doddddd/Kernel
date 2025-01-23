#!/bin/bash

set -e

TIME=$(date +%s)
export PATH=$HOME/tool/Clang/r383902b1/bin:$PATH

ARGS=(DTC_EXT="$(pwd)/tools/dtc" CONFIG_BUILD_ARM64_DT_OVERLAY=y ARCH=arm64 CROSS_COMPILE="$HOME/tool/GCC/bin/aarch64-linux-android-" REAL_CC="ccache clang" CLANG_TRIPLE=aarch64-linux-gnu-)

if [[ "$*" =~ "clean" ]]; then
    make "${ARGS[@]}" mrproper
    rm out -rf
fi

make -j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" "${ARGS[@]}" vendor/o1q_chn_hkx_defconfig

make -j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" "${ARGS[@]}"

cp ./out/arch/arm64/boot/Image ../AnyKernel3/zImage
OUTPUT=../output/$(basename "$(pwd)")
MODULE_NAME=$(basename "$(pwd)")_$(date +%F_%H-%M-%S)
mkdir "$OUTPUT/old" -p
if [[ -n "$(find "$OUTPUT" -maxdepth 1 -name "*.zip")" ]]; then
    mv "$OUTPUT"/*.zip "$OUTPUT/old"
fi
cd ../AnyKernel3
zip -r "$OUTPUT/$MODULE_NAME.zip" ./*
rm ../AnyKernel3/zImage
echo -e "\e[32m   用时: $((($(date +%s) - TIME) / 60))m$((($(date +%s) - TIME) % 60))s\e[0m"