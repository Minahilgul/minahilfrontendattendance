// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';

// class DeviceMacHelper {
//   /// Returns MAC address on iOS/older Android.
//   /// On Android 10+, returns a stable device ID prefixed with "ANDROID_ID:"
//   /// because the OS blocks real MAC access.
//   static Future<String> getMacAddress() async {
//     try {
//       if (Platform.isAndroid) {
//         final info = NetworkInfo();
//         final mac = await info.getWifiBSSID(); // returns 02:00:00:00:00:00 on Android 10+

//         if (mac != null && mac != '02:00:00:00:00:00') {
//           return mac.toUpperCase();
//         }

//         // Fallback: use Android ID as stable device identifier
//         final deviceInfo = DeviceInfoPlugin();
//         final androidInfo = await deviceInfo.androidInfo;
//         return 'ANDROID_ID:${androidInfo.id}';
//       }

//       if (Platform.isIOS) {
//         // iOS also blocks MAC; use identifierForVendor
//         final deviceInfo = DeviceInfoPlugin();
//         final iosInfo = await deviceInfo.iosInfo;
//         return 'IOS_UUID:${iosInfo.identifierForVendor ?? 'unknown'}';
//       }
//     } catch (e) {
//       return 'UNKNOWN';
//     }
//     return 'UNKNOWN';
//   }
// }