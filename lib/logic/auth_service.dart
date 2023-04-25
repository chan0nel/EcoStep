import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService with ChangeNotifier {
  late User user;
  late StreamSubscription? userAuthSub;

  AuthenticationService() {
    userAuthSub = FirebaseAuth.instance.authStateChanges().listen((newUser) {
      print('AuthProvider - FirebaseAuth - onAuthStateChanged - $newUser');
      if (newUser == null) throw Exception();
      user = newUser;
      notifyListeners();
    }, onError: (e) {
      print('AuthProvider - FirebaseAuth - onAuthStateChanged - $e');
    });
  }

  @override
  void dispose() {
    if (userAuthSub != null) {
      userAuthSub!.cancel();
      userAuthSub = null;
    }
    super.dispose();
  }

  bool get isAnonymous {
    return user.isAnonymous;
  }

  bool get isVerified {
    return user.emailVerified;
  }

  bool get isAuthenticated {
    return user != null;
  }

  Future<String> signIn({String? email, String? password}) async {
    try {
      final uc = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email ?? '', password: password ?? '');
      return 'Добро пожаловать, ${uc.additionalUserInfo?.profile?['nickname']}';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Пользователь не найден';
        case 'invalid-email':
          return 'Неккоректная почта';
        case 'wrong-password':
          return 'Неверный пароль';
        default:
          return 'Неизвестная ошибка';
      }
    }
  }

  Future<String> signUp({String? email, String? password}) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        if (FirebaseAuth.instance.currentUser!.isAnonymous) {
          final credential = EmailAuthProvider.credential(
              email: email ?? '', password: password ?? '');
          //await FirebaseAuth.instance.currentUser!.delete();
          await FirebaseAuth.instance.currentUser
              ?.linkWithCredential(credential);
        }
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email ?? '', password: password ?? '');
      }
      return 'Не забудь подтвердить почту: $email';
    } on FirebaseAuthException catch (e) {
      switch (e.code.toLowerCase()) {
        case 'weak-password':
          return 'Слабый пароль';
        case 'invalid-email':
          return 'Неккоректная почта';
        case 'email-already-in-use':
          return 'Пользователь с данной почтой уже зарегистрирован';
        case 'provider-already-linked':
          return 'Провайдер уже подключен';
        case 'invalid-credential':
          return 'Некорректный токен';
        case 'credential-already-in-use':
          return 'Уже подключен';
        default:
          return 'Неизвестная ошибка';
      }
    }
  }

  Future<void> updateInfo({String? nickname, String? photo}) async {
    if (nickname != null) {
      await FirebaseAuth.instance.currentUser!.updateDisplayName(nickname);
    }
    if (photo != null) {
      await FirebaseAuth.instance.currentUser!.updatePhotoURL(photo);
    }
  }

  Future<String?> signUpAnon() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> verificate() async {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      FirebaseAuth.instance.currentUser!.reload();
    }
  }

  Future<void> signOut() async {
    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
      await FirebaseAuth.instance.currentUser!.delete();
    }
    await FirebaseAuth.instance.signOut();
  }
}
