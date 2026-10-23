import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cyberencrypt_flutter/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberEncryptApp());
    await tester.pump();

    // Just confirms the app builds and renders — replace with real
    // assertions later once you want actual test coverage.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}