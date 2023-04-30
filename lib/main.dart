import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/providers.dart';
import 'package:diplom/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (!AuthenticationService().isAuthenticated) {
    await AuthenticationService().signUpAnon();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MapModel(),
        ),
        StreamProvider(
          create: (context) => InternetConnectionChecker().onStatusChange,
          initialData: InternetConnectionStatus.connected,
        )
      ],
      child: MaterialApp(
        title: 'EcoStep',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
