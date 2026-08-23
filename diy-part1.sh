#!/bin/bash

# 8916dts
mkdir -p target/linux/msm89xx/dts/
cp -f "$GITHUB_WORKSPACE/scripts/dts/msm8916.dtsi" "target/linux/msm89xx/dts/msm8916.dtsi"


mkdir -p target/linux/airoha/patches-6.18/
cp -f "$GITHUB_WORKSPACE/scripts/patch-25.12.0-rc2/target/linux/airoha/patches-6.12/992-mtd-spinand-add-skyhigh-robust-read-workaround.patch" "target/linux/airoha/patches-6.18/992-mtd-spinand-add-skyhigh-robust-read-workaround.patch"

# OpenClash
# git clone --depth 1 https://github.com/vernesong/OpenClash.git OpenClash

# turboacc
# curl -sSL https://raw.githubusercontent.com/mufeng05/turboacc/main/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# 调试
sed -i 's|src-git-full openstick https://github.com/lkiuyu/openstick-feeds.git|src-git-full openstick https://github.com/xuxin1955/openstick-feeds|g' feeds.conf.default

# test
# cat > feeds.conf.default << 'EOF'
# src-git packages https://github.com/immortalwrt/packages.git;openwrt-25.12
# src-git luci https://github.com/immortalwrt/luci.git;openwrt-25.12
# src-git routing https://github.com/openwrt/routing.git;openwrt-25.12
# src-git telephony https://github.com/openwrt/telephony.git;openwrt-25.12
# src-git video https://github.com/openwrt/video.git;openwrt-25.12
# src-git-full openstick https://github.com/xuxin1955/openstick-feeds.git
# EOF

# inspect
echo ">>> OPP VOLTAGE COUNT: $(grep -c 'opp-microvolt' target/linux/msm89xx/dts/msm8916.dtsi) <<<"
