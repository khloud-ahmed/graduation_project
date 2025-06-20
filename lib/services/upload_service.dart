import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UploadService {
  Future<String> uploadImage(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final extension = imageFile.name.split('.').last.toLowerCase();
      final contentType = _getContentType(extension);
      final imagePath = 'product_images/$fileName.$extension';

      UploadTask uploadTask;

      if (kIsWeb) {
        // لا نضغط الصور على الويب
        final bytes = await imageFile.readAsBytes();
        final metadata = SettableMetadata(contentType: contentType);
        uploadTask = storageRef.child(imagePath).putData(bytes, metadata);
      } else {
        final file = File(imageFile.path);

        // ضغط الصورة على الموبايل
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          '${file.parent.path}/compressed_$fileName.jpg',
          quality: 50,
        );

        if (compressedFile == null) throw Exception('Failed to compress image');

        final metadata = SettableMetadata(contentType: contentType);
        uploadTask = storageRef.child(imagePath).putFile(File(compressedFile.path), metadata);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }

  String _getContentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
