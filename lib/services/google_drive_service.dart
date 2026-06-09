import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const _backupFileName = 'consumo_mazda_backup.csv';
  static const _mimeTypeCsv = 'text/csv';

  static drive.DriveApi _api(Map<String, String> authHeaders) {
    final client = _AuthClient(authHeaders, http.Client());
    return drive.DriveApi(client);
  }

  static Future<String?> _findBackupFileId(Map<String, String> authHeaders) async {
    final api = _api(authHeaders);
    final response = await api.files.list(
      q: "name='$_backupFileName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    if (response.files != null && response.files!.isNotEmpty) {
      return response.files!.first.id;
    }
    return null;
  }

  static Future<void> uploadBackup(Map<String, String> authHeaders, File csvFile) async {
    final api = _api(authHeaders);
    final existingId = await _findBackupFileId(authHeaders);

    final media = drive.Media(csvFile.openRead(), await csvFile.length(), contentType: _mimeTypeCsv);

    if (existingId != null) {
      await api.files.update(
        drive.File()..mimeType = _mimeTypeCsv,
        existingId,
        uploadMedia: media,
      );
    } else {
      await api.files.create(
        drive.File()
          ..name = _backupFileName
          ..mimeType = _mimeTypeCsv,
        uploadMedia: media,
      );
    }
  }

  static Future<String> downloadBackupContent(Map<String, String> authHeaders) async {
    final fileId = await _findBackupFileId(authHeaders);
    if (fileId == null) {
      throw StateError('No backup found in Google Drive');
    }

    final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media');
    final response = await http.Client().send(http.Request('GET', url)..headers.addAll(authHeaders));
    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    }
    throw HttpException('Failed to download backup (${response.statusCode})');
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _authHeaders;
  final http.Client _inner;

  _AuthClient(this._authHeaders, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_authHeaders);
    request.headers['Content-Type'] ??= 'application/json';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}
