#!/bin/bash

# 删除可能冲突的旧 target（如果有）
rm -rf target/linux/msm8916

# 从适配者仓库强行拉取 msm8916 的支持包
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm8916 target/linux/msm8916

# 关键：检查内核版本并适配
# 如果官方是 6.6，而适配包里只有 patches-6.1，我们需要强行重命名尝试
if [ -d "target/linux/msm8916/patches-6.1" ]; then
    mv target/linux/msm8916/patches-6.1 target/linux/msm8916/patches-6.6
fi

# 清理临时文件
rm -rf temp_repo
