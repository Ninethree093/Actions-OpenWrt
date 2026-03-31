#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 终极头文件补全方案 (OpenWrt Files Overlay 机制) ---
# 关键改动：将路径中的 include 改为 files/include
# OpenWrt 会在准备内核时，自动把 files 下的所有内容复制到 linux-6.6.122/ 内部
mkdir -p target/linux/msm89xx/files/include/dt-bindings/soc/
cp -f temp_repo/target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h target/linux/msm89xx/files/include/dt-bindings/soc/ 2>/dev/null || true

# --- 3. 补丁适配与内核降级 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 4. 精确提取插件 (避开系统核心冲突) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取并准备 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
