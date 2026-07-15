# n8n 接入

本目录包含可导入的 n8n 工作流模板 [`自动发布笔记到小红书.json`](./自动发布笔记到小红书.json)。模板把 Chat Trigger、AI Agent、语言模型和 MCP Client Tool 连接起来。

> 模板内的模型、提示词和 MCP 私网地址只是示例。导入后必须逐项检查，不能直接用于生产发布。

## 1. 前提

- 可用的 n8n 实例
- n8n 中可用的 AI Agent、Chat Model 和 MCP Client Tool 节点
- 已配置的模型凭证
- 正常运行并已登录的 xiaohongshu-mcp

启动 MCP 服务：

```bash
go build -o build/xiaohongshu-mcp .
go build -o build/login ./cmd/login
./login.sh
./run.sh
```

```bash
curl http://127.0.0.1:18060/health
```

n8n 的安装和运行方式请参考 [n8n 官方文档](https://docs.n8n.io/hosting/)。

## 2. 导入模板

1. 在 n8n 新建工作流。
2. 选择从文件导入。
3. 选择本目录的 `自动发布笔记到小红书.json`。
4. 打开每个节点并检查配置。

![导入工作流](./images/image-20250915230216557.png)

导入后应看到以下连接：

```text
Chat Trigger
    │
    ▼
AI Agent ◀── Chat Model
    ▲
    └──── MCP Client Tool
```

## 3. 必须修改的内容

### MCP Client Tool

模板中的 `xhs_MCP` 节点保存了示例私网 IP。将 Endpoint URL 改为 n8n 实际可以访问的地址，并选择 Streamable HTTP：

| n8n 运行位置 | MCP 地址 |
| --- | --- |
| 与 MCP 服务同机、非容器 | `http://127.0.0.1:18060/mcp` |
| Docker Desktop 容器 | `http://host.docker.internal:18060/mcp` |
| 另一台设备或服务器 | `http://<MCP 服务局域网 IP>:18060/mcp` |

Linux Docker 中使用 `host.docker.internal` 时，需要增加 `host-gateway`，或将两个服务放入可互通的 Docker 网络。

![配置 MCP 节点](./images/image-20250915231537715.png)

### 语言模型

模板使用一个 DeepSeek 兼容的 Chat Model 节点。你可以换成任何被当前 n8n AI Agent 支持、且具备工具调用能力的模型。删除模板中遗留的凭证引用，再选择自己的凭证。

### Agent 提示词

模板提示词是演示内容，包含与小红书发布无关的引导逻辑。请完整替换为自己的发布规则，例如：

```text
你负责整理小红书图文笔记。
调用任何发布或互动工具前，必须先展示最终标题、正文、标签、图片路径、可见范围和原创声明选项。
只有在用户明确确认后，才允许调用 xiaohongshu-mcp。
工具失败时停止流程并返回原始错误，不要自动重复发布。
```

## 4. 测试顺序

先单独执行 MCP Client Tool，测试：

```text
check_login_status
```

确认工具清单和登录状态正常后，再从 Chat Trigger 输入只读请求：

```text
搜索关键词“周末徒步”，只返回前 5 条结果，不执行任何互动操作。
```

最后使用仅自己可见的测试内容验证发布，并在小红书端检查实际结果。

![执行工作流](./images/image-20250915232457764.png)

## 5. 工作流建议

- 在发布节点前增加人工确认。
- 为每篇内容生成业务唯一 ID，避免 n8n 重试造成重复发布。
- 记录工具参数、返回值和执行时间，但不要记录 Cookies。
- 为模型节点和 MCP 节点分别设置超时与错误分支。
- 批量流程应限制并发和频率。
- 图片路径必须能被 xiaohongshu-mcp 进程读取，而不只是能被 n8n 读取。

## 6. 排查

### MCP 连接失败

从 n8n 所在环境访问 `http://<地址>:18060/health`。如果 n8n 在容器内，容器里的 `127.0.0.1` 不是宿主机。

### 工具列表为空

确认 MCP Client Tool 的传输类型为 Streamable HTTP，Endpoint 以 `/mcp` 结尾，并重新执行节点。

### Agent 不调用工具

确认 MCP Client Tool 已通过 `ai_tool` 连接到 Agent，模型支持工具调用，且提示词明确要求使用工具。

### 发布重复

关闭自动重试，检查 n8n 执行历史，并在工作流中加入内容去重和幂等控制。

返回示例索引：[examples/README.md](../README.md)。
