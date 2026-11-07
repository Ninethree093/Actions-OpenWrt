# ImmortalWrt-MSM8916-Actions

用 GitHub Actions 给 **高通 msm8916（OpenStick 系列 4G 棒子）** 编译 ImmortalWrt 固件的独立项目。

- 13 个机型，可单选一个或全编
- 源码可选 immortalwrt 的**分支**（跟随上游更新）或**稳定版 tag**（出正式版号）
- 产物自动发布到 Releases，附完整包清单与校验和
- 25.12 / v25.12.x 已**实机验证可启动**；24.10 与 master 尚未验证

本仓库只保留 msm8916 相关的编译流程，其它机型（mt7620 / mt7621 / mt7628 / XG-040G / sy108 等）已移除。

## 关于本仓库（Fork 说明）

本仓库 fork 自 [`xuxin1955/Actions`](https://github.com/xuxin1955/Actions)，但内容已经大改：只保留 msm8916、工作流重写、主分支改为 `immortalwrt`。所以在 GitHub 上仍会显示 “forked from”。

因为它还是 fork，有三点要注意：

- **不要点 “Sync fork”**：上游是另一套多机型项目，同步会把它的工作流和配置合进来，覆盖这里的改动。要跟随 immortalwrt 上游更新，改编译时的 `source` 下拉就行。
- **提 PR 请指向本仓库**：fork 的默认 PR 目标是父仓库，别提交到上游去。
- **许可证沿用 fork 继承的 GPL-3.0**（覆盖本仓库自有文件），`scripts/msm89xx` 另按上游 GPL-2.0，详见文末「许可证」。

> 旧的 `main` 分支是 fork 时带过来的历史内容（新分支是 `immortalwrt`），如果不需要可以删掉，删掉之后 “Sync fork” 按钮也会消失，能避免误点。

## 工作流

| 工作流 | 作用 |
| --- | --- |
| `Build_imm_高通_8916.yml` | 编译 msm8916 固件的 13 个机型矩阵，自动发布 Release（标签 `MSM8916-<分支>-<日期>-V<构建号>`），手动触发（已去掉定时） |
| `Build_bootloader_msm8916.yml` | 编译 lk2nd / lk1st 引导（`aboot.bin`、`lk2nd.img`），产物名 `msm8916-bootloader` |

## 选择 immortalwrt 源码（分支 / 稳定版二合一）

源码来自 <https://github.com/immortalwrt/immortalwrt>，运行时只用一个下拉框选，不用改代码：

| 下拉项 | 说明 |
| --- | --- |
| `openwrt-25.12` | 25.12 分支，跟随上游更新（默认） |
| `openwrt-24.10` | 24.10 分支 |
| `master` | 开发分支，内核随上游变化（当前 6.18） |
| `v25.12.2` `v25.12.1` `v25.12.0` | 25.12 稳定版 tag，编出来是正式版号 |
| `v24.10.6` `v24.10.5` | 24.10 稳定版 tag |

- **触发方式**：只有手动（Actions → Run workflow）和 `repository_dispatch`，**已去掉定时任务**
- **机型**：另一个下拉 `device`，`all` = 全部 13 个，否则只编选中的那个
- 没有任何自定义输入项：分支/tag 只能从下拉里选，内核也自动跟随源码

**只有稳定版 tag 才会显示正式版号**（`25.12.2`）；选分支编出来是 `25.12-SNAPSHOT`。

### 缓存复用

tag 会映射成对应分支来算缓存 key：`v25.12.2 → openwrt-25.12`。所以第一次编某个 tag 时，能直接复用同名分支的 `ccache` 和 `dl` 缓存，省掉大部分重复编译和下载。

### 内核自动跟随源码

不再提供手动内核选项。克隆之后、打入 msm89xx target 之前，读源码自带的 `target/linux/generic/kernel-*`：

1. 源码里有 target 默认要求的 `7.3` → 用 7.3
2. 没有 7.3 → 用源码自带的最新内核
3. 一个都没有 → 回落 7.3，并在下一步报错

| 源码 | 自动选的内核 |
| --- | --- |
| `openwrt-25.12` / `v25.12.x` | 6.12 |
| `openwrt-24.10` / `v24.10.x` | 6.6 |
| `master` | 6.18（随上游变化） |

选定值写进 `KERNEL_PATCHVER`，由 `diy-part1.sh` 覆盖 target 里写死的 `KERNEL_PATCHVER:=7.3`。

### 各源码的验证情况

| 源码 | 内核 | 状态 |
| --- | --- | --- |
| `openwrt-25.12` / `v25.12.x` | 6.12 | ✅ 已编译并**实机启动成功**（jz02v10） |
| `openwrt-24.10` / `v24.10.x` | 6.6 | ⚠️ 未验证（6.6 的 target 补丁很少） |
| `master` | 6.18 | ⚠️ 未验证（上游默认内核已是 6.18，而 target 按 7.3 写的） |

内核版本对上只是必要条件，能不能编通还取决于 `scripts/msm89xx/target/linux/msm89xx/patches-<内核版本>/` 的补丁是否够用。25.12 这条路已经跑通并实机验证过。

## 软件源（固件里的 apk / opkg 源）

固件里的软件源在构建时**按源码版本生成**，不再是写死的快照地址：

| 源码 | 软件源根 |
| --- | --- |
| `v25.12.2` | `https://downloads.immortalwrt.org/releases/25.12.2` |
| `openwrt-25.12` | `https://downloads.immortalwrt.org/releases/25.12-SNAPSHOT` |
| `v24.10.6` | `https://downloads.immortalwrt.org/releases/24.10.6` |
| `openwrt-24.10` | `https://downloads.immortalwrt.org/releases/24.10-SNAPSHOT` |
| `master` | `https://downloads.immortalwrt.org/snapshots` |

只写 `aarch64_generic` 的 5 个通用源：`base` / `luci` / `packages` / `routing` / `telephony`。

- **不写 target 源**：本 target（`msm89xx/msm8916`）上游没有发布，`releases/*/targets/msm89xx/msm8916/packages` 是 404
- **也不写 `targets/armsr/armv8`**：那是 armsr 设备的 target 源，里面的 kmod 装到 msm8916 上会直接把系统搞坏

25.12 用 apk，生成 `files/etc/apk/repositories.d/distfeeds.list`；24.10 及更早用 opkg，生成 `files/etc/opkg/distfeeds.conf`，两份都写。要加自己的源，写 `/etc/apk/repositories.d/customfeeds.list`。

## 产物与发布

每次构建成功都会自动发一个 Release：

```
MSM8916-<源码>-<日期>-V<构建号>
例：MSM8916-v25.12.2-2026.11.06-V21
```

Release 正文包含编译时间、机型、版本类型（稳定版 / 快照版）、源码、内核、管理地址，以及本次实际带上的 `luci-app-*` 清单。

附件一共 9 个：

| 文件 | 用途 |
| --- | --- |
| `*-squashfs-sysupgrade.bin` | **日常升级用这个**（系统内 / Web 在线升级） |
| `*-squashfs-system.img` | 首次刷机的 rootfs，改名为 `rootfs.img` |
| `*-squashfs-boot.img` | 首次刷机的内核，改名为 `boot.img` |
| `*.manifest` | 本次固件的完整包清单 |
| `config.buildinfo` / `feeds.buildinfo` / `version.buildinfo` | 构建输入快照，便于复现 |
| `profiles.json` / `sha256sums` | 机型列表 / 校验和 |

构建过程中还会额外上传一个 `build-config` artifact（含最终的 `.config` 和 `feeds.conf.default`），排查问题时用得上。

## 支持机型

`jz02v10` `ufi001c` `ufi001b` `ufi103s` `qrzl903` `w001` `ufi003` `uz801` `mf32` `mf601` `wf2` `sp970v11` `sp970v10`

对应的编译配置位于 `config/<机型>.config`。

## 选择机型

只有一个 `device` 下拉框：

- `all`（默认）= 全部 13 个机型，13 个 job 并行
- 具体某一个机型 = 只跑 1 个 job

工作流先跑一个 `setup` 任务解析名单（校验 `config/<机型>.config` 是否存在，填错会列出所有可用机型并失败），再把结果通过 `fromJSON` 喂给 `build` 的矩阵。

**增删机型**：加一个 `config/<机型>.config`，然后改两处——`env.ALL_DEVICES` 和 `inputs.device.options` 里同步加上名字。`strategy.matrix` 是动态生成的，不用动。

## 默认插件

`config/*.config` 里已经调好，13 个机型一致：

- **不含** `luci-app-simadmin`（`CONFIG_PACKAGE_luci-app-simadmin is not set`）
- **包含** `luci-app-openclash`（`CONFIG_PACKAGE_luci-app-openclash=y`，来自 `small` feed）

需要改的话直接改 `config/<机型>.config` 里对应那行。

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

## 许可证

本仓库是**聚合分发**，不同部分各自遵循原来的许可证：

| 部分 | 许可证 |
| --- | --- |
| 自有文件（`.github/workflows/`、`diy-part*.sh`、`check-patches.sh`、`config/`、`scripts/files-8916/`） | [GPL-3.0](LICENSE)（继承自上游 `xuxin1955/Actions`） |
| `scripts/msm89xx/`（immortalwrt / OpenWrt 源码） | GPL-2.0 为主，逐文件以 SPDX 为准，见 [LICENSE.md](scripts/msm89xx/LICENSE.md) |
| `flash.zip` 内的第三方工具与厂商镜像 | 见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) |

> GPL-2.0 与 GPL-3.0 不能合并为单一作品，所以上述两部分是**并列的独立组件**，根目录 `LICENSE` 只覆盖自有文件。
>
> `flash.zip` 里的 `aboot.bin`、`hyp.mbn`、`rpm.mbn`、`sbl1.mbn`、`tz.mbn` 是从原厂固件提取的高通签名镜像，**没有可再分发的授权**，正式发布前建议移除。

## 鸣谢

- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)（MIT，云编译工作流的最初模板）
- [xuxin1955/Actions](https://github.com/xuxin1955/Actions)（GPL-3.0，本仓库的直接上游）
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [lede](https://github.com/coolsnowwolf/lede)
- [msm8916-mainline](https://github.com/msm8916-mainline)（lk2nd / qtestsign）
