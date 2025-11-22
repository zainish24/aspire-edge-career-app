// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import 'package:aspire_edge/firebase_options.dart';
import 'package:aspire_edge/routes/route_constants.dart';
import 'package:aspire_edge/routes/router.dart' as router;
import 'package:aspire_edge/routes/screen_export.dart';
import 'package:aspire_edge/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print(
      '🚀 Successfully connected to Firebase project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  runApp(
    // MultiProvider(
    //   providers: [
    //     // add other providers here
    //   ],
    //   child: const MyApp(),
    // ),
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'aspire_edge',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.dark,
      onGenerateRoute: router.generateRoute,
      initialRoute: onbordingScreenRoute,
    );
  }
}
