import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// GPT Mini 同款液态玻璃组件库(mini-ref 复刻稿参数直译):
/// - 浮层玻璃:blur(6px) saturate(140%) + 白 .03 底 + 白 .1 描边 + 40px 投影
/// - 深层菜单:blur(18px) saturate(155%) + 70px 深投影
/// - 三环额度:r 10.5 / 7.2 / 3.9 几何
/// - 呼吸状态点:#5CFFA8 + 辉光,1.82s 循环

/// 液态玻璃卡。`deep: true` 用于菜单/面板(blur 18 + 深投影),
/// 默认用于顶栏/输入区等悬浮条(blur 6 + 标准投影)。
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final bool deep;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.margin,
    this.border,
    this.deep = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final dark = colors.isDark;
    final bg = deep
        ? (dark ? const Color(0x05FFFFFF) : const Color(0xD9FFFFFF))
        : (dark ? const Color(0x08FFFFFF) : const Color(0xE6FFFFFF));
    final line = colors.borderGlass;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: deep ? 0.42 : 0.25),
            blurRadius: deep ? 70 : 40,
            offset: Offset(0, deep ? 16 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: deep ? 18 : 6,
            sigmaY: deep ? 18 : 6,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: border ?? Border.all(color: line),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// 呼吸状态点(mini .title-dot):8px 圆点 + 辉光,1.82s 透明度呼吸。
/// `idle: true` 时为静态灰点(空闲态不呼吸)。
class PulsingDot extends StatefulWidget {
  final double size;
  final bool idle;

  const PulsingDot({super.key, this.size = 8, this.idle = false});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1820),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.idle) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.idle) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    if (widget.idle) return _dot(colors, colors.textFaint, 0);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // mini titleDotFlash:透明度在 1 → 0.45 间往复。
        final glow = ui.lerpDouble(1.0, 0.45, _ctrl.value)!;
        return _dot(colors, colors.statusDot, glow);
      },
    );
  }

  Widget _dot(EmberColors colors, Color color, double glow) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(color, colors.bg, 1 - glow),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.52 * glow),
            blurRadius: 8,
            spreadRadius: 1.75,
          ),
        ],
      ),
    );
  }
}

/// mini icon-btn:36px 圆形,蓝染底 + 蓝描边(输入区 + 号等)。
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final button = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary.withValues(alpha: 0.09),
          border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, size: 18, color: colors.primary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}

/// 三环额度:外环=上下文,中环=5小时额度,内环=周额度(mini 同款几何)。
/// 取值 0..100;颜色外环用状态绿,中/内用灰白。
class TripleQuotaRing extends StatelessWidget {
  final double contextPct;
  final double fiveHourPct;
  final double weeklyPct;
  final double size;
  final Color? contextColor;
  final VoidCallback? onTap;
  final String? tooltip;

  const TripleQuotaRing({
    super.key,
    required this.contextPct,
    this.fiveHourPct = 0,
    this.weeklyPct = 0,
    this.size = 26,
    this.contextColor,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final track = (colors.isDark ? Colors.white : Colors.black)
        .withValues(alpha: 0.13);
    final ringColor = contextColor ??
        (colors.isDark ? const Color(0xFF8EF0B7) : const Color(0xFF2E7D4F));
    final middleColor = colors.isDark
        ? Colors.white.withValues(alpha: 0.62)
        : Colors.black.withValues(alpha: 0.45);
    final widget = CustomPaint(
      size: Size.square(size),
      painter: _RingsPainter(
        track: track,
        contextPct: contextPct.clamp(0, 100),
        fiveHourPct: fiveHourPct.clamp(0, 100),
        weeklyPct: weeklyPct.clamp(0, 100),
        contextColor: ringColor,
        middleColor: middleColor,
      ),
    );
    final button = onTap == null
        ? widget
        : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(size), child: widget);
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}

class _RingsPainter extends CustomPainter {
  final Color track;
  final double contextPct;
  final double fiveHourPct;
  final double weeklyPct;
  final Color contextColor;
  final Color middleColor;

  _RingsPainter({
    required this.track,
    required this.contextPct,
    required this.fiveHourPct,
    required this.weeklyPct,
    required this.contextColor,
    required this.middleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    void ring(double radius, double width, Color color, double pct) {
      final trackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = track;
      canvas.drawCircle(center, radius, trackPaint);
      if (pct <= 0) return;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = color;
      final rect = Rect.fromCircle(center: center, radius: radius);
      const start = -math.pi / 2;
      canvas.drawArc(rect, start, 2 * math.pi * pct / 100, false, paint);
    }

    // mini 几何:r 10.5 / 7.2 / 3.9 → 比例 1.0 / 0.686 / 0.371
    final r = size.width / 2;
    ring(r - 1.2, 2.2, contextColor, contextPct);
    ring(r * 0.686, 2.0, middleColor, fiveHourPct);
    ring(r * 0.371, 2.0, middleColor, weeklyPct);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.contextPct != contextPct ||
      old.fiveHourPct != fiveHourPct ||
      old.weeklyPct != weeklyPct;
}

/// 单行统计条:速度 · 缓存 · 输入 · 输出(mini composer-stats 同款,
/// 11px / 650 字重 / 34% 白)。
class GlassStatsRow extends StatelessWidget {
  final String speed;
  final String cacheRate;
  final String inputTokens;
  final String outputTokens;

  const GlassStatsRow({
    super.key,
    required this.speed,
    required this.cacheRate,
    required this.inputTokens,
    required this.outputTokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = EmberColors.of(context);
    final statColor = colors.statText;
    Widget stat(String l, String v) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$l ', style: TextStyle(fontSize: 11, color: statColor)),
        Text(v,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statColor)),
      ]);
    }

    Widget sep() => Text('·', style: TextStyle(fontSize: 11, color: statColor));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          stat('速度', speed),
          const SizedBox(width: 6),
          sep(),
          const SizedBox(width: 6),
          stat('缓存', cacheRate),
          const SizedBox(width: 6),
          sep(),
          const SizedBox(width: 6),
          stat('输入', inputTokens),
          const SizedBox(width: 6),
          sep(),
          const SizedBox(width: 6),
          stat('输出', outputTokens),
        ],
      ),
    );
  }
}
