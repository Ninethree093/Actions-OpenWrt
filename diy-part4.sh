#!/bin/bash

# turboacc
# curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh --no-sfe
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

# mode
echo 'src-git QModem https://github.com/FUjr/QModem' >> feeds.conf.default

# OpenClash
git clone --depth 1 https://github.com/vernesong/OpenClash.git OpenClash

# name: Remove incompatible Realtek PHY patches
cd "$(dirname "$0")/.."

rm -f target/linux/generic/backport-6.12/750-v7.0-net-phy-move-mmd_phy_read-and-mmd_phy_write-to-phyli.patch
rm -f target/linux/generic/backport-6.12/793-v7.0-net-phy-realtek-add-C45-accessors-for-cl45-over-c22.patch
rm -f target/linux/generic/backport-6.12/794-v7.0-net-phy-realtek-support-interrupt-also-for-C22-varia.patch
rm -f target/linux/generic/backport-6.12/795-v7.0-net-phy-realtek-simplify-C22-reg-access-via-MDIO_MMD.patch
rm -f target/linux/generic/pending-6.12/720-01-net-phy-realtek-use-genphy_soft_reset-for-2.5G-PHYs.patch
rm -f target/linux/generic/pending-6.12/720-03-net-phy-realtek-make-sure-paged-read-is-protected-by.patch
rm -f target/linux/generic/pending-6.12/720-04-net-phy-realtek-setup-aldps.patch
rm -f target/linux/generic/pending-6.12/720-05-net-phy-realtek-detect-early-version-of-RTL8221B.patch
rm -f target/linux/generic/pending-6.12/720-07-net-phy-realtek-disable-MDIO-broadcast.patch
rm -f target/linux/generic/pending-6.12/720-07-net-phy-realtek-mark-existing-MMDs-as-present.patch
rm -f target/linux/generic/pending-6.12/720-08-net-phy-realtek-rate-adapter-in-C22-mode.patch
rm -f target/linux/generic/hack-6.12/400-mtd-spinand-Support-fmsh.patch
rm -f target/linux/mediatek/patches-6.12/733-net-phy-realtek-add-led-link-select-for-RTL8221.patch

ls target/linux/generic/backport-6.12/750-v7.0-net-phy-move-mmd_phy_read-and-mmd_phy_write-to-phyli.patch 2>/dev/null || echo "✅"
ls target/linux/generic/backport-6.12/793-v7.0-net-phy-realtek-add-C45-accessors-for-cl45-over-c22.patch 2>/dev/null || echo "✅"
ls target/linux/generic/backport-6.12/794-v7.0-net-phy-realtek-support-interrupt-also-for-C22-varia.patch 2>/dev/null || echo "✅"
ls target/linux/generic/backport-6.12/795-v7.0-net-phy-realtek-simplify-C22-reg-access-via-MDIO_MMD.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-01-net-phy-realtek-use-genphy_soft_reset-for-2.5G-PHYs.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-03-net-phy-realtek-make-sure-paged-read-is-protected-by.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-04-net-phy-realtek-setup-aldps.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-05-net-phy-realtek-detect-early-version-of-RTL8221B.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-07-net-phy-realtek-disable-MDIO-broadcast.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-07-net-phy-realtek-mark-existing-MMDs-as-present.patch 2>/dev/null || echo "✅"
ls target/linux/generic/pending-6.12/720-08-net-phy-realtek-rate-adapter-in-C22-mode.patch 2>/dev/null || echo "✅"
ls target/linux/generic/hack-6.12/400-mtd-spinand-Support-fmsh.patch 2>/dev/null || echo "✅"
ls target/linux/mediatek/patches-6.12/733-net-phy-realtek-add-led-link-select-for-RTL8221.patch 2>/dev/null || echo "✅"
