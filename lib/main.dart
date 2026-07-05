// lib/main.dart
//
// Application entry point.
// Initialises Hive, SharedPreferences, and flutter_local_notifications
// before handing off to the Flutter widget tree.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/local_storage_service.dart';
import 'providers/provider.dart';
import 'app/app_shell.dart';
// Global notifications plugin instance.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preferred orientation — allows both portrait and landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Transparent system bars for immersive feel.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  // Initialise local storage (Hive + SharedPreferences).
  await LocalStorageService.instance.init();
  // Initialise local notifications.
  await _initNotifications();
  runApp(
    ProviderScope(
      overrides: [
        // Inject the already-initialised storage singleton.
        localStorageProvider.overrideWithValue(LocalStorageService.instance),
      ],
      child: const QuotelyApp(),
    ),
  );
}
/// Root application widget. Responds to theme and font-size changes reactively.
class QuotelyApp extends ConsumerWidget {
  const QuotelyApp({super.key});
  @override
Widget build(BuildContext context, WidgetRef ref) {
  final themeModeNotifier = ref.watch(themeModeProvider.notifier);

  final fontScale =
      ref.watch(fontSizeProvider.notifier).textScaleFactor;

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(fontScale),
    ),
    child: MaterialApp(
      title: 'Quotely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeNotifier.themeMode,
      home: const AppShell(),
    ),
  );
}
}
// ── Notification initialisation ──────────────────────────────────────────────
Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const initSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}