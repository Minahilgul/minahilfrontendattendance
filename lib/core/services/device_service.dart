import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final info = await deviceInfo.webBrowserInfo;
        return '${info.browserName.name}_${info.userAgent.hashCode}';
      }

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;

        // Temporary for testing
        print('ANDROID DEVICE ID: ${info.id}');

        return info.id;
      }

      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.identifierForVendor ?? 'unknown-ios';
      }

      if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        return info.deviceId;
      }

      if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        return info.systemGUID ?? 'unknown-mac';
      }

      return 'unknown-device';
    } catch (e) {
      print('DEVICE ID ERROR: $e');
      return 'error-device';
    }
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;

        return {
          'device_id': info.id,
          'device_name': info.model,
          'device_brand': info.brand,
          'device_os': 'Android ${info.version.release}',
        };
      }

      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;

        return {
          'device_id': info.identifierForVendor ?? 'unknown',
          'device_name': info.model,
          'device_brand': 'Apple',
          'device_os': 'iOS ${info.systemVersion}',
        };
      }

      if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;

        return {
          'device_id': info.deviceId,
          'device_name': info.computerName,
          'device_brand': 'Windows',
          'device_os': 'Windows ${info.majorVersion}',
        };
      }

      return {
        'device_id': 'unknown',
        'device_name': 'unknown',
        'device_brand': 'unknown',
        'device_os': 'unknown',
      };
    } catch (e) {
      return {
        'device_id': 'error',
        'device_name': 'error',
        'device_brand': 'error',
        'device_os': 'error',
      };
    }
  }
}
