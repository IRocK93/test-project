import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google and return the ID token for backend verification
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Check if user is already signed in with Google
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  /// Get currently signed in account
  Future<GoogleSignInAccount?> getCurrentAccount() async {
    return _googleSignIn.signInSilently();
  }
}