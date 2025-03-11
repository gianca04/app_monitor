import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/providers/evidence_providers.dart';
import 'package:app_monitor/providers/evidence_detail_provider.dart';
import 'package:app_monitor/views/evidence_detail_screen.dart';
import 'package:app_monitor/views/evidence_list_screen.dart';
import 'package:app_monitor/views/SignInScreen.dart';
import 'package:app_monitor/views/home_screen.dart';

//
// ==============================
// RUTAS CON go_router
// ==============================
//

final GoRouter _router = GoRouter(
  initialLocation: '/signin',
  routes: [
    GoRoute(path: '/signin', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) => EvidenceListScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return Scaffold(body: Center(child: Text("ID inválido")));
            }
            return ChangeNotifierProvider(
              create: (_) => EvidenceDetailProvider(id)..loadEvidence(),
              child: EvidenceDetailScreen(evidenceId: id),
            );
          },
        ),
      ],
    ),
  ],
);

//
// ==============================
// PUNTO DE ENTRADA DE LA APP
// ==============================
//

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EvidenceProvider()..loadEvidences(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MONITOR SAC',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
