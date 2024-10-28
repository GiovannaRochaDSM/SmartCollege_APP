import 'package:flutter/material.dart';
import 'package:smart_college/app/app_widget.dart';
import 'package:smart_college/app/data/services/workmanager_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  scheduleNotificationFetch();
  runApp(const MyApp());
}
