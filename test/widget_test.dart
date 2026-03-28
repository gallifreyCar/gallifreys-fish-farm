import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gallifreys_fish_farm/main.dart';

void main() {
  testWidgets('game shell renders with provider scope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('金币'), findsOneWidget);
    expect(find.text('钓鱼'), findsOneWidget);
    expect(find.text('战斗'), findsOneWidget);
  });
}
