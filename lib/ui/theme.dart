import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Design tokens + theme controller (dark / light / system, persisted).
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'zflow_theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
        _ => 'dark',
      },
    );
  }
}

/// 全局主题:GPT Mini 设计语言(mini-ref 复刻稿)的 token 化移植。
/// 深色为设计基准(近黑 #0D0D0D + 冷白字 + 蓝/黄/绿点缀),浅色为中性
/// zinc 推导。slot → token 映射:
///   primary / onPrimary              = mini 蓝 / 深墨字
///   secondary 三槽                   = primary / raise / textSolid
///     (SegmentedButton、ChoiceChip、FilledButton.tonal 选中态取用)
///   surface、surfaceContainerHighest = card(浮层、卡片、输入框同一面)
///   onSurface / onSurfaceVariant     = textSolid / textMuted
///   outline                          = hairline;scaffold 底色 = bg
ThemeData buildDarkTheme() {
  const c = EmberColors.dark();
  final scheme = ColorScheme.dark(
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.primary,
    secondaryContainer: c.raise,
    onSecondaryContainer: c.textSolid,
    error: c.err,
    surface: c.card,
    surfaceContainerHighest: c.card,
    onSurface: c.textSolid,
    onSurfaceVariant: c.textMuted,
    outline: c.hairline,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: EmberFonts.ui,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: EmberFonts.ui,
        color: c.textSolid,
      ),
      iconTheme: IconThemeData(color: c.textSoft),
    ),
    cardTheme: CardThemeData(
      color: c.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.hairline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      hintStyle: TextStyle(
          color: c.textFaint, fontSize: 14, fontFamily: EmberFonts.ui),
    ),
    dividerTheme: DividerThemeData(
      color: c.hairline,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.raise,
      contentTextStyle:
          TextStyle(color: c.textSolid, fontFamily: EmberFonts.ui),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: c.primary,
      unselectedLabelColor: c.textFaint,
      indicatorColor: c.primary,
      dividerColor: c.hairline,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.card,
      indicatorColor: c.primary.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: EmberType.caption,
          fontFamily: EmberFonts.ui,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: c.textSolid, fontSize: 14, height: 1.5),
      bodySmall: TextStyle(color: c.textMuted, fontSize: 12, height: 1.4),
      titleMedium: TextStyle(
          color: c.textSolid, fontSize: 15, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(color: c.textFaint, fontSize: 11),
    ),
  );
}

/// 浅色主题:同一套映射(见 [buildDarkTheme] 注释),中性 zinc 推导。
ThemeData buildLightTheme() {
  const c = EmberColors.light();
  final scheme = ColorScheme.light(
    primary: c.primary,
    onPrimary: Colors.white,
    secondary: c.primary,
    secondaryContainer: c.raise,
    onSecondaryContainer: c.textSolid,
    error: c.err,
    surface: c.card,
    surfaceContainerHighest: c.card,
    onSurface: c.textSolid,
    onSurfaceVariant: c.textMuted,
    outline: c.hairline,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: EmberFonts.ui,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: EmberFonts.ui,
        color: c.textSolid,
      ),
      iconTheme: IconThemeData(color: c.textMuted),
    ),
    cardTheme: CardThemeData(
      color: c.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.hairline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      hintStyle: TextStyle(
          color: c.textFaint, fontSize: 14, fontFamily: EmberFonts.ui),
    ),
    dividerTheme: DividerThemeData(
      color: c.hairline,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.raise,
      contentTextStyle:
          TextStyle(color: c.textSolid, fontFamily: EmberFonts.ui),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: c.primary,
      unselectedLabelColor: c.textFaint,
      indicatorColor: c.primary,
      dividerColor: c.hairline,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.card,
      indicatorColor: c.primary.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: EmberType.caption,
          fontFamily: EmberFonts.ui,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? c.primary
              : c.textMuted,
        ),
      ),
    ),
  );
}

/// Provides the app-wide [ThemeController] down the tree.
class ThemeControllerProvider extends InheritedWidget {
  final ThemeController controller;

  const ThemeControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static ThemeController? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ThemeControllerProvider>()
      ?.controller;

  @override
  bool updateShouldNotify(ThemeControllerProvider oldWidget) =>
      controller != oldWidget.controller;
}

/// 设计色板单一来源——GPT Mini 设计语言(mini-ref/mini 复刻稿 CSS 变量
/// 直译)。全部界面统一经此类取色;类名沿用 EmberColors,避免全库改名。
class EmberColors {
  final bool isDark;
  const EmberColors._(this.isDark);
  const EmberColors.dark() : this._(true);
  const EmberColors.light() : this._(false);

  static EmberColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const EmberColors.light()
          : const EmberColors.dark();

  // 暗色(设计基准,mini :root 直译)
  static const _dBg = Color(0xFF0D0D0D);        // --bg
  static const _dCard = Color(0xFF171717);      // --panel
  static const _dRaise = Color(0xFF242424);     // --panel-2
  static const _dHairline = Color(0x17FFFFFF);  // --line rgba(255,255,255,.09)
  static const _dSolid = Color(0xFFF4F4F5);     // --text
  static const _dSoft = Color(0xFFD4D4D8);
  static const _dMuted = Color(0xFFA1A1AA);     // --muted
  // AA:faint 由 mini #71717A 提亮至 #7D7D86,on bg(#0D0D0D) ≥ 4.5:1。
  static const _dFaint = Color(0xFF7D7D86);

