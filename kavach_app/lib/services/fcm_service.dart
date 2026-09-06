import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FcmService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Ask for notification permission.
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get this device's FCM registration token.
    final token = await _messaging.getToken();

    print('=================================');
    print('HEATGUARD FCM TOKEN:');
    print(token);
    print('=================================');

    // Token can change, so listen for updates.
    _messaging.onTokenRefresh.listen((newToken) {
      print('HEATGUARD NEW FCM TOKEN:');
      print(newToken);
    });

    // Messages received while the app is open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('HEATGUARD FCM MESSAGE RECEIVED');

      final title =
          message.notification?.title ?? 'HEATGUARD Alert';

      final body =
          message.notification?.body ?? 'New heat warning received.';

      print('Title: $title');
      print('Body: $body');

      // Show a visible notification while the app is in foreground.
      await NotificationService.showFcmNotification(
        title: title,
        body: body,
      );
    });
  }
}