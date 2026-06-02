import 'package:admin_app/core/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/admin_auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: adminAuthProvider),
      ],
      child: const KangrowAdminApp(),
    ),
  );
}

class KangrowAdminApp extends StatelessWidget {
  const KangrowAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kangrow Admin',
      theme: AdminTheme.darkTheme, // Premium dark theme by default
      darkTheme: AdminTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: adminRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
