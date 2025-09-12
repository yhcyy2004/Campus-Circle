import 'package:campus_circle/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusCircleApp());
    await tester.pump();
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
