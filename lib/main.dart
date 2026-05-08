import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'features/todos/presentation/screens/todo_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator(); // Инициализация графа зависимостей

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Список задач',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          foregroundColor: Color(0xFF0F172A),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.blueGrey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0F766E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}
