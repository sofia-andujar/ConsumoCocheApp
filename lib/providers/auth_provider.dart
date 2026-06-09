import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/google_config.dart';

const _driveScope = 'https://www.googleapis.com/auth/drive.file';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<GoogleSignInAccount?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  final GoogleSignIn _googleSignIn;

  AuthNotifier()
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: GoogleSignInConfig.webClientId,
        ),
        super(const AsyncValue.data(null)) {
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      state = AsyncValue.data(account);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final account = await _googleSignIn.signIn();
      state = AsyncValue.data(account);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' && e.message?.contains('10') == true) {
        state = AsyncValue.error(
          const _GoogleSignInException(
            'Google Sign-In requires an OAuth client ID.\n\n'
            '1. Go to https://console.cloud.google.com/apis/credentials\n'
            '2. Create an OAuth 2.0 Client ID for "Android" with:\n'
            '     Package: com.consumo_coche_chof\n'
            '     SHA-1: (run keytool -list -v -keystore ~/.android/debug.keystore)\n'
            '3. Create an OAuth 2.0 Client ID for "Web application"\n'
            '4. Paste the web client ID in lib/data/google_config.dart\n'
            '5. Add the SHA-1 to your Android OAuth client in the Cloud Console\n\n'
            'See the google_config.dart file for detailed instructions.',
          ),
          StackTrace.current,
        );
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    state = const AsyncValue.data(null);
  }

  Future<bool> ensureDriveScope() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return false;

    try {
      final granted = await _googleSignIn.requestScopes([_driveScope]);
      return granted;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>?> getAuthHeaders() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    try {
      return await account.authHeaders;
    } catch (_) {
      return null;
    }
  }
}

class _GoogleSignInException implements Exception {
  final String message;
  const _GoogleSignInException(this.message);

  @override
  String toString() => message;
}
