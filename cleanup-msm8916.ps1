<#
  只保留 msm8916：删除仓库里其它机型（mt7620 / mt7621 / mt7628 / XG-040G / sy108 等）的文件
  用法：在仓库根目录执行
    powershell -ExecutionPolicy Bypass -File cleanup-msm8916.ps1            # 真正删除
    powershell -ExecutionPolicy Bypass -File cleanup-msm8916.ps1 -DryRun    # 只打印要删什么
#>
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'

# 切到脚本所在目录（脚本就放在仓库根目录）
Push-Location -LiteralPath $PSScriptRoot

if (-not (Test-Path '.github\workflows') -or -not (Test-Path 'scripts\msm89xx')) {
    Write-Error '请在仓库根目录执行本脚本'
    exit 1
}

$git = $false
try { git rev-parse --is-inside-work-tree *> $null; $git = ($LASTEXITCODE -eq 0) } catch { $git = $false }

$targets = @(
    '.github\workflows\Build_imm_HLK-7628D.yml',
    '.github\workflows\Build_imm_HLK-7628N.yml',
    '.github\workflows\Build_imm_XG_040G.yml',
    '.github\workflows\Build_imm_xiaomi_miwifi-mini.yml',
    '.github\workflows\Build_sy108_uboot.yml',
    '.github\workflows\Build_sy108_UDX710.yml',
    '.github\workflows\Build_test.yml',
    'config\040-nousb.config',
    'config\040.config',
    'config\hlk7621.config',
    'config\hlk7628_LEDE.config',
    'config\hlk7628d.config',
    'config\hlk7628n.config',
    'config\xiaomi_miwifi-mini.config',
    'diy-part0.sh',
    'diy-part3.sh',
    'diy-part4.sh',
    'diy-part5.sh',
    'diy-part6.sh',
    'diy-part7.sh',
    'diy-part8.sh',
    'diy-sy108.sh',
    'sy108-oem',
    'scripts\dts',
    'scripts\files-7620',
    'scripts\files-7628',
    'scripts\image',
    'scripts\mt7620',
    'scripts\mt7621',
    'scripts\sy108',
    '.config'
)

# 个人杂项工具目录（名字含中文，用通配符匹配，避免源码编码问题）
Get-ChildItem 'scripts' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like '410*' } |
    ForEach-Object { $targets += $_.FullName }

$removed = 0
foreach ($t in $targets) {
    if (-not (Test-Path -LiteralPath $t)) { Write-Host "skip (不存在): $t"; continue }
    if ($DryRun) { Write-Host "[dry-run] $t"; continue }
    if ($git) {
        git rm -r -f -q --ignore-unmatch -- $t 2>$null
        if ($LASTEXITCODE -ne 0) { Remove-Item -LiteralPath $t -Recurse -Force }
    }
    else { Remove-Item -LiteralPath $t -Recurse -Force }
    Write-Host "removed: $t"
    $removed++
}

if ($DryRun) { Write-Host '== dry-run 结束，未改动任何文件 =='; exit 0 }
Write-Host "== 完成，处理 $removed 项 =="
if ($git) { git status --short | Select-Object -First 40 }
