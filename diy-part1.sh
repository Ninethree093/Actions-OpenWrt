#!/bin/bash

# --- 1. 移植 Target (维持现状，这是必须的) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 强制降级内核版本 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
[ -d "target/linux/msm89xx/patches-6.12" ] && cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6

# --- 3. 精确插件移植 (关键修改！) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages

# [重要] 仅拷贝高通 410 特有的包，绝对不要拷贝 kernel/busybox/ppp 等系统核心包
# 我们只拷贝特定的 luci 插件和必要的驱动目录
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm8916-* package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
