import 'package:flutter/material.dart';
import 'package:flutter_note_keeper/screens/note_details.dart';
import 'package:flutter_note_keeper/screens/notes_list.dart';
import 'package:flutter_note_keeper/utils/database_helper.dart';
import 'package:test/test.dart';
import 'package:flutter_note_keeper/models/note.dart';

void main() {

  group("Testing the Note object", () {
    final note = Note.withId(1,"Title", "May 23 2019", 1, "My Note");

    test("Note object can be created", () {

      expect("Title", note.title);
      expect("May 23 2019", note.date);
      expect(1, note.priority);
      expect("My Note", note.description);

    });

    test("Note to Map and Map to Note", () {


      var noteMap = note.toMap();
      expect("{id: 1, title: Title, description: My Note, priority: 1, date: May 23 2019}", noteMap.toString());
      expect(["id", "title", "description", "priority", "date"], noteMap.keys);
      expect([1, "Title", "My Note", 1, "May 23 2019"], noteMap.values);

      var mNote = Note.fromMapObject(noteMap);
      expect("Instance of 'Note'", mNote.toString());

    });
  });

  group("Testing NotesListState logic", () {
    final noteListState = NotesListState();

    test("Get priority color", () {

      final color1 = noteListState.getPriorityColor(1);
      expect(Colors.deepPurple, color1);

      final color2 = noteListState.getPriorityColor(2);
      expect(Colors.blue, color2);
    });

    test("Get priority icon", () {

      final icon1 = noteListState.getPriorityIcon(1);
      expect(Icon(Icons.arrow_right).toString(), icon1.toString());

      final icon2 = noteListState.getPriorityIcon(2);
      expect(Icon(Icons.keyboard_arrow_right).toString(), icon2.toString());
    });
  });
  
  group("Testing NoteDetailsState logic", () {
    final notesDetailsState = NoteDetailsState(Note.withId(1,"Title", "May 23 2019", 1, "My Note"), "AppBar Title");
    
    test("Get priority as String", () {

      final priorityHigh = notesDetailsState.getPriorityAsString(1);
      expect("High", priorityHigh);

      final priorityLow = notesDetailsState.getPriorityAsString(2);
      expect("Low", priorityLow);
    });
  });

  group("Testing the DatabaseHelper logic", () {
    final dbHelper = DatabaseHelper();

    test("Instance of DatabaseHelper", () {

      expect("Instance of 'DatabaseHelper'", dbHelper.toString());
    });
  });
}