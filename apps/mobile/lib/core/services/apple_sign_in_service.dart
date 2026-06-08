import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService {
  /// Check if Apple Sign-In is available on this device
  Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Sign in with Apple and return the credentials
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.babymon.app', // Replace with your Service ID
          redirectUri: Uri.parse('https://babymon.app/callback'),
        ),
      );

      // Build full name from givenName and familyName
      final givenName = credential.givenName;
      final familyName = credential.familyName;
      final fullName = (givenName != null || familyName != null)
          ? '${givenName ?? ''} ${familyName ?? ''}'.trim()
          : null;

      return {
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
        'email': credential.email,
        'userIdentifier': credential.userIdentifier,
        'givenName': givenName,
        'familyName': familyName,
        'fullName': fullName,
      };
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  /// Sign out from Apple (Apple doesn't have a sign-out API like Google)
  Future<void> signOut() async {
    // Apple Sign-In doesn't require explicit sign-out
    // The credential is managed by iOS
  }
}