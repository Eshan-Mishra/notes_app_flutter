import 'dart:developer' as dev show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';

class Registre extends StatefulWidget {
  const Registre({super.key});

  @override
  State<Registre> createState() => _RegistreState();
}

class _RegistreState extends State<Registre> {
  late TextEditingController _email;
  late TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void deactivate() {
    _email.dispose();
    _password.dispose();

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(hintText: "Email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                 FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
              } on FirebaseAuthException catch (e) {
                dev.log(e.code);
              }
            },
            child: const Text("register"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginroute, (route) => false);
              },
              child: const Text('already registered? login.'))
        ],
      ),
    );
  }
}
