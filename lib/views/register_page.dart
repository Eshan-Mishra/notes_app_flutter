// import 'dart:developer' as dev show log;
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_services.dart';
import 'package:notes/utilities/show_error_dialog.dart';

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
                // Make sure to await the createUser call
                await AuthService.firebase()
                    .createUser(email: email, password: password);
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verify_email);
              } on EmailAlreadyInUseAuthException {
                // Handle the email already in use exception
                await showErrordialogBox(context, 'Email already in use');
              } on GenericExceptions {
                // Handle other generic exceptions
                await showErrordialogBox(
                    context, 'An authentication error occurred');
              } catch (e) {
                // Handle any other exceptions that might occur
                await showErrordialogBox(
                    context, 'An unexpected error occurred');
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
