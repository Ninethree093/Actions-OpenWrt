# Actions-OpenWrt (msm8916)

基于 GitHub Actions 自动编译 **高通 msm8916（OpenStick 系列 4G 棒子）** 的 immortalwrt 固件。
本仓库只保留 msm8916 相关的编译流程，其它机型（mt7620 / mt7621 / mt7628 / XG-040G / sy108 等）已移除。

## 工作流

| 工作流 | 作用 |
| --- | --- |
| `Build_imm_高通_8916.yml` | 编译 msm8916 固件的 13 个机型矩阵，自动发布 Release（标签 `MSM8916-<分支>-<日期>-V<构建号>`），每周六 17:00 定时触发 |
| `Build_bootloader_msm8916.yml` | 编译 lk2nd / lk1st 引导（`aboot.bin`、`lk2nd.img`），产物名 `msm8916-bootloader` |

## 选择 immortalwrt 分支 / 稳定版

源码来自 <https://github.com/immortalwrt/immortalwrt>，分支或 tag 在运行时选择，不用改代码：

- **定时 / repository_dispatch**：默认 `master`
- **手动运行**（Actions → `Build_imm_高通_8916` → Run workflow）：
  - `branch` 下拉框：`master` / `openwrt-25.12` / `openwrt-24.10`
  - `release` 下拉框：`none` / `v25.12.2` / `v25.12.1` / `v25.12.0` / `v24.10.6` / `v24.10.5`
    —— 选具体 tag 就编**正式版**（系统里显示 `25.12.2` 而不是 `25.12-SNAPSHOT`），会覆盖 `branch` 的选择
  - `branch_custom`：填了就覆盖上面两项，可填任意分支名或 tag
  - `kernel`：可选，**留空即可**——工作流会自动用该分支自带的内核；填了才强制覆盖
- **repository_dispatch**：可以在 payload 里传 `{"branch": "openwrt-24.10"}`

优先级：`branch_custom` > `client_payload.branch` > `release` > `branch` 下拉 > `master`。

工作流第一步会用 `git ls-remote` 同时查分支和 tag，填错会直接失败并列出可用项。

## 默认插件

`config/*.config` 里已经调好，13 个机型一致：

- **不含** `luci-app-simadmin`（`CONFIG_PACKAGE_luci-app-simadmin is not set`）
- **包含** `luci-app-openclash`（`CONFIG_PACKAGE_luci-app-openclash=y`，来自 `small` feed）

需要改的话直接改 `config/<机型>.config` 里对应那行，或者用 `devices_custom` 之外的机型单独调。

**内核版本自动跟随分支**：克隆之后、打入 msm89xx target 之前，会先读这个分支自带的 `target/linux/generic/kernel-*`：

1. 手动填了 `kernel` → 用它
2. 分支里有 target 默认的 `7.3` → 用 7.3（master 就是这种）
3. 分支里没有 7.3 → 用分支自带的最新内核（`openwrt-25.12` 是 6.12，`openwrt-24.10` 是 6.6）
4. 分支里一个都没有 → 回落 7.3，并在下一步报错

选定值会写进 `KERNEL_PATCHVER`，由 `diy-part1.sh` 覆盖 target 里写死的 `KERNEL_PATCHVER:=7.3`。

| 分支 | 自动选的内核 |
| --- | --- |
| `master` | 7.3 |
| `openwrt-25.12` | 6.12 |
| `openwrt-24.10` | 6.6 |

**但能编过与否还要看补丁**：`scripts/msm89xx/target/linux/msm89xx/patches-<内核版本>/` 里的补丁要够（目前 6.6 只有 1 个、6.1 有 10 个、6.12 有 2 个、6.18/7.3 各有若干）。内核版本对上了只是必要条件，非 `master` 分支仍可能在设备树/驱动补丁阶段失败，拿不准就先跑 `master`。

## 支持机型

`jz02v10` `ufi001c` `ufi001b` `ufi103s` `qrzl903` `w001` `ufi003` `uz801` `mf32` `mf601` `wf2` `sp970v11` `sp970v10`

对应的编译配置位于 `config/<机型>.config`。

## 选择机型

手动运行时会多出两个输入框：

- `device` 下拉：`all`（全部 13 个）或具体某一个机型
- `devices_custom`：填了就覆盖下拉，空格或逗号分隔可以一次编多个，例如 `ufi001c,ufi003`

优先级：`devices_custom` > `client_payload.devices` > `device` 下拉 > `all`。定时任务和 `repository_dispatch` 默认还是全部机型，行为不变。

工作流先跑一个 `setup` 任务解析名单（去重 + 校验 `config/<机型>.config` 是否存在，填错会列出所有可用机型并失败），再把结果通过 `fromJSON` 喂给 `build` 的矩阵。所以选 1 个机型就只跑 1 个 job，13 个就是 13 个 job，并行度和以前一样。

**增删机型**：加一个 `config/<机型>.config`，然后改两处——`env.ALL_DEVICES` 和 `inputs.device.options` 里同步加上名字。`strategy.matrix` 是动态生成的，不用动。

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
