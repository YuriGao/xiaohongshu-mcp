#!/usr/bin/env bash
# 启动小红书 MCP 服务
# 用法:
#   ./run.sh                          # 默认有界面模式, 端口 :18060
#   PORT=:9090 ./run.sh               # 自定义端口
#   HEADLESS=true ./run.sh            # 显式启用无头模式
#   BIN_PATH=/path/to/chrome ./run.sh # 指定浏览器
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$SCRIPT_DIR/build/xiaohongshu-mcp"

if [[ ! -x "$BIN" ]]; then
    echo "错误: 找不到可执行文件 $BIN" >&2
    echo "请先编译: go build -o build/xiaohongshu-mcp ." >&2
    exit 1
fi

# 可通过环境变量覆盖
PORT="${PORT:-:18060}"
HEADLESS="${HEADLESS:-false}"
BIN_PATH="${BIN_PATH:-${ROD_BROWSER_BIN:-}}"

args=(-port "$PORT" -headless="$HEADLESS")
[[ -n "$BIN_PATH" ]] && args+=(-bin "$BIN_PATH")

exec "$BIN" "${args[@]+"${args[@]}"}"
