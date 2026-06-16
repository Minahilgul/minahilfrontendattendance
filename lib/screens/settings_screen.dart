import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/base_scaffold.dart';
import '../core/services/system_setting_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final storage = FlutterSecureStorage(); 
  String token = ""; // 👈 hardcoded token hata diya

  List<dynamic> settings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadToken(); // 👈 direct fetchSettings nahi
  }

  // 👇 ye naya function add kiya
  Future<void> loadToken() async {
    String? savedToken = await storage.read(key: 'token'); // 👈 secure storage se lo
    print("Secure Token Loaded: $savedToken");

    if (savedToken != null && savedToken.isNotEmpty) {
      setState(() => token = savedToken);
      fetchSettings(); // 👈 token milne ke baad call karo
    } else {
      setState(() => isLoading = false);
      _showSnack('Login karo pehle');
    }
  }

  Future<void> fetchSettings() async {
    setState(() => isLoading = true);
    try {
      final fetchedSettings = await SystemSettingService.fetchSettings(token);
      setState(() {
        settings = fetchedSettings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack('Error: $e');
    }
  }

  Future<void> updateSetting(int id, String value) async {
    final success = await SystemSettingService.updateSetting(
      id: id,
      value: value,
      token: token,
    );
    if (success) {
      fetchSettings();
      _showSnack('Setting updated');
    } else {
      _showSnack('Update failed');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Color(0xFF0F9D58))
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'System Settings',
      role: 'admin',
      body: isLoading
      ? Center(child: CircularProgressIndicator(color: Color(0xFF0F9D58)))
        : settings.isEmpty
       ? Center(child: Text('No settings found'))
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: settings.length,
            itemBuilder: (context, index) {
              var setting = settings[index];
              TextEditingController controller =
                TextEditingController(text: setting['value'].toString());

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(setting['key'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(setting['description']?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          keyboardType: setting['type'] == 'number'? TextInputType.number : TextInputType.text,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.save, color: Color(0xFF0F9D58)),
                        onPressed: () => updateSetting(setting['id'], controller.text),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}