#!/bin/bash

# --- 1. 移植 Target 目录 ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 深度清洗：强制降级内核版本 ---
# 递归搜索 msm89xx 目录下所有 Makefile，将 6.12 强制改为 6.6
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=6.12/KERNEL_PATCHVER:=6.6/g' {} +
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +

# --- 3. 补齐 patches 目录 ---
# 24.10.5 必须有 patches-6.6 文件夹才能通过校验
cd target/linux/msm89xx
if [ ! -d "patches-6.6" ]; then
    # 找到现有的最高版本补丁（可能是 6.1 或 6.12）作为基础
    BEST_FIT=$(ls -d patches-* 2>/dev/null | sort -V | tail -n 1)
    if [ -n "$BEST_FIT" ]; then
        cp -r "$BEST_FIT" patches-6.6
        echo "Using $BEST_FIT as a template for patches-6.6"
    fi
fi
cd ../../../

# --- 4. 移植工具与插件 ---
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf package/msm8916-packages
git clone --depth 1 https://github.com/xuxin1955/openwrt-packages package/msm8916-packages

rm -rf temp_repo
