import 'dart:io';
import 'package:flutter/material.dart';
import 'perfil_usuario_screen.dart';
import 'seguridad_screen.dart';
import '../models/user_model.dart';
import 'ayuda_soporte_screen.dart';
import 'login_screen.dart';
import '../presenters/ajustes_presenter.dart';
import '../contracts/ajustes_contract.dart';
import '../widgets/common_widgets.dart';

class AjustesScreen extends StatefulWidget {
  final User user;

  const AjustesScreen({super.key, required this.user});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen>
    implements AjustesContract {
  late AjustesPresenter _presenter;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _presenter = AjustesPresenter(this);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilUsuarioScreen(
          user: _currentUser,
          onUserUpdated: (updatedUser) {
            updateCurrentUser(updatedUser);
          },
        ),
      ),
    );
  }

  @override
  void updateCurrentUser(User updatedUser) {
    if (mounted) {
      setState(() => _currentUser = updatedUser);
    }
  }

  @override
  void navigateToSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeguridadScreen(user: _currentUser),
      ),
    );
  }

  @override
  void navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AyudaSoporteScreen()),
    );
  }

  @override
  Future<bool> showLogoutConfirmation() async {
    return await ConfirmLogoutDialog.show(context);
  }

  @override
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0066FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.deepOrange, size: 30),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Configuración",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "UCIFitness",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildUserCard(),
            const SizedBox(height: 25),
            const Text(
              "Cuenta",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildOptionItem(
              icon: Icons.person_outline,
              title: "Perfil de usuario",
              onTap: () => _presenter.openProfile(),
            ),
            _buildOptionItem(
              icon: Icons.lock_outline,
              title: "Seguridad",
              onTap: () => _presenter.openSecurity(),
            ),
            _buildOptionItem(
              icon: Icons.help_outline,
              title: "Ayuda y soporte",
              onTap: () => _presenter.openHelp(),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(
              icon: Icons.logout,
              title: "Cerrar sesión",
              isDestructive: true,
              onTap: () => _presenter.performLogout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    final bool hasPhoto =
        _currentUser.foto != null && _currentUser.foto!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade800,
            backgroundImage: hasPhoto
                ? FileImage(File(_currentUser.foto!))
                : null,
            child: !hasPhoto
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  _currentUser.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "Rol: ${_getRoleLabel(_currentUser.role)}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Administrador';
      case 'admin':
        return 'Administrador';
      case 'arbitro':
        return 'Árbitro';
      case 'user':
        return 'Usuario Básico';
      case 'capitan':
        return 'Capitán';
      default:
        return role;
    }
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.black26,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
