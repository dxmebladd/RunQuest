import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:runquest/services/run_logik.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunLogik>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RunLogik>(
        builder: (context, tracking, child) {
          final currentPosition = tracking.currentPosition;
          final route = tracking.route;
          final isRunning = tracking.isRunning;
          final distance = tracking.distance;
          final timeString = tracking.timeString;
          return Stack(
            children: [
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
                        onPressed: () {
                          if (isRunning) {
                            tracking.stopRun();
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
