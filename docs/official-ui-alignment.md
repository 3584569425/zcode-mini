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

## UI 调试闭环(已验证可用)
安卓模拟器本机未装(无 emulator/系统镜像);改用 Web 调试路线:
1. cd ZcodeMini-App && flutter build web --release
2. python3 -m http.server 8200 -d build/web
3. 浏览器(iab)开 http://localhost:8200,视口 390x844
4. Flutter Web 是 canvas 渲染:DOM 快照无效,用 cua.click 坐标点击 + 截图验证
   (点击若无效,确认无遮挡后重试;坐标按逻辑像素)
5. 已通过 Web 端完整协议连上真实桌面(YOLO 条/用量条/模型药丸全活数据)
6. 迭代:改 Flutter 代码 → flutter build web → reload → 截图对比
注意:已移除 fork 对上游 zflow 的启动更新检查(会弹无关更新框)。

## V4ComposerToolbar 设计规格(已提取,映射到 composer.dart)
- 模型触发:fullLabel + providerPrefix(紧凑断点隐藏前缀);极窄=28px 纯图标模式
- **思考档是循环按钮**(ThoughtLevelCycleControl):点一下循环下一档,非菜单 — zflow 需改
- 模型菜单不可用态:加载失败重试按钮 / remoteWaiting / targetMissing 三种文案
- ChatContextUsage 在工具栏上方独立一行
- zflow 对应改法:思考药丸 onClick 循环 state.thoughtLevels 下一档(optimisticPatch),
  模型药丸保持弹层

## 思考循环已实现(待真机/浏览器复核)
- chat_page.dart 新增 _cycleThought():点思考药丸循环 thoughtLevels 下一档,
  optimisticPatch 乐观更新 + switchModelConfig 提交;无档位回落思考菜单。
- 已通过 analyze(0 issue)+ web 构建。
## 浏览器调试坐标教训
- cua 坐标 = 截图逻辑像素 1:1,但页面可滚动导致同坐标不同元素;
  每次点击前必须先截图确认目标当前位置,不要凭记忆。
- 对话 Tab 底栏图标在 y≈790(设置页滚动态),主页 y≈820;注意区分。
## 待续
1. 浏览器里回到对话页(返回箭头→底栏对话),点击思考药丸验证循环
2. 顶栏/会话列表对照官方重做
3. Flutter 端 Android 构建发布(协议+通知全在,随 UI 一起发)

## v0.4.x UI 重构验证记录(Web 端实机截图确认)
✅ 玻璃控制轨顶栏:三环额度环(上下文绿环活数据) + max/GLM-5.3 徽章 + 设备/设置
✅ 单行 composer:+圆钮 / 输入 / 发送圆钮
✅ 统计行:速度 · 缓存 98% · 输入 20.9 百万 · 输出 2.2 万(真桌面活数据)
✅ 底栏三 Tab 移除(单屏);YOLO 红条移除(计划条保留)
✅ 状态胶囊实时翻转保留(测试回归绿)
✅ 状态胶囊随玻璃卡实时翻转(布局回归 5/5 绿)
✅ 设备档案持久化(secure storage 跨会话) + 配对秒连
⚠️ 待续:设置归类首页已实现(SettingsHome,齿轮入口已接线,浏览器点击
   验证受 IAB 坐标漂移影响未截图确认——真机直接验);可移动洞察胶囊、
   加号面板模式入口待做;root_shell_test 13 个 Tab 时代测试待适配
   (底栏/Tab 已按用户要求废弃,测试需改走新导航:齿轮→归类首页)。
## 调试经验(重要)
- Flutter Web canvas 点击:IAB cua.click 在部分状态不生效(过渡帧/
  hover 暖机),点击前先截图测坐标,无效时补一次移动+点击;
- Flutter Web DOM 快照默认为空,需激活 flt-semantics-placeholder;
- main.dart.js 缓存:换端口或加时间戳强刷;
- 模拟器(320x640 自定义 AVD)渲染正常但 Flutter 点击不响应
  (系统 Settings 点击正常)——待查,优先用真机验证。
