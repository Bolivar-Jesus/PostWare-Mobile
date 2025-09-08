import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'forgot_password.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/login_request.dart';
import '../widgets/theme_switch_button.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberCredentials = false;
  bool _biometricAvailable = false;
  bool _biometricEnrolled = false;
  bool _showBiometricButton = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Cargar preferencias de recordar credenciales
    await _loadRememberPreference();

    // Cargar credenciales guardadas si "recordar" está activado
    await _loadSavedCredentials();

    // Inicializar sistema de biometría
    await _initBiometrics();
  }

  Future<void> _loadRememberPreference() async {
    final credentials = await AuthService.getSavedCredentials();
    setState(() {
      _rememberCredentials = credentials['rememberCredentials'] ?? false;
    });
  }

  Future<void> _loadSavedCredentials() async {
    if (_rememberCredentials) {
      final credentials = await AuthService.getSavedCredentials();
      final email = credentials['email'] as String?;
      final password = credentials['password'] as String?;

      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    }
  }

  Future<void> _initBiometrics() async {
    try {
      // Verificar si la biometría está disponible en el dispositivo
      final available = await BiometricService.isBiometricAvailable();

      if (!available) {
        setState(() {
          _biometricAvailable = false;
          _biometricEnrolled = false;
          _showBiometricButton = false;
        });
        return;
      }

      setState(() {
        _biometricAvailable = true;
      });

      // Solo verificar enrolamiento si hay credenciales guardadas
      final saved = await AuthService.getSavedCredentials();
      final savedEmail = saved['email'] as String?;
      final savedPassword = saved['password'] as String?;

      if (savedEmail != null &&
          savedEmail.isNotEmpty &&
          savedPassword != null &&
          savedPassword.isNotEmpty) {
        // Verificar si la huella está habilitada para este email
        final enrolled =
            await BiometricService.isAppFingerprintEnrolledForEmail(savedEmail);

        setState(() {
          _biometricEnrolled = enrolled;
          _showBiometricButton = enrolled;
        });
      } else {
        setState(() {
          _biometricEnrolled = false;
          _showBiometricButton = false;
        });
      }
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
        _biometricEnrolled = false;
        _showBiometricButton = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _apiService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (result['success'] == true) {
          // Verificar que la respuesta tenga la estructura esperada
          if (result['data'] == null) {
            throw Exception('Respuesta del servidor incompleta');
          }

          // Guardar credenciales
          final data = result['data'] as Map<String, dynamic>;

          // Verificar que los campos requeridos estén presentes
          if (data['idusuario'] == null || data['token'] == null) {
            throw Exception(
                'Campos requeridos faltantes en la respuesta del servidor');
          }

          final usuario = data['usuario'] as Map<String, dynamic>? ?? data;
          final token = data['token'] as String;
          final documentocliente = data['documentocliente']?.toString() ?? '';

          await AuthService.saveCredentials(
            userId: data['idusuario'] as int,
            name: usuario['nombre'] as String? ?? 'Usuario',
            email: usuario['email'] as String? ?? _emailController.text,
            role: usuario['rol']?.toString() ?? '2',
            token: token,
            password: _passwordController.text,
            documentocliente: documentocliente,
            rememberCredentials: _rememberCredentials,
          );

          // Preguntar si quiere habilitar huella SOLO si no está habilitada
          if (_biometricAvailable && !_biometricEnrolled) {
            final enroll = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('¿Habilitar inicio de sesión con huella?'),
                content: const Text(
                    '¿Deseas habilitar el inicio de sesión con tu huella para esta app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sí'),
                  ),
                ],
              ),
            );

            if (enroll == true) {
              final ok = await BiometricService.enrollFingerprintForApp(
                  _emailController.text);
              if (ok) {
                setState(() {
                  _biometricEnrolled = true;
                  _showBiometricButton = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Huella habilitada para iniciar sesión'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo habilitar la huella'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          Navigator.of(context)
              .pushNamedAndRemoveUntil('/catalog', (route) => false);
        } else {
          String errorMsg = result['message'] ?? 'Error en la solicitud';
          if (errorMsg.toLowerCase().contains('correo') ||
              errorMsg.toLowerCase().contains('usuario') ||
              errorMsg.toLowerCase().contains('contraseña')) {
            if (errorMsg.toLowerCase().contains('correo')) {
              errorMsg =
                  'Correo no registrado. No existe una cuenta con ese correo.';
            } else if (errorMsg.toLowerCase().contains('usuario') ||
                errorMsg.toLowerCase().contains('contraseña')) {
              errorMsg = 'Usuario o contraseña incorrectos.';
            }
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No se pudo iniciar sesión'),
              content: Text(errorMsg,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error de conexión'),
            content: Text('Error: ${e.toString()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleLoginWithFingerprint() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final saved = await AuthService.getSavedCredentials();
      final email = saved['email'] as String?;
      final password = saved['password'] as String?;

      // Verificar que haya credenciales válidas
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No hay credenciales válidas guardadas. Inicia sesión normalmente primero.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Autenticar con huella
      final ok = await BiometricService.authenticateWithAppFingerprint(email);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo autenticar con huella'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Si llegamos aquí, la autenticación fue exitosa
      // Hacer login automático con las credenciales guardadas
      final result = await _apiService.login(email, password);

      if (result['success'] == true) {
        // Verificar que la respuesta tenga la estructura esperada
        if (result['data'] == null) {
          throw Exception('Respuesta del servidor incompleta');
        }

        // Guardar credenciales nuevamente (por si el token cambió)
        final data = result['data'] as Map<String, dynamic>;

        // Verificar que los campos requeridos estén presentes
        if (data['idusuario'] == null || data['token'] == null) {
          throw Exception(
              'Campos requeridos faltantes en la respuesta del servidor');
        }

        final usuario = data['usuario'] as Map<String, dynamic>? ?? data;
        final token = data['token'] as String;
        final documentocliente = data['documentocliente']?.toString() ?? '';

        await AuthService.saveCredentials(
          userId: data['idusuario'] as int,
          name: usuario['nombre'] as String? ?? 'Usuario',
          email: usuario['email'] as String? ?? email,
          role: usuario['rol']?.toString() ?? '2',
          token: token,
          password: password,
          documentocliente: documentocliente,
          rememberCredentials: _rememberCredentials,
        );

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/catalog', (route) => false);
      } else {
        throw Exception('Error en login automático: ${result['message']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con huella: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        actions: const [ThemeSwitchButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40.0),
                // Logo o título
                const Icon(
                  Icons.account_circle,
                  size: 80.0,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Inicia sesión en tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40.0),

                // Campo de Email con validación
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
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
                const SizedBox(height: 20.0),

                // Campo de Contraseña con validación
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Switch para recordar credenciales
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _rememberCredentials,
                      onChanged: (value) {
                        setState(() {
                          _rememberCredentials = value;
                        });
                      },
                    ),
                    const Text('Recordar mis credenciales'),
                  ],
                ),
                const SizedBox(height: 30.0),

                // Divisor
                const Divider(thickness: 1.0),
                const SizedBox(height: 30.0),

                // Botón de Iniciar Sesión con validación
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
                const SizedBox(height: 12.0),

                // Botón de Iniciar Sesión con Huella (si disponible y enrolada)
                if (_showBiometricButton)
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleLoginWithFingerprint,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Iniciar sesión con huella'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),

                const SizedBox(height: 24.0),

                // Enlaces inferiores
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Botón de Registrarse
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  },
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
