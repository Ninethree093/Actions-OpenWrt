#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 内核版本强制对齐 ---
# 将所有 Makefile 中的内核版本强制改为 6.6
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +

# 准备补丁目录
mkdir -p target/linux/msm89xx/patches-6.6/

# --- 3. 核心修复：注入全兼容的 memshare 头文件补丁 ---
# 同时包含两种常见的宏定义命名方式，彻底消除 "No such file" 和 "undeclared" 报错
cat << 'EOF' > target/linux/msm89xx/patches-6.6/001-add-qcom-memshare-header.patch
--- /dev/null
+++ b/include/dt-bindings/soc/qcom,memshare.h
@@ -0,0 +1,15 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __DT_QCOM_MEMSHARE_H__
+#define __DT_QCOM_MEMSHARE_H__
+
+/* 兼容版本 A: MEMSHARE_PROC 风格 */
+#define MEMSHARE_PROC_MPSS_V01 0
+#define MEMSHARE_PROC_ADSP_V01 1
+#define MEMSHARE_PROC_WCNSS_V01 2
+
+/* 兼容版本 B: MEM_SHARE_SEC 风格 */
+#define MEM_SHARE_SEC_CLIENT_0 0
+#define MEM_SHARE_SEC_CLIENT_1 1
+#define MEM_SHARE_SEC_CLIENT_2 2
+
+#endif
EOF

# --- 4. 同步现有补丁 ---
# 如果 6.12 目录下有其他补丁，也一并同步过来
if [ -d "target/linux/msm89xx/patches-6.12" ]; then
    cp -f target/linux/msm89xx/patches-6.12/*.patch target/linux/msm89xx/patches-6.6/ 2>/dev/null || true
fi

# --- 5. 插件与工具提取 ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
