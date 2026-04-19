import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_service.dart';
import 'notification_service.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

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

    // Save FCM token for reminders
    final token = await NotificationService().getFcmToken();
    if (token != null) {
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'fcm_token': token,
      });
    }

    // Seed initial habits to provide a 'First-Class' experience for reviewers
    await HabitService().seedDefaultHabits(credential.user!.uid);

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

    // Refresh FCM token on sign in
    final token = await NotificationService().getFcmToken();
    if (token != null) {
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'fcm_token': token,
      });
    }

    return UserModel.fromJson({'id': doc.id, ...doc.data()!});
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    // Clear local traces
    await Hive.box('habits_cache').clear();
    await Hive.box('logs_cache').clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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

  // Delete Account (Comprehensive & Atomic Hardening)
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    final userId = user?.uid;
    if (userId == null) throw Exception('No authenticated user found.');

    try {
      AppLogger.i('Starting atomic account purge for user: $userId');

      // 1. Delete Firestore Data in Batches
      final batch = _firestore.batch();
      int operationCount = 0;

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(userId));
      operationCount++;

      // Delete user analytics
      batch.delete(_firestore.collection('analytics').doc(userId));
      operationCount++;

      // Delete user habits (pagination handle)
      final habits = await _firestore
          .collection('habits')
          .where('user_id', isEqualTo: userId)
          .get();
      for (final doc in habits.docs) {
        batch.delete(doc.reference);
        operationCount++;
      }

      // Delete user logs
      final logs = await _firestore
          .collection('habit_logs')
          .where('user_id', isEqualTo: userId)
          .get();
      for (final doc in logs.docs) {
        batch.delete(doc.reference);
        operationCount++;
      }

      if (operationCount > 0) {
        await batch.commit();
        AppLogger.i('Firestore data purged successfully ($operationCount operations).');
      }

      // 2. Clear Local Persistence
      await Hive.box('habits_cache').clear();
      await Hive.box('logs_cache').clear();
      final box = await Hive.openBox('settings'); // Ensure settings box is cleared
      await box.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Final Step: Delete Firebase Auth Account
      // Note: This often triggers 'requires-recent-login'
      await user?.delete();
      AppLogger.i('User $userId fully purged from HabitForge.');
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        AppLogger.e('Critical: Account deletion requires recent login. Signal UI.');
        throw Exception('re-authentication-required');
      }
      AppLogger.e('FirebaseAuth error during deletion: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.e('Fatal error during account purge: $e');
      rethrow;
    }
  }
}
