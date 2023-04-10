import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EcoStep',
      home: MyHomePage(),
    );
  }
}
