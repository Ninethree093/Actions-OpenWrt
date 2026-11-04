#!/bin/bash

# msm8916
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/target/." target/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/package/." package/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/toolchain/." toolchain/
cp -rf "$GITHUB_WORKSPACE/scripts/msm89xx/feeds.conf.default" feeds.conf.default

# scripts/msm89xx/package/kernel/mac80211/Makefile 是 master 的（PKG_SOURCE_VERSION:=7.2）。
# 直接盖上去会把其它分支的 backports 版本改掉（例如 openwrt-25.12 是 6.18.55），
# 该分支自带的 mac80211 补丁就会大面积对不上。这里还原分支自己的 Makefile，
# 只补真正需要的那一行依赖。
if [ -f package/kernel/mac80211/Makefile ]; then
	git checkout -- package/kernel/mac80211/Makefile 2>/dev/null || true
	if ! grep -q 'kmod-crypto-arc4' package/kernel/mac80211/Makefile; then
		sed -i 's/^\([[:space:]]*DEPENDS+= .*hostapd-common\)$/\1 +kmod-crypto-arc4/' package/kernel/mac80211/Makefile
		echo "mac80211: 补上 +kmod-crypto-arc4 依赖"
	fi
	echo "mac80211 使用的 backports 版本："
	grep -E '^(PKG_VERSION|PKG_SOURCE_VERSION|PKG_HASH):=' package/kernel/mac80211/Makefile
fi

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

