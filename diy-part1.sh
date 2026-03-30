#!/bin/bash

# --- 1. 强力移植 Target 目录 ---
# 先清理旧的残余
rm -rf target/linux/msm89xx target/linux/msm8916

# 克隆魔改仓库
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo

# 自动判断对方仓库的文件夹名称并搬运
if [ -d "temp_repo/target/linux/msm89xx" ]; then
    mv temp_repo/target/linux/msm89xx target/linux/msm89xx
    echo "Found target: msm89xx"
elif [ -d "temp_repo/target/linux/msm8916" ]; then
    mv temp_repo/target/linux/msm8916 target/linux/msm89xx
    echo "Found target: msm8916, renamed to msm89xx"
fi

# --- 2. 内核版本对齐 (针对 24.10.5 的 Kernel 6.6) ---
# 进入新搬来的目录，确保有 patches-6.6
if [ -d "target/linux/msm89xx" ]; then
    cd target/linux/msm89xx
    if [ ! -d "patches-6.6" ]; then
        # 寻找现有的最高版本补丁作为模板
        BEST_FIT=$(ls -d patches-* 2>/dev/null | sort -V | tail -n 1)
        if [ -n "$BEST_FIT" ]; then
            cp -r "$BEST_FIT" patches-6.6
            echo "Linked $BEST_FIT to patches-6.6"
        fi
    fi
    cd ../../../
fi

# --- 3. 搬运编译脚本和插件 ---
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf package/msm8916-packages
git clone --depth 1 https://github.com/xuxin1955/openwrt-packages package/msm8916-packages

# 清理
rm -rf temp_repo
