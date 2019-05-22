import 'dart:async';
import 'dart:io';

import 'package:flutter_note_keeper/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper
      _databaseHelper; //Singleton object of the DatabaseHelper
  static Database _database; //Singleton object of the Database

  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  DatabaseHelper._instance();

  /// Named constructor to create an instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) _databaseHelper = DatabaseHelper._instance();

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();

    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Getting the directory path for both Android and iOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = directory.path + "notes.db";

    // Open/Create the Database at a given path
    var notesDb = await openDatabase(dbPath, version: 1, onCreate: _createDb);
    return notesDb;
  }

  void _createDb(Database db, int dbVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  // Fetch operation: Get all the notes object from the database.
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery("SELECT * FROM $noteTable order by $colPriority ASC");
    var result = await db.query(noteTable, orderBy: "$colPriority ASC");

    return result;
  }

  // Insert operation: Insert a Note object to the database.
  Future<int> insertNote(Note note) async {
    Database db = await this.database;

//    var result = db.rawInsert(
//        "INSERT INTO $noteTable VALUES(${note.id}, ${note.title}, ${note
//            .description}, ${note.priority}, ${note.date})");
    var result = db.insert(noteTable, note.toMap());
    return result;
  }

  // Update operation: Update a Note object and save it to the database.
  Future<int> updateNote(Note note) async {
    Database db = await this.database;

//    var result = db.rawUpdate("UPDATE $noteTable SET ");
    var result = db.update(noteTable, note.toMap(),
        where: "$colId = ?", whereArgs: [note.id]);
    return result;
  }

  // Delete operation: Delete a Note object from the database.
  Future<int> deleteNote(int id) async {
    var db = await this.database;

    int result =
        await db.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
    return result;
  }

  //Get the number of Note objects in the database
  Future<int> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT * FROM $noteTable");
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Gets the 'Map List' [ List<Map> ] fro db and converts it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from the database
    int count = noteMapList.length; // Count the number of map entries in the database table

    List<Note> notesList = List<Note>();
    // Using a 'For Loop' to create a 'Note List' from a 'Map List'
    for (int i =0; i < count; i++) {
      notesList.add(Note.fromMapObject(noteMapList[i]));
    }

    return notesList;
  }
}
