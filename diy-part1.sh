#!/bin/bash

# --- 1. 移植 Target (机型支持) ---
rm -rf target/linux/msm89xx
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo
mv temp_repo/target/linux/msm89xx target/linux/msm89xx

# --- 2. 内核降级与补丁合并 ---
find target/linux/msm89xx -name "Makefile" -exec sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' {} +
if [ -d "target/linux/msm89xx/patches-6.12" ] && [ ! -d "target/linux/msm89xx/patches-6.6" ]; then
    cp -r target/linux/msm89xx/patches-6.12 target/linux/msm89xx/patches-6.6
fi

# --- 3. 终极必杀技：动态生成内核补丁，强制注入头文件 ---
# 既然 -nostdinc 锁死了路径，我们就用 diff 凭空捏造一个补丁
# 这个补丁会在内核编译前，像特洛伊木马一样把 qcom,memshare.h 塞进它内部！
mkdir -p a/include/dt-bindings/soc
mkdir -p b/include/dt-bindings/soc
# 把缺失的头文件拿过来
cp temp_repo/target/linux/msm89xx/include/dt-bindings/soc/qcom,memshare.h b/include/dt-bindings/soc/ 2>/dev/null || true
# 对比生成标准的 Linux kernel patch，放到补丁文件夹下
diff -urN a b > target/linux/msm89xx/patches-6.6/999-force-add-memshare-header.patch
rm -rf a b

# --- 4. 精确提取插件 (避开系统核心冲突) ---
rm -rf package/msm8916-packages
mkdir -p package/msm8916-packages
cp -r temp_repo/package/luci-* package/msm8916-packages/ 2>/dev/null || true
cp -r temp_repo/package/msm-firmware-loader package/msm8916-packages/ 2>/dev/null || true

# 提取 mkbootimg 工具
[ -f "temp_repo/scripts/mkbootimg" ] && cp temp_repo/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

rm -rf temp_repo
