// login.dart
import 'package:flutter/material.dart';
import 'main.dart'; // Importa la página de notas

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // ⚠️ NOTA: Este es un login SIMULADO sin Firebase Auth
    // En una aplicación real, usarías FirebaseAuth.instance.signInWithEmailAndPassword
    
    // Simulación: Comprobar que los campos no estén vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Muestra un error o mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa email y contraseña.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // **REAL:** Aquí iría la lógica de Firebase Auth
      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );
      
      // Simulación de un retraso de red
      await Future.delayed(const Duration(seconds: 2));

      // Navegar a la página de notas, reemplazando la ruta (para que el usuario no pueda volver al login)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NotesPage(),
          ),
        );
      }
    } catch (e) {
      // **REAL:** Manejo de errores de Firebase Auth (por ejemplo, credenciales incorrectas)
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de Login: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Título o Logo
            const Text(
              'Bienvenido a Notas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 40),

            // Campo Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Campo Contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Botón de Login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón de registro (Opcional, para indicar la funcionalidad completa)
            TextButton(
              onPressed: () {
                // Aquí iría la navegación a la página de registro
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ir a la página de registro...')),
                );
              },
              child: const Text("¿No tienes cuenta? Regístrate aquí"),
            ),
          ],
        ),
      ),
    );
  }
}