import 'package:flutter/material.dart';
import 'package:runquest/screens/history/histore_screen.dart';
import 'package:runquest/services/firestore_service.dart';
import 'package:flutter/services.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  double _caloriesGoal = 0;
  double _goal = 0;
  double _currentDistance = 0;
  double _weight = 70;
  String _gender = 'Мужчина';
  double get _currentCalories {
    if (_gender == 'Женщина') {
      return _currentDistance * _weight * 0.9;
    }
    return _currentDistance * _weight * 1.036;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadGoal();
    _loadCaloriesGoal();
    _loadLastDistance();
  }

  Future<void> _loadUserData() async {
    final data = await _firestoreService.getUserData();
    setState(() {
      _weight = (data['weight'] ?? 70).toDouble();
      _gender = data['gender'] ?? 'Мужчина';
    });
  }

  Future<void> _loadGoal() async {
    final goal = await _firestoreService.getGoal();
    setState(() {
      _goal = goal;
    });
  }

  Future<void> _loadLastDistance() async {
    final distance = await _firestoreService.getLastDistance();
    setState(() {
      _currentDistance = distance;
    });
  }

  Future<void> _loadCaloriesGoal() async {
    final caloriesGoal = await _firestoreService.getCaloriesGoal();
    setState(() {
      _caloriesGoal = caloriesGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _currentDistance >= _goal && _goal > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF515151),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B8B8B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текущая цель',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_currentDistance.toStringAsFixed(2)} / ${_goal.toStringAsFixed(2)} км',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _goal > 0 && _currentDistance >= _goal
                            ? Icons.check
                            : Icons.close,
                        color: _goal > 0 && _currentDistance >= _goal
                            ? Colors.green
                            : Colors.red,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_currentCalories.toStringAsFixed(0)} / ${_caloriesGoal.toStringAsFixed(0)} ккал',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _caloriesGoal > 0 && _currentCalories >= _caloriesGoal
                            ? Icons.check
                            : Icons.close,
                        color:
                            _caloriesGoal > 0 &&
                                _currentCalories >= _caloriesGoal
                            ? Colors.green
                            : Colors.red,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_goal > 0 &&
                      _caloriesGoal > 0 &&
                      _currentDistance >= _goal &&
                      _currentCalories >= _caloriesGoal)
                    const Center(
                      child: Text(
                        'Цель выполнена ✅',

                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Введите цель в км',
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
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Введите цель в ккал',
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
            const SizedBox(height: 30),
            SizedBox(
              width: 365,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B8B8B),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final goal = double.tryParse(_goalController.text);
                  final caloriesGoal = double.tryParse(
                    _caloriesController.text,
                  );
                  if ((_goalController.text.isNotEmpty && goal == null) ||
                      (_caloriesController.text.isNotEmpty &&
                          caloriesGoal == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Введите корректную цель',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final hasDistanceGoal = goal != null && goal > 0;

                  final hasCaloriesGoal =
                      caloriesGoal != null && caloriesGoal > 0;

                  if (!hasDistanceGoal && !hasCaloriesGoal) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Введите хотя бы одну цель'),
                        backgroundColor: Colors.blue,
                      ),
                    );

                    return;
                  }
                  try {
                    await _firestoreService.saveGoal(
                      targetDistance: hasDistanceGoal ? goal : 0,
                      targetCalories: hasCaloriesGoal ? caloriesGoal : 0,
                    );
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _goal = hasDistanceGoal ? goal : 0;
                      _caloriesGoal = hasCaloriesGoal ? caloriesGoal : 0;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Цель сохранена',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Сохранить', style: TextStyle(fontSize: 20)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 365,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B8B8B),

                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: const Text(
                  'История пробежек',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
