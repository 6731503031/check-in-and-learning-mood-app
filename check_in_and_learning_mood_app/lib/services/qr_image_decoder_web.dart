// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<String?> pickAndDecodeQrFromImage() async {
  late final html.BarcodeDetector detector;
  try {
    detector = html.BarcodeDetector();
  } catch (_) {
    throw StateError(
      'This browser does not support BarcodeDetector. '
      'Please use manual input instead.',
    );
  }

  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  await input.onChange.first;

  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) {
    return null;
  }

  final imageUrl = html.Url.createObjectUrl(file);
  final image = html.ImageElement(src: imageUrl);

  try {
    await image.onLoad.first;

    final detected = await detector.detect(image);
    if (detected.isEmpty) {
      return null;
    }

    final rawValue = (detected.first as dynamic).rawValue;
    if (rawValue is String && rawValue.trim().isNotEmpty) {
      return rawValue.trim();
    }

    return null;
  } finally {
    html.Url.revokeObjectUrl(imageUrl);
  }
}
