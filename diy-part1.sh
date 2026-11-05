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

# toolchain/kernel-headers 的 0104-uapi-128bit.patch 把 arm64 uapi 的 __u128 改回 __uint128_t。
# 实测：6.12 和 6.18 的 arch/arm64/include/uapi/asm/ptrace.h 里本来就是 __uint128_t，
# 只有 7.x 才换成 __u128（uapi/linux/types.h 早就有 __u128 定义，但头文件没用它）。
# 所以这个补丁只对 7.x 有效，6.x 上硬套就是 "Hunk FAILED -> Patch failed!"，直接跳过。
KP="${KERNEL_PATCHVER:-7.3}"
if [ -f toolchain/kernel-headers/patches/0104-uapi-128bit.patch ]; then
	if awk -v v="$KP" 'BEGIN{split(v,p,"."); exit (p[1]+0<7) ? 0 : 1}'; then
		rm -f toolchain/kernel-headers/patches/0104-uapi-128bit.patch
		echo "kernel-headers: 内核 $KP 是 6.x（uapi 本来就用 __uint128_t），跳过 0104-uapi-128bit.patch"
	else
		echo "kernel-headers: 内核 $KP 是 7.x，保留 0104-uapi-128bit.patch"
	fi
fi

# dt-bindings/clock/qcom,dsi-phy-28nm.h 是内核 6.15 才加的（6.6 / 6.12 都没有），
# 但 dts/msm8916.dtsi 引用了里面的 DSI_BYTE_PLL_CLK / DSI_PIXEL_PLL_CLK。
# 低版本内核 dts 编译会 "fatal error: ... No such file or directory"，
# 这里把这两个宏直接内联（就是头文件里的全部内容：0 和 1）。
if [ -f target/linux/msm89xx/dts/msm8916.dtsi ]; then
	if awk -v v="$KP" 'BEGIN{split(v,p,"."); exit ((p[1]+0<6) || (p[1]+0==6 && p[2]+0<15)) ? 0 : 1}'; then
		sed -i 's|^#include <dt-bindings/clock/qcom,dsi-phy-28nm.h>|/* kernel < 6.15 has no dsi-phy-28nm.h; inline its two clock IDs */\n#define DSI_BYTE_PLL_CLK 0\n#define DSI_PIXEL_PLL_CLK 1|' target/linux/msm89xx/dts/msm8916.dtsi
		echo "dts: 内核 $KP 没有 dsi-phy-28nm.h，已内联 DSI_BYTE_PLL_CLK / DSI_PIXEL_PLL_CLK"
		grep -n 'DSI_BYTE_PLL_CLK\|DSI_PIXEL_PLL_CLK' target/linux/msm89xx/dts/msm8916.dtsi | head -4
	fi

	# 6.18 起 rpmpd 的电源域 ID 换了名字：6.12 叫 MSM8916_VDDCX/VDDMX，6.18+ 叫 RPMPD_VDDCX/VDDMX，
	# 值完全相同（0 / 3）。老内核上 dts 里的新名字会原样留给 dtc，被当成语法错误。
	# 用 #ifndef 别名兜底：新内核已有定义，这段自动失效。
	sed -i 's|^#include <dt-bindings/power/qcom-rpmpd.h>|&\n/* before 6.18 these ids are MSM8916_VDDCX/VDDMX, values are identical */\n#ifndef RPMPD_VDDCX\n#define RPMPD_VDDCX MSM8916_VDDCX\n#endif\n#ifndef RPMPD_VDDMX\n#define RPMPD_VDDMX MSM8916_VDDMX\n#endif|' target/linux/msm89xx/dts/msm8916.dtsi
	echo "dts: 已为 RPMPD_VDDCX / RPMPD_VDDMX 加 MSM8916_* 别名（新内核上自动失效）"
fi

# 老内核的 target config 是残次品：config-6.12 里连 CONFIG_SQUASHFS / OVERLAY_FS /
# QCOM_Q6V5_MSS / CRYPTO_AES 都没开，编出来的固件挂不上 squashfs 根分区，
# 刷进机器就是不启动（表现：拿不到后台 IP）。
# 用 config-7.3 做基底补全，再把 <KP> 独有的项补回去；kconfig 之后会自动丢弃新内核才有的符号。
CFG="target/linux/msm89xx/config-$KP"
REF="target/linux/msm89xx/config-7.3"
if [ -f "$CFG" ] && [ -f "$REF" ] && ! grep -q '^CONFIG_SQUASHFS=y' "$CFG"; then
	cp "$REF" "$CFG.merged"
	grep -E '^(CONFIG_[A-Za-z0-9_]+=|# CONFIG_[A-Za-z0-9_]+ is not set)' "$CFG" | while IFS= read -r line; do
		key=$(printf '%s\n' "$line" | sed -E 's/^# (CONFIG_[A-Za-z0-9_]+) .*/\1/; s/^(CONFIG_[A-Za-z0-9_]+)=.*/\1/')
		if ! grep -q "^$key=" "$REF" && ! grep -q "^# $key is not set" "$REF"; then
			printf '%s\n' "$line" >> "$CFG.merged"
		fi
	done
	mv "$CFG.merged" "$CFG"
	echo "kernel: config-$KP 缺关键项（SQUASHFS 等），已用 config-7.3 补全"
	grep -E '^CONFIG_(SQUASHFS|OVERLAY_FS|QCOM_Q6V5_MSS|QCOM_WCNSS_PIL|CRYPTO_AES|CRYPTO_GCM)=' "$CFG"
fi

# feeds 跟 base 分支对齐：非 master 时把官方 feed 钉到同名分支。
# 不钉的话会拿到 master 的包，版本和 base 对不上。典型例子：
#   25.12 的 libffi 在 packages 的 openwrt-25.12 分支里，master 已经把它挪进 base，
#   于是 25.12 上找不到 libffi，glib2 打包时报 "missing dependencies: libffi.so.8"
# 注意分隔符是「;」不是「^」：scripts/feeds 里 split(/;/) 取分支，
# 「^」是钉 commit，用错了会 clone 完再 checkout 一个不存在的 ref 而失败。
BR="${REPO_BRANCH:-master}"
if [ -n "$BR" ] && [ "$BR" != "master" ]; then
	for name in packages luci routing telephony video; do
		url=$(sed -n "s#^src-git[^ ]* ${name} \(https://[^ ]*\)\$#\1#p" feeds.conf.default | head -1)
		[ -n "$url" ] || continue
		if git ls-remote --exit-code --heads "$url" "$BR" >/dev/null 2>&1; then
			sed -i "s#^\(src-git[^ ]* ${name} https://[^ ]*\)\$#\1;${BR}#" feeds.conf.default
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

