import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ReceiptService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickReceiptFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveReceipt(image);
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
    return null;
  }

  static Future<String?> pickReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveReceipt(image);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  static Future<String> _saveReceipt(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final fileName =
        'receipt_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final savedPath = '${receiptsDir.path}/$fileName';

    await File(image.path).copy(savedPath);

    return savedPath;
  }

  static Future<void> deleteReceipt(String? receiptPath) async {
    if (receiptPath == null) return;

    try {
      final file = File(receiptPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting receipt: $e');
    }
  }

  static bool receiptExists(String? receiptPath) {
    if (receiptPath == null) return false;
    return File(receiptPath).existsSync();
  }
}
