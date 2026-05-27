import 'package:flutter/material.dart';
import 'package:runquest/screens/main/main_screen.dart';
import 'package:runquest/services/auth_service.dart';
import 'package:runquest/services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _showPasswordError = false;

  bool _obscurePassword = true;

  void register() {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final nickname = _nicknameController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF515151),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 5),
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Имя',
                  filled: true,
                  fillColor: const Color(0xFF8B8B8B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Почта',
                  filled: true,
                  fillColor: const Color(0xFF8B8B8B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                onChanged: (value) {
                  setState(() {
                    _showPasswordError = value.isNotEmpty && value.length < 6;
                  });
                },
                obscureText: _obscurePassword,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  filled: true,
                  fillColor: const Color(0xFF8B8B8B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (_showPasswordError)
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Пароль должен содержать минимум 6 символов',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              TextField(
                controller: _nicknameController,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Никнейм',
                  filled: true,
                  fillColor: const Color(0xFF8B8B8B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: 350,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B8B8B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final name = _nameController.text.trim();
                    final nickname = _nicknameController.text.trim();
                    if (email.isEmpty ||
                        password.isEmpty ||
                        name.isEmpty ||
                        nickname.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Заполните все поля',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final error = await _authService.register(
                      email: email,
                      password: password,
                    );
                    if (error == null) {
                      try {
                        await _firestoreService.createUser(
                          name: name,
                          nickname: nickname,
                          email: email,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
