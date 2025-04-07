import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  
  String _document = '';
  String _name = '';
  String _lastName = '';
  String _phone = '';
  String _password = '';

  bool _validatePassword(String value) {
    final hasMinLength = value.length >= 8;
    final hasLowerCase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasMinLength && hasLowerCase && hasNumber && hasSpecialChar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo de la aplicación
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 40.0),
                    child: Image.asset(
                      'lib/assets/images/postware_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Campo de Documento
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Documento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su documento';
                      }
                      return null;
                    },
                    onSaved: (value) => _document = value!,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Nombre
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Apellido
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su apellido';
                      }
                      return null;
                    },
                    onSaved: (value) => _lastName = value!,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Teléfono
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su teléfono';
                      }
                      return null;
                    },
                    onSaved: (value) => _phone = value!,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Ingrese un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Confirmar Email
                  TextFormField(
                    controller: _confirmEmailController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirme su email';
                      }
                      if (value != _emailController.text) {
                        return 'Los emails no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Contraseña
                  TextFormField(
                    controller: _passwordController,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una contraseña';
                      }
                      if (!_validatePassword(value)) {
                        return 'La contraseña debe tener:\n- 8+ caracteres\n- 1 minúscula\n- 1 número\n- 1 caracter especial';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de Confirmar Contraseña
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirme su contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30.0),

                  // Botón de Registrarse
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registro exitoso')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Enlace para volver al Login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }
}