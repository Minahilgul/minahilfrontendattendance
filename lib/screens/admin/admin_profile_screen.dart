import 'package:flutter/material.dart';
import '../../core/services/admin_profile_service.dart';
import '../edit_profile_dialog.dart';
import '../change_password_dialog.dart';
import '../change_email_dialog.dart';
import 'package:get/get.dart';  
import '../../core/theme/app_colors.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);
 
  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}
 
class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AdminProfileService _profileService = AdminProfileService();
  Map<String, dynamic>? _adminData;
  bool _isLoading = true;
  String? _error;
 
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
 
  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _profileService.getProfile();
      setState(() { _adminData = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }
 
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _profileService.logout();
      if (mounted) Get.offAllNamed('/login');
      
    }
  }
 
  Future<void> _logoutAllDevices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout All Devices', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This will log you out from all devices. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _profileService.logoutAllDevices();
        if (mounted) Get.offAllNamed('/login');
        
      } catch (e) {
        if (mounted) _showSnackbar(e.toString(), isError: true);
      }
    }
  }
 
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
 
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'A';
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorState()
              : _buildProfileBody(),
    );
  }
 
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error ?? 'Unknown error', textAlign: TextAlign.center, style: TextStyle(color: AppColors.danger)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
 
  Widget _buildProfileBody() {
    final name = _adminData?['name'] ?? 'Admin';
    final email = _adminData?['email'] ?? '';
    final phone = _adminData?['phone'] ?? '';
    final lastLogin = _adminData?['last_login'];
 
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Administrator', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  if (lastLogin != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Last login: $lastLogin',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
 
            const SizedBox(height: 20),
 
            // Info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(email, phone),
            ),
 
            const SizedBox(height: 16),
 
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActionsCard(name, email, phone),
            ),
 
            const SizedBox(height: 16),
 
            // Logout section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLogoutCard(),
            ),
 
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
 
  Widget _buildInfoCard(String email, String phone) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Divider(height: 20),
            _buildInfoRow(Icons.email_outlined, 'Email', email),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(Icons.shield_outlined, 'Role', 'Administrator'),
          ],
        ),
      ),
    );
  }
 
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget _buildActionsCard(String name, String email, String phone) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildActionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update name and phone number',
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => EditProfileDialog(name: name, phone: phone, profileService: _profileService),
                );
                if (result == true) {
                   await _loadProfile(); _showSnackbar('Profile updated successfully'); }
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildActionTile(
              icon: Icons.email_outlined,
              title: 'Change Email',
              subtitle: 'Update your email address',
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => ChangeEmailDialog(currentEmail: email, profileService: _profileService),
                );
                if (result == true) { await _loadProfile(); _showSnackbar('Email updated successfully'); }
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildActionTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => ChangePasswordDialog(profileService: _profileService),
                );
                if (result == true) _showSnackbar('Password changed successfully');
              },
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildActionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
 
  Widget _buildLogoutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.devices_outlined, color: AppColors.warning, size: 22),
              ),
              title: const Text('Logout All Devices', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Sign out from all active sessions', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: _logoutAllDevices,
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.logout, color: AppColors.danger, size: 22),
              ),
              title: Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.danger)),
              subtitle: Text('Sign out from this device', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}