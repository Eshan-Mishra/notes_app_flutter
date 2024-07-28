import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/crud/notes_services.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
//need to hold of this variable as every time a hot reload happens the build function is called and it creat a new instance

  DataBaseNote? _note;

//also going to hold notes service factory constructor to avoid calling it again again
  late final NotesService _notesService;
//also need to be in controll of text editing controller need to create a text field
// the user keep typing it will vertically expand and simuntaneously sync it with the cloud

  late final TextEditingController _textController;
  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  //this function will help to auto save the note and will be hooked to textcontroller
  //whenever the the text is updated it save the content
  void _textControllerListener() async {
    final note = _note;
    final text = _textController.text;
    if (note == null) return;
    await _notesService.updateNotes(
      note: note,
      text: text,
    );
  }

// The _setupTextcontrollerListner function is responsible for
// setting up the listener for the text controller. It first
// removes any existing listener to avoid multiple listeners being
// attached, which could lead to unexpected behavior. Then, it
// adds _textControllerListener as the new listener to the text
// controller. This ensures that every time the text in the
// controller changes, the _textControllerListener function is
// called to handle the update.

  void _setupTextcontrollerListner() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DataBaseNote> createNewNote() async {
    // Check if we have created a note, return the existing note
    final exixtingNote = _note;
    if (exixtingNote != null) {
      // print('Existing note found: $exixtingNote');
      return exixtingNote;
    }

    // If the note is not created, then create the note and return that note
    // Notes view created the new user in the database, we just need to use that and count as existing user in database

    // This isn't a safe way but we rather have the app crash instead of the user ending up on this without being a current user
    final currentUser = AuthService.firebase().currentUser!;
    // print('Current user: $currentUser');

    final email = currentUser.email!;
    // print('Current user email: $email');

    final owner = await _notesService.getUser(email: email);
    // print('Owner retrieved: $owner');

    final newNote = await _notesService.createNote(owner: owner);
    // print('New note created: $newNote');

    return newNote;
  }

//delete the note if its empty
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }
//if note is not empty run updateNote function in _noteservice

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      _notesService.updateNotes(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DataBaseNote?>(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DataBaseNote;
              _setupTextcontrollerListner();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
            default:
              return const CircularProgressIndicator();}
        },
      ),
    );
  }
}
