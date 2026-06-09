class GoogleSignInConfig {
  GoogleSignInConfig._();

  /// Your web application OAuth 2.0 Client ID from Google Cloud Console.
  ///
  /// To create one:
  ///   1. Go to https://console.cloud.google.com/apis/credentials
  ///   2. Create a new OAuth 2.0 Client ID of type "Web application"
  ///   3. Copy the client ID (ends with .apps.googleusercontent.com)
  ///   4. Paste it below and uncomment the line
  ///
  /// Also add it to the AndroidManifest.xml as:
  ///   <meta-data android:name="com.google.android.gms.signin.CLIENT_ID"
  ///              android:value="YOUR_WEB_CLIENT_ID" />
  ///
  /// For local dev, the default debug keystore SHA-1 must also be registered
  /// in the Android OAuth client (Google Cloud Console → APIs & Services →
  /// Credentials → Android client → add SHA-1 from debug.keystore).
  static const String? webClientId = null; // ← Set your web client ID here
}
