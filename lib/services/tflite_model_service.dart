// Platform-specific conditional export
// This file will export the appropriate TFLite service based on the platform

export 'tflite_model_service_mobile.dart' if (dart.library.html) 'tflite_model_service_web.dart';
