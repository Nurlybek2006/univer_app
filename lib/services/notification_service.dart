import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/hive_service.dart';

/// Фоналық хабарламаларды өңдеу (top-level function — isolate талабы)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background-та flutter_local_notifications жұмыс жасамайды,
  // FCM өзі тікелей system tray-ге шығарады.
}

/// Push хабарлама сервисі
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'univer_channel',
    'Студент хабарламалары',
    description: 'ҚазҰПУ Студент Көмекшісі хабарламалары',
    importance: Importance.high,
    playSound: true,
  );

  /// Инициализация — main.dart-тан шақырылады
  Future<void> init() async {
    // Android notification channel
    await _local.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Local notifications init
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground FCM хабарламасын local notification-ға айналдыру
    FirebaseMessaging.onMessage.listen((msg) {
      final notificationsOn =
          HiveService.settings.get('notifications', defaultValue: true) as bool;
      if (!notificationsOn) return;
      _showLocal(
        title: msg.notification?.title ?? msg.data['title'] ?? 'Хабарлама',
        body: msg.notification?.body ?? msg.data['body'] ?? '',
        payload: jsonEncode(msg.data),
      );
    });
  }

  /// Хабарлама рұқсатын сұрау және FCM токенін сақтау
  Future<void> requestPermissionAndSaveToken(String uid) async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(uid, token);
      }
      // Токен жаңарғанда қайта сақтау
      _fcm.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(uid, newToken);
      });
    }
  }

  Future<void> _saveTokenToFirestore(String uid, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});
    } catch (_) {}
  }

  /// Жергілікті хабарлама көрсету
  Future<void> _showLocal({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    await _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
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
      payload: payload,
    );
  }

  /// Жергілікті хабарлама көрсету (сыртқы шақыру үшін)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final notificationsOn =
        HiveService.settings.get('notifications', defaultValue: true) as bool;
    if (!notificationsOn) return;
    await _showLocal(
      title: title,
      body: body,
      payload: payload,
      id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Болашақта маршруттауды осында қосуға болады
  }

  /// Студенттің жеке хабарламаларын Firestore-дан тыңдау.
  /// Жаңа (isRead=false) хабарлама келгенде local notification шығарады.
  /// Логин болған кезде бір рет шақырылады.
  void listenForMessages(String uid) {
    FirebaseFirestore.instance
        .collection('messages')
        .where('studentId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      final notificationsOn =
          HiveService.settings.get('notifications', defaultValue: true) as bool;
      if (!notificationsOn) return;

      for (final change in snapshot.docChanges) {
        // Тек жаңадан қосылған хабарламаларда ғана notification шығар
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final title = data['title'] as String? ?? 'Жаңа хабарлама';
          final body = data['body'] as String? ?? '';
          _showLocal(
            title: '✉️ $title',
            body: body,
            payload: change.doc.id,
            id: change.doc.id.hashCode & 0x7FFFFFFF,
          );
        }
      }
    });
  }
}
