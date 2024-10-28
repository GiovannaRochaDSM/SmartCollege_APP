import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/notification_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/common/constants/app_notifications.dart';
import 'package:smart_college/app/data/repositories/notification_repository.dart';

class NotificationHelper {
  static Future<List<NotificationModel>> fetchNotifications() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      final response = await http.get(
        Uri.parse(AppRoutes.notifications),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<NotificationModel> notifications = jsonResponse
            .map((data) => NotificationModel.fromMap(data))
            .toList();

        DateTime now = DateTime.now();
        for (var notification in notifications) {
          DateTime scheduledTime = notification.scheduledTime;
          if (scheduledTime.year == now.year &&
              scheduledTime.month == now.month &&
              scheduledTime.day == now.day) {
            await showNotification(notification);
          }
        }

        return notifications;
      } else {
        throw Exception('Falha ao carregar as notificações, tente novamente.');
      }
    } catch (e) {
      throw Exception('Falha interna ao carregar as notificações: $e');
    }
  }
}
