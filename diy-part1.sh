#!/bin/bash

# --- 1. 移植 Target 目录 (必须包含，否则无法识别高通410) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 强制降级内核版本 (适配 v24.10.5 的 6.6 内核) ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +

# 补齐 patches 目录，防止内核编译校验失败
if [ -d "target/linux/msm89xx/patches-6.12" ] && [ ! -d "target/linux/msm89xx/patches-6.6" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 3. 移植工具与插件 (你目前脚本的核心逻辑) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/* package/msm8916-packages/

[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

# 清理
rm -rf temp_repo
