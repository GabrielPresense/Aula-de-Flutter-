import 'package:appcontabancaria/views/home.dart';
import 'package:flutter/material.dart';

class AppContaBancaria extends StatelessWidget {
  const AppContaBancaria({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue.shade600,
        ),
      ),
      home: const Home(),
    );
  }
}
