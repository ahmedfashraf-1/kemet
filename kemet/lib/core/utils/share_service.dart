import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareLandmark(BuildContext context, Landmark landmark) async {
  final name = _safeText(landmark.name, fallback: 'Landmark');
  final mapLink = _buildMapsLink(landmark.latitude, landmark.longitude);

  final buffer = StringBuffer()..writeln('Check out this place: $name');

  if (mapLink.isNotEmpty) {
    buffer.writeln(mapLink);
  }

  final shareText = buffer.toString().trim();
  try {
    ShareResult result;
    if (kIsWeb) {
      await Share.share(shareText);
      return;
    }
    if (Platform.isAndroid) {
      result = await Share.share(shareText);
    } else {
      final shareOrigin = _buildShareOrigin(context);
      result = await Share.share(shareText, sharePositionOrigin: shareOrigin);
    }
    if (!context.mounted) {
      return;
    }
    if (Platform.isIOS && result.status == ShareResultStatus.unavailable) {
      await _copyToClipboard(context, shareText);
    }
  } on PlatformException {
    if (!context.mounted) {
      return;
    }
    await _copyToClipboard(context, shareText);
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    await _copyToClipboard(context, shareText);
  }
}

Rect _buildShareOrigin(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is RenderBox) {
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
  final size = MediaQuery.sizeOf(context);
  return Rect.fromCenter(center: size.center(Offset.zero), width: 1, height: 1);
}

Future<void> _copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Share not available. Copied to clipboard.')),
  );
}

String _buildMapsLink(double? lat, double? lng) {
  if (lat == null || lng == null) {
    return '';
  }
  return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}

String _safeText(String? value, {required String fallback}) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? fallback : trimmed;
}
