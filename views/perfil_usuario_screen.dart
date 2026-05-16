import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';
import '../models/user_model.dart';
import '../presenters/perfil_usuario_presenter.dart';
import '../contracts/perfil_usuario_contract.dart';
import '../widgets/common_widgets.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  final User user;
  final Function(User)? onUserUpdated;

  const PerfilUsuarioScreen({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen>
    implements PerfilUsuarioContract {
  late PerfilUsuarioPresenter _presenter;
  File? _image;
  late User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _presenter = PerfilUsuarioPresenter(this, _currentUser);

    if (_currentUser.foto != null && _currentUser.foto!.isNotEmpty) {
      _image = File(_currentUser.foto!);
    }
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void updateProfileImage(File image) {
    if (mounted) {
      setState(() {
        _image = image;
        // Actualizar _currentUser con la nueva ruta de foto
        _currentUser = User(
          id: _currentUser.id,
          nombre: _currentUser.nombre,
          email: _currentUser.email,
          telefono: _currentUser.telefono,
          password: _currentUser.password,
          role: _currentUser.role,
          foto: image.path, // 👈 Guardar ruta de la nueva foto
        );
      });
      // Notificar a AjustesScreen inmediatamente con el usuario actualizado
      widget.onUserUpdated?.call(_currentUser);
    }
  }

  @override
  void updateNombre(String nombre) {
    if (mounted) {
      setState(() {
        _currentUser = User(
          id: _currentUser.id,
          nombre: nombre,
          email: _currentUser.email,
          telefono: _currentUser.telefono,
          password: _currentUser.password,
          role: _currentUser.role,
          foto: _currentUser.foto,
        );
      });
      widget.onUserUpdated?.call(_currentUser);
    }
  }

  @override
  void updateEmail(String email) {
    if (mounted) {
      setState(() {
        _currentUser = User(
          id: _currentUser.id,
          nombre: _currentUser.nombre,
          email: email,
          telefono: _currentUser.telefono,
          password: _currentUser.password,
          role: _currentUser.role,
          foto: _currentUser.foto,
        );
      });
      widget.onUserUpdated?.call(_currentUser);
    }
  }

  @override
  void updateTelefono(String telefono) {
    if (mounted) {
      setState(() {
        _currentUser = User(
          id: _currentUser.id,
          nombre: _currentUser.nombre,
          email: _currentUser.email,
          telefono: telefono,
          password: _currentUser.password,
          role: _currentUser.role,
          foto: _currentUser.foto,
        );
      });
      widget.onUserUpdated?.call(_currentUser);
    }
  }

  @override
  void showEditDialog(String title, String field, String currentValue) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    IconData fieldIcon;
    switch (field) {
      case 'nombre':
        fieldIcon = Icons.person_outline;
        break;
      case 'email':
        fieldIcon = Icons.email_outlined;
        break;
      case 'telefono':
        fieldIcon = Icons.phone_android_outlined;
        break;
      default:
        fieldIcon = Icons.edit_outlined;
    }

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
              // Header con gradiente azul — igual que ejercicios/equipo
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
                      child: Icon(fieldIcon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Editar campo",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
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

              // Cuerpo del formulario
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label con icono deepOrange — igual que el resto de la app
                    Row(
                      children: [
                        Icon(
                          fieldIcon,
                          color: Colors.deepOrange.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Nuevo $title",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Campo de texto con fondo blue.shade100
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ingrese $title...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: field == 'telefono'
                            ? TextInputType.phone
                            : field == 'email'
                            ? TextInputType.emailAddress
                            : TextInputType.text,
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
                              if (controller.text.isNotEmpty) {
                                Navigator.pop(context);
                                _presenter.updateField(
                                  field,
                                  controller.text.trim(),
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
  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void showError(String message) {
    if (!mounted) return;
    MessageOverlay.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Perfil de Usuario",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white24,
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : null,
                          child: _image == null
                              ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _presenter.pickAndUpdatePhoto(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildAttributeItem(
                    icon: Icons.person_outline,
                    label: "Nombre Completo",
                    value: _currentUser.nombre,
                    onEdit: () => _presenter.requestEditField(
                      "Nombre",
                      "nombre",
                      _currentUser.nombre,
                    ),
                  ),
                  _buildAttributeItem(
                    icon: Icons.email_outlined,
                    label: "Correo Electrónico",
                    value: _currentUser.email,
                    onEdit: () => _presenter.requestEditField(
                      "Correo",
                      "email",
                      _currentUser.email,
                    ),
                  ),
                  _buildAttributeItem(
                    icon: Icons.phone_android_outlined,
                    label: "Teléfono",
                    value: _currentUser.telefono,
                    onEdit: () => _presenter.requestEditField(
                      "Teléfono",
                      "telefono",
                      _currentUser.telefono,
                    ),
                  ),
                  _buildAttributeItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: "Rol de Usuario",
                    value: _getRoleLabel(_currentUser.role),
                    canEdit: false,
                  ),
                ],
              ),
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

  Widget _buildAttributeItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
    bool canEdit = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.blue),
                onPressed: onEdit,
              )
            : null,
      ),
    );
  }
}
