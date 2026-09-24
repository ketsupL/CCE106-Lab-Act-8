import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  // User state getters
  User? get currentUser => _auth.currentUser;
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Ensures a persistent guest session.
  /// If a user is already signed in (guest or permanent), returns that user.
  /// Otherwise, signs in anonymously.
  Future<User?> ensureGuestUser() async {
    if (_auth.currentUser != null) {
      return _auth.currentUser;
    }
    return signInAnonymously();
  }

  /// Explicitly signs in as an anonymous guest.
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to sign in anonymously: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Promotes the currently signed-in anonymous guest to an email/password account.
  /// Preserves the user's UID and all existing Firestore data.
  Future<User?> promoteWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('No user is currently signed in to promote.');
      return null;
    }

    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );

    try {
      final userCredential = await user.linkWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to promote guest with email: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Promotes the currently signed-in anonymous guest to a Google account.
  /// Preserves the user's UID and all existing Firestore data.
  Future<User?> promoteWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('No user is currently signed in to promote.');
      return null;
    }

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await user.linkWithPopup(googleProvider);
        return userCredential.user;
      } else {
        final googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await user.linkWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to promote guest with Google: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Registers with email/password.
  /// If the current user is a guest, automatically promotes the existing account
  /// unless [promoteIfGuest] is false.
  Future<User?> registerWithEmail(
    String email,
    String password, {
    bool promoteIfGuest = true,
  }) async {
    if (promoteIfGuest && isGuest) {
      return promoteWithEmail(email, password);
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to register user: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Signs in with email/password.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to log in user: ${e.code} - ${e.message}');
      return null;
    }
  }

  /// Signs in with Google.
  /// If the current user is an anonymous guest and [promoteIfGuest] is true,
  /// attempts to link the guest account first. If the Google account is already
  /// in use, it will fall back to signing into the existing Google account.
  Future<User?> signInWithGoogle({bool promoteIfGuest = true}) async {
    if (promoteIfGuest && isGuest) {
      final promoted = await promoteWithGoogle();
      if (promoted != null) return promoted;
      // If promotion failed (e.g. credential already in use), proceed with standard Google sign-in
    }

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        final googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to sign in with Google: ${e.code} - ${e.message}');
      return null;
    }
  }


  /// Signs out of Firebase and Google (if applicable).
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
    await _auth.signOut();
  }
}
