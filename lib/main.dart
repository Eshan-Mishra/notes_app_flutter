// import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/views/login_page.dart';
import 'package:notes/views/notes_views.dart';
import 'package:notes/views/register_page.dart';
import 'package:notes/views/verify_email.dart';
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
      future: AuthService.firebase().intialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailverified) {
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


