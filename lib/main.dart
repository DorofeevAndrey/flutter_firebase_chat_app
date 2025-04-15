import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/firebase_options.dart';
import 'package:flutter_firebase_chat_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import 'services/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final Brightness platformBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(systemBrightness: platformBrightness),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
