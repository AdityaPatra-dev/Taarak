import 'package:image_picker/image_picker.dart';
import 'package:taarak/core/media/media_picker_service.dart';

class ImagePickerMediaService implements MediaPickerService {
  final ImagePicker _picker;

  ImagePickerMediaService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  @override
  Future<String?> pickPhoto({required MediaPickerSource source}) async {
    final file = await _picker.pickImage(
      source: source == MediaPickerSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return file?.path;
  }
}
