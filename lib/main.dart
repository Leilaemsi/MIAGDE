import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/HomeScreen.dart';
import '../models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
      routes: {
        '/home': (context) => HomeScreen(
            user: ModalRoute.of(context)!.settings.arguments as UserModel),
      },
    );
  }
}
