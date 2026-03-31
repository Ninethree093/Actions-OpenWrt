#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
#

# 1. 修改默认主题
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 2. 下载额外的插件
git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
git clone https://github.com/gSpotx2f/luci-app-cpu-status-mini package/luci-app-cpu-status-mini
git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# 3. 【关键修复】修复内核补丁冲突 (解决之前的 Hunk fail)
rm -rf target/linux/msm89xx/patches-6.6/777-EDIT-CERT-MAKEFILE.patch

# 4. 【核心修复】强制注入缺失的 qcom,memshare.h 头文件 (解决当前 fatal error)
# 我们直接把文件拷贝到编译系统的全局 include 路径下，确保编译器能抓到它
mkdir -p staging_dir/target-aarch64_generic_musl/usr/include/dt-bindings/soc/
cp -f target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h staging_dir/target-aarch64_generic_musl/usr/include/dt-bindings/soc/ 2>/dev/null || true

# 5. 批量修复旧插件中已失效的依赖名称
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/libcrypt-compat//g' {} +
find package/msm8916-packages/ -name "Makefile" -exec sed -i 's/ca-certs/ca-bundle/g' {} +
