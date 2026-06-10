import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/session_service.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  String latitude = "";
  String longitude = "";

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}

    // Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");

    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
    await SessionService.createSession(
  position.latitude,
  position.longitude,
);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    CreateSessionPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latitude: $latitude"),
            const SizedBox(height: 10),
            Text("Longitude: $longitude"),
          ],
        ),
      ),
    );
  }
}