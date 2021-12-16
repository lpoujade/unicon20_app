import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unicon/main.dart';

void main() {

  testWidgets('Verify main title', (WidgetTester tester) async {
    await tester.pumpWidget(const UniconApp());
    expect(find.textContaining('Unicon'), findsOneWidget);
  });

  testWidgets('Search for app bar', (WidgetTester tester) async {
    await tester.pumpWidget(const UniconApp());
    expect(find.byType(AppBar), findsOneWidget);
  });
}
