import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/views/login_page.dart';
import 'package:notes/views/register_page.dart';
import 'package:notes/views/verify_email.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(103, 58, 183, 1)),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginroute: (context) => const LoginPage(),
      registerroute: (context) => const Registre(),
      notesroute: (context) => const NotesView(),
      verify_email:(context) => const VerifyEmailView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              }
            } else {
              return const VerifyEmailView();
            }
            return const LoginPage();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("main ui"),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldlogOut = await showlogOutDialog(context);
                  if (!mounted) return;
                if (shouldlogOut) {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginroute, (route) => false);
                }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: MenuAction.logout, child: Text('logout'))
              ];
            },
          )
        ],
      ),
      body: const Text("hello world"),
    );
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
