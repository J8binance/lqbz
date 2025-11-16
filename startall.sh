#!/bin/bash

lighterDir="/data/lighter"
accountPrefix="account"

echo "======================================="
echo "     Lighter 一键全部启动脚本"
echo "---------------------------------------"
echo "  自动启动 ${accountPrefix}1 ~ ${accountPrefix}10"
echo "  其他逻辑与原脚本保持一致"
echo "======================================="

# 直接选择 1~10 全部账号
accounts=$(seq 1 10)
echo "👉 已选择全部账号: $accounts"

for n in $accounts; do
    # 检查合法性（防止以后改范围）
    if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt 10 ]; then
        echo "⚠️ 跳过无效编号: $n（仅支持 1-10）"
        continue
    fi

    account_dir="${lighterDir}/${accountPrefix}${n}"
    screen_name="${accountPrefix}${n}"

    # 检查目录
    if [ ! -d "$account_dir" ]; then
        echo "⚠️ 目录不存在: $account_dir"
        continue
    fi

    cd "$account_dir" || continue

    # 检查虚拟环境
    if [ ! -f "venv/bin/activate" ]; then
        echo "⚠️ 未找到虚拟环境: $account_dir/venv/bin/activate"
        continue
    fi

    # 检查是否已在运行
    if screen -list | grep -q "[.]${screen_name}"; then
        echo "🔁 ${screen_name} 已在运行，跳过。"
        continue
    fi

    echo "🚀 正在启动 ${screen_name}..."

    # 在 screen 中启动并输出日志
    screen -dmS "$screen_name" bash -c '
        source venv/bin/activate
        python dual_account_wash_trading.py 2>&1 | tee -a "account.log"
    '

    if [ $? -eq 0 ]; then
        echo "✅ ${screen_name} 启动成功"
    else
        echo "❌ ${screen_name} 启动失败"
    fi

    sleep 1
done

echo "---------------------------------------"
echo "✅ 全部账号已处理完成"
echo "   可用命令查看运行状态: screen -ls"
echo "---------------------------------------"
