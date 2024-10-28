import 'package:workmanager/workmanager.dart';
import 'package:smart_college/app/data/helpers/fetch_notifications.dart';


void scheduleNotificationFetch() {
  Workmanager().registerPeriodicTask(
    'fetchNotifications',
    'fetchNotifications',
    frequency: const Duration(minutes: 15), 
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationHelper.fetchNotifications();  
    return Future.value(true);
  });
}