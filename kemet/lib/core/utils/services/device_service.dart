import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  DeviceService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<String> getDeviceName() async {
    try {
      if (kIsWeb) return 'Web Browser';

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final androidInfo = await _deviceInfo.androidInfo;
          return _joinParts([androidInfo.brand, androidInfo.model], fallback: 'Android Device');
        case TargetPlatform.iOS:
          final iosInfo = await _deviceInfo.iosInfo;
          return _joinParts([
            iosInfo.identifierForVendor,
            iosInfo.utsname.machine,
          ], fallback: 'iOS Device');
        case TargetPlatform.macOS:
          final macInfo = await _deviceInfo.macOsInfo;
          return _joinParts([macInfo.model, macInfo.computerName], fallback: 'macOS Device');
        case TargetPlatform.windows:
          final windowsInfo = await _deviceInfo.windowsInfo;
          return _joinParts([windowsInfo.computerName], fallback: 'Windows Device');
        case TargetPlatform.linux:
          final linuxInfo = await _deviceInfo.linuxInfo;
          return _joinParts([linuxInfo.prettyName], fallback: 'Linux Device');
        case TargetPlatform.fuchsia:
          return 'Fuchsia Device';
      }
    } catch (_) {
      return 'Unknown Device';
    }
  }

  String _joinParts(List<String?> values, {required String fallback}) {
    final parts = values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (parts.isEmpty) return fallback;
    return parts.join(' ');
  }
}

