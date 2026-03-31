# --- 4. 移植工具与插件 (修复版) ---
# 先清理旧的临时目录和目标目录
rm -rf temp_repo_pkg
rm -rf package/msm8916-packages

# 1. 克隆包含 package 的主仓库 (由于仓库较大，使用 --depth 1 节省时间)
git clone --depth 1 https://github.com/xuxin1955/immortalwrt temp_repo_pkg

# 2. 将仓库内的 package 文件夹内容移动到你的编译目录中
# 建议新建一个分类目录存放，防止与系统自带 package 冲突
mkdir -p package/msm8916-packages
cp -r temp_repo_pkg/package/* package/msm8916-packages/

# 3. 额外检查：如果需要特定的 mkbootimg 工具，也从这里提取
[ -f "temp_repo_pkg/scripts/mkbootimg" ] && cp temp_repo_pkg/scripts/mkbootimg scripts/
chmod +x scripts/mkbootimg 2>/dev/null

# 4. 清理临时仓库
rm -rf temp_repo_pkg
