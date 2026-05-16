import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'package:sqflite/sqflite.dart';

class AppColors {
  static const Color fondo = Color(0xFF0066FF);
  static const Color blancoInput = Color(0xFFFFFFFF);
  static const Color deepOrange = Colors.deepOrange;
  static const Color textoBlanco = Color(0xFFFFFFFF);
  static const Color textoOscuro = Color(0xFF333333);
  static const Color textoInactivo = Color(0xFFA0A0A0);
  static const Color primario = Color(0xFF1A5F7A);
  static const Color secundario = Colors.deepOrange;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await openDatabase('temp.db');
  final result = await db.rawQuery('SELECT sqlite_version()');
  print('>>> SQLite: ${result.first.values.first}');
  await db.close();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UCIFitness',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.fondo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
