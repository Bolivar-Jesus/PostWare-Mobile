import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/client.dart';
import 'edit_profile_screen.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/cart_icon.dart';
import '../widgets/menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  Client? _client;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Cargar perfil usando el ID de usuario guardado internamente en ApiService
      final clientData = await _apiService.getClientProfile();

      if (mounted) {
        setState(() {
          _client = clientData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        String errorMsg = e.toString();
        if (errorMsg.toLowerCase().contains('perfil') ||
            errorMsg.toLowerCase().contains('no se encontró')) {
          errorMsg = 'No se encontró información de tu perfil.';
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al cargar el perfil'),
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
    }
  }

  Future<void> _updateProfile() async {
    if (_client != null) {
      try {
        await _apiService.updateClientProfile(_client!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        String errorMsg = e.toString();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al actualizar el perfil'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          const ThemeSwitchButton(),
          const CartIcon(),
          AppMenu(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _client == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No se encontró información del perfil'),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: $_errorMessage',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                _client!.nombre.isNotEmpty
                                    ? _client!.nombre[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(
                            "Información Personal",
                            [
                              _buildInfoRow("Nombre completo",
                                  "${_client!.nombre} ${_client!.apellido}"),
                              _buildInfoRow(
                                  "Tipo de documento", _client!.tipodocumento),
                              _buildInfoRow(
                                  "Documento", "${_client!.documentocliente}"),
                              _buildInfoRow("Estado",
                                  _client!.estado ? "Activo" : "Inactivo"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            "Contacto",
                            [
                              _buildInfoRow("Email", _client!.email),
                              _buildInfoRow("Teléfono", _client!.telefono),
                              _buildInfoRow("Municipio", _client!.municipio),
                              _buildInfoRow("Dirección", _client!.direccion),
                              _buildInfoRow("Barrio", _client!.barrio),
                              _buildInfoRow(
                                  "Complemento", _client!.complemento),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: _client != null && !_isLoading
          ? SafeArea(
              minimum: EdgeInsets.zero,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push<Client>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(client: _client!),
                        ),
                      );
                      if (updated != null) {
                        setState(() {
                          _client = updated;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Editar Información',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
