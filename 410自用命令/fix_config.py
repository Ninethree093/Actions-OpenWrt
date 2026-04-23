#!/usr/bin/env python3
import re
import sys

if len(sys.argv) != 2:
    print("用法: python3 fix_config.py 型号")
    sys.exit(1)

target_dev = sys.argv[1]
input_file = 'config'
output_file = f'{target_dev}.config'

with open(input_file, 'r') as f:
    lines = f.readlines()

devices = set()
for ln in lines:
    m = re.search(r'openstick-([a-zA-Z0-9]+)', ln)
    if m:
        devices.add(m.group(1))

patt_pkg = re.compile(r'^.*CONFIG_PACKAGE_qcom-msm8916.*openstick-[a-zA-Z0-9]+.*(firmware|nv).*$')
cleaned = [ln for ln in lines if not patt_pkg.match(ln)]
pkg_start = None
for i, ln in enumerate(cleaned):
    if 'CONFIG_PACKAGE_qcom-msm8916' in ln:
        pkg_start = i
        break
new_pkg_block = [
    f'CONFIG_PACKAGE_qcom-msm8916-modem-openstick-{target_dev}-firmware=y\n',
    f'CONFIG_PACKAGE_qcom-msm8916-openstick-{target_dev}-wcnss-firmware=y\n',
    f'CONFIG_PACKAGE_qcom-msm8916-wcnss-openstick-{target_dev}-nv=y\n'
]
for dev in sorted(devices):
    if dev == target_dev:
        continue
    new_pkg_block += [
        f'# CONFIG_PACKAGE_qcom-msm8916-modem-openstick-{dev}-firmware is not set\n',
        f'# CONFIG_PACKAGE_qcom-msm8916-openstick-{dev}-wcnss-firmware is not set\n',
        f'# CONFIG_PACKAGE_qcom-msm8916-wcnss-openstick-{dev}-nv is not set\n'
    ]
if pkg_start is not None:
    cleaned = cleaned[:pkg_start] + new_pkg_block + cleaned[pkg_start:]
else:
    cleaned += new_pkg_block

patt_def = re.compile(r'^.*CONFIG_DEFAULT_qcom-msm8916.*openstick-[a-zA-Z0-9]+.*(firmware|nv).*$')
def_start = None
for i, ln in enumerate(cleaned):
    if patt_def.match(ln):
        def_start = i
        break
cleaned2 = [ln for ln in cleaned if not patt_def.match(ln)]
new_def_block = [
    f'CONFIG_DEFAULT_qcom-msm8916-modem-openstick-{target_dev}-firmware=y\n',
    f'CONFIG_DEFAULT_qcom-msm8916-openstick-{target_dev}-wcnss-firmware=y\n',
    f'CONFIG_DEFAULT_qcom-msm8916-wcnss-openstick-{target_dev}-nv=y\n'
]
for dev in sorted(devices):
    if dev == target_dev:
        continue
    new_def_block += [
        f'# CONFIG_DEFAULT_qcom-msm8916-modem-openstick-{dev}-firmware is not set\n',
        f'# CONFIG_DEFAULT_qcom-msm8916-openstick-{dev}-wcnss-firmware is not set\n',
        f'# CONFIG_DEFAULT_qcom-msm8916-wcnss-openstick-{dev}-nv is not set\n'
    ]
if def_start is not None:
    cleaned2 = cleaned2[:def_start] + new_def_block + cleaned2[def_start:]
else:
    prof_idx = None
    for i, ln in enumerate(cleaned2):
        if 'CONFIG_TARGET_PROFILE=' in ln:
            prof_idx = i
            break
    if prof_idx is not None:
        cleaned2 = cleaned2[:prof_idx+1] + new_def_block + cleaned2[prof_idx+1:]
    else:
        cleaned2 += new_def_block

final_lines = []
for ln in cleaned2:
    m = re.match(r'(# )?CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-([a-zA-Z0-9]+)( is not set|=y)', ln.strip())
    if m:
        dev = m.group(2)
        if dev == target_dev:
            final_lines.append(f'CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-{dev}=y\n')
        else:
            final_lines.append(f'# CONFIG_TARGET_msm89xx_msm8916_DEVICE_openstick-{dev} is not set\n')
        continue
    if 'CONFIG_TARGET_PROFILE=' in ln:
        final_lines.append(f'CONFIG_TARGET_PROFILE="DEVICE_openstick-{target_dev}"\n')
        continue
    final_lines.append(ln)

with open(output_file, 'w') as f:
    f.writelines(final_lines)

print(f"完成: {target_dev} -> {output_file}")
