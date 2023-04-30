import 'dart:async';

import 'package:diplom/logic/database/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diplom/logic/database/users.dart' as users;

class AuthenticationService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;
  late StreamSubscription? userAuthSub;

  AuthenticationService() {
    user = _auth.currentUser;
  }
  //notifyListeners();
  // userAuthSub = FirebaseAuth.instance.authStateChanges().listen((newUser) {
  //   if (newUser == null) {
  //     signUpAnon();
  //   } else {
  //     user = newUser;
  //     notifyListeners();
  //   }
  // }, onError: (e) {
  //   // ignore: avoid_print
  //   print('AuthProvider - FirebaseAuth - onAuthStateChanged - $e');
  // });

  @override
  void dispose() {
    if (userAuthSub != null) {
      userAuthSub!.cancel();
      userAuthSub = null;
    }
    super.dispose();
  }

  bool get isAuthenticated {
    // ignore: unnecessary_null_comparison
    return user != null;
  }

  String get uid {
    return user?.uid ?? '';
  }

  bool get isAnonymous {
    return user?.isAnonymous ?? true;
  }

  bool get isVerified {
    return user?.emailVerified ?? false;
  }

  Future<String> signIn(
      {String? email, String? password, String? nickname}) async {
    try {
      final uc = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email ?? '', password: password ?? '');
      users.User u = users.User(uid: uc.user!.uid, name: nickname ?? 'user');
      await DBService().setUser(u);
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
      final uc = await FirebaseAuth.instance.signInAnonymously();
      users.User u = users.User(uid: uc.user!.uid);
      await DBService().setUser(u);
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
    await signUpAnon();
  }
}
