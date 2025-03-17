import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/providers/evidence_providers.dart';
import 'package:app_monitor/providers/evidence_detail_provider.dart';
import 'package:app_monitor/views/evidence_detail_screen.dart';
import 'package:app_monitor/views/evidence_list_screen.dart';
import 'package:app_monitor/views/SignInScreen.dart';
import 'package:app_monitor/views/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses =
      await [
        Permission.storage,
        Permission.photos, // Android 14 usa READ_MEDIA_IMAGES
      ].request();

  // Verificar si los permisos fueron concedidos
  if (statuses[Permission.storage]?.isDenied == true ||
      statuses[Permission.photos]?.isDenied == true) {
    print("Permiso denegado. No se podrá acceder a las imágenes.");
  }

  if (statuses[Permission.storage]?.isPermanentlyDenied == true ||
      statuses[Permission.photos]?.isPermanentlyDenied == true) {
    print("El usuario bloqueó el permiso permanentemente. Mostrar diálogo.");
    openAppSettings(); // Abre la configuración del sistema
  }
}
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions(); // Solicita los permisos antes de iniciar la app
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
