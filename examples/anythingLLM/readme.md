# AnythingLLM 接入

本示例演示如何在 AnythingLLM Desktop 的对话和 Agent Flow 中调用 xiaohongshu-mcp。

## 1. 前提

- 已安装 [AnythingLLM Desktop](https://anythingllm.com/desktop)
- 已配置一个支持工具调用的模型
- xiaohongshu-mcp 已在本机运行

启动项目：

```bash
go build -o build/xiaohongshu-mcp .
go build -o build/login ./cmd/login
./login.sh
./run.sh
```

确认健康检查：

```bash
curl http://127.0.0.1:18060/health
```

## 2. 配置 MCP

优先在 AnythingLLM 的 Agent Skills 或 MCP 管理页面添加服务器：

```text
名称：xiaohongshu-mcp
类型：Streamable HTTP
地址：http://127.0.0.1:18060/mcp
```

如果当前 Desktop 版本仍使用配置文件，macOS 的常见路径为：

```text
~/Library/Application Support/anythingllm-desktop/storage/plugins/anythingllm_mcp_servers.json
```

配置内容：

```json
{
  "mcpServers": {
    "xiaohongshu-mcp": {
      "type": "streamable",
      "url": "http://127.0.0.1:18060/mcp"
    }
  }
}
```

保存后回到 Agent Skills 页面刷新：

![MCP 服务配置](./images/mcp-server-config.png)

AnythingLLM 的配置位置和字段可能随版本变化，界面可用时以界面配置为准。

## 3. 在对话中使用

创建对话并启用 Agent，然后先调用登录检查：

```text
@agent 使用 xiaohongshu-mcp 检查登录状态。
```

![直接调用 MCP](./images/direct-mcp-call.png)

如果未登录，调用 `get_login_qrcode` 扫码。发布前建议要求 Agent 先展示最终参数：

```text
@agent 根据下面的素材生成一篇小红书图文笔记。
先展示标题、正文、标签、图片路径和可见范围；得到我的确认后再调用 publish_content。
```

## 4. Agent Flow

可以把读取本地笔记、整理内容和 MCP 发布串成 Agent Flow：

1. 新建 Flow，例如 `publish_note`。
2. 用 Flow Variable 接收素材路径和发布选项。
3. 用 Read File 读取原始内容。
4. 用 LLM Instruction 生成结构化标题、正文和标签。
5. 在发布工具前加入人工确认。
6. 调用 `publish_content`，并记录工具返回结果。

![Agent Flow 配置](./images/agent-workflow-config.png)

| 执行过程 | 执行结果 |
| --- | --- |
| ![执行过程](./images/workflow-execution-process.png) | ![执行结果](./images/workflow-execution-results.png) |

不要让 Flow 在没有确认、去重和失败处理的情况下批量发布。

## 5. 网络地址

- AnythingLLM Desktop 与 MCP 服务同机：`http://127.0.0.1:18060/mcp`
- AnythingLLM 运行在 Docker Desktop：`http://host.docker.internal:18060/mcp`
- 两者在不同设备：使用 MCP 服务所在设备的局域网地址

## 6. 排查

- 列表中没有工具：刷新 Agent Skills，重启 AnythingLLM，并检查 JSON 语法。
- 连接失败：先访问 `/health`，确认客户端使用 Streamable HTTP。
- 工具不被模型调用：确认当前模型支持工具调用，并在对话中启用对应 Skill。
- 图片找不到：路径必须对运行 MCP 服务的进程可见。

返回示例索引：[examples/README.md](../README.md)。
