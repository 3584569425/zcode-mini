import 'package:flutter_test/flutter_test.dart';
import 'package:zflow/ui/chat_page.dart';

void main() {
  group('思考档循环(官方 ThoughtLevelCycleControl 同款)', () {
    test('max → 列表下一档', () {
      expect(nextThoughtLevel(['max', 'high', 'nothink'], 'max'), 'high');
    });
    test('末档循环回首档', () {
      expect(nextThoughtLevel(['max', 'high', 'nothink'], 'nothink'), 'max');
    });
    test('当前档不在列表(如空)→ 回落首档', () {
      expect(nextThoughtLevel(['max', 'high'], ''), 'max');
      expect(nextThoughtLevel(['max', 'high'], 'turbo'), 'max');
    });
    test('空档位列表返回 null(调用方回落菜单)', () {
      expect(nextThoughtLevel([], 'max'), isNull);
    });
  });
}
