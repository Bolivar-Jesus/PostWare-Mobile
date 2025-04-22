import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Client client;
  const EditProfileScreen({Key? key, required this.client}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.client.nombre);
    _apellidoController = TextEditingController(text: widget.client.apellido);
    _emailController = TextEditingController(text: widget.client.email);
    _telefonoController = TextEditingController(text: widget.client.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // Construir nuevo Client con campos actualizados
      final updatedClient = Client(
        id: widget.client.id,
        documentocliente: widget.client.documentocliente,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        estado: widget.client.estado,
      );
      await _apiService.updateClientProfile(updatedClient);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Información'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 