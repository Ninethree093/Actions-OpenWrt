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

# toolchain/kernel-headers 的 0104-uapi-128bit.patch 把 __u128 改回 __uint128_t。
# 但 __u128 是 6.16 之后内核才有的写法，6.6 / 6.12 这些分支的 uapi 本来就是 __uint128_t，
# 硬套只会 "Hunk FAILED -> Patch failed!" 把 toolchain 编译打断，所以低版本内核直接跳过这个补丁。
KP="${KERNEL_PATCHVER:-7.3}"
if [ -f toolchain/kernel-headers/patches/0104-uapi-128bit.patch ]; then
	if awk -v v="$KP" 'BEGIN{split(v,p,"."); exit ((p[1]+0<6) || (p[1]+0==6 && p[2]+0<16)) ? 0 : 1}'; then
		rm -f toolchain/kernel-headers/patches/0104-uapi-128bit.patch
		echo "kernel-headers: 内核 $KP 没有 __u128，跳过 0104-uapi-128bit.patch"
	else
		echo "kernel-headers: 内核 $KP 需要 0104-uapi-128bit.patch，保留"
	fi
fi

# feeds 跟 base 分支对齐：非 master 时把官方 feed 钉到同名分支。
# 不钉的话会拿到 master 的包，版本和 base 对不上。典型例子：
#   25.12 的 libffi 在 packages 的 openwrt-25.12 分支里，master 已经把它挪进 base，
#   于是 25.12 上找不到 libffi，glib2 打包时报 "missing dependencies: libffi.so.8"
BR="${REPO_BRANCH:-master}"
if [ -n "$BR" ] && [ "$BR" != "master" ]; then
	for name in packages luci routing telephony video; do
		url=$(sed -n "s#^src-git[^ ]* ${name} \(https://[^ ]*\)\$#\1#p" feeds.conf.default | head -1)
		[ -n "$url" ] || continue
		if git ls-remote --exit-code --heads "$url" "$BR" >/dev/null 2>&1; then
			sed -i "s#^\(src-git[^ ]* ${name} https://[^ ]*\)\$#\1^${BR}#" feeds.conf.default
			echo "feeds: $name -> $BR"
		else
			echo "feeds: $name 没有 $BR 分支，保持默认分支"
		fi
	done
fi
echo "--- feeds.conf.default ---"
grep -E '^src-git' feeds.conf.default

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

