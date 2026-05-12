import 'package:flutter/material.dart';
import 'package:runquest/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:runquest/services/run_logik.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RunLogik())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Berlin'),
        home: const LoginScreen(),
      ),
    );
  }
}
