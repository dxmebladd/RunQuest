import 'package:flutter/material.dart';
import 'package:runquest/services/auth_service.dart';
import 'package:runquest/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF515151),
      body: Align(
        alignment: Alignment.bottomCenter,

        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),

          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 114, 110),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),

            onPressed: () async {
              await _authService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },

            icon: const Icon(Icons.logout),

            label: const Text(
              'Выйти из аккаунта',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
