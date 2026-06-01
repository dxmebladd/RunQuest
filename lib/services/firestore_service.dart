import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUser({
    required String nickname,
    required String email,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).set({
      'nickname': nickname,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> saveRun({
    required double distance,
    required int duration,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).collection('runs').add({
      'distance': distance,
      'duration': duration,
      'date': Timestamp.now(),
    });
  }

  Future<void> saveGoal({
    required double targetDistance,
    required double targetCalories,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('goal')
        .doc('current')
        .set({
          'targetDistance': targetDistance,
          'targetCalories': targetCalories,
        });
  }

  Future<double> getGoal() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goal')
        .doc('current')
        .get();

    if (!doc.exists) {
      return 0;
    }

    return (doc.data()?['targetDistance'] ?? 0).toDouble();
  }

  Future<void> saveLastDistance({required double distance}) async {
    final uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goal')
        .doc('current')
        .set({'lastDistance': distance}, SetOptions(merge: true));
  }

  Future<double> getLastDistance() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goal')
        .doc('current')
        .get();
    if (!doc.exists) {
      return 0;
    }
    return (doc.data()?['lastDistance'] ?? 0).toDouble();
  }

  Future<double> getCaloriesGoal() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goal')
        .doc('current')
        .get();
    if (!doc.exists) {
      return 0;
    }
    return (doc.data()?['targetCalories'] ?? 0).toDouble();
  }

  Future<void> saveUserData({
    required double weight,
    required double height,
    required String gender,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).set({
      'weight': weight,
      'height': height,
      'gender': gender,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }
}
