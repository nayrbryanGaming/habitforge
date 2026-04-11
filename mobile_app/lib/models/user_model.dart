import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String subscriptionStatus;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.subscriptionStatus,
    this.fcmToken,
  });

  bool get isPremium => subscriptionStatus == 'premium';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
      subscriptionStatus: json['subscription_status'] as String? ?? 'free',
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'subscription_status': subscriptionStatus,
      'fcm_token': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? subscriptionStatus,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
