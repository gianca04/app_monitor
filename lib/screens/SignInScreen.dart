import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondo.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ), // Transparencia
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20), // Aumentar padding
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                // Hacer los bordes más redondeados
                side: BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ), // Color azul en los bordes
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15), // Aumentar padding
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildLogo(),
                      buildTitle(),
                      SizedBox(height: 20),
                      buildDescription(),
                      buildUsernameTextField(),
                      buildPasswordTextField(),
                      SizedBox(height: 20),
                      buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Image.asset('assets/images/LOGO-SAT.png', width: 250, height: 200),
    );
  }

  Widget buildTitle() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: const Text(
        'SAT - MONITOR',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildDescription() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: const Text(
        'Inicia sesión con las credenciales Asignadas',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildUsernameTextField() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: nameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            // Color azul para el borde
            borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
          ),
          labelText: 'Correo',
        ),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextField(
        obscureText: true,
        controller: passwordController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            // Color azul para el borde
            borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
          ),
          labelText: 'Contraseña',
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () => _login(),
        child: const Text('Acceder', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _login() async {
    String name = 'Juan'; // Aquí deberías obtener el nombre real del usuario
    context.go('/home/$name'); // Navegar con parámetro

    /*try {
      if (nameController.text.isEmpty || passwordController.text.isEmpty) {
        _showSnackbar(
          "${nameController.text.isEmpty ? "Correo " : ""}${passwordController.text.isEmpty ? "Contraseña " : ""} requerido",
        );
        return;
      } else {
        _showSnackbar("Validando credenciales...");
        String email = nameController.text;
        String password = passwordController.text;

        try {
          String userId = await usuarioProvider.iniciarSesion(email, password);
          if (userId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(name: 'gian')),
            );
          } else {
            _showSnackbar("Usuario inexistente");
          }
        } catch (e) {
          _showSnackbar("Error al validar: $e");
        }
      }
    } catch (e) {
      _showSnackbar("Error inesperado: $e");
    }
    */
  }
}
