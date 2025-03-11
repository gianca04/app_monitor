import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String name;
  const HomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Hola, $name 👋", style: TextStyle(fontSize: 24)),
    );
  }
}
