# Actions-OpenWrt (msm8916)

基于 GitHub Actions 自动编译 **高通 msm8916（OpenStick 系列 4G 棒子）** 的 immortalwrt 固件。
本仓库只保留 msm8916 相关的编译流程，其它机型（mt7620 / mt7621 / mt7628 / XG-040G / sy108 等）已移除。

## 工作流

| 工作流 | 作用 |
| --- | --- |
| `Build_imm_高通_8916.yml` | 编译 msm8916 固件的 13 个机型矩阵，自动发布 Release（标签 `MSM8916-<分支>-<日期>-V<构建号>`），每周六 17:00 定时触发 |
| `Build_bootloader_msm8916.yml` | 编译 lk2nd / lk1st 引导（`aboot.bin`、`lk2nd.img`），产物名 `msm8916-bootloader` |

## 选择 immortalwrt 分支

源码来自 <https://github.com/immortalwrt/immortalwrt>，分支在运行时选择，不用改代码：

- **定时 / repository_dispatch**：默认 `master`
- **手动运行**（Actions → `Build_imm_高通_8916` → Run workflow）：
  - `branch` 下拉框：`master` / `openwrt-25.12` / `openwrt-24.10`
  - `branch_custom`：填了就覆盖下拉框，可填任意分支名（包括 24.10 之前的老分支）
  - `kernel`：可选，覆盖 `scripts/msm89xx/target/linux/msm89xx/Makefile` 里的 `KERNEL_PATCHVER`
- **repository_dispatch**：可以在 payload 里传 `{"branch": "openwrt-24.10"}`

优先级：`branch_custom` > `client_payload.branch` > `branch` 下拉 > `master`。

工作流第一步会用 `git ls-remote` 校验分支存在，填错会直接失败并列出该仓库所有可用分支；克隆之后还会把该分支自带的内核版本列出来。

**内核要注意**：`scripts/msm89xx` 的 target 默认 `KERNEL_PATCHVER:=7.3`。

| 分支 | 内核 | 说明 |
| --- | --- | --- |
| `master` | 7.3 | 默认，和 target 自带的一致 |
| `openwrt-25.12` | 需在运行时的日志里确认 | 选它时建议先不填 `kernel`，看「检查内核版本可用性」那一步的输出 |
| `openwrt-24.10` | 6.6 | 需要在 `kernel` 输入框填 `6.6` |

非 `master` 分支能不能编过，取决于 `scripts/msm89xx/target/linux/msm89xx/patches-<内核版本>/` 里的补丁齐不齐（目前 6.6 只有 1 个补丁，6.1 有 10 个，6.12/6.18/7.3 各有若干）。换句话说：**分支可选，但能编通的分支以内核和补丁对得上为准**，拿不准就先跑 master。

## 支持机型

`jz02v10` `ufi001c` `ufi001b` `ufi103s` `qrzl903` `w001` `ufi003` `uz801` `mf32` `mf601` `wf2` `sp970v11` `sp970v10`

对应的编译配置位于 `config/<机型>.config`。如需增删机型，同时修改工作流里的 `env.ALL_DEVICES` 和 `strategy.matrix.device`。

- 管理地址：`192.168.10.1`
- 默认用户：`root`，默认密码：空

## 目录说明

```
.github/workflows/             两个 msm8916 工作流
config/                        13 个机型的 .config
diy-part1.sh                   打入 msm89xx target / package / toolchain，追加 feeds
diy-part2.sh                   改默认 IP、主题、files-8916 覆盖、firewall4 fullcone 补丁
check-patches.sh               编译前 backports 补丁预检
scripts/msm89xx/               msm8916 的 target / package / toolchain 源码
scripts/files-8916/            固件里的 /etc 覆盖文件（网络、apk/opkg 源、modem 初始化等）
scripts/diy-part.sh            修 onionshare-cli 依赖警告
scripts/show_hardware_info.sh  打印 runner 硬件信息
flash.zip                      首次刷机用的线刷包
```

## 刷机

- 首次刷机：下载仓库里的 `flash.zip` 并解压 —— **不执行这一步无法开机**
  - 把 `immortalwrt-msm89xx-msm8916-openstick-jz02v10-squashfs-system.img` 改名为 `rootfs.img`
  - 把 `immortalwrt-msm89xx-msm8916-openstick-jz02v10-squashfs-boot.img` 改名为 `boot.img`
  - `boot.img` 和 `rootfs.img` 放进解压好的 flash 目录
  - Windows 执行 `flash.bat`，Linux 执行 `./flash.sh`
  - 其它机型按型号下载替换对应文件
  - `fsg.bin`、`fsc.bin`、`modemst1.bin`、`modemst2.bin` 最好用自己机型提取的
- 后续升级：系统内在线升级，直接刷 `...-squashfs-sysupgrade.bin`
- web 在线升级没变化时，用 `flash.zip` 线刷一下最新固件即可
- 快速进 bootloader：直接重启即进入 bootloader 模式
- 系统内也可以执行：`dd if=/dev/zero of=/dev/mmcblk0p12 bs=4M sync`

## 鸣谢

- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [lede](https://github.com/coolsnowwolf/lede)
- [msm8916-mainline](https://github.com/msm8916-mainline)（lk2nd / qtestsign）
