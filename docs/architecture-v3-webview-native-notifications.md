# Zcode mini 架构 v3:官方 UI(WebView) + 原生协议通知层

## 决策
UI 直接承载官方 Web 远程界面(WebView),壳层原生;**核心差异化 = 通知**。
官方开源源码(zai-org/ZCode)提供状态语义;AIMini-WebView 提供壳层模板。

## 为什么可行(上次 WebView 尝试的死因与解法)
- 上次误报被接管:App 内自连接竞态 + 轮询一击即中。
- v3 方案:**连接交接制**——前台 WebView 在线时原生不连接;App 退后台
  (onStop)时 WebView 连接已冻死,原生协议客户端立即接管连接并推通知;
  回前台(onStart)原生先断开 → WebView reload 重连。全程同一时刻
  只有一个客户端,不存在互踢。

## 数据源(官方源码已确认)
- 状态:sessions-index 订阅(snapshot+deltas),phase 语义与 zflow
  task_notifier.computeNotifyUpdate 一致(官方 packages/ui/src/v4/agentSessionsIndexTransport.ts)。
- 协议链路:relay wss + auth_challenge/proof(HMAC-SHA256) + bootstrap +
  workspace-bridge-open + rpc-frame(分片+CRC32) + channel(IPC 值编码)。
  官方参照:packages/ui/src/v4/agentConversationTransport.ts(629行)。

## 实现清单(参照 zflow protocol/ 逐文件移植到 Java)
1. Proof + RemoteLink(已备,复用 0.2.1 原生壳)
2. IpcValueCodec(值编码,机械移植 ipc_codec.dart)
3. Crc32 + RpcFrameTransport(分片重组)
4. ChannelClient(方法调用/事件订阅)
5. RelayClient(auth/pair/heartbeat/退避重连)
6. SessionsIndexClient(订阅+状态机)
7. NotifyStateMachine(边沿检测:running→terminal / pendingInteraction)
8. ZcodeNotificationService(前台服务:WakeLock + 通知,参照 AIMiniNotificationService)
9. 交接控制:MainActivity onStart/onStop 驱动
10. 设置:通知开关三类(进行中/完成/需交互),默认仅完成+需交互

## UI 保留
官方页面即 UI;壳顶栏(会话/设备/设置)与 v0.2.1 相同。
