import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/registration_request.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _tipoDocumento;
  String _documento = '';
  String _nombre = '';
  String _apellido = '';
  String _email = '';
  String _telefono = '';
  String _municipio = '';
  String _complemento = '';
  String _direccion = '';
  String _barrio = '';
  String _password = '';

  Map<String, bool> _fieldAutovalidate = {};

  final FocusNode _tipoDocumentoFocus = FocusNode();
  final FocusNode _documentoFocus = FocusNode();
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _apellidoFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();
  final FocusNode _municipioFocus = FocusNode();
  final FocusNode _direccionFocus = FocusNode();
  final FocusNode _barrioFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _complementoFocus = FocusNode();

  bool _showAllErrors = false;

  @override
  void initState() {
    super.initState();
    _fieldAutovalidate = {
      'tipoDocumento': false,
      'documento': false,
      'nombre': false,
      'apellido': false,
      'email': false,
      'telefono': false,
      'municipio': false,
      'direccion': false,
      'barrio': false,
      'password': false,
      'confirmPassword': false,
    };
  }

  void _setFieldAutovalidate(String field, bool value) {
    setState(() {
      _fieldAutovalidate[field] = value;
    });
  }

  // Validaciones
  String? validateTipoDocumento(String? tipoDocumento) {
    if (tipoDocumento == null || tipoDocumento.isEmpty) {
      return 'El tipo de documento es requerido';
    }
    return null;
  }

  String? validateDocumento(String? documento) {
    if (documento == null || documento.trim().isEmpty) {
      return 'El documento es requerido';
    }
    if (!RegExp(r'^\d{7,10}').hasMatch(documento)) {
      return 'El documento debe tener entre 7 y 10 dígitos numéricos';
    }
    return null;
  }

  String? validateNombreApellido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El $campo es requerido';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{3,10}').hasMatch(valor)) {
      return 'El $campo debe tener entre 3 y 10 letras';
    }
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    if (!emailRegex.hasMatch(email)) {
      return 'El formato del email no es válido';
    }
    if (email.length > 100) {
      return 'El email excede la longitud máxima permitida';
    }
    if (RegExp(r'[<>()[\]\\,;:\s"]+').hasMatch(email)) {
      return 'El email contiene caracteres no permitidos';
    }
    return null;
  }

  String? validateTelefono(String? telefono) {
    if (telefono == null || telefono.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    if (!RegExp(r'^\d{10}').hasMatch(telefono)) {
      return 'El teléfono debe tener exactamente 10 dígitos numéricos';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'La contraseña es requerida';
    }
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'La contraseña debe contener al menos un carácter especial';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    return null;
  }

  String? validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return 'Debe confirmar la contraseña';
    }
    if (confirmPassword != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? validateMunicipio(String? municipio) {
    if (municipio == null || municipio.trim().isEmpty) {
      return 'El municipio es requerido';
    }
    if (municipio.trim().length < 3 || municipio.trim().length > 15) {
      return 'El municipio debe tener entre 3 y 15 caracteres';
    }
    return null;
  }

  String? validateComplemento(String? complemento) {
    if (complemento == null || complemento.trim().isEmpty) {
      return null;
    }
    if (complemento.trim().length < 3 || complemento.trim().length > 20) {
      return 'El complemento debe tener entre 3 y 20 caracteres';
    }
    return null;
  }

  String? validateDireccion(String? direccion) {
    if (direccion == null || direccion.trim().isEmpty) {
      return 'La dirección es requerida';
    }
    if (direccion.trim().length < 3 || direccion.trim().length > 20) {
      return 'La dirección debe tener entre 3 y 20 caracteres';
    }
    final numeros = RegExp(r'\d').allMatches(direccion);
    if (numeros.length < 2) {
      return 'La dirección debe contener al menos 2 números';
    }
    return null;
  }

  String? validateBarrio(String? barrio) {
    if (barrio == null || barrio.trim().isEmpty) {
      return 'El barrio es requerido';
    }
    if (barrio.trim().length < 3 || barrio.trim().length > 15) {
      return 'El barrio debe tener entre 3 y 15 caracteres';
    }
    return null;
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _showAllErrors = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final data = {
        "tipodocumento": _tipoDocumento,
        "documentocliente": int.parse(_documento),
        "nombre": _nombre,
        "apellido": _apellido,
        "email": _emailController.text,
        "telefono": _telefono,
        "municipio": _municipio,
        "complemento": _complemento,
        "direccion": _direccion,
        "barrio": _barrio,
        "password": _passwordController.text,
      };
      try {
        final result = await _apiService.registerClient(data);
        if (!mounted) return;
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          String errorMsg = result['message'] ?? 'Error en el registro';
          if (errorMsg.toLowerCase().contains('correo')) {
            errorMsg =
                'El correo ya está registrado. Usa otro correo o recupera tu contraseña.';
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No se pudo registrar'),
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
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 40.0),
                    child: Image.asset(
                      'lib/assets/images/postware_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Tipo de documento
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tipo de documento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    value: _tipoDocumento,
                    items: const [
                      DropdownMenuItem(
                          value: 'CC',
                          child: Text('Cédula de Ciudadanía (CC)')),
                      DropdownMenuItem(
                          value: 'CE',
                          child: Text('Cédula de Extranjería (CE)')),
                      DropdownMenuItem(
                          value: 'TI',
                          child: Text('Tarjeta de Identidad (TI)')),
                    ],
                    focusNode: _tipoDocumentoFocus,
                    autovalidateMode:
                        (_showAllErrors || _tipoDocumentoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    onChanged: (value) {
                      setState(() {
                        _tipoDocumento = value;
                      });
                    },
                    validator: validateTipoDocumento,
                  ),
                  const SizedBox(height: 16.0),
                  // Documento
                  TextFormField(
                    focusNode: _documentoFocus,
                    autovalidateMode:
                        (_showAllErrors || _documentoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
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
                    maxLength: 10,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    keyboardType: TextInputType.number,
                    validator: validateDocumento,
                    onSaved: (value) => _documento = value!,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Nombre
                  TextFormField(
                    focusNode: _nombreFocus,
                    autovalidateMode: (_showAllErrors || _nombreFocus.hasFocus)
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
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
                    maxLength: 10,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: (value) =>
                        validateNombreApellido(value, 'nombre'),
                    onSaved: (value) => _nombre = value!,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Apellido
                  TextFormField(
                    focusNode: _apellidoFocus,
                    autovalidateMode:
                        (_showAllErrors || _apellidoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
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
                    maxLength: 10,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: (value) =>
                        validateNombreApellido(value, 'apellido'),
                    onSaved: (value) => _apellido = value!,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Email
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
                    maxLength: 30,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Teléfono
                  TextFormField(
                    focusNode: _telefonoFocus,
                    autovalidateMode:
                        (_showAllErrors || _telefonoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
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
                    maxLength: 10,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    keyboardType: TextInputType.phone,
                    validator: validateTelefono,
                    onSaved: (value) => _telefono = value!,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Municipio
                  TextFormField(
                    focusNode: _municipioFocus,
                    autovalidateMode:
                        (_showAllErrors || _municipioFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: 'Municipio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    maxLength: 15,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validateMunicipio,
                    onChanged: (value) => setState(() {}),
                    onSaved: (value) => _municipio = value ?? '',
                  ),
                  const SizedBox(height: 16.0),
                  // Complemento
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Complemento',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    focusNode: _complementoFocus,
                    autovalidateMode:
                        (_showAllErrors || _complementoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    maxLength: 20,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validateComplemento,
                    onChanged: (value) => setState(() {}),
                    onSaved: (value) => _complemento = value ?? '',
                  ),
                  const SizedBox(height: 16.0),
                  // Dirección
                  TextFormField(
                    focusNode: _direccionFocus,
                    autovalidateMode:
                        (_showAllErrors || _direccionFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    maxLength: 20,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validateDireccion,
                    onChanged: (value) => setState(() {}),
                    onSaved: (value) => _direccion = value ?? '',
                  ),
                  const SizedBox(height: 16.0),
                  // Barrio
                  TextFormField(
                    focusNode: _barrioFocus,
                    autovalidateMode: (_showAllErrors || _barrioFocus.hasFocus)
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: 'Barrio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    maxLength: 15,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validateBarrio,
                    onChanged: (value) => setState(() {}),
                    onSaved: (value) => _barrio = value ?? '',
                  ),
                  const SizedBox(height: 16.0),
                  // Contraseña
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    autovalidateMode:
                        (_showAllErrors || _passwordFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                            _obscureConfirmPassword = _obscurePassword;
                          });
                        },
                      ),
                    ),
                    maxLength: 20,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validatePassword,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Confirmar contraseña
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    autovalidateMode:
                        (_showAllErrors || _confirmPasswordFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                    maxLength: 20,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    validator: validateConfirmPassword,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16.0),
                          ),
                  ),
                  const SizedBox(height: 16.0),
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
    _tipoDocumentoFocus.dispose();
    _documentoFocus.dispose();
    _nombreFocus.dispose();
    _apellidoFocus.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    _municipioFocus.dispose();
    _direccionFocus.dispose();
    _barrioFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _complementoFocus.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
