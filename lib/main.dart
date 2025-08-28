import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'db_helper.dart'; Handles local SQLite database (currently not needed, working with isar.)
import 'inventory/product_manager.dart'; // Product and sales state management
import 'theme_provider.dart';
import 'screens/home_screen.dart'; // Import HomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DBHelper().database;
  runApp(
    MultiProvider(
      providers: [
        // Theme provider to handle light/dark theme switching
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // ProductManager handles products, sales, and credits
        ChangeNotifierProvider(create: (_) => ProductManager()),
      ],
      child: const SLRApp(),
    ),
  );
}

class SLRApp extends StatelessWidget {
  const SLRApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SouqNote',
      // Light theme configuration
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Dark theme configuration
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Select theme mode based on user preference
      themeMode: themeProvider.themeMode,

      // Main screen shown when the app launches
      home: const HomeScreen(),
    );
  }
}
