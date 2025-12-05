import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser {
    final user = _auth.currentUser;
    print('🔍 Firebase currentUser getter called: ${user?.uid ?? "null"}');
    return user;
  }

  // Get current user ID with debug logging
  static String? get currentUserId {
    final user = _auth.currentUser;
    final uid = user?.uid;
    print('🔍 Firebase currentUserId: $uid');
    print('🔍 Firebase user email: ${user?.email ?? "not logged in"}');
    print('🔍 Firebase user displayName: ${user?.displayName ?? "no name"}');

    if (uid == null) {
      print('⚠️ WARNING: No Firebase user is currently signed in!');
    }

    return uid;
  }

  // Get current user email
  static String? get currentUserEmail {
    final email = _auth.currentUser?.email;
    print('🔍 Firebase currentUserEmail: ${email ?? "null"}');
    return email;
  }

  // Get current user display name
  static String? get currentUserDisplayName {
    final name = _auth.currentUser?.displayName;
    print('🔍 Firebase currentUserDisplayName: ${name ?? "null"}');
    return name;
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('🔵 Starting sign up with email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User created with UID: ${credential.user?.uid}');

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      print('✅ Display name updated to: $displayName');

      // Reload user to get updated info
      await credential.user?.reload();
      print('✅ User info reloaded');

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign up error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected sign up error: $e');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Starting sign in with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Sign in successful!');
      print('✅ User UID: ${credential.user?.uid}');
      print('✅ User Email: ${credential.user?.email}');

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected sign in error: $e');
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔵 Starting Google sign in...');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        print('⚠️ User cancelled Google sign in');
        return null;
      }

      print('🔵 Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Signing in to Firebase with Google credential...');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ Google sign in successful!');
      print('✅ User UID: ${userCredential.user?.uid}');
      print('✅ User Email: ${userCredential.user?.email}');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Google sign in Firebase error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Google sign in error: $e');
      throw 'Google sign-in failed: ${e.toString()}';
    }
  }

  // Sign out - FIXED VERSION
  static Future<void> signOut() async {
    try {
      print('🔵 Signing out...');

      // Sign out from Firebase first
      await _auth.signOut();
      print('✅ Firebase sign out successful');

      // Try to sign out from Google, but don't fail if it errors
      try {
        final isSignedIn = await _googleSignIn.isSignedIn();
        if (isSignedIn) {
          await _googleSignIn.signOut();
          print('✅ Google sign out successful');
        } else {
          print('ℹ️ User was not signed in with Google');
        }
      } catch (googleError) {
        print('⚠️ Google sign out error (non-critical): $googleError');
        // Continue anyway - Firebase sign out is more important
      }

      print('✅ Sign out completed');
      print('🔍 Current user after sign out: ${_auth.currentUser?.uid ?? "null"}');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('🔵 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected password reset error: $e');
      throw 'Failed to send password reset email: ${e.toString()}';
    }
  }

  // Update user profile
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for profile update');
        throw 'No user signed in';
      }

      print('🔵 Updating profile for user: ${user.uid}');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        print('✅ Display name updated to: $displayName');
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
        print('✅ Photo URL updated');
      }

      await user.reload();
      print('✅ Profile updated successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ Profile update error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected profile update error: $e');
      throw 'Failed to update profile: ${e.toString()}';
    }
  }

  // Update email
  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for email update');
        throw 'No user signed in';
      }

      print('🔵 Updating email to: $newEmail');
      await user.verifyBeforeUpdateEmail(newEmail);
      print('✅ Email update verification sent');
    } on FirebaseAuthException catch (e) {
      print('❌ Email update error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected email update error: $e');
      throw 'Failed to update email: ${e.toString()}';
    }
  }

  // Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for password update');
        throw 'No user signed in';
      }

      print('🔵 Updating password for user: ${user.uid}');
      await user.updatePassword(newPassword);
      print('✅ Password updated successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ Password update error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected password update error: $e');
      throw 'Failed to update password: ${e.toString()}';
    }
  }

  // Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for re-authentication');
        throw 'No user signed in';
      }
      if (user.email == null) {
        print('❌ No email associated with account');
        throw 'No email associated with this account';
      }

      print('🔵 Re-authenticating user: ${user.email}');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-authentication successful');
    } on FirebaseAuthException catch (e) {
      print('❌ Re-authentication error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected re-authentication error: $e');
      throw 'Re-authentication failed: ${e.toString()}';
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for account deletion');
        throw 'No user signed in';
      }

      print('🔵 Deleting account for user: ${user.uid}');

      await user.delete();

      // Try to sign out from Google, but don't fail if it errors
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('⚠️ Google sign out error during account deletion (non-critical): $e');
      }

      print('✅ Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      print('❌ Account deletion error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected account deletion error: $e');
      throw 'Failed to delete account: ${e.toString()}';
    }
  }

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user signed in for email verification');
        throw 'No user signed in';
      }

      print('🔵 Sending email verification to: ${user.email}');
      await user.sendEmailVerification();
      print('✅ Verification email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ Email verification error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected email verification error: $e');
      throw 'Failed to send verification email: ${e.toString()}';
    }
  }

  // Check if email is verified
  static bool get isEmailVerified {
    final verified = _auth.currentUser?.emailVerified ?? false;
    print('🔍 Email verified status: $verified');
    return verified;
  }

  // Reload current user
  static Future<void> reloadUser() async {
    print('🔵 Reloading current user...');
    await _auth.currentUser?.reload();
    print('✅ User reloaded');
  }

  // Check if user is signed in
  static bool get isSignedIn {
    final signedIn = _auth.currentUser != null;
    print('🔍 User signed in: $signedIn');
    return signedIn;
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'account-exists-with-different-credential':
        return 'An account exists with this email but different sign-in method';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }
}