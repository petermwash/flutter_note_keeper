import 'package:flutter/material.dart';
import 'package:flutter_note_keeper/models/note.dart';
import 'package:flutter_note_keeper/utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note, this.appBarTitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  var _formKey = GlobalKey<FormState>();
  var _priorities = ["High", "Low"];

  DatabaseHelper dbHelper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  Note note;

  NoteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          ///Here we control navigation when the user click the back button on their device
          navigateToPreviousScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: GestureDetector(
                child: Icon(Icons.arrow_back),
                onTap: () {
                  ///Here we control the navigation using the back icon on the appBar
                  navigateToPreviousScreen();
                }),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 5),
                child: GestureDetector(
                  child: Icon(Icons.delete),
                  onTap: () {
                    setState(() {
                      _delete();
                    });
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_formKey.currentState.validate())
                  navigateToPreviousScreen();
              });
            },
            child: Icon(Icons.save),
            tooltip: "Save the note",
          ),
          body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: ListView(
                  children: <Widget>[
                    // First element
                    ListTile(
                      title: DropdownButton(
                          items: _priorities.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          style: textStyle,
                          value: getPriorityAsString(note.priority),
                          onChanged: (valueSelectedByUser) {
                            setState(() {
                              onDropDownItemSelected(valueSelectedByUser);
                            });
                          }),
                    ),

                    // Second Element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (String value) {
                          if (value.isEmpty) return "Title cannot be empty";
                        },
                        style: textStyle,
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    // Third Element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: descriptionController,
                        maxLines: null,
                        style: textStyle,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Description cannot be empty!";
                          }
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: InputBorder.none
//                            (
//                              borderRadius: BorderRadius.circular(5.0))
                            ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  void onDropDownItemSelected(String newItemSelected) {
    setState(() {
      updatePriorityAsInt(newItemSelected);
    });
  }

  void navigateToPreviousScreen() {
    if (titleController.text.isNotEmpty) {
      _save();
    }
    Navigator.pop(context, true);
  }

  // Converting the String priority in the form of integer before sending it to the db
  void updatePriorityAsInt(String priority) {
    switch (priority) {
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority = 2;
        break;
    }
  }

  // Converting the int priority in the form of String and display it to user in DropDown button
  String getPriorityAsString(int priority) {
    String _priority;

    switch (priority) {
      case 1:
        _priority = _priorities[0]; // High
        break;
      case 2:
        _priority = _priorities[1]; // Low
        break;
    }

    return _priority;
  }

  // Update the title and the description of Note object
  void updateNote() {
    note.title = titleController.text;
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    updateNote();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;

    if (note.id != null) {
      // Case 1: Update operation
      result = await dbHelper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await dbHelper.insertNote(note);
    }

    if (result != 0) {
      // Success
      Fluttertoast.showToast(msg: "Note Saved");
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    Navigator.pop(context, true);

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'Nothing to Delete');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await dbHelper.deleteNote(note.id);
    if (result != 0) {
      // Success
      Fluttertoast.showToast(
        msg: "Note Deleted",
        timeInSecForIos: 3,
      );
    } else {
      // Failure
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
