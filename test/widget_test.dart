import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_note_keeper/main.dart';

void main() {
  testWidgets("AppBartitle", (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    
    expect(find.text("Note Keeper"), findsNothing);
  });
}
