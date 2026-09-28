// 此文件是 chat_page.dart 的一部分(part):同库共享导入与私有类可见。
part of '../chat_page.dart';

/// "+"面板(U2):先出分类入口(Skills/斜杠命令/附件/添加上下文),
/// 点进分类再列明细,避免一打开就是一整面列表。
class _PlusSheet extends StatefulWidget {
  final List<_SlashItem> slashItems;
  final bool loading;
  final void Function(String insert) onSelect;
  final VoidCallback onAttach;
  final Future<void> Function() onRefresh;

  const _PlusSheet({
    required this.slashItems,
    required this.loading,
    required this.onSelect,
    required this.onAttach,
    required this.onRefresh,
  });

  @override
  State<_PlusSheet> createState() => _PlusSheetState();
}

class _PlusSheetState extends State<_PlusSheet> {
  /// null = 分类首页;'skills' / 'commands' = 对应明细列表。
  String? _section;

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final commands =
        widget.slashItems.where((i) => !i.isSkill).toList(growable: false);
    final skills =
        widget.slashItems.where((i) => i.isSkill).toList(growable: false);

    Widget section(String title, List<_SlashItem> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Text('无',
                    style: TextStyle(
                        fontSize: 12, color: colors.textFaint)),
              )
            else
              for (final item in items)
                ListTile(
                  dense: true,
                  leading: Text(item.isSkill ? r'$' : '/',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: EmberFonts.term,
                          color: colors.primary)),
                  title: Text(item.name,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: item.description.isNotEmpty
                      ? Text(item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: colors.textFaint))
                      : null,
                  onTap: () => widget.onSelect(item.insert),
                ),
          ],
        );

    Widget body;
    if (_section == 'skills' || _section == 'commands') {
      body = section(_section == 'skills' ? 'Skills' : '斜杠命令',
          _section == 'skills' ? skills : commands);
    } else {
      body = Column(children: [
        _plusCategory(context, Icons.auto_awesome_outlined, 'Skills',
            '${skills.length} 项', () => setState(() => _section = 'skills')),
        _plusCategory(
            context,
            Icons.terminal,
            '斜杠命令',
            '${commands.length} 项',
            () => setState(() => _section = 'commands')),
        _plusCategory(context, Icons.attach_file, '附件', '选择文件上传',
            () => widget.onAttach()),
        _plusCategory(context, Icons.data_object_outlined, '添加上下文',
            '选择文件并插入引用', () => widget.onAttach()),
      ]);
    }

    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(children: [
              if (_section != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  tooltip: '返回',
                  onPressed: () => setState(() => _section = null),
                )
              else
                const SizedBox(width: 40),
              Text(
                  _section == 'skills'
                      ? 'Skills'
                      : _section == 'commands'
                          ? '斜杠命令'
                          : '插入',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (widget.loading)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                  icon: Icon(Icons.refresh,
                      size: 18, color: colors.textMuted),
                  tooltip: '刷新',
                  onPressed: widget.onRefresh,
                ),
            ]),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(child: body),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _plusCategory(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    final colors = EmberColors.of(context);
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(EmberRadius.control),
        ),
        child: Icon(icon, size: 18, color: colors.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 11, color: colors.textFaint)),
      trailing: Icon(Icons.chevron_right,
          size: 18, color: colors.textFaint),
      onTap: onTap,
    );
  }
}

/// 会话设置面板图标行(桌面同款布局)。按钮全部压缩密度,整行高度约为
/// 常规 IconButton 行的一半。
/// 协作模式元数据(用户裁定:菜单汉化、按钮两字缩写)。宿主实际下发
/// ask/edit/plan/full(桌面源码另有 build/yolo 别名),两套都覆盖。
const _modeMeta = {
  'build': ('构建', '改动前先询问,每次文件改动都会征求确认'),
  'ask': ('构建', '改动前先询问,每次文件改动都会征求确认'),
  'edit': ('编辑', '自动编辑选定文件'),
  'plan': ('计划', '只读研究,方案产出后需确认才会动手'),
  'yolo': ('YOLO', '编辑与执行命令几乎免确认'),
  'full': ('YOLO', '编辑与执行命令几乎免确认'),
};

/// 协作模式中文标签(模式菜单与按钮共用);未知值原样返回。
String modeLabelOf(String value) {
  final meta = _modeMeta[value.toLowerCase()];
  return meta?.$1 ?? value;
}

/// 协作模式中文描述(菜单副标题);未知值返回 null(回落原始 name)。
String? modeDescriptionOf(String value) {
  return _modeMeta[value.toLowerCase()]?.$2;
}

