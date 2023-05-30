import 'package:diplom/logic/list_provider.dart';
import 'package:diplom/logic/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/map_provider.dart';
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
        ChangeNotifierProvider(
          create: (context) => ListModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthenticationService(),
        ),
        StreamProvider(
          create: (context) => InternetConnectionChecker().onStatusChange,
          initialData: InternetConnectionStatus.connected,
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'EcoStep',
          debugShowCheckedModeBanner: false,
          theme: Provider.of<ThemeProvider>(context).theme,
          home: const HomePage(),
        );
      },
    );
  }
}
