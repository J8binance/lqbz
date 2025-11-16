#!/bin/bash

lighterDir="/data/lighter"
accountName="account"

# 检查 expect 是否安装
if ! command -v expect &> /dev/null; then
	apt update &> /dev/null
	apt install expect -y &> /dev/null
fi

# 获取所有 account* 目录
accounts=$(ls -l "$lighterDir" | grep '^d' | grep "$accountName" | awk '{print $NF}')

if [ -z "$accounts" ]; then
    echo "⚠️ 未找到任何 $lighterDir/$accountName* 目录"
    exit 0
fi

# 定义自动升级函数（批量切换到 Premium）
auto_upgrade_premium() {
    local dir="$1"
    echo "🚀 正在处理账户目录: $dir"

    # 在子 shell 中 cd，避免影响外层目录
    (
        cd "$dir" || { echo "❌ 无法进入目录 $dir"; exit 1; }
        source venv/bin/activate

        # 检查 upgrade_account_tier.py 是否存在（可选）
        if [ ! -f upgrade_account_tier.py ]; then
            echo "⚠️  $dir 中未找到 upgrade_account_tier.py，跳过"
            exit 0
        fi

        # 使用 expect 自动交互
        expect <<EOF
spawn python upgrade_account_tier.py
expect "请输入选项 (0-7):"
send "6\r"
expect "确认继续? (yes/no):"
send "yes\r"
expect "按 Enter 继续..."
send "\r"
expect "请输入选项 (0-7):"
send "0\r"
expect eof
EOF
    )
}

# 遍历每个账户目录并执行升级
for account in $accounts; do
    auto_upgrade_premium "$lighterDir/$account"
    echo "✅ 完成处理: $account"
    echo "-----------------------------"
done

echo "🎉 所有账户目录处理完毕。"
