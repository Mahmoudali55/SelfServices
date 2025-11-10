import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? _currentUser;

  // محاولة تسجيل الدخول الصامت
  Future<void> init() async {
    _currentUser = await _googleSignIn.signInSilently();
  }

  // تسجيل الدخول يدويًا إذا لم يكن مسجلاً
  Future<bool> signInIfNeeded() async {
    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signIn();
    }
    return _currentUser != null;
  }

  Future<String?> uploadFile(File file) async {
    final signedIn = await signInIfNeeded();
    if (!signedIn) return null;

    final authHeaders = await _currentUser!.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(client);

    final driveFile = drive.File()..name = file.path.split('/').last;
    final media = drive.Media(file.openRead(), file.lengthSync());

    final uploadedFile = await driveApi.files.create(driveFile, uploadMedia: media);

    // جعل الملف متاحًا للقراءة العامة
    await driveApi.permissions.create(
      drive.Permission(role: 'reader', type: 'anyone'),
      uploadedFile.id!,
    );

    return 'https://drive.google.com/uc?id=${uploadedFile.id}';
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
