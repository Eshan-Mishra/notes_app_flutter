
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_services.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('verify email'),
      ),
      body: Column(
        children: [
          const Text("we've send you email for verification ,check your email"),
          const Text('if not recived click the button below'),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
                // log('send email to ${AuthService.firebase().currentUser}');
              },
              child: const Text("send email verification")),
          TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerroute,
                    (route) => false,
                  );
                } on UserNotLoggedIn {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginroute, (route) => false);
                }
              },
              child: const Text('restart'))
        ],
      ),
    );
  }
}
