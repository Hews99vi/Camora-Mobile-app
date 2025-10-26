import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadProductImage(String imagePath) async {
    final fileName = path.basename(imagePath);
    final destination = 'products/$fileName';
    
    try {
      final ref = _storage.ref(destination);
      final file = File(imagePath);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
