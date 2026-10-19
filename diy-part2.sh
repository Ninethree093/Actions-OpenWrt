#!/bin/bash
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# eth0
sed -i "s/ucidef_set_interface_lan 'eth0'/ucidef_set_interface_lan 'br-lan'/" package/base-files/files/etc/board.d/99-default_network

# Modify default theme
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# DbusSmsForwardCPlus
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# 北大源
cp -r "$GITHUB_WORKSPACE/scripts/files-8916" "$GITHUB_WORKSPACE/openwrt/files"
ls -R "$GITHUB_WORKSPACE/openwrt/files"


# 压制 GCC 14 类型错误
pwd
ls package/libs/libnftnl/Makefile
sed -i '/^TARGET_CFLAGS += \$(FPIC)/a TARGET_CFLAGS += -Wno-error=incompatible-pointer-types' package/libs/libnftnl/Makefile

# 验证
grep -n "Wno-error=incompatible-pointer-types" package/libs/libnftnl/Makefile && echo "✓ 修复已应用" || echo "✗ 修复失败"



[ -f include/toplevel.mk ] || cd "$GITHUB_WORKSPACE/openwrt" || exit 1
grep -rlE '^[[:space:]]*PKG_VERSION[[:space:]]*[:?]?=.*_(rc|alpha|beta|pre|git|svn|cvs|hg|p[0-9])' package feeds --include=Makefile 2>/dev/null | while read -r mk; do
    pv=$(sed -nE 's/^[[:space:]]*PKG_VERSION[[:space:]]*[:?]?=[[:space:]]*//p' "$mk" | head -n1)
    sed -i -E 's/^(PKG_VERSION[[:space:]]*[:?]?=[[:space:]]*[0-9][0-9.]*)_[a-z]+[0-9]*/\1/' "$mk"
    echo "[apk-ver-fixed] $mk"
done
