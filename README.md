# wefewe/zed2api

> **镜像来源声明与开源闭环**：  
> 本仓库是 [`csmsqj/zed-api`](https://github.com/csmsqj/zed-api)（基于 `yukmakoto/zed2api`，MIT 许可）的自动化同步与多架构构建镜像源。源码存放于 `upstream/` 目录。
> 
> 针对云端 Swarm 生产环境加固规范：
> 1. **预发布本地冒烟测试门禁 (CI Quality Gate)**：多架构发布前本地编译并探活 `:8001/v1/models`，未通过严禁发布。
> 2. **多架构生产镜像**：自动化构建 `linux/amd64` 与 `linux/arm64`，发布至 `ghcr.io/wefewe/zed2api:latest`。
> 3. **错峰自动同步**：每 2 小时定时对齐上游代码变更，上游一旦更新即刻触发重新构建。

---

## 快速使用

### Docker 运行

```bash
docker run -d \
  --name zed2api \
  -p 8001:8001 \
  -v ./data:/app/data \
  ghcr.io/wefewe/zed2api:latest
```

- **Web 管理面板**：`http://localhost:8001/`
- **OpenAI 兼容端点**：`http://localhost:8001/v1/chat/completions`
- **Anthropic 兼容端点**：`http://localhost:8001/v1/messages`
- **Codex 兼容端点**：`http://localhost:8001/v1/responses`
- **模型列表**：`http://localhost:8001/v1/models`
- **账号列表**：`http://localhost:8001/zed/accounts`

### 配置环境变量

| 环境变量 | 默认值 | 说明 |
| --- | --- | --- |
| `HEALTH_PROBE_INTERVAL_SECONDS` | `1800` | 定时健康探测间隔秒数（默认 30 分钟，设置为 `0` 禁用自动探测） |
| `HEALTH_PROBE_INTERVAL_MINUTES` | - | 定时健康探测间隔分钟数（效果等同于秒数换算） |
| `TG_NOTIFY_SCRIPT` | `/usr/local/bin/cluster-tg-notify.sh` | 探测异常或恢复时调用的 Telegram 广播通知脚本路径 |
| `HTTPS_PROXY` | - | 上游网络代理（可选） |

