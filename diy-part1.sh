#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 修复缺失的 DTS 头文件 (解决当前报错的关键！) ---
# 创建缺失的目录层级
mkdir -p target/linux/msm89xx/include/dt-bindings/soc/
# 从临时仓库中提取缺少的 memshare.h 文件
cp -f temp_repo/target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h target/linux/msm89xx/include/dt-bindings/soc/ 2>/dev/null || true

# --- 3. 补丁适配与内核降级 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 4. 精确插件移植 ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取并准备工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
