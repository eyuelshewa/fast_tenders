import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fast_tenders/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TenderWinApp()));

    // Verify that the app renders the bottom navigation bar with "Tenders"
    expect(find.text('Tenders'), findsOneWidget);
    expect(find.text('CPO Calc'), findsOneWidget);
  });
}