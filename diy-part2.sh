#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
# sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile


#temp
git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
git clone https://github.com/gSpotx2f/luci-app-cpu-status-mini package/luci-app-cpu-status-mini
git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# 修复内核补丁冲突，删除会导致编译失败的过时补丁
rm -rf target/linux/msm89xx/patches-6.6/777-EDIT-CERT-MAKEFILE.patch

# 修正旧插件对 wget-any 和 ca-certs 的错误依赖命名
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/wget-any/wget/g' {} +
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/ca-certs/ca-bundle/g' {} +
