class GoogleSignInConfig {
  GoogleSignInConfig._();

  static const String _envKey = 'TANKUP_GOOGLE_WEB_CLIENT_ID';

  static const String _hardcodedClientId =
      '55358591865-67c0qlq76sq0h8lpmduqork91ov6iatp.apps.googleusercontent.com';

  static String? get webClientId {
    const envValue = String.fromEnvironment(_envKey);
    if (envValue.isNotEmpty) return envValue;
    return _hardcodedClientId;
  }

  static const String androidClientIdPlaceholder =
      '55358591865-67c0qlq76sq0h8lpmduqork91ov6iatp.apps.googleusercontent.com';

  static const String iosClientIdPlaceholder =
      '55358591865-67c0qlq76sq0h8lpmduqork91ov6iatp.apps.googleusercontent.com';

  static bool get isConfigured => true;
}
