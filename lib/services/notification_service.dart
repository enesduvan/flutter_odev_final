import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _notificationsAvailable = true;

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'todo_reminders',
      'Todo Hatırlatıcı',
      channelDescription: 'Görev hatırlatma bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    if (kIsWeb) {
      _notificationsAvailable = false;
      _isInitialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    try {
      await _plugin.initialize(initializationSettings);
      await _requestPermissions();
      _isInitialized = true;
    } on MissingPluginException {
      _notificationsAvailable = false;
      _isInitialized = true;
    } on PlatformException {
      _notificationsAvailable = false;
      _isInitialized = true;
    } on UnimplementedError {
      _notificationsAvailable = false;
      _isInitialized = true;
    }
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleTodoReminder({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_notificationsAvailable) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    try {
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on MissingPluginException {
      _notificationsAvailable = false;
    } on PlatformException {
      _notificationsAvailable = false;
    } on UnimplementedError {
      _notificationsAvailable = false;
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_notificationsAvailable) {
      return;
    }
    try {
      await _plugin.cancel(notificationId);
    } on MissingPluginException {
      _notificationsAvailable = false;
    } on PlatformException {
      _notificationsAvailable = false;
    } on UnimplementedError {
      _notificationsAvailable = false;
    }
  }
}
