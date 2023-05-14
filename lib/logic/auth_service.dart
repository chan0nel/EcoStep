// ignore_for_file: avoid_init_to_null, unused_local_variable

import 'dart:async';

import 'package:diplom/logic/database/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/logic/database/users.dart' as users;

class AuthenticationService extends ChangeNotifier {
  late User? user = FirebaseAuth.instance.currentUser;
  late StreamSubscription? userAuthSub;
  Future<users.User> get my => user!.isAnonymous
      ? Future(() => users.User(uid: 'anonymous'))
      : DBService().getUser(uid);

  Stream<User?> get stream => FirebaseAuth.instance.userChanges();

  AuthenticationService() {
    FirebaseAuth.instance.userChanges().listen((newUser) {
      if (newUser == null) {
        return;
      } else {
        user = newUser;
        notifyListeners();
      }
    }, onError: (e) {
      // ignore: avoid_print
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

  bool get isAuthenticated {
    return user != null;
  }

  String get uid {
    return user?.uid ?? 'unknown';
  }

  bool get isAnonymous {
    return user?.isAnonymous ?? true;
  }

  bool get isVerified {
    return user?.emailVerified ?? false;
  }

  Future<String> signIn({String? email, String? password}) async {
    try {
      if (isAnonymous) await FirebaseAuth.instance.currentUser!.delete();
      final uc = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email ?? '', password: password ?? '');
      return 'Добро пожаловать, ';
    } on FirebaseAuthException catch (e) {
      signUpAnon();
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

  Future<String> signUp(
      {String? email, String? password, String? nickname}) async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        if (FirebaseAuth.instance.currentUser!.isAnonymous) {
          final credential = EmailAuthProvider.credential(
              email: email ?? '', password: password ?? '');
          final uc = await FirebaseAuth.instance.currentUser
              ?.linkWithCredential(credential);
          users.User u =
              users.User(uid: uc?.user?.uid ?? '', name: nickname ?? 'user');
          await DBService().setUser(u);
        }
      } else {
        final uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email ?? '', password: password ?? '');
        users.User u = users.User(uid: uc.user!.uid, name: nickname ?? 'user');
        await DBService().setUser(u);
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

  Future<String?> signUpAnon() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> resetPass({String? email = null}) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email ?? user!.email ?? '');
      await user?.reload();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> verificate() async {
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      await user!.reload();
    }
  }

  Future<void> signOut() async {
    if (FirebaseAuth.instance.currentUser!.isAnonymous) {
      await FirebaseAuth.instance.currentUser!.delete();
    }
    await FirebaseAuth.instance.signOut();
    await signUpAnon();
  }
}
