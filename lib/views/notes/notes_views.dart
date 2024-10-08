import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/main.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/services/crud/notes_services.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("main ui"),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldlogOut = await showlogOutDialog(context);
                    if (!mounted) return;
                    if (shouldlogOut) {
                      await AuthService.firebase().logOut();
                      if (!mounted) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginroute, (route) => false);
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                      value: MenuAction.logout, child: Text('logout')),
                  PopupMenuItem(child: Text("hello")),
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
            future: _notesService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  // print('User created or retrieved: ${snapshot.data}');
                  return StreamBuilder(
                      stream: _notesService.allnotes,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return const Text('waiting for notes');
                          default:
                            return const CircularProgressIndicator();
                        }
                      });
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}

Future<bool> showlogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sing Out'),
          content: const Text("Do You Want To Log Out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('no'),
            )
          ],
        );
      }).then((value) => value ?? false);
}
