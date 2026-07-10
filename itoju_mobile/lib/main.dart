// ignore_for_file: non_constant_identifier_names

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/features/auth/pages/app_lock.dart';
import 'package:itoju_mobile/features/auth/pages/auth_gate.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/firebase_options.dart';
import 'package:itoju_mobile/sync/purchase_service.dart';
import 'package:itoju_mobile/sync/sync_controller.dart';
import 'package:itoju_mobile/sync/sync_scheduler.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox(HiveKeys.appBox);
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 3));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

//Global Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final NavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return navigatorKey;
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _lockShowing = false;

  // Re-lock the app if it was backgrounded longer than this (WhatsApp-style).
  static const _lockAfter = Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Configure IAP (no-op unless RC_API_KEY is provided) and start the
    // connectivity-regained sync trigger.
    ref.read(purchaseServiceProvider).configure();
    ref.read(syncSchedulerProvider).start();
    // Attempt a sync on launch (no-op unless authenticated + entitled).
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerSync());
  }

  void _triggerSync() {
    // Fire-and-forget; runs only when the chosen cadence is due, and the engine
    // still gates on entitlement and guards re-entry.
    ref.read(syncControllerProvider).maybePeriodicSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _maybeLock();
      _triggerSync();
    }
  }

  Future<void> _maybeLock() async {
    if (_lockShowing) return;
    final bg = _backgroundedAt;
    if (bg == null || DateTime.now().difference(bg) < _lockAfter) return;
    // App-lock protects local health data, which exists without an account, so
    // it no longer depends on having a session token.
    if (!Session.isAppLockEnabled()) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    _lockShowing = true;
    await nav.push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AppLockScreen(
        onUnlocked: () => navigatorKey.currentState?.pop(),
      ),
    ));
    _lockShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        useInheritedMediaQuery: true,
        minTextAdapt: true,
        designSize: const Size(375, 812),
        builder: (context, _) => GestureDetector(
              onTap: () {
                unfocus();
              },
              child: ToastificationWrapper(
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  initialRoute: '/',
                  routes: {
                    '/': (context) => const AuthGate(),
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'Itoju Health',
                  theme: ThemeData(
                    fontFamily: 'Axiforma',
                    colorScheme:
                        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                ),
              ),
            ));
  }
}

void unfocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
