import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/home_widget/presentation/providers/home_widget_providers.dart';
import 'features/lockscreen/presentation/providers/lockscreen_providers.dart';
import 'features/reminders/presentation/providers/reminder_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final localStorage = SharedPrefsLocalStorage(prefs);

  // Initialize home_widget with app group ID.
  // On Android this is required to initialize the shared preferences namespace.
  // On iOS this would point to a real App Group; for now Android-only build.
  await HomeWidget.setAppGroupId('com.timeflow.timeflow');

  runApp(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(localStorage)],
      child: const TimeFlowApp(),
    ),
  );
}

class TimeFlowApp extends ConsumerStatefulWidget {
  const TimeFlowApp({super.key});

  @override
  ConsumerState<TimeFlowApp> createState() => _TimeFlowAppState();
}

class _TimeFlowAppState extends ConsumerState<TimeFlowApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifService = ref.read(localNotificationServiceProvider);
      await notifService.initialize(
        onNotificationTap: (taskId) {
          appRouter.go('/tasks');
        },
      );
      await notifService.requestPermissions();

      // Initial lockscreen notification sync on startup
      final lockscreenPayload = ref.read(lockscreenPayloadProvider);
      await ref
          .read(lockscreenBridgeProvider)
          .updateOngoingNotification(lockscreenPayload);

      // Initial home screen widget sync on startup
      final homeWidgetPayload = ref.read(homeWidgetPayloadProvider);
      await ref
          .read(homeWidgetServiceProvider)
          .updateWidgets(homeWidgetPayload);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final homeWidgetPayload = ref.read(homeWidgetPayloadProvider);
      ref.read(homeWidgetServiceProvider).updateWidgets(homeWidgetPayload);

      final lockscreenPayload = ref.read(lockscreenPayloadProvider);
      ref
          .read(lockscreenBridgeProvider)
          .updateOngoingNotification(lockscreenPayload);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appReminderSyncListenerProvider);
    ref.watch(lockscreenAutoSyncListenerProvider);
    ref.watch(homeWidgetAutoSyncListenerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
    );
  }
}
