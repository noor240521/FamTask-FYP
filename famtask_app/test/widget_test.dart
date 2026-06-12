import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:famtask_app/main.dart';
import 'package:famtask_app/core/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const FamTaskApp(),
      ),
    );

    // Verify that the title or initial screen loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
