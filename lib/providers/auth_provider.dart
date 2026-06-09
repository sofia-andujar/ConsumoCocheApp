import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _driveScope = 'https://www.googleapis.com/auth/drive.file';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<GoogleSignInAccount?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  final GoogleSignIn _googleSignIn;

  AuthNotifier()
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
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
