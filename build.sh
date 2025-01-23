#!/bin/bash

set -e

TIME=$(date +%s)

if [[ -d "$HOME/tool/Clang/r487747c" ]]; then
    export PATH=$PATH:$HOME/tool/Clang/r487747c/bin
else
    echo "缺少 Clang r487747c"
    exit 1
fi

if [[ "$*" =~ "lto" ]]; then
    LOCALVERSION=-lto
elif [[ "$*" =~ "thin" ]]; then
    LOCALVERSION=-lto-thin
fi

ARGS=(CC="ccache clang" ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION="$LOCALVERSION")

if [[ "$*" =~ "clean" ]]; then
    make "${ARGS[@]}" mrproper
    rm out -rf
fi

make -j"$(nproc)" -C "$(pwd)" O="$(pwd)/out" "${ARGS[@]}" stock_defconfig

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