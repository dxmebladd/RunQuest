import 'package:flutter/material.dart';
import 'package:runquest/screens/home/home_screen.dart';
import 'package:runquest/screens/tasks/tasks_screen.dart';
import 'package:runquest/screens/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFFCECECE),
          selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          unselectedItemColor: const Color.fromARGB(136, 75, 75, 75),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: 'Бег',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt),
              label: 'Задачи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
