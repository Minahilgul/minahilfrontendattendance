import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String baseUrl = "http://10.0.2.2:8000/api";
  List<dynamic> settings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/settings'));
      if (res.statusCode == 200) {
        setState(() {
          settings = jsonDecode(res.body)['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack('Error: $e');
    }
  }

  Future<void> updateSetting(int id, String value) async {
    final res = await http.put(
      Uri.parse('$baseUrl/settings/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': value}),
    );
    if (res.statusCode == 200) {
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('System Settings'),
        backgroundColor: Color(0xFF0F9D58),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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