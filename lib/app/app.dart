import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/router.dart';
import 'package:taarak/app/theme.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/sync/application/sync_providers.dart';

class TaarakApp extends ConsumerWidget {
  const TaarakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kept alive for the app's lifetime so M17's sync-on-reconnect trigger
    // is always listening, independent of which screen is on top.
    ref.watch(syncOnReconnectTriggerProvider);

    // Router redirects assume the session restore is already resolved, so
    // hold on a splash screen until then rather than teaching the router
    // about a loading state.
    final isRestoringSession = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    if (isRestoringSession) {
      return MaterialApp(
        title: 'TAARAK',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const _SplashScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TAARAK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TAARAK', style: TextStyle(fontSize: 28)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
