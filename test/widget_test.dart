import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylandy/injection_container.dart';
import 'package:mylandy/main.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    // Bootstrap the GetIt service locator exactly as main() does
    await initDependencies();

    await tester.pumpWidget(const MyLandyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
