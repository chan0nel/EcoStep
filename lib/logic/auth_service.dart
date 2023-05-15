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

  Future<bool> signIn({String? email, String? password}) async {
    try {
      if (isAnonymous) await FirebaseAuth.instance.currentUser!.delete();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email ?? '', password: password ?? '');
      return true;
    } on FirebaseAuthException catch (e) {
      signUpAnon();
      return false;
    }
  }

  Future<bool> signUp(
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
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
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

  Future<bool> resetPass({String? email = null}) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email ?? user!.email ?? '');
      await user?.reload();
      return true;
    } catch (e) {
      return false;
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
