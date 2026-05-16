// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../presenters/seguridad_presenter.dart';
import '../contracts/seguridad_contract.dart';

class SeguridadScreen extends StatefulWidget {
  final User user;

  const SeguridadScreen({super.key, required this.user});

  @override
  State<SeguridadScreen> createState() => _SeguridadScreenState();
}

class _SeguridadScreenState extends State<SeguridadScreen>
    implements SeguridadContract {
  late SeguridadPresenter _presenter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = SeguridadPresenter(this, widget.user);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  // Implementación de SeguridadContract.View
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void showPasswordDialog() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente azul
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seguridad de la cuenta",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Cambiar Contraseña",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cuerpo
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo: Contraseña actual
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.deepOrange.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Contraseña Actual",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: currentPassController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ingresa tu contraseña actual...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Campo: Contraseña nueva
                    Row(
                      children: [
                        Icon(
                          Icons.lock_open_outlined,
                          color: Colors.deepOrange.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Nueva Contraseña",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: newPassController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ingresa tu nueva contraseña...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (currentPassController.text.isNotEmpty &&
                                  newPassController.text.isNotEmpty) {
                                _presenter.changePassword(
                                  currentPassController.text,
                                  newPassController.text,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Guardar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void showPermissionsDialog(List<User> users) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modificar Permisos"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta el diálogo al contenido

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Subtítulo con iniciales
            const Text(
              "AD: Admin | CP: Capitán | AR: Árbitro | UB: Usuario Basico",

              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const Divider(),

            SizedBox(
              width: double.maxFinite,

              height: 300,

              child: ListView.builder(
                itemCount: users.length,

                itemBuilder: (context, index) {
                  final u = users[index];

                  final String roleLower = u.role.toLowerCase();

                  // Icono según el rol actual

                  IconData roleIcon;
                  String roleLetter;
                  String displayRole;
                  if (roleLower == 'admin' || roleLower == 'superadmin') {
                    roleIcon = Icons.verified_user;
                    roleLetter = "AD";
                    displayRole = roleLower == 'superadmin'
                        ? "SuperAdmin"
                        : "Admin";
                  } else if (roleLower == 'capitan') {
                    roleIcon = Icons.military_tech;
                    roleLetter = "CP";
                    displayRole = "Capitán";
                  } else if (roleLower == 'arbitro') {
                    roleIcon = Icons.real_estate_agent;
                    roleLetter = "AR";
                    displayRole = "Árbitro";
                  } else {
                    roleIcon = Icons.person_outline;
                    roleLetter = "UB";
                    displayRole = "Usuario Básico";
                  }
                  // No permitir modificar superadmin
                  final bool isSuperAdmin = roleLower == 'superadmin';
                  return ListTile(
                    leading: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, color: Colors.deepOrange),
                        Text(
                          roleLetter,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    title: Text(
                      u.nombre,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text("Rol: ${u.role}"),

                        const SizedBox(height: 4),

                        if (isSuperAdmin)
                          const Icon(Icons.lock, color: Colors.grey, size: 20)
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              // Opción Admin
                              Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,

                                    icon: Icon(
                                      Icons.verified_user,

                                      color: roleLower == 'admin'
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),

                                    onPressed: () =>
                                        _presenter.toggleUserRole(u),
                                  ),

                                  const Text(
                                    "AD",

                                    style: TextStyle(
                                      fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // Opción Capitán
                              Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,

                                    icon: Icon(
                                      Icons.military_tech,

                                      color: roleLower == 'capitan'
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),

                                    onPressed: () =>
                                        _presenter.toggleUserCaptain(u),
                                  ),

                                  const Text(
                                    "CP",

                                    style: TextStyle(
                                      fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // Opción Árbitro
                              Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,

                                    icon: Icon(
                                      Icons.real_estate_agent,

                                      color: roleLower == 'arbitro'
                                          ? Colors.green
                                          : Colors.grey,
                                    ),

                                    onPressed: () =>
                                        _presenter.toggleUserArbitro(u),
                                  ),

                                  const Text(
                                    "AR",

                                    style: TextStyle(
                                      fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Opción Árbitro
                              Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmarEliminacion(u),
                                  ),

                                  const Text(
                                    "Borrar",

                                    style: TextStyle(
                                      fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para confirmar antes de borrar
  void _confirmarEliminacion(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text(
          "¿Estás seguro de que deseas eliminar a ${user.nombre}? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo de confirmación
              _presenter.deleteUser(user); // Llama al presentador
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void closeDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.user.role.toLowerCase() == 'admin';
    final bool isSuperAdmin = widget.user.role.toLowerCase() == 'superadmin';

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Seguridad",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin || isSuperAdmin) ...[
                    const Text(
                      "Administración",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSecurityCard(
                      icon: Icons.admin_panel_settings,
                      title: "Gestión de Permisos",
                      subtitle: "Cambiar roles de otros usuarios",
                      onTap: () => _presenter.openPermissionsDialog(),
                    ),
                    const SizedBox(height: 25),
                  ],
                  const Text(
                    "Seguridad de la Cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSecurityCard(
                    icon: Icons.lock_reset,
                    title: "Cambiar Contraseña",
                    subtitle: "Actualiza tu clave de acceso",
                    onTap: () => _presenter.openPasswordDialog(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSecurityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
