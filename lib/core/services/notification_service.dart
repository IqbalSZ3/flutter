import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/installments/data/models/installment_model.dart';
import '../../features/subscriptions/data/models/subscription_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _notificationsPlugin.initialize(settings: initSettings);

    if (Platform.isAndroid) {
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleInstallments(List<InstallmentModel> installments) async {
    for (final inst in installments) {
      if (inst.isCompleted) continue;

      // Identify the very next payment schedule item
      final schedule = inst.paymentSchedule;
      final nextOverdueOrUnpaid = schedule.where((e) => !e.isPaid).toList();
      if (nextOverdueOrUnpaid.isEmpty) continue;
      
      final nextItem = nextOverdueOrUnpaid.first;

      // Notify 1 day before due date at 10 AM
      final scheduledDate = DateTime(
        nextItem.dueDate.year,
        nextItem.dueDate.month,
        nextItem.dueDate.day - 1,
        10, // 10:00 AM
      );

      // Unique ID for this installment payment
      final id = inst.id.hashCode;
      final title = 'Installment Due Tomorrow: ${inst.name}';
      final body = 'Payment ${nextItem.number}/${inst.tenure} is due tomorrow.';

      await _scheduleReminder(id: id, title: title, body: body, scheduledDate: scheduledDate);
    }
  }

  Future<void> scheduleSubscriptions(List<SubscriptionModel> subscriptions) async {
    for (final sub in subscriptions) {
      final daysBefore = sub.reminderDaysBefore ?? 3;
      final scheduledDate = DateTime(
        sub.nextRenewalDate.year,
        sub.nextRenewalDate.month,
        sub.nextRenewalDate.day - daysBefore,
        10, // 10:00 AM
      );

      // Unique ID
      final id = sub.id.hashCode;
      final title = 'Subscription Renewal: ${sub.name}';
      final body = 'Renews in $daysBefore days on ${sub.nextRenewalDate.day}/${sub.nextRenewalDate.month}';

      await _scheduleReminder(id: id, title: title, body: body, scheduledDate: scheduledDate);
    }
  }

  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Only schedule if it's in the future
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'billing_reminders',
      'Billing Reminders',
      channelDescription: 'Reminders for bills, subscriptions, and installments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
