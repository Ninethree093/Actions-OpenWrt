# 第三方组件与许可声明

本仓库是**聚合分发**：自有文件与上游源码/工具并列存放，各自遵循原来的许可证，不合并成单一作品。

## 1. 本仓库自有文件

`.github/workflows/`、`diy-part1.sh`、`diy-part2.sh`、`check-patches.sh`、`config/*.config`、`scripts/files-8916/`、`README.md`

遵循根目录 [LICENSE](LICENSE)：**GPL-3.0**（继承自本仓库的 fork 来源 `xuxin1955/Actions`）。

## 2. 上游源码（目录内保留原许可）

| 目录 | 来源 | 许可证 |
| --- | --- | --- |
| `scripts/msm89xx/target/` | [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt)、[OpenWrt](https://github.com/openwrt/openwrt) | GPL-2.0（逐文件以 SPDX 为准） |
| `scripts/msm89xx/target/linux/msm89xx/dts/` | Linux kernel 设备树 | GPL-2.0 |
| `scripts/msm89xx/package/`、`scripts/msm89xx/toolchain/` | OpenWrt / musl / Linux | GPL-2.0、BSD-3-Clause、MIT（逐文件以 SPDX 为准） |

该目录下的文件头部大多带 `SPDX-License-Identifier`，实测分布：BSD-3-Clause 117 个、`GPL-2.0+ OR MIT` 80 个、`GPL-2.0-only` 57 个、`GPL-2.0` 32 个，其余为无 SPDX 的补丁/二进制资源。**以文件内声明为准**，本仓库不改变它们的许可。

## 3. `flash.zip` 内的第三方内容

| 文件 | 来源 | 许可证 |
| --- | --- | --- |
| `adb.exe`、`fastboot.exe`、`AdbWinApi.dll`、`AdbWinUsbApi.dll`、`etc1tool.exe`、`hprof-conv.exe` | Android SDK Platform-Tools | Apache-2.0（压缩包内已带 `NOTICE.txt`） |
| `mke2fs.exe`、`make_f2fs.exe`、`mke2fs.conf` | e2fsprogs | GPL-2.0 |
| `sqlite3.exe` | SQLite | Public Domain |
| `libwinpthread-1.dll` | mingw-w64 runtime | GPL-2.0 with GCC Runtime Library Exception |
| `lk2nd.img` | [msm8916-mainline/lk2nd](https://github.com/msm8916-mainline/lk2nd) | GPL-2.0 |
| `aboot.bin`、`hyp.mbn`、`rpm.mbn`、`sbl1.mbn`、`tz.mbn`、`sbc_1.0_8016.bin`、`gpt_*.bin` | 高通 / 原厂固件中提取的签名镜像 | **厂商专有，未授权再分发** |
| `flash.bat`、`flash.sh`、`edl_config.json` | 本仓库 | GPL-3.0 |

### 关于高通签名镜像

`aboot.bin` / `hyp.mbn` / `rpm.mbn` / `sbl1.mbn` / `tz.mbn` 是从原厂固件里提取的签名二进制，**没有可再分发的授权**。公开仓库里带着它们有法律风险，建议：

- 从仓库移除，改为在 Release 里附说明，让用户用自己机型备份出来的镜像
- 或者只在本地保留，不提交

## 4. 上游项目署名

本仓库的工作流与脚本源自以下项目，特此致谢：

| 项目 | 许可证 | 说明 |
| --- | --- | --- |
| [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) | MIT | 云编译工作流的最初模板 |
| [xuxin1955/Actions](https://github.com/xuxin1955/Actions) | GPL-3.0 | 本仓库 fork 的直接上游，msm8916 target 与脚本来源 |
| [nicker1982/Actions-OpenWrt](https://github.com/nicker1982/Actions-OpenWrt) | — | fork 链上的中间项目 |
| [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt) | GPL-2.0 | 固件源码 |
| [msm8916-mainline](https://github.com/msm8916-mainline) | GPL-2.0 | lk2nd / qtestsign |

## 5. 合规说明

GPL-2.0（`GPL-2.0-only`）与 GPL-3.0 **不能合并成单一作品**，所以：

- 根目录 `LICENSE`（GPL-3.0）只覆盖第 1 节列出的自有文件
- `scripts/msm89xx/` 仍是上游的 GPL-2.0 及其他许可，本仓库只做搬运，不改许可
- 两者在同一仓库里属于**聚合（aggregation）**，各自独立，不构成派生关系

分发 GPL 二进制（`mke2fs.exe` 等）时，需要能提供对应源码——e2fsprogs 源码见 <https://e2fsprogs.sourceforge.net/>。
