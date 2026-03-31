#!/bin/bash

# --- 1. 移植 Target 目录 (解决机型识别) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 强制降级内核版本 (适配 24.10.5) ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 3. 精确移植插件 (避开 linux 等核心包) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages

# 这里只拷贝文件夹名不包含 'linux' 的包，避免 overriding recipe 报错
cp -r temp_repo/package/[!l]* package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

# 清理
rm -rf temp_repo
