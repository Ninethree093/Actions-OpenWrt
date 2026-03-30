#!/bin/bash

# 1. 移植硬件支持
rm -rf target/linux/msm8916
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm8916 target/linux/msm8916

# 2. 关键：内核补丁版本对齐
# 官方 24.10.5 使用 6.6 内核，如果移植过来的目录里没有 patches-6.6，就强行创建一个链接
cd target/linux/msm8916
if [ ! -d "patches-6.6" ]; then
    # 寻找最接近的补丁目录（例如 6.1）并创建软连接或改名
    BEST_FIT=$(ls -d patches-* | sort -V | tail -n 1)
    echo "Using $BEST_FIT as base for patches-6.6"
    cp -r "$BEST_FIT" patches-6.6
fi
cd ../../../

# 3. 移植工具与插件
cp temp_repo/scripts/mkbootimg scripts/ 2>/dev/null || wget https://raw.githubusercontent.com/xuxin1955/immortalwrt/master/scripts/mkbootimg -P scripts/
chmod +x scripts/mkbootimg

rm -rf package/msm8916-packages
git clone --depth 1 https://github.com/xuxin1955/openwrt-packages package/msm8916-packages
rm -rf temp_repo
