#!/bin/bash

# msm8916
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/target/." target/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/package/." package/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/toolchain/." toolchain/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/feeds.conf.default" feeds.conf.default

# 可选：覆盖 target 的 KERNEL_PATCHVER（选非 master 分支时用，例如 openwrt-24.10 填 6.6）
if [ -n "${KERNEL_PATCHVER:-}" ]; then
	sed -i "s/^KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=${KERNEL_PATCHVER}/" target/linux/msm89xx/Makefile
	echo "kernel: KERNEL_PATCHVER 覆盖为 ${KERNEL_PATCHVER}"
	grep -n '^KERNEL_PATCHVER' target/linux/msm89xx/Makefile
fi

# 验证
ls target/linux/msm89xx/Makefile package/kernel/mac80211/patches/ath/*wcn36xx* package/kernel/mac80211/ath.mk toolchain/musl/include/sys/glibc-types.h

# OpenAppFilter
git clone --depth 1 https://github.com/destan19/luci-app-harbor-file.git package/harbor-file

# turboacc
# curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh
# curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# kenzo
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default

# small
echo 'src-git small https://github.com/kenzok8/small' >> feeds.conf.default