  // 浅色(中性 zinc 推导)
  static const _lBg = Color(0xFFF4F4F5);
  static const _lCard = Color(0xFFFFFFFF);
  static const _lRaise = Color(0xFFE4E4E7);
  static const _lHairline = Color(0x1A000000);
  static const _lSolid = Color(0xFF18181B);
  static const _lSoft = Color(0xFF3F3F46);
  static const _lMuted = Color(0xFF52525B);
  // AA:on bg(#F4F4F5) ≥ 4.5:1(实测 4.63)。
  static const _lFaint = Color(0xFF6E6E77);

  Color get bg => isDark ? _dBg : _lBg;
  Color get card => isDark ? _dCard : _lCard;
  Color get raise => isDark ? _dRaise : _lRaise;
  Color get hairline => isDark ? _dHairline : _lHairline;
  Color get primary => isDark ? const Color(0xFF9ECBFF) : const Color(0xFF2563EB);
  // 深色主题主色为 mini 蓝,配深墨字保对比(白字不足 4.5:1)。
  Color get onPrimary => isDark ? const Color(0xFF0B2540) : Colors.white;
  Color get ok => isDark ? const Color(0xFF8EF0B7) : const Color(0xFF2E7D4F);
  Color get err => isDark ? const Color(0xFFFF7A76) : const Color(0xFFC53035);
  Color get warn => isDark ? const Color(0xFFFFD68A) : const Color(0xFFA8851F);
  Color get run => isDark ? const Color(0xFF9ECBFF) : const Color(0xFF4A7BB5);
  Color get textSolid => isDark ? _dSolid : _lSolid;
  Color get textSoft => isDark ? _dSoft : _lSoft;
  Color get textMuted => isDark ? _dMuted : _lMuted;
  Color get textFaint => isDark ? _dFaint : _lFaint;

  // ---- mini 专属点缀色 ----

  /// 模型徽章黄(mini --yellow #FFD447)。
  Color get accentYellow =>
      isDark ? const Color(0xFFFFD447) : const Color(0xFFA16207);

  /// 模式/排队橙(mini --orange #FF9D45)。
  Color get accentOrange =>
      isDark ? const Color(0xFFFF9D45) : const Color(0xFFEA580C);

  /// 运行状态呼吸点(mini --green-status / .title-dot #5CFFA8)。
  Color get statusDot =>
      isDark ? const Color(0xFF5CFFA8) : const Color(0xFF16A34A);

  /// 用户气泡底(mini --user-bubble #2F2F2F)。
  Color get bubbleUser => isDark ? const Color(0xFF2F2F2F) : _lRaise;

  /// 玻璃描边(mini --glass-border 白 .1 / 浅色黑 .08)。
  Color get borderGlass =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0x14000000);

  /// 输入区统计行文字(mini composer-stats 34% 白)。
  Color get statText =>
      isDark ? const Color(0x57F4F4F5) : const Color(0x73000000);

  /// 玻璃行底(mini --glass-row-bg 白 .032)。
  Color get glassRow =>
      isDark ? const Color(0x08FFFFFF) : const Color(0x08000000);

  /// 当前行高亮(mini thread.is-current 白 .09)。
  Color get rowCurrent =>
      isDark ? const Color(0x17FFFFFF) : _lRaise;

  // 代码面:markdown 代码块、diff 容器、工具输出共用同一“代码表面”。
  // mini:行内 code 芯片 #242424 无边框,文本同正文色。
  Color get codeBlockBg => isDark ? _dRaise : const Color(0xFFECECEE);
  Color get codeInlineBg => isDark ? _dRaise : const Color(0xFFECECEE);
  Color get codeText => isDark ? _dSolid : _lSolid;
}

/// 圆角双轨:内容区大圆角、控制区胶囊(999 由各组件显式使用)。
abstract final class EmberRadius {
  static const content = 16.0;   // 气泡/卡片
  static const bubbleTail = 4.0; // 气泡尾角
  static const sheet = 20.0;     // sheet 顶部
  static const control = 10.0;   // 任务卡/设置行组/按钮
  static const avatar = 8.0;     // 缩略图/头像
  static const pill = 999.0;     // mini 胶囊(顶栏/输入区/徽章)
}

/// 4px 网格间距。
abstract final class EmberSpacing {
  static const page = 16.0;
  static const cardPad = 12.0;
  static const listItemH = 12.0;
  static const listItemV = 8.0;
  static const gapS = 8.0;
  static const gapM = 12.0;
}

/// 六档字阶 + 行高。
abstract final class EmberType {
  static const title = 22.0;
  static const section = 17.0;
  static const emphasis = 15.0;
  static const body = 13.0;
  static const secondary = 12.0;
  static const caption = 11.0;
  static const lineHeight = 1.5;
}

/// 字体族单一来源:UI 正文用 Sarasa UI,等宽/代码用 Sarasa Term。
abstract final class EmberFonts {
  static const ui = 'Sarasa UI SC';
  static const term = 'Sarasa Term SC';
}
