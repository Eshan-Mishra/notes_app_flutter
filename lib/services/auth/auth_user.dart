import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/widgets.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailverified;
  const AuthUser({
    required this.isEmailverified,
    required this.email,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailverified: user.emailVerified,
        email : user.email,
      );
}
