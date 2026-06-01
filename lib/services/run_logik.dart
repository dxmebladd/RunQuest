import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class RunLogik extends ChangeNotifier {
  LatLng? _currentPosition;
  final Distance _distanceCalc = const Distance();
  final List<LatLng> _route = [];
  bool _isRunning = false;
  bool isPaused = false;
  StreamSubscription<Position>? _positionStream;
  double _distance = 0;
  int _seconds = 0;
  Timer? _timer;

  LatLng? get currentPosition => _currentPosition;
  List<LatLng> get route => _route;
  bool get isRunning => _isRunning;
  double get distance => _distance;
  int get seconds => _seconds;

  String get timeString {
    final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;
    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  void startRun() {
    _isRunning = true;
    _route.clear();
    _distance = 0;
    _seconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          final point = LatLng(position.latitude, position.longitude);
          _currentPosition = point;

          if (_route.isNotEmpty) {
            final distance = const Distance().as(
              LengthUnit.Meter,
              _route.last,
              point,
            );
            _distance += distance / 1000;
          }
          _route.add(point);
          notifyListeners();
        });

    notifyListeners();
  }

  void stopRun() {
    isPaused = false;
    _positionStream?.cancel();
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void pause() {
    isPaused = true;
    _timer?.cancel();
    _positionStream?.cancel();
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((pos) {
          final point = LatLng(pos.latitude, pos.longitude);
          if (route.isNotEmpty) {
            final d = _distanceCalc.as(LengthUnit.Meter, route.last, point);
            _distance += d / 1000;
          }
          route.add(point);
          _currentPosition = point;
          notifyListeners();
        });
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
