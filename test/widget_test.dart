import 'package:flutter/material.dart';
import 'package:flutter_note_keeper/models/note.dart';
import 'package:flutter_note_keeper/screens/note_details.dart';
import 'package:flutter_note_keeper/screens/notes_list.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_note_keeper/main.dart';

void main() {
  group("Testing Noteslist Widgets", () {
    testWidgets("AppBartitle is displayed", (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());

      expect(find.text("My Notes"), findsOneWidget);
    });

    testWidgets("Add FAB is displayed", (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());

        expect(find.byIcon(Icons.add), findsOneWidget);

    });

  });
}
