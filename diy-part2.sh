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
patch -p1 --fuzz=2 <<'EOF'
--- a/include/kernel.mk
+++ b/include/kernel.mk
@@ -212,7 +212,8 @@
     SECTION:=kernel
     CATEGORY:=Kernel modules
     EXTRA_DEPENDS:=kernel (=$(subst -rc,_rc,$(LINUX_VERSION))~$(LINUX_VERMAGIC)-r$(LINUX_RELEASE))
-    VERSION:=$(subst -rc,_rc,$(LINUX_VERSION))$(if $(PKG_VERSION),.$(PKG_VERSION))-r$(if $(PKG_RELEASE),$(PKG_RELEASE),$(LINUX_RELEASE))
+    KVER_APK:=$(if $(PKG_VERSION),$(firstword $(subst -, ,$(LINUX_VERSION))),$(subst -rc,_rc,$(LINUX_VERSION)))
+    VERSION:=$(KVER_APK)$(if $(PKG_VERSION),.$(PKG_VERSION))-r$(if $(PKG_RELEASE),$(PKG_RELEASE),$(LINUX_RELEASE))
     PKGFLAGS:=$(PKGFLAGS)
     $(call KernelPackage/$(1))
     $(call KernelPackage/$(1)/$(BOARD))
EOF
grep -q 'firstword' include/kernel.mk && echo "OK: kernel.mk 补丁已应用" || echo "FAIL: kernel.mk 补丁未应用"

[ -f include/toplevel.mk ] || cd "$GITHUB_WORKSPACE/openwrt" || exit 1
mkdir -p dl
gzip -t dl/linux-7.3-rc7.tar.gz 2>/dev/null || {
  rm -f dl/linux-7.3-rc7.tar.gz
  curl -fL --retry 3 --retry-delay 5 -o dl/linux-7.3-rc7.tar.gz "https://codeload.github.com/torvalds/linux/tar.gz/refs/tags/v7.3-rc7"
}
gzip -t dl/linux-7.3-rc7.tar.gz && echo "OK: linux-7.3-rc7.tar.gz ready" || echo "FAIL: tarball invalid"
