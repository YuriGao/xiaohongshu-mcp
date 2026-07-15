# Cherry Studio 接入

本示例演示如何让 Cherry Studio 通过 Streamable HTTP 连接本机的 xiaohongshu-mcp。

Cherry Studio 的界面会随版本变化；如菜单名称不同，请参考其 [MCP 官方文档](https://docs.cherry-ai.com/advanced-basic/mcp/config)。

## 1. 启动服务

在项目根目录完成构建和首次登录：

```bash
go build -o build/xiaohongshu-mcp .
go build -o build/login ./cmd/login
./login.sh
./run.sh
```

验证：

```bash
curl http://127.0.0.1:18060/health
```

## 2. 添加 MCP 服务

在 Cherry Studio 中打开“设置”并进入“MCP 服务器”：

![Cherry Studio 设置](./images/cherrystudio-settings.png)

新增服务并填写：

| 字段 | 值 |
| --- | --- |
| 名称 | `xiaohongshu-mcp` |
| 类型 | `Streamable HTTP` |
| URL | `http://127.0.0.1:18060/mcp` |

![MCP 配置](./images/cherrystudio-config.png)

保存并启用后，打开工具列表。连接成功时应能看到 `check_login_status`、`publish_content`、`search_feeds` 等工具：

![工具列表](./images/cherrystudio-tools.png)

此服务通过 HTTP 连接，不需要为它配置 `uv`、`bun` 或本地启动命令。

## 3. 在对话中启用

创建助手或新对话，选择支持工具调用的模型，然后在输入框的工具菜单中启用 `xiaohongshu-mcp`：

![在对话中启用 MCP](./images/cherrystudio-conversation.png)

建议先测试只读操作：

```text
检查当前小红书登录状态。
```

```text
搜索最近一周的图文笔记，关键词是“周末徒步”，按最新排序。
```

确认调用过程正常后，再测试发布：

```text
发布一篇仅自己可见的测试图文笔记，使用图片 /Users/me/Pictures/test.jpg。
调用发布工具前先把标题、正文、标签和图片路径展示给我确认。
```

## 4. 地址选择

- Cherry Studio 与服务在同一台电脑：`http://127.0.0.1:18060/mcp`
- Cherry Studio 在另一台设备：使用服务所在电脑的局域网 IP，并确保防火墙允许访问
- 服务在 Docker、Cherry Studio 在宿主机：仍使用 `http://127.0.0.1:18060/mcp`

不要把无鉴权的 MCP 地址直接暴露到公网。

## 5. 常见问题

### 连接失败

1. 访问 `http://127.0.0.1:18060/health`。
2. 确认配置类型是 Streamable HTTP，而不是 STDIO。
3. 检查端口是否被占用或被防火墙拦截。
4. 重启 Cherry Studio 后重新加载工具列表。

### 未登录

调用 `get_login_qrcode`，使用小红书 App 扫码，再调用 `check_login_status`。

### 本地图片不可用

图片路径必须是运行 xiaohongshu-mcp 的电脑可读取的绝对路径。Docker 部署请使用 `/app/images/...`。

返回示例索引：[examples/README.md](../README.md)。
