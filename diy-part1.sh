#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 内核降级与补丁适配 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ] && [ ! -d "target/linux/msm89xx/patches-6.6" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 3. 终极必杀：凭空生成内核头文件补丁 ---
# 利用标准的 OpenWrt 补丁机制，在内核编译前，将头文件直接注入内核源码深处！
mkdir -p target/linux/msm89xx/patches-6.6/
cat << 'EOF' > target/linux/msm89xx/patches-6.6/999-add-qcom-memshare-header.patch
--- /dev/null
+++ b/include/dt-bindings/soc/qcom,memshare.h
@@ -0,0 +1,6 @@
+#ifndef _DT_BINDINGS_SOC_QCOM_MEMSHARE_H
+#define _DT_BINDINGS_SOC_QCOM_MEMSHARE_H
+#define MEM_SHARE_SEC_CLIENT_0 0
+#define MEM_SHARE_SEC_CLIENT_1 1
+#define MEM_SHARE_SEC_CLIENT_2 2
+#endif
EOF

# --- 4. 精确提取插件 (避开系统核心冲突) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
