import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignInService {
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Initialize Facebook SDK
  Future<void> initialize() async {
    // FacebookAuth is auto-initialized in newer versions
    // No explicit initialization needed
  }

  /// Sign in with Facebook
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the Facebook Login flow
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await _facebookAuth.getUserData(
          fields: 'email,name,picture,first_name,last_name',
        );

        // Get access token info using string keys for compatibility
        final accessTokenString = result.accessToken?.toJson();

        return {
          'accessToken': accessTokenString?['token'],
          'userId': accessTokenString?['userId'],
          'email': userData['email'],
          'name': userData['name'],
          'firstName': userData['first_name'],
          'lastName': userData['last_name'],
          'picture': userData['picture']?['data']?['url'],
        };
      } else if (result.status == LoginStatus.cancelled) {
        // User cancelled login
        return null;
      } else {
        throw Exception(result.message ?? 'Facebook login failed');
      }
    } catch (e) {
      throw Exception('Facebook sign-in failed: $e');
    }
  }

  /// Sign out from Facebook
  Future<void> signOut() async {
    await _facebookAuth.logOut();
  }

  /// Get current access token
  Future<String?> getCurrentAccessToken() async {
    final accessToken = await _facebookAuth.accessToken;
    return accessToken?.toJson()['token'] as String?;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await _facebookAuth.accessToken;
    return accessToken != null;
  }
}