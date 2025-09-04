import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/password_recovery_request.dart';
import '../widgets/theme_switch_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showAllErrors = false;
  final FocusNode _tokenFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _apiService.resetPassword(
          token: _tokenController.text,
          nuevaPassword: _passwordController.text,
        );

        if (!mounted) return;

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar de vuelta a la pantalla de login
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          String errorMsg =
              result['message'] ?? 'Error al restablecer la contraseña';
          if (errorMsg.toLowerCase().contains('token')) {
            errorMsg =
                'El token es inválido o ha expirado. Solicita uno nuevo.';
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No se pudo restablecer la contraseña'),
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
        if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        actions: const [
          ThemeSwitchButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 40.0),
                  child: Image.asset(
                    'lib/assets/images/postware_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'Ingresa el token recibido en tu correo y tu nueva contraseña',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _tokenController,
                  focusNode: _tokenFocus,
                  autovalidateMode: (_showAllErrors || _tokenFocus.hasFocus)
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: 'Token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  buildCounter: (_,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El token es requerido';
                    }
                    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                      return 'El token debe ser un código de 4 dígitos';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  autovalidateMode: (_showAllErrors || _passwordFocus.hasFocus)
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
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
                    if (value == null || value.trim().isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    if (!RegExp(r'\d').hasMatch(value)) {
                      return 'Debe contener al menos un número';
                    }
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Debe contener al menos un carácter especial';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Debe contener al menos una mayúscula';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  obscureText: _obscurePassword,
                  autovalidateMode:
                      (_showAllErrors || _confirmPasswordFocus.hasFocus)
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    // No suffixIcon aquí, solo en nueva contraseña
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe confirmar la contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handlePasswordReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Restablecer Contraseña',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tokenFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }
}
