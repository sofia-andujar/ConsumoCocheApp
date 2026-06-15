import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/google_config.dart';
import '../utils/app_logger.dart';

const _driveScope = 'https://www.googleapis.com/auth/drive.file';

enum _AuthStatus { initial, loading, signedIn, signedOut, error }

class _AuthState {
  final _AuthStatus status;
  final GoogleSignInAccount? account;
  final Object? error;
  final Set<String> grantedScopes;

  const _AuthState({
    this.status = _AuthStatus.initial,
    this.account,
    this.error,
    this.grantedScopes = const {},
  });

  _AuthState copyWith({
    _AuthStatus? status,
    GoogleSignInAccount? account,
    Object? error,
    Set<String>? grantedScopes,
  }) {
    return _AuthState(
      status: status ?? this.status,
      account: account ?? this.account,
      error: error,
      grantedScopes: grantedScopes ?? this.grantedScopes,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<GoogleSignInAccount?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<GoogleSignInAccount?>> {
  final GoogleSignIn _googleSignIn;
  _AuthState _internalState = const _AuthState();

  AuthNotifier()
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile', _driveScope],
          serverClientId: GoogleSignInConfig.webClientId,
        ),
        super(const AsyncValue.data(null)) {
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    _internalState = _internalState.copyWith(status: _AuthStatus.loading);
    state = const AsyncValue.loading();
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        _internalState = _internalState.copyWith(
          status: _AuthStatus.signedIn,
          account: account,
          grantedScopes: {'email', 'profile', _driveScope},
        );
        state = AsyncValue.data(account);
      } else {
        _internalState = _internalState.copyWith(
          status: _AuthStatus.signedOut,
          account: null,
          grantedScopes: const {},
        );
        state = const AsyncValue.data(null);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e, silent: true);
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: e,
        account: null,
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn() async {
    _internalState = _internalState.copyWith(status: _AuthStatus.loading);
    state = const AsyncValue.loading();
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        _internalState = _internalState.copyWith(
          status: _AuthStatus.signedIn,
          account: account,
        );
        state = AsyncValue.data(account);
      } else {
        _internalState = _internalState.copyWith(
          status: _AuthStatus.signedOut,
          account: null,
        );
        state = const AsyncValue.data(null);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e, silent: false);
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: e,
        account: null,
      );
      state = AsyncValue.error(e, st);
    }
  }

  void _handlePlatformException(PlatformException e, {required bool silent}) {
    if (e.code == 'sign_in_failed' && e.message?.contains('10') == true) {
      const configError = _GoogleSignInException(
        'Google Sign-In requires an OAuth client ID.\n\n'
        '1. Go to https://console.cloud.google.com/apis/credentials\n'
        '2. Create an OAuth 2.0 Client ID for "Android" with:\n'
        '     Package: com.tankup\n'
        '     SHA-1: (run keytool -list -v -keystore ~/.android/debug.keystore)\n'
        '3. Create an OAuth 2.0 Client ID for "Web application"\n'
        '4. Set the environment variable TANKUP_GOOGLE_WEB_CLIENT_ID\n'
        '   or update lib/data/google_config.dart\n'
        '5. Add the SHA-1 to your Android OAuth client in the Cloud Console\n\n'
        'See the google_config.dart file for detailed instructions.',
      );
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: configError,
        account: null,
      );
      state = AsyncValue.error(configError, StackTrace.current);
    } else if (e.code == 'network_error') {
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: e,
        account: null,
      );
      state = AsyncValue.error(
        _GoogleSignInException('Network error. Check your connection and try again.'),
        StackTrace.current,
      );
    } else if (e.code == 'user_canceled') {
      _internalState = _internalState.copyWith(
        status: _AuthStatus.signedOut,
        account: null,
        error: null,
      );
      state = const AsyncValue.data(null);
    } else {
      logError(e, StackTrace.current, tag: 'auth_provider');
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: e,
        account: null,
      );
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _internalState = const _AuthState(status: _AuthStatus.signedOut);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      _internalState = _internalState.copyWith(
        status: _AuthStatus.error,
        error: e,
      );
    }
  }

  Future<bool> ensureDriveScope() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return false;

    if (_internalState.grantedScopes.contains(_driveScope)) {
      return true;
    }

    try {
      final granted = await _googleSignIn.requestScopes([_driveScope]);
      if (granted) {
        _internalState = _internalState.copyWith(
          grantedScopes: {..._internalState.grantedScopes, _driveScope},
        );
      }
      return granted;
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      return false;
    }
  }

  Future<Map<String, String>?> getAuthHeaders() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    try {
      final headers = await account.authHeaders;
      return headers;
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      if (e is PlatformException && e.code == 'invalid_credentials') {
        final refreshed = await _refreshAccount();
        return refreshed ? await _googleSignIn.currentUser?.authHeaders : null;
      }
      return null;
    }
  }

  Future<bool> _refreshAccount() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        _internalState = _internalState.copyWith(
          status: _AuthStatus.signedIn,
          account: account,
        );
        state = AsyncValue.data(account);
        return true;
      }
      return false;
    } catch (e, st) {
      logError(e, st, tag: 'auth_provider');
      return false;
    }
  }
}

class _GoogleSignInException implements Exception {
  final String message;
  const _GoogleSignInException(this.message);

  @override
  String toString() => message;
}
