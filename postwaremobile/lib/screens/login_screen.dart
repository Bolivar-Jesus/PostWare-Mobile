import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo de la aplicación
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: Image.asset(
                    'lib/assets/images/postware_logo.png', // Asegúrate de que esta ruta coincida con tu archivo
                    height: 120, // Ajusta este valor según el tamaño de tu logo
                    fit: BoxFit.contain,
                  ),
                ),

                // Campo de Usuario
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Campo de Contraseña
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // Divisor
                const Divider(thickness: 1.0),
                const SizedBox(height: 30.0),

                // Botón de Iniciar Sesión
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Enlaces inferiores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Aún no tienes cuenta?',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Botón de Registrarse
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}