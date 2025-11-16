import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'dvek8vfaw', // استبدل بالقيم الخاصة بك
    'unsigned_chat_upload', // استبدل باسم الـ upload preset (تقدر تعمل unsigned preset من Cloudinary Dashboard)
    cache: false,
  );

  Future<String?> uploadImage(File file) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFile(File file) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Raw),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadAudio(File file) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Auto),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }
}
