// Cross-platform file abstraction for web compatibility
// On web, XFile from image_picker will be used directly
// On mobile, dart:io File will be used

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

// Helper to check if we're on a mobile platform
bool get isMobilePlatform => !kIsWeb;

// PlatformFile class to handle files across platforms
class PlatformFile {
  final dynamic file;
  final String path;

  PlatformFile({required this.file, required this.path});

  factory PlatformFile.fromXFile(XFile xFile) {
    return PlatformFile(file: xFile, path: xFile.path);
  }
}