/// 高风险模式(警示色/横幅):计划与 YOLO(含 full 别名)。
bool modeIsHot(String value) {
  final v = value.toLowerCase();
  return v == 'plan' || v == 'yolo' || v == 'full';
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;

  /// 会话运行中:占位文案切「排队」语义,输入为空时发送键变停止。
  final bool running;

  /// 排队中的乐观消息数(桌面 √N 徽标)。
  final int queueCount;

  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback onPlusMenu;

  /// 协作模式药丸(mini mode-pill 同款:+ 号旁的图标+文字胶囊,
  /// 高风险模式着橙)。点击呼出模式菜单。
  final String modeLabel;
  final bool modeHot;
  final VoidCallback? onModeMenu;

  /// mini 同款统计行:速度 / 缓存率 / 输入 / 输出。
  final String speedLabel;
  final String cacheLabel;
  final String inputLabel;
  final String outputLabel;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.running,
    required this.queueCount,
    required this.onSend,
    required this.onStop,
    required this.onPlusMenu,
    this.modeLabel = '构建',
    this.modeHot = false,
    this.onModeMenu,
    this.speedLabel = '—',
    this.cacheLabel = '—',
    this.inputLabel = '—',
    this.outputLabel = '—',
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final dark = colors.isDark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 单行玻璃 composer(mini .composer 直译):9px 内边距、
            // 白 .06 底 + 白 .18 描边 + r29 + blur(6) saturate(140%)。
            ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 5, 5, 5),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0x0FFFFFFF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(29),
                    border: Border.all(
                        color: dark
                            ? const Color(0x2EFFFFFF)
                            : Colors.black.withValues(alpha: 0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.27 : 0.08),
                        blurRadius: 42,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // mini 同款:+ 默认圆形加号;高风险模式(计划/YOLO)
                      // 把加号本身变形为「图标+文字」药丸,避免挤占输入框。
                      _ComposerPlusButton(
                        sending: sending,
                        modeLabel: modeLabel,
                        modeHot: modeHot,
                        onPlusMenu: onPlusMenu,
                        onModeMenu: onModeMenu,
                      ),
                      if (queueCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text('√$queueCount',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary)),
                        ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 6,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: colors.textSolid),
                          cursorColor: colors.primary,
                          decoration: InputDecoration(
                            hintText:
                                running ? '继续输入以排队后续修改' : '向 ZCode 提问…',
                            hintStyle: TextStyle(color: colors.textFaint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            filled: false,
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      _SendOrStop(
                        controller: controller,
                        sending: sending,
                        running: running,
                        onSend: onSend,
                        onStop: onStop,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 统计行:速度 · 缓存 · 输入 · 输出(mini composer-stats 同款)
            GlassStatsRow(
              speed: speedLabel,
              cacheRate: cacheLabel,
              inputTokens: inputLabel,
              outputTokens: outputLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// composer 左侧入口(mini 同款):默认 36px 圆形加号;计划/YOLO 把加号
/// 本身变形为「盾标+文字」药丸,不再额外占一行。短按打开加号面板,
/// 长按打开协作模式菜单。
class _ComposerPlusButton extends StatelessWidget {
  final bool sending;
  final String modeLabel;
  final bool modeHot;
  final VoidCallback onPlusMenu;
  final VoidCallback? onModeMenu;

  const _ComposerPlusButton({
    required this.sending,
    required this.modeLabel,
    required this.modeHot,
    required this.onPlusMenu,
    this.onModeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    if (modeHot) {
      return Tooltip(
        message: '协作模式 $modeLabel · 点开加号面板,长按切换模式',
        child: InkWell(
          onTap: sending ? null : onPlusMenu,
          onLongPress: sending ? null : onModeMenu,
          borderRadius: BorderRadius.circular(EmberRadius.pill),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EmberRadius.pill),
              border: Border.all(
                  color: colors.accentOrange.withValues(alpha: 0.35)),
              color: colors.accentOrange.withValues(alpha: 0.12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined,
                    size: 14, color: colors.accentOrange),
                const SizedBox(width: 4),
                Text(modeLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: colors.accentOrange)),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: sending ? null : onModeMenu,
      child: GlassIconButton(
        icon: Icons.add,
        tooltip: 'Skills / 命令 / 附件 / 模式',
        onTap: sending ? null : onPlusMenu,
      ),
    );
  }
}

/// 发送/停止键:会话运行中且输入为空 → 停止方块(桌面同款);其余状态
/// 为发送箭头(发送在途显转圈)。与图标行同高。
class _SendOrStop extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final bool running;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const _SendOrStop({
    required this.controller,
    required this.sending,
    required this.running,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final dark = colors.isDark;
    const size = 36.0;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final empty = value.text.trim().isEmpty;
        if (running && empty) {
          // 停止键(mini .stop-btn):玻璃底 + 白色小方块。
          return Tooltip(
            message: '停止',
            child: InkWell(
              onTap: onStop,
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? Colors.white.withValues(alpha: 0.055)
                      : Colors.black.withValues(alpha: 0.05),
                  border: Border.all(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.24)
                          : Colors.black.withValues(alpha: 0.15)),
                ),
                child: Icon(Icons.stop,
                    size: 16, color: colors.textSolid),
              ),
            ),
          );
        }
        // 发送键(mini .send-btn):空输入为玻璃 + 绿辉光;有文字变橙
        // 渐变 + 橙辉光。
        final hot = !empty;
        return Tooltip(
          message: '发送',
          child: InkWell(
            onTap: sending ? null : onSend,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: hot
                        ? colors.accentOrange.withValues(alpha: 0.5)
                        : (dark
                            ? Colors.white.withValues(alpha: 0.24)
                            : Colors.black.withValues(alpha: 0.15))),
                gradient: hot
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFB054), Color(0xFFFF8A1E)])
                    : null,
                color: hot
                    ? null
                    : (dark
                        ? Colors.white.withValues(alpha: 0.055)
                        : Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: hot
                        ? const Color(0xFFFF8A1E).withValues(alpha: 0.35)
                        : const Color(0xFF8EF0B7).withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: sending
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colors.textSolid),
                    )
                  : Icon(Icons.arrow_upward,
                      color: hot ? Colors.white : colors.textSolid, size: 19),
            ),
          ),
        );
      },
    );
  }
}
