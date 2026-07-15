# 集成示例

本目录保存 xiaohongshu-mcp 与第三方 MCP 客户端、Agent 和工作流平台的接入示例。

## 示例列表

| 示例 | 适用场景 | 文档 |
| --- | --- | --- |
| Cherry Studio | 在桌面聊天客户端中手动选择并调用工具 | [查看指南](./cherrystudio/README.md) |
| AnythingLLM | 在对话或 Agent Flow 中调用工具 | [查看指南](./anythingLLM/readme.md) |
| n8n | 将 MCP 工具连接到 AI Agent 工作流 | [查看指南](./n8n/README.md) |

## 共同前提

在配置任何客户端之前，请先在项目根目录完成构建、登录和启动：

```bash
go build -o build/xiaohongshu-mcp .
go build -o build/login ./cmd/login
./login.sh
./run.sh
```

确认服务可用：

```bash
curl http://127.0.0.1:18060/health
```

MCP 地址为：

```text
http://127.0.0.1:18060/mcp
```

如果客户端运行在 Docker 容器、虚拟机或另一台设备中，`127.0.0.1` 指向的是客户端自身，必须改成客户端能够访问的宿主机地址。

## 使用建议

- 第一次连接先调用 `check_login_status`，不要直接发布。
- 涉及发布、评论、点赞、收藏或删除 Cookies 时，保留人工确认步骤。
- 本地图片路径必须能被 MCP 服务进程访问；容器部署请使用 `/app/images/...`。
- 不要把 MCP 服务直接暴露到公网，它没有内置鉴权。
- 示例中的模型、凭证、私网 IP 和提示词都只是占位内容，导入后必须检查。

欢迎新增可复现的集成示例。提交前请移除密钥、Cookies、账号信息和本机绝对路径。
