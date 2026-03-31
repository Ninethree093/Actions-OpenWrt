#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 终极暴力破解：DTS 头文件缺失 ---
# 既然编译器死活找不到头文件，我们就直接把里面的核心代码（3个常量定义）
# 原地替换到所有报错的 dts/dtsi 源码里，彻底干掉 #include，让编译器无话可说！
find target/linux/msm89xx -name "*.dts*" -type f -exec sed -i 's|#include <dt-bindings/soc/qcom,memshare.h>|#define MEM_SHARE_SEC_CLIENT_0 0\n#define MEM_SHARE_SEC_CLIENT_1 1\n#define MEM_SHARE_SEC_CLIENT_2 2|g' {} +

# 为了防止内核编译器的其他环节还需要它，顺手在 files 覆盖目录里塞一份（双重保险）
mkdir -p target/linux/msm89xx/files/include/dt-bindings/soc/
cat <<EOF > target/linux/msm89xx/files/include/dt-bindings/soc/qcom,memshare.h
#ifndef _DT_BINDINGS_SOC_QCOM_MEMSHARE_H
#define _DT_BINDINGS_SOC_QCOM_MEMSHARE_H
#define MEM_SHARE_SEC_CLIENT_0 0
#define MEM_SHARE_SEC_CLIENT_1 1
#define MEM_SHARE_SEC_CLIENT_2 2
#endif
EOF

# --- 3. 内核降级与补丁适配 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ] && [ ! -d "target/linux/msm89xx/patches-6.6" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 4. 精确提取插件 ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
