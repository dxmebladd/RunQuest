import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:runquest/services/firestore_service.dart';
import 'package:runquest/services/run_logik.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double caloriesGoal = 0;
  double goal = 0;
  final FirestoreService _firestoreService = FirestoreService();
  @override
  void initState() {
    super.initState();
    _loadGoal();
    _loadCaloriesGoal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunLogik>().getCurrentLocation();
    });
  }

  Future<void> _loadCaloriesGoal() async {
    final loadedCaloriesGoal = await _firestoreService.getCaloriesGoal();
    setState(() {
      caloriesGoal = loadedCaloriesGoal;
    });
  }

  Future<void> _loadGoal() async {
    final loadedGoal = await _firestoreService.getGoal();
    setState(() {
      goal = loadedGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RunLogik>(
        builder: (context, tracking, child) {
          final FirestoreService _firestoreService = FirestoreService();
          final currentPosition = tracking.currentPosition;
          final route = tracking.route;
          final isRunning = tracking.isRunning;
          final distance = tracking.distance;
          final timeString = tracking.timeString;
          return Stack(
            children: <Widget>[
              if (currentPosition != null)
                FlutterMap(
                  options: MapOptions(
                    initialCenter: currentPosition,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.runquest',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          strokeWidth: 5,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.circle, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                )
              else
                const Center(child: CircularProgressIndicator()),
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xCC2B2B2B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${tracking.distance.toStringAsFixed(2)} / ${goal.toStringAsFixed(2)} км',

                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '${(tracking.distance * 60).toStringAsFixed(0)} / ${caloriesGoal.toStringAsFixed(0)} ккал',

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        color: tracking.distance >= goal
                            ? Colors.green
                            : Colors.blue,
                        value: goal == 0
                            ? 0
                            : (tracking.distance / goal).clamp(0, 1),
                        minHeight: 14,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal > 0 && tracking.distance >= goal
                            ? 'Выполнено'
                            : '${((goal == 0 ? 0 : tracking.distance / goal) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(color: Color(0xCC2B2b2b)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Дистанция:",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "${distance.toStringAsFixed(2)} км",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Время:",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(width: 50),
                          Text(
                            timeString,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Positioned(
                bottom: 20,
                right: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isRunning
                              ? Colors.red
                              : const Color(0xFFBDBDBD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (isRunning) {
                            try {
                              await _firestoreService.saveRun(
                                distance: tracking.distance,
                                duration: tracking.seconds,
                              );
                              await _firestoreService.saveLastDistance(
                                distance: tracking.distance,
                              );
                              tracking.stopRun();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } else {
                            tracking.startRun();
                          }
                        },
                        icon: Icon(
                          isRunning ? Icons.stop : Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isRunning) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: tracking.isPaused
                                ? Colors.green
                                : Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (tracking.isPaused) {
                              tracking.resume();
                            } else {
                              tracking.pause();
                            }
                          },
                          icon: Icon(
                            tracking.isPaused ? Icons.play_arrow : Icons.pause,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
