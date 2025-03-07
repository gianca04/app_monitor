import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String name;
  HomeScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido")),
      body: Center(
        child: Text("Hola, $name 👋", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
