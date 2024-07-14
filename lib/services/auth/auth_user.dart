import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/widgets.dart';

@immutable
class AuthUser {
  final bool isEmailverified;
  const AuthUser({required this.isEmailverified});

  factory AuthUser.fromFirebase(User user) => AuthUser(isEmailverified:  user.emailVerified);
}
