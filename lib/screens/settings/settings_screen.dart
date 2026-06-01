import 'package:flutter/material.dart';
import 'package:runquest/services/auth_service.dart';
import 'package:runquest/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:runquest/services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _nickname;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedGender = 'Мужчина';
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _loadUserData() async {
    final data = await _firestoreService.getUserData();
    setState(() {
      _nickname = data['nickname'];
      _weightController.text = (data['weight'] ?? '').toString();
      _heightController.text = (data['height'] ?? '').toString();
      _selectedGender = data['gender'] ?? 'Мужчина';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF515151),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Ваши параметры',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _nickname == null ? 'Загрузка...' : '$_nickname',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 30),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Вес, кг',
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
              const SizedBox(height: 20),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Рост, см',
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
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                dropdownColor: const Color(0xFF8B8B8B),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
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
                items: const [
                  DropdownMenuItem(value: 'Мужчина', child: Text('Мужчина')),
                  DropdownMenuItem(value: 'Женщина', child: Text('Женщина')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFF8B8B8B),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final weight = double.tryParse(_weightController.text);
                  final height = double.tryParse(_heightController.text);
                  if (weight == null || height == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 5,
                          left: 20,
                          right: 20,
                        ),
                        content: Text('Введите корректные данные'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  await _firestoreService.saveUserData(
                    weight: weight,
                    height: height,
                    gender: _selectedGender,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Данные сохранены'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Сохранить параметры',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 150),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B8B8B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user?.email == null) {
                    return;
                  }
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: user!.email!,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Письмо отправлено')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text(
                  'Сменить пароль',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 180, 114, 110),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
