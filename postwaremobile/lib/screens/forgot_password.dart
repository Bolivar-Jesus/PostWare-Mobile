import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/password_recovery_request.dart';
import '../widgets/theme_switch_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _showAllErrors = false;
  final FocusNode _emailFocus = FocusNode();

  Future<void> _handlePasswordRecovery() async {
    setState(() {
      _showAllErrors = true;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result =
            await _apiService.requestPasswordRecovery(_emailController.text);

        if (!mounted) return;

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Revisa tu correo'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/reset-password');
        } else {
          String errorMsg = result['message'] ?? 'Error en la solicitud';
          // Si el error es por correo no registrado, mostrar mensaje amigable
          if ((result['error'] ?? '').contains('correo') ||
              errorMsg.toLowerCase().contains('correo')) {
            errorMsg =
                'Correo no registrado. No existe una cuenta con ese correo.';
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No se pudo recuperar la contraseña'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        actions: const [
          ThemeSwitchButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20.0),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32.0),
                    child: Image.asset(
                      'lib/assets/images/postware_logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    'Ingresa tu correo electrónico para recuperar tu contraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    autovalidateMode: (_showAllErrors || _emailFocus.hasFocus)
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
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
                      if (value == null || value.trim().isEmpty) {
                        return 'El email es requerido';
                      }
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
                      if (!emailRegex.hasMatch(value)) {
                        return 'El formato del email no es válido';
                      }
                      if (value.length > 100) {
                        return 'El email excede la longitud máxima permitida';
                      }
                      if (RegExp(r'[<>()[\]\\,;:\s"]+').hasMatch(value)) {
                        return 'El email contiene caracteres no permitidos';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handlePasswordRecovery,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Enviar Instrucciones',
                            style: TextStyle(fontSize: 16.0),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver al Login'),
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
    _emailFocus.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
