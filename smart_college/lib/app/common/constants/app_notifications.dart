import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/notification_model.dart';
import 'package:smart_college/app/data/repositories/notification_repository.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

const String notificationChannelId = 'notification_channel_id';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  await _createNotificationChannel();
}

Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, 
    'Notificações', 
    description: 'Canal de notificações SmartCollege',
    importance: Importance.max, 
    playSound: true, 
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

 Future<void> showNotification(NotificationModel notification) async {
  try {
    DateTime now = DateTime.now();

    if (notification.scheduledTime.year == now.year &&
        notification.scheduledTime.month == now.month &&
        notification.scheduledTime.day == now.day) {

      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        notificationChannelId,
        'Notificações',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: 'logo',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      
      int notificationIdInt = notification.id.hashCode.remainder(100000); 

      await flutterLocalNotificationsPlugin.show(
          notificationIdInt,
          notification.title,
          notification.body,
          platformChannelSpecifics
      );

      final IHttpClient httpClient = HttpClient();
      final notificationRepository = NotificationRepository(client: httpClient);
      
      String? token = await AppStrings.secureStorage.read(key: 'token');
      if (token == null) {
        throw Exception('Token não encontrado.');
      }

      await notificationRepository.deleteNotification(notification.id, token);
    }
  } catch (e) {
    throw e; 
  }
}
