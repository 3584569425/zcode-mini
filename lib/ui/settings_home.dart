import 'package:flutter/material.dart';

import 'automation_page.dart';
import 'model_providers_page.dart';
import 'services_page.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'usage_page.dart';
import '../protocol/zflow_client.dart';
import '../state/account_store.dart';
import '../state/app_session.dart';

/// 设置归类首页(mini 同款):分类入口列表,点进二级子页。
/// 从对话页右上角齿轮进入;自动化/模型/用量等服务页也归拢到这里。
class SettingsHome extends StatelessWidget {
  final ZflowClient? client;
  final BridgeSession? bridge;
  final AccountStore store;
  final AppSession session;
  final VoidCallback onDisconnect;

  /// 当前工作区 scope(模型/用量/服务子页需要;null = 未选工作区)。
  final Map<String, dynamic>? scope;

  const SettingsHome({
    super.key,
    this.client,
    this.bridge,
    required this.store,
    required this.session,
    required this.onDisconnect,
    this.scope,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryCard(
            context: context,
            icon: Icons.palette_outlined,
            tint: const Color(0xFFE8B84B),
            title: '外观与显示',
            subtitle: '主题、语言、界面与代码字号',
            onTap: () => _push(context, SettingsPage(
              key: const ValueKey('settings-appearance'),
              store: store,
              session: session,
              onDisconnect: onDisconnect,
              themeController: ThemeControllerProvider.of(context),
              groups: const {'外观'},
            )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.notifications_outlined,
            tint: const Color(0xFFE8935B),
            title: '通知与后台',
            subtitle: '保活、息屏唤醒、任务提醒开关、电池白名单',
            onTap: () => _push(context, SettingsPage(
              key: const ValueKey('settings-notify'),
              store: store,
              session: session,
              onDisconnect: onDisconnect,
              themeController: ThemeControllerProvider.of(context),
              groups: const {'后台与通知'},
            )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.devices_other,
            tint: const Color(0xFF82C6F8),
            title: '设备与连接',
            subtitle: '设备管理、协议帧日志、诊断日志',
            onTap: () => _push(context, SettingsPage(
              key: const ValueKey('settings-device'),
              store: store,
              session: session,
              onDisconnect: onDisconnect,
              themeController: ThemeControllerProvider.of(context),
              groups: const {'设备与连接'},
            )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.model_training,
            tint: const Color(0xFF9EE6A6),
            title: '模型供应商',
            subtitle: '添加 / 启停 / 删除模型供应商',
            onTap: bridge == null
                ? null
                : () => _push(context, ModelProvidersPage(
                      session: bridge!,
                      scope: scope ?? const {'workspacePath': ''},
                    )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.donut_small,
            tint: const Color(0xFFB48BE8),
            title: '用量与额度',
            subtitle: '上下文、五小时窗口、周配额、订阅余额',
            onTap: bridge == null
                ? null
                : () => _push(context, UsagePage(session: bridge!)),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.bolt_outlined,
            tint: const Color(0xFFE8D75B),
            title: '自动化',
            subtitle: bridge == null
                ? '连接设备后可用'
                : '定时任务、执行历史、闲时队列',
            onTap: bridge == null ? null : () => _push(context, AutomationPage(
              key: ValueKey('auto-settings'),
              bridge: bridge!,
              workspace: _workspaceFallback(),
              onOpenTask: (_, _) {},
            )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.extension_outlined,
            tint: const Color(0xFF7FD8D8),
            title: '服务与技能',
            subtitle: 'MCP 服务、插件、Skills、斜杠命令',
            onTap: bridge == null
                ? null
                : () => _push(context, ServicesPage(
                      session: bridge!,
                      scope: scope ?? const {'workspacePath': ''},
                    )),
          ),
          _CategoryCard(
            context: context,
            icon: Icons.info_outline,
            tint: const Color(0xFF9AA1AE),
            title: '关于与诊断',
            subtitle: '版本更新、诊断日志、协议日志、调试器',
            onTap: () => _push(context, SettingsPage(
              key: const ValueKey('settings-about'),
              store: store,
              session: session,
              onDisconnect: onDisconnect,
              themeController: ThemeControllerProvider.of(context),
              groups: const {'关于'},
            )),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.link_off,
                color: EmberColors.of(context).err, size: 20),
            title: Text('断开当前设备',
                style: TextStyle(
                    fontSize: EmberType.emphasis,
                    color: EmberColors.of(context).err)),
            onTap: onDisconnect,
          ),
        ],
      ),
    );
  }

  /// 自动化子页需要工作区参数:取 shell 最近工作区的退化实现。
  /// (完整工作区选择在对话页抽屉;此处仅保自动化入口可达。)
  Map<String, dynamic> _workspaceFallback() =>
      const {'workspacePath': '', 'workspaceIdentity': ''};

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

/// 分类卡(mini settings-nav-row 同款):彩底图标 + 标题/副标题 + 箭头。
class _CategoryCard extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.context,
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext buildContext) {
    final colors = EmberColors.of(buildContext);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(EmberRadius.control + 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(EmberRadius.control + 2),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(EmberSpacing.cardPad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EmberRadius.control + 2),
              border: Border.all(color: colors.hairline),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(EmberRadius.control),
                  ),
                  child: Icon(icon, size: 20, color: tint),
                ),
                const SizedBox(width: EmberSpacing.gapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: EmberType.body,
                              fontWeight: FontWeight.w600,
                              color: colors.textSolid)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: EmberType.caption,
                              color: colors.textFaint,
                              height: 1.3)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 20, color: colors.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
