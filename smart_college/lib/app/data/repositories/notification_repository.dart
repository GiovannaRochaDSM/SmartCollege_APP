import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/notification_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications(String? token);
  Future<bool> addNotification(NotificationModel notification, String? token);
  Future<bool> deleteNotification(String notificationId, String? token);
}

class NotificationRepository implements INotificationRepository {
  final IHttpClient client;

  NotificationRepository({required this.client});

  @override
  Future<List<NotificationModel>> getNotifications(String? token) async {
    final response = await client.get(
      url: AppRoutes.notifications,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<NotificationModel> notifications = [];
      final List<dynamic> body = jsonDecode(response.body);

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('id')) {
          final NotificationModel notification = NotificationModel.fromMap(item);
          notifications.add(notification);
        }
      }
      return notifications;
    } else {
      throw Exception('Não foi possível carregar as notificações. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> addNotification(NotificationModel notification, String? token) async {
    final response = await client.post(
      url: AppRoutes.notifications,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notification.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao adicionar a notificação. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteNotification(String notificationId, String? token) async {
    final response = await client.delete(
      url: '${AppRoutes.notifications}$notificationId',
      headers: {
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir a notificação. Status code: ${response.statusCode}');
    }
  }
}
