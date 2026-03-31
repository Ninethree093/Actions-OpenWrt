#!/bin/bash

# 修改默认主题
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 下载额外的插件
git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
git clone https://github.com/gSpotx2f/luci-app-cpu-status-mini package/luci-app-cpu-status-mini
git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# 1. 修复内核补丁冲突 (非常关键，必须保留)
rm -rf target/linux/msm89xx/patches-6.6/777-EDIT-CERT-MAKEFILE.patch

# 2. 批量修复旧插件中已失效的依赖名称
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/libcrypt-compat//g' {} +
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/ca-certs/ca-bundle/g' {} +
