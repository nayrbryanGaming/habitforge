import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Stream to listen for notification selections in the UI
  static final _notificationStreamController = StreamController<String?>.broadcast();
  static Stream<String?> get onNotificationTap => _notificationStreamController.stream;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _notificationStreamController.add(response.payload);
        }
      },
    );

    // Create notification channel (Android)
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDesc,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Handle FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }


  Future<void> requestPermission() async {
    // 1. Request FCM Permission (iOS & Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('User granted notification permission.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      AppLogger.i('User granted provisional notification permission.');
    } else {
      AppLogger.i('User declined or has not accepted notification permission.');
    }

  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.i('Background Notification Tapped: ${message.data}');
    final habitId = message.data['habitId'];
    if (habitId != null) {
      _notificationStreamController.add(habitId);
    }
  }

  // Schedule daily habit reminder
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitTitle,
    required int hour,
    required int minute,
    required List<int> days, // 1=Mon, 7=Sun
  }) async {
    await cancelHabitReminder(habitId);

    for (final day in days) {
      final id = '${habitId}_$day'.hashCode;
      await _localNotifications.zonedSchedule(
        id,
        '⚡ Time to forge your habit!',
        'Don\'t break your streak — complete "$habitTitle" now!',
        _nextInstanceOfDayTime(day, hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDesc,
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              'Don\'t break your streak — complete "$habitTitle" now! 🔥',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      ).catchError((e) async {
        if (e.toString().contains('SecurityException')) {
          AppLogger.e('Exact alarm failed (SecurityException), falling back to inexact...');
          await _localNotifications.zonedSchedule(
            id,
            '⚡ Time to forge your habit!',
            'Don\'t break your streak — complete "$habitTitle" now!',
            _nextInstanceOfDayTime(day, hour, minute),
            NotificationDetails(
              android: AndroidNotificationDetails(
                AppConstants.notificationChannelId,
                AppConstants.notificationChannelName,
                channelDescription: AppConstants.notificationChannelDesc,
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      });
    }
  }

  // Cancel habit reminder
  Future<void> cancelHabitReminder(String habitId) async {
    for (int day = 1; day <= 7; day++) {
      final id = '${habitId}_$day'.hashCode;
      await _localNotifications.cancel(id);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get FCM Token
  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  // Schedule next instance of given day+time
  tz.TZDateTime _nextInstanceOfDayTime(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Find next occurrence of the target weekday
    // weekday indices: 1=Mon, 7=Sun
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
