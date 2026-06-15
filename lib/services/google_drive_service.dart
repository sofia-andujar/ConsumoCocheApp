import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class GoogleDriveService {
  static const _backupFileName = 'tankup_backup.csv';
  static const _mimeTypeCsv = 'text/csv';
  static const _maxRetries = 3;
  static const _initialRetryDelay = Duration(milliseconds: 500);

  static Future<void> uploadBackup(Map<String, String> authHeaders, File csvFile) async {
    await _withRetry(() async {
      final client = http.Client();
      try {
        final api = drive.DriveApi(_AuthClient(authHeaders, client));
        final existingId = await _findBackupFileId(client, authHeaders);

        final media = drive.Media(
          csvFile.openRead(),
          await csvFile.length(),
          contentType: _mimeTypeCsv,
        );

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
      } finally {
        client.close();
      }
    });
  }

  static Future<String> downloadBackupContent(Map<String, String> authHeaders) async {
    return await _withRetry(() async {
      final client = http.Client();
      try {
        final fileId = await _findBackupFileId(client, authHeaders);
        if (fileId == null) {
          throw const BackupException('noBackupFound');
        }

        final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media');
        final request = http.Request('GET', url)..headers.addAll(authHeaders);
        final streamedResponse = await client.send(request);
        if (streamedResponse.statusCode == 200) {
          return await streamedResponse.stream.bytesToString();
        }
        if (streamedResponse.statusCode == 401) {
          throw const BackupException('authRequired');
        }
        throw BackupException('downloadFailed_${streamedResponse.statusCode}');
      } finally {
        client.close();
      }
    });
  }

  static Future<String?> _findBackupFileId(http.Client client, Map<String, String> authHeaders) async {
    final api = drive.DriveApi(_AuthClient(authHeaders, client));
    try {
      final response = await api.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'drive',
      );
      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first.id;
      }
      return null;
    } on drive.DetailedApiRequestError catch (e) {
      if (e.status == 401) {
        throw const BackupException('authRequired');
      }
      if (e.status == 403) {
        throw const BackupException('driveScopeRequired');
      }
      rethrow;
    }
  }

  static Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Duration delay = _initialRetryDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        final isRetryable = _isRetryable(e);
        if (++attempts >= _maxRetries || !isRetryable) {
          rethrow;
        }
        logError(e, null, tag: 'google_drive_retry');
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  static bool _isRetryable(Object error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is drive.DetailedApiRequestError) {
      final status = error.status;
      return status == 429 || (status != null && status >= 500);
    }
    if (error is BackupException) return false;
    return true;
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

class BackupException implements Exception {
  final String code;
  const BackupException(this.code);

  @override
  String toString() => code;
}
