import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landymaker/injection_container.dart';
import 'package:landymaker/main.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    // Bootstrap the GetIt service locator exactly as main() does
    await initDependencies();

    await tester.pumpWidget(const LandyMakerApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
