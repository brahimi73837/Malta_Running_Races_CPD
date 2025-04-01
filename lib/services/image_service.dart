import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<String> generateFilePath(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<void> saveImageToAppDirectory(XFile image, String path) async {
    final imageFile = File(path);
    await imageFile.writeAsBytes(await image.readAsBytes());
  }

  Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }
}