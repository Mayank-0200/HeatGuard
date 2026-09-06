import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    bool requestPermission = true,
  }) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );

    if (requestPermission) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
    }
  }

  // HEATGUARD background/local heat-risk alert
  static Future<void> showHeatAlert({
    required String risk,
    required String score,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'heatguard_alerts',
      'HEATGUARD Alerts',
      channelDescription: 'Heat risk notifications from HEATGUARD',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: 0,
      title: 'HEATGUARD Heat Alert',
      body: '$risk heat risk detected. Thermal stress score: $score',
      notificationDetails: details,
    );
  }

  // Firebase Cloud Messaging notification
  static Future<void> showFcmNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'heatguard_alerts',
      'HEATGUARD Alerts',
      channelDescription: 'HEATGUARD Firebase notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: 100,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}