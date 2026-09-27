# 协议能力审计:开源源码够不够做一个完整原生 App?

结论:**够**。除"中继服务器"外全链路开源,新建会话/打开文件夹等均有协议支撑。

## 已确认的能力(官方源码定位)
| 能力 | 协议 | 开源位置 |
|---|---|---|
| 新建会话 | V4 命令 createSession(含断线重放 pendingCommandRegistry) | packages/ui/src/v4/pendingCommand*.ts |
| 发消息/目标/压缩 | sendText/sendGoalCommand/compact | 同上 |
| 会话列表/状态 | sessions-index 订阅(snapshot+deltas+resync) | agentSessionsIndexTransport.ts |
| 会话编辑/重试/分叉/回滚 | editUserQuery/retryTurn/forkAssistant/applyFileRewind | commandFactory.ts |
| 打开文件夹 | UI 走 services 的目录选择(fs/system selectDirectory),桌面 handler 开源 | packages/ui/src/root/openWorkspaceFolderEntry.ts |
| 文件读/传 | file 信道 + attachment*V4 | packages/services/src/file |
| 工作流视图 | conversationWorkflowRuns*(zflow 未实现) | agentConversationTransport.ts |
| 终端/Git/Skills/设置等 | 35+ 个桌面服务全部开源(services/src 全目录) | packages/services/src/ |

## 不可见部分(唯一)
中继服务器(配对/单客户端限制/Taken Over 判定)闭源 → 多设备同时在线做不到,
**交接制仍是正解**;relay 层 zcode_type 消息(bootstrap/bridge-open 等)桌面端闭源,
但 zflow 已逆向固化且稳定。

## 关键洞察
packages/ui 同时跑在桌面(本地)和浏览器(远程)——远程模式下 UI 的服务调用
经桥代理到桌面。所以 UI 源码里每一个交互 = 远程 App 可复刻的协议调用。

## 路线建议(v4:完整原生客户端)
zflow 即起点(协议层已验证),对照官方源码补全 + 全新 UI:
1. 以 ZcodeMini-App(Flutter fork)为基座,UI 按官方 v4 组件重写
2. 补协议:createSession 断线重放、workflow runs、文件管理
3. 通知交接制从原生壳移植到 Flutter 端(前台服务 + 多设备并行)
