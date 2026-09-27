# 官方 UI 对照精修 — 工作底稿

官方源码:zai-org/ZCode (6688★, main) 已克隆至 ../zcode-official/
本 App 源码:/Users/pingguobijiben/Documents/chatgpt/zcode-mini/ZcodeMini-App

## 已确认的官方规则(来自源码)
1. 模型按钮文案(modelTriggerDisplay.ts):内置套餐 provider 只显示模型名;
   自定义 provider 显示 "providerName/model"。✅ 我们的药丸已符合。
2. 官方 composer 关键组件:V4ComposerToolbar.tsx(1096 行)、
   V4ComposerModeControls.tsx、ConversationComposer.tsx(2387 行)。
3. 官方顶栏 ConversationHeader.tsx 是桌面窗格 chrome;手机版顶栏需继续定位
   (官方手机适配在 packages/web 或响应式断点里)。

## 待办(下一轮)
- [ ] 对照 V4ComposerToolbar.tsx 精修输入卡工具行(间距/图标/层级)
- [ ] 定位官方手机断点布局(搜 packages/web 的 responsive/断点)
- [ ] 协议审计:agentConversationTransport.ts(629行) 对照 zflow protocol/,
      补 conversationWorkflowRuns* / queryConversationCommandsV4
- [ ] 重连可靠性:对照 agentV4ConnectionHandshake.ts / workspaceConnectionRegistry.ts

## v4 UI 还原进行中(官方源码提取记录)
- composer 主结构:ConversationComposer.tsx L1700+ dock = flex 纵向列,
  附件行在上、工具栏在下;进度环用 -rotate-90 SVG stroke-border。
- 模型触发(modelTriggerDisplay):结构化 {fullLabel, providerPrefix?, modelLabel},
  窄屏可按密度隐藏 provider 前缀 —— zflow 药丸已符合,补前缀逻辑即可。
- 工具栏含 quota/upgrade 入口(chat.toolbar.model.label)。
- 待办:V4ComposerToolbar.tsx 1096 行逐段映射到 composer.dart;
  ConversationHeader 是窗格 chrome,手机顶栏在别处继续找。

## 用户决策记录
- v4 路线确认:ZcodeMini-App(Flutter,zflow 协议层)为基座,
  UI 按官方源码重做;协议审计结论见 protocol-capability-audit.md。
- 用户要的功能:新建会话✓(zflow draft)、打开文件夹(待加)、
  多设备(✓ zflow 连接池,无交接制需要!)、通知(✓ zflow task_notifier)。
