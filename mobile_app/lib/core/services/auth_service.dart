import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(displayName);

    final userModel = UserModel(
      id: credential.user!.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      subscriptionStatus: 'free',
      photoUrl: null,
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(userModel.toJson());

    return userModel;
  }

  // Sign In
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) {
      throw Exception('User profile not found.');
    }

    return UserModel.fromJson({'id': doc.id, ...doc.data()!});
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson({'id': doc.id, ...doc.data()!});
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    await _firestore.collection('users').doc(userId).update(updates);
    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    // Delete Firestore data
    await _firestore.collection('users').doc(userId).delete();

    // Delete Auth account
    await _auth.currentUser?.delete();
  }
}
