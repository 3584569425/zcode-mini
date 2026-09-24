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
