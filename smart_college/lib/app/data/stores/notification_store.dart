import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/notification_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/repositories/notification_repository.dart';

class NotificationStore {
  final INotificationRepository repository;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<NotificationModel>> state = ValueNotifier<List<NotificationModel>>([]);
  final ValueNotifier<String> error = ValueNotifier<String>('');

  NotificationStore({required this.repository});

  Future<void> getNotifications() async {
    isLoading.value = true;
    error.value = '';
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token'); // Obtém o token
      final result = await repository.getNotifications(token); // Passa o token
      state.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    isLoading.value = true;
    error.value = '';
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token'); // Obtém o token
      await repository.deleteNotification(notificationId, token); // Passa o token
      state.value = state.value.where((notification) => notification.id != notificationId).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}