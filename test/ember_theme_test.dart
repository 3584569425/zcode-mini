// test/ember_theme_test.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zflow/ui/markdown_view.dart';
import 'package:zflow/ui/theme.dart';

void main() {
  // WCAG 相对亮度与对比度(仅测试用,校验 AA 下限)。Color.r/g/b 为
  // 0..1 的 sRGB 分量。
  double luminance(Color c) {
    double ch(double v) =>
        v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
  }

  group('EmberColors', () {
    test('dark palette matches GPT Mini spec', () {
      final c = EmberColors.dark();
      expect(c.bg, const Color(0xFF0D0D0D));
      expect(c.card, const Color(0xFF171717));
      expect(c.raise, const Color(0xFF242424));
      expect(c.hairline, const Color(0x17FFFFFF));
      expect(c.primary, const Color(0xFF9ECBFF));
      expect(c.onPrimary, const Color(0xFF0B2540));
      expect(c.ok, const Color(0xFF8EF0B7));
      expect(c.err, const Color(0xFFFF7A76));
      expect(c.warn, const Color(0xFFFFD68A));
      expect(c.run, const Color(0xFF9ECBFF));
      expect(c.textSolid, const Color(0xFFF4F4F5));
      expect(c.textSoft, const Color(0xFFD4D4D8));
      expect(c.textMuted, const Color(0xFFA1A1AA));
      expect(c.textFaint, const Color(0xFF7D7D86));
      expect(c.accentYellow, const Color(0xFFFFD447));
      expect(c.accentOrange, const Color(0xFFFF9D45));
      expect(c.statusDot, const Color(0xFF5CFFA8));
      expect(c.bubbleUser, const Color(0xFF2F2F2F));
      expect(c.isDark, isTrue);
    });

    test('light palette matches zinc spec', () {
      final c = EmberColors.light();
      expect(c.bg, const Color(0xFFF4F4F5));
      expect(c.card, const Color(0xFFFFFFFF));
      expect(c.raise, const Color(0xFFE4E4E7));
      expect(c.primary, const Color(0xFF2563EB));
      expect(c.textSolid, const Color(0xFF18181B));
      expect(c.textSoft, const Color(0xFF3F3F46));
      expect(c.textMuted, const Color(0xFF52525B));
      expect(c.textFaint, const Color(0xFF6E6E77));
      expect(c.isDark, isFalse);
    });

    test('AA contrast: light primary on white, faints on bg ≥ 4.5:1', () {
      final light = EmberColors.light();
      final dark = EmberColors.dark();
      // 白字 onPrimary(spec §2:主色白字下限)。
      expect(
          contrast(const Color(0xFFFFFFFF), light.primary), greaterThanOrEqualTo(4.5));
      // 文字最浅档 on bg(spec §2:辅助信息可读下限)。
      expect(contrast(light.textFaint, light.bg), greaterThanOrEqualTo(4.5));
      expect(contrast(dark.textFaint, dark.bg), greaterThanOrEqualTo(4.5));
    });

    testWidgets('EmberColors.of follows theme brightness', (tester) async {
      late EmberColors captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              captured = EmberColors.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured.bg, const Color(0xFFF4F4F5));
    });
  });

  group('Ember tokens', () {
    test('radius dual-track matches spec', () {
      expect(EmberRadius.content, 16.0);
      expect(EmberRadius.bubbleTail, 4.0);
      expect(EmberRadius.sheet, 20.0);
      expect(EmberRadius.control, 10.0);
      expect(EmberRadius.avatar, 8.0);
    });

    test('spacing grid is 4px-aligned', () {
      expect(EmberSpacing.page, 16.0);
      expect(EmberSpacing.cardPad, 12.0);
      expect(EmberSpacing.gapS, 8.0);
      expect(EmberSpacing.gapM, 12.0);
      for (final v in [EmberSpacing.page, EmberSpacing.cardPad,
        EmberSpacing.listItemV, EmberSpacing.listItemH,
        EmberSpacing.gapS, EmberSpacing.gapM]) {
        expect(v % 4, 0, reason: '4px 网格对齐');
      }
    });

    test('type scale matches spec', () {
      expect(EmberType.title, 22.0);
      expect(EmberType.section, 17.0);
      expect(EmberType.emphasis, 15.0);
      expect(EmberType.body, 13.0);
      expect(EmberType.secondary, 12.0);
      expect(EmberType.caption, 11.0);
    });
  });

  group('global theme wired to Ember', () {
    test('dark theme colorScheme/scaffold come from EmberColors', () {
      final theme = buildDarkTheme();
      final c = EmberColors.dark();
      expect(theme.colorScheme.primary, c.primary);
      expect(theme.colorScheme.onPrimary, c.onPrimary);
      // secondary 三槽不落 SDK 默认(硬编码青),选中态走 Ember。
      expect(theme.colorScheme.secondary, c.primary);
      expect(theme.colorScheme.secondaryContainer, c.raise);
      expect(theme.colorScheme.onSecondaryContainer, c.textSolid);
      expect(theme.colorScheme.error, c.err);
      expect(theme.colorScheme.surface, c.card);
      expect(theme.colorScheme.surfaceContainerHighest, c.card);
      expect(theme.colorScheme.outline, c.hairline);
      expect(theme.scaffoldBackgroundColor, c.bg);
    });

    test('light theme colorScheme/scaffold come from EmberColors', () {
      final theme = buildLightTheme();
      final c = EmberColors.light();
      expect(theme.colorScheme.primary, c.primary);
      expect(theme.colorScheme.secondary, c.primary);
      expect(theme.colorScheme.secondaryContainer, c.raise);
      expect(theme.colorScheme.onSecondaryContainer, c.textSolid);
      expect(theme.colorScheme.error, c.err);
      expect(theme.colorScheme.surface, c.card);
      expect(theme.colorScheme.surfaceContainerHighest, c.card);
      expect(theme.colorScheme.outline, c.hairline);
      expect(theme.scaffoldBackgroundColor, c.bg);
    });

    test('divider theme follows hairline in both themes', () {
      for (final (themeData, c) in [
        (buildDarkTheme(), EmberColors.dark()),
        (buildLightTheme(), EmberColors.light()),
      ]) {
        expect(themeData.dividerTheme.color, c.hairline);
      }
    });

    testWidgets('markdown body ink follows Ember textSolid', (tester) async {
      for (final themeData in [buildDarkTheme(), buildLightTheme()]) {
        await tester.pumpWidget(MaterialApp(
          theme: themeData,
          home: const ZflowMarkdown('hello'),
        ));
        final p = tester
            .widget<MarkdownBody>(find.byType(MarkdownBody))
            .styleSheet!
            .p!;
        expect(p.color, EmberColors.of(tester.element(find.byType(MarkdownBody))).textSolid);
      }
    });
  });

  testWidgets('app theme uses Sarasa UI family', (tester) async {
    for (final themeData in [buildDarkTheme(), buildLightTheme()]) {
      late ThemeData theme;
      await tester.pumpWidget(MaterialApp(
        theme: themeData,
        home: Builder(builder: (context) {
          theme = Theme.of(context);
          return const SizedBox.shrink();
        }),
      ));
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Sarasa UI SC');
      expect(theme.appBarTheme.titleTextStyle!.fontFamily, 'Sarasa UI SC');
    }
  });
}
