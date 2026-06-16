import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/auth_service.dart';
import '../core/services/session_service.dart';
import '../core/services/class_service.dart';
import '../widgets/base_scaffold.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _storage = const FlutterSecureStorage();
  
  double? _latitude;
  double? _longitude;
  bool _gpsFetched = false;
  String? _gpsError;
  bool _isLocating = false;

  List<Map<String, dynamic>> _classes = [];
  int? _selectedClassId;
  bool _isLoadingClasses = false;
  String? _classesError;

  bool _isCreatingSession = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUserRole();
    await _fetchClasses();
    await _getCurrentLocation();
  }

  Future<void> _loadUserRole() async {
    String? role = await _storage.read(key: 'role');
    setState(() {
      _userRole = role ?? 'admin';
    });
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _classesError = null;
    });

    try {
      final List<Map<String, dynamic>> data = await ClassService.fetchClasses();
      setState(() {
        _classes = data;
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes.first['id'];
        }
        _isLoadingClasses = false;
      });
    } catch (e) {
      setState(() {
        _classesError = "Failed to load classes: $e";
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _gpsError = null;
      _gpsFetched = false;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsError = "Location permission denied. Please grant permission in settings.";
          _isLocating = false;
        });
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsError = "GPS is disabled. Please enable location services.";
          _isLocating = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gpsFetched = true;
        _isLocating = false;
      });
    } catch (e) {
      setState(() {
        _gpsError = "Error retrieving GPS: $e";
        _isLocating = false;
      });
    }
  }

  Future<void> _submitSession() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create session: GPS location is missing.')),
      );
      return;
    }

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first.')),
      );
      return;
    }

    setState(() {
      _isCreatingSession = true;
    });

    try {
      String? userIdStr = await _storage.read(key: 'userId');
      int userId = int.tryParse(userIdStr ?? '') ?? 1;

      final result = await SessionService.createSession(
        teacherId: userId,
        classId: _selectedClassId!,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      setState(() {
        _isCreatingSession = false;
      });

      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: Text(result['message'] ?? 'Attendance session created successfully!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss Dialog
                  Navigator.of(context).pop(); // Go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to create session.');
      }
    } catch (e) {
      setState(() {
        _isCreatingSession = false;
      });
      _showErrorDialog("An unexpected connection error occurred: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Create Session",
      role: _userRole ?? "admin",
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome / Header banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2979FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Start Classroom Attendance",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Make sure you are inside the campus range to establish a session.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Class selection card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SELECT CLASS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingClasses)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (_classesError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _classesError!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                            TextButton.icon(
                              onPressed: _fetchClasses,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text("Retry loading classes"),
                            ),
                          ],
                        )
                      else if (_classes.isEmpty)
                        const Text(
                          "No classes available. Add a class in Class Directory first.",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: _selectedClassId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
                            ),
                          ),
                          items: _classes.map((c) {
                            return DropdownMenuItem<int>(
                              value: c['id'],
                              child: Text(
                                "${c['class_name'] ?? 'Class'} (${c['name'] ?? 'No Teacher'})",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedClassId = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // GPS / Location card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "GEOLOCATION STATUS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (_isLocating)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.my_location, size: 18, color: Color(0xFF2979FF)),
                              onPressed: _getCurrentLocation,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              tooltip: "Refresh location",
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_gpsError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _gpsError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_gpsFetched)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: Colors.green),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Latitude: ${_latitude?.toStringAsFixed(6)}",
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Longitude: ${_longitude?.toStringAsFixed(6)}",
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        const Center(
                          child: Text(
                            "Fetching location coordinates...",
                            style: TextStyle(color: Colors.black38, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isCreatingSession || !_gpsFetched || _selectedClassId == null)
                      ? null
                      : _submitSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCreatingSession
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Create Session",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
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