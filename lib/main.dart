import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inventory/product_manager.dart';
import 'inventory/lock_manager.dart';
import 'theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/lock_check_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductManager()),
        ChangeNotifierProvider(
            create: (_) => LockManager()), // <-- LockManager added here
      ],
      child: const SLRApp(),
    ),
  );
}

class SLRApp extends StatelessWidget {
  const SLRApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SouqNote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: themeProvider.themeMode,
      home: const LockCheckWrapper(
          child: HomeScreen()), // <-- wrapped with LockCheckWrapper
    );
  }
}
