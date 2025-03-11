import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_monitor/screens/SignInScreen.dart';
import 'package:app_monitor/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Definir el router
  final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/home/:name', // Ruta con parametro
        builder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Invitado';
          return HomeScreen(name: name);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router, // Usar GoRouter
    );
  }
}
