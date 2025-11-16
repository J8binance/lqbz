#!/bin/bash
#!/bin/bash
# 一键对 account1-10 的 screen 发送 Ctrl+C（若不存在则跳过）

# 你可以在此修改范围，例如只想控制1-5则改成 {1..5}
for i in {1..15}; do
  SESSION="account$i"
  if screen -list | grep -q "$SESSION"; then
    screen -S "$SESSION" -X stuff "^C"
    echo "✅ 已向 $SESSION 发送 Ctrl+C"
  else
    echo "⚠️ 未找到 $SESSION，跳过"
  fi
done

echo "✅ 操作完成：已对存在的 screen 发送 Ctrl+C，但保留会话。"

