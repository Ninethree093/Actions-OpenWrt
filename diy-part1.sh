#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 强行补齐 DTS 头文件 (解决当前报错的最终手段) ---
# 先将头文件拷贝到一个通用路径
mkdir -p target/linux/generic/include/dt-bindings/soc/
cp -f temp_repo/target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h target/linux/generic/include/dt-bindings/soc/

# 关键：同时在顶层 include 创建软链接，确保全局可见
mkdir -p include/dt-bindings/soc/
cp -f temp_repo/target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h include/dt-bindings/soc/

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

# 提取工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
