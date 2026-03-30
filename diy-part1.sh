#!/bin/bash

# 1. 强行拉取 msm8916 的硬件适配代码 (Target)
# 我们需要从 xuxin1955 的仓库里把 target/linux/msm8916 文件夹搬过来
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
cp -r temp_repo/target/linux/msm8916 target/linux/
rm -rf temp_repo

# 2. 补齐必要的 mkbootimg 编译工具支持（如果源码里没有）
# MSM8916 编译最后生成 boot.img 需要此工具
if [ ! -f "scripts/mkbootimg" ]; then
    wget https://raw.githubusercontent.com/xuxin1955/immortalwrt/master/scripts/mkbootimg -P scripts/
    chmod +x scripts/mkbootimg
fi

# 3. 添加必要的外部 feeds（如基带管理工具）
# 在 feeds.conf.default 末尾追加适配者常用的源
echo "src-git msm8916 https://github.com/xuxin1955/openwrt-packages;main" >> feeds.conf.default
