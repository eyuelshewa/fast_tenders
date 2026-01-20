import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/navigation/app_router.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://sqbqjagpflsynyzbpbtg.supabase.com',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxYnFqYWdwZmxzeW55emJwYnRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0NTc1OTgsImV4cCI6MjA4NDAzMzU5OH0.Mg6wVqSD0ZHnCeIrL_Wt-URc_mvkj-l0UEximp_HvnY',
  );

  runApp(const ProviderScope(child: TenderWinApp()));
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class TenderWinApp extends StatelessWidget {
  const TenderWinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TenderWin Ethiopia',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
