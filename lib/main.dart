import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EmoSyncApp());
}

class EmoSyncApp extends StatelessWidget {
  const EmoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: AuthProvider.navigatorKey,
        title: 'EmoSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF8A65),
          ),
          useMaterial3: true,
        ),
        home: const EmoSyncSplashScreen(),
      ),
    );
  }
}