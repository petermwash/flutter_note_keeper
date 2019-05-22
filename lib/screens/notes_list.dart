import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_note_keeper/screens/note_details.dart';
import 'package:flutter_note_keeper/utils/database_helper.dart';
import 'package:flutter_note_keeper/models/note.dart';

class NotesList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return NotesListState();
  }
}

class NotesListState extends State<NotesList> {
  var count = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> notesList;

  @override
  Widget build(BuildContext context) {

    if (notesList == null) {
      notesList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        backgroundColor: Colors.blueGrey,
      ),
      body: getNotesListView(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetails(Note("", "", 2), "Add Note");
          },
          tooltip: "Add Note",

        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNotesListView() {
    TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .subhead;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white70,
            elevation: 2.0,

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.notesList[position].priority),
                child: getPriorityIcon(this.notesList[position].priority),
              ),

              title: Text(this.notesList[position].title, style: titleStyle,),

              subtitle: Text(this.notesList[position].date),

              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey,),
                onTap: () {
                  _delete(context, this.notesList[position]
                  );
                  },
              ),

              onTap: () {
                navigateToDetails(notesList[position], "Edit Note");
              },
            ),
          );
        }
    );
  }

  //Return the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.deepPurple;
        break;
      case 2:
        return Colors.blue;
        break;
      default:
        return Colors.blue;
    }
  }
  //Return the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.arrow_right);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  //Deletes a Note item
  void _delete(BuildContext context, Note note) async {

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note Deleted Successfully");

      updateListView();
    }
  }

  void navigateToDetails(Note note, String screenTitle) async {
    bool result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return NoteDetails(note, screenTitle);
        }));

    if (result == true)
      updateListView();
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    dbFuture.then((database) {
      Future<List<Note>> notesListFuture = databaseHelper.getNoteList();
      notesListFuture.then((notesList) {
        setState(() {
          this.notesList = notesList;
          this.count = notesList.length;
        });
      });
    });
  }
}