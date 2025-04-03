import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp()); // Ya tenía 'const' correctamente
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor ya correcto

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( // Añadí 'const' aquí
      title: 'PostWare',
      home: LoginScreen(), // Este es el origen de las advertencias
    );
  }
}