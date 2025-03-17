import 'package:app_monitor/views/evidence_create.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:app_monitor/views/evidence_list_screen.dart';
import 'package:app_monitor/screens/ProfilePage.dart';
import 'package:app_monitor/views/evidence_search.dart';

class HomeScreen extends StatefulWidget {
  //final String name;
  //const HomeScreen({super.key, required this.name});
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas dentro del Bottom Navigation Bar
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      EvidenceListScreen(),
      CreateEvidenceForm(),
      EvidenceSearchScreen(),
      ProfilePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("Bienvenido, ${widget.name}")),
      body: _screens[_selectedIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Inicio"),
            selectedColor: Colors.purple,
          ),

          SalomonBottomBarItem(
            icon: Icon(Icons.add_a_photo),
            title: Text("Agregar Evidencia"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Filtrar evidencias"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Perfil"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
