import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/cart_icon.dart';
import '../widgets/menu.dart';

class EditProfileScreen extends StatefulWidget {
  final Client client;
  const EditProfileScreen({Key? key, required this.client}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _showAllErrors = false;

  // Controllers
  late TextEditingController _documentoController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _municipioController;
  late TextEditingController _direccionController;
  late TextEditingController _barrioController;
  late TextEditingController _complementoController;

  // FocusNodes
  final FocusNode _tipoDocumentoFocus = FocusNode();
  final FocusNode _documentoFocus = FocusNode();
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _apellidoFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();
  final FocusNode _municipioFocus = FocusNode();
  final FocusNode _direccionFocus = FocusNode();
  final FocusNode _barrioFocus = FocusNode();
  final FocusNode _complementoFocus = FocusNode();

  String? _tipoDocumento;
  Map<String, bool> _fieldAutovalidate = {};

  @override
  void initState() {
    super.initState();
    _tipoDocumento = widget.client.tipodocumento;
    _documentoController =
        TextEditingController(text: widget.client.documentocliente.toString());
    _nombreController = TextEditingController(text: widget.client.nombre);
    _apellidoController = TextEditingController(text: widget.client.apellido);
    _emailController = TextEditingController(text: widget.client.email);
    _telefonoController = TextEditingController(text: widget.client.telefono);
    _municipioController = TextEditingController(text: widget.client.municipio);
    _direccionController = TextEditingController(text: widget.client.direccion);
    _barrioController = TextEditingController(text: widget.client.barrio);
    _complementoController =
        TextEditingController(text: widget.client.complemento);
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
      'complemento': false,
    };
    // Forzar rebuild inicial para que el botón esté deshabilitado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _municipioController.dispose();
    _direccionController.dispose();
    _barrioController.dispose();
    _complementoController.dispose();
    _tipoDocumentoFocus.dispose();
    _documentoFocus.dispose();
    _nombreFocus.dispose();
    _apellidoFocus.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    _municipioFocus.dispose();
    _direccionFocus.dispose();
    _barrioFocus.dispose();
    _complementoFocus.dispose();
    super.dispose();
  }

  void _setFieldAutovalidate(String field, bool value) {
    setState(() {
      _fieldAutovalidate[field] = value;
    });
  }

  // Validaciones (idénticas a registro)
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

  Future<void> _saveProfile() async {
    setState(() {
      _showAllErrors = true;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> updatedFields = {};
      if (_tipoDocumento != widget.client.tipodocumento) {
        updatedFields['tipodocumento'] = _tipoDocumento;
      }
      if (_documentoController.text.trim() !=
          widget.client.documentocliente.toString()) {
        updatedFields['documentocliente'] =
            int.tryParse(_documentoController.text.trim()) ??
                widget.client.documentocliente;
      }
      if (_nombreController.text.trim() != widget.client.nombre) {
        updatedFields['nombre'] = _nombreController.text.trim();
      }
      if (_apellidoController.text.trim() != widget.client.apellido) {
        updatedFields['apellido'] = _apellidoController.text.trim();
      }
      if (_emailController.text.trim() != widget.client.email) {
        updatedFields['email'] = _emailController.text.trim();
      }
      if (_telefonoController.text.trim() != widget.client.telefono) {
        updatedFields['telefono'] = _telefonoController.text.trim();
      }
      if (_municipioController.text.trim() != widget.client.municipio) {
        updatedFields['municipio'] = _municipioController.text.trim();
      }
      if (_direccionController.text.trim() != widget.client.direccion) {
        updatedFields['direccion'] = _direccionController.text.trim();
      }
      if (_barrioController.text.trim() != widget.client.barrio) {
        updatedFields['barrio'] = _barrioController.text.trim();
      }
      if (_complementoController.text.trim() != widget.client.complemento) {
        updatedFields['complemento'] = _complementoController.text.trim();
      }
      if (updatedFields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay cambios para guardar.')),
        );
        setState(() => _isLoading = false);
        return;
      }
      await _apiService.updateClientProfilePartial(
          widget.client.documentocliente, updatedFields);
      final updatedClient = Client(
        id: widget.client.id,
        tipodocumento: _tipoDocumento ?? widget.client.tipodocumento,
        documentocliente: int.tryParse(_documentoController.text.trim()) ??
            widget.client.documentocliente,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        estado: widget.client.estado,
        municipio: _municipioController.text.trim(),
        complemento: _complementoController.text.trim(),
        direccion: _direccionController.text.trim(),
        barrio: _barrioController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedClient);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _hasChanges {
    return (_tipoDocumento != widget.client.tipodocumento) ||
        (_documentoController.text.trim() !=
            widget.client.documentocliente.toString()) ||
        (_nombreController.text.trim() != widget.client.nombre) ||
        (_apellidoController.text.trim() != widget.client.apellido) ||
        (_emailController.text.trim() != widget.client.email) ||
        (_telefonoController.text.trim() != widget.client.telefono) ||
        (_municipioController.text.trim() != widget.client.municipio) ||
        (_direccionController.text.trim() != widget.client.direccion) ||
        (_barrioController.text.trim() != widget.client.barrio) ||
        (_complementoController.text.trim() != widget.client.complemento);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Información'),
        actions: [
          const ThemeSwitchButton(),
          const CartIcon(),
          AppMenu(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    controller: _documentoController,
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
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Nombre
                  TextFormField(
                    controller: _nombreController,
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
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Apellido
                  TextFormField(
                    controller: _apellidoController,
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
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Teléfono
                  TextFormField(
                    controller: _telefonoController,
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
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Municipio
                  TextFormField(
                    controller: _municipioController,
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
                    validator: validateMunicipio,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Dirección
                  TextFormField(
                    controller: _direccionController,
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
                    validator: validateDireccion,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Barrio
                  TextFormField(
                    controller: _barrioController,
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
                    validator: validateBarrio,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  // Complemento
                  TextFormField(
                    controller: _complementoController,
                    focusNode: _complementoFocus,
                    autovalidateMode:
                        (_showAllErrors || _complementoFocus.hasFocus)
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
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
                    validator: validateComplemento,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 24.0),
                  SafeArea(
                    minimum: EdgeInsets.zero,
                    child: ElevatedButton(
                      onPressed:
                          (!_hasChanges || _isLoading) ? null : _saveProfile,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
