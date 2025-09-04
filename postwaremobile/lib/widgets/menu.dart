import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/catalog_screen.dart';
import '../screens/orders_screen.dart';
import '../services/biometric_service.dart';

class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) async {
        switch (value) {
          case 'mi_perfil':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
          case 'mis_pedidos':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
            break;
          case 'catalogo':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CatalogScreen(),
              ),
            );
            break;
          case 'cerrar_sesion':
            await AuthService.logout();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'mi_perfil',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Mi Perfil'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'mis_pedidos',
          child: ListTile(
            leading: Icon(Icons.list),
            title: Text('Mis Pedidos'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'catalogo',
          child: ListTile(
            leading: Icon(Icons.category),
            title: Text('Catálogo'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'cerrar_sesion',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
          ),
        ),
      ],
    );
  }
}
