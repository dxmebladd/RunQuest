import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF515151),
      appBar: AppBar(
        title: const Text('История пробежек'),
        backgroundColor: const Color(0xFF515151),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('runs')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final runs = snapshot.data!.docs;
          if (runs.isEmpty) {
            return const Center(
              child: Text(
                'История пуста',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final run = runs[index];
              final distance = run['distance'];
              final duration = run['duration'];
              final date = (run['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yy').format(date);
              final minutes = (duration ~/ 60).toString().padLeft(2, '0');
              final seconds = (duration % 60).toString().padLeft(2, '0');
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B8B8B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${distance.toStringAsFixed(2)} км',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
