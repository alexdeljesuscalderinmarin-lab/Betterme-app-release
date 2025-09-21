// lib/services/notification_service.dart
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    await _setupTimezone();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // ✅ NUEVO: Verificar permisos de notificaciones
  Future<bool> hasPermission() async {
    try {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  // ✅ NUEVO: Solicitar permisos
  Future<bool> requestPermission() async {
    try {
      // Para Android, normalmente los permisos se manejan automáticamente
      // Para iOS, se solicita a través de initialize()
      return true;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> _setupTimezone() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.local);
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse details) {
    // Lógica cuando se toca una notificación
  }

  // ✅ NUEVO: Notificaciones diarias para recordatorios de comidas
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminders_channel',
      'Recordatorios Diarios',
      channelDescription: 'Recordatorios para comidas y ejercicios diarios',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'daily_reminders',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ✅ MANTENER: Recordatorios de workouts programados
  Future<void> scheduleWorkoutReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      scheduledDate.subtract(const Duration(minutes: 30)),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'workout_reminder_channel',
      'Recordatorios de Entrenamiento',
      channelDescription: 'Recordatorios para tus sesiones de ejercicio programadas',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'workout_reminders',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ✅ MANTENER: Notificaciones de logros desbloqueados
  Future<void> showAchievementUnlocked({
    required String achievementName,
    required String achievementDescription,
    required String popCultureReference,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'achievement_channel',
        'Logros Desbloqueados',
        channelDescription: 'Notificaciones de logros y trofeos',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        Random().nextInt(1000),
        '🎉 $achievementName',
        '$achievementDescription\n$popCultureReference',
        notificationDetails,
      );
    } catch (e) {
      print('Error showing achievement notification: $e');
    }
  }

  // ✅ MANTENER: Alertas de progreso semanal
  Future<void> scheduleWeeklyProgressReport() async {
    DateTime nextSunday = DateTime.now();
    while (nextSunday.weekday != DateTime.sunday) {
      nextSunday = nextSunday.add(const Duration(days: 1));
    }
    final DateTime scheduledTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 20, 0);
    final tz.TZDateTime scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Reportes de Progreso',
      channelDescription: 'Resúmenes semanales de tu progreso fitness y nutricional',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      threadIdentifier: 'weekly_progress',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      100,
      '📊 Tu Progreso Semanal',
      'Revisa cómo te fue esta semana en BetterMe! Toca para ver tu reporte.',
      scheduledTzTime,
      details,
      payload: 'weekly_progress',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ✅ NUEVO: Notificación simple inmediata
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'general_channel', 
      'Notificaciones Generales',
      channelDescription: 'Notificaciones generales de la aplicación',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      Random().nextInt(1000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelScheduledWorkoutReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // ✅ NUEVO: Cancelar notificación específica por ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // ✅ NUEVO: Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}