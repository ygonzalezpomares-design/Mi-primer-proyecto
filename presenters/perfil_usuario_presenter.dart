import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../database_helper.dart';
import '../models/user_model.dart';
import '../contracts/perfil_usuario_contract.dart';

class PerfilUsuarioPresenter implements Presenter {
  final PerfilUsuarioContract _view;
  final DatabaseHelper _dbHelper;
  final ImagePicker _picker;
  User _currentUser;

  PerfilUsuarioPresenter(this._view, this._currentUser)
      : _dbHelper = DatabaseHelper(),
        _picker = ImagePicker();

  @override
  Future<void> updateField(String field, String newValue) async {
    final sanitizedValue = _sanitizeInput(newValue);

    if (sanitizedValue.isEmpty) {
      _view.showError("El campo no puede estar vacío");
      return;
    }

    if (field == 'nombre' && !_validarNombre(sanitizedValue)) {
      _view.showError("El nombre solo puede contener letras y espacios (2-50 caracteres)");
      return;
    }

    if (field == 'email' && !_validarEmail(sanitizedValue)) {
      _view.showError("Ingresa un correo electrónico válido");
      return;
    }

    if (field == 'telefono' && !_validarTelefono(sanitizedValue)) {
      _view.showError("El teléfono debe tener exactamente 8 dígitos");
      return;
    }

    _view.showLoading();

    try {
      User updatedUser = User(
        id: _currentUser.id,
        nombre: field == 'nombre' ? sanitizedValue : _currentUser.nombre,
        email: field == 'email' ? sanitizedValue : _currentUser.email,
        telefono: field == 'telefono' ? sanitizedValue : _currentUser.telefono,
        password: _currentUser.password,
        role: _currentUser.role,
        foto: _currentUser.foto,
      );

      await _dbHelper.updateUser(updatedUser);

      _currentUser = updatedUser;

      _view.hideLoading();

      if (field == 'nombre') {
        _view.updateNombre(sanitizedValue);
      } else if (field == 'email') {
        _view.updateEmail(sanitizedValue);
      } else if (field == 'telefono') {
        _view.updateTelefono(sanitizedValue);
      }

      _view.showSuccess("Datos actualizados correctamente");
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al actualizar: ${e.toString()}");
    }
  }

  @override
  Future<void> pickAndUpdatePhoto() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (selectedImage != null) {
        _view.showLoading();

        File imageFile = File(selectedImage.path);

        User updatedUser = User(
          id: _currentUser.id,
          nombre: _currentUser.nombre,
          email: _currentUser.email,
          telefono: _currentUser.telefono,
          password: _currentUser.password,
          role: _currentUser.role,
          foto: selectedImage.path,
        );

        int resultado = await _dbHelper.updateUser(updatedUser);

        _view.hideLoading();

        if (resultado > 0) {
          _currentUser = updatedUser;
          _view.updateProfileImage(imageFile);
          _view.showSuccess("Foto de perfil actualizada correctamente");
        } else {
          _view.showError("Error al guardar la foto");
        }
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al seleccionar imagen: ${e.toString()}");
    }
  }

  @override
  void requestEditField(String title, String field, String currentValue) {
    _view.showEditDialog(title, field, currentValue);
  }

  @override
  void dispose() {}

  String _sanitizeInput(String input) {
    String result = input.trim();
    result = result.replaceAll('<', '');
    result = result.replaceAll('>', '');
    result = result.replaceAll('"', '');
    result = result.replaceAll("'", '');
    return result;
  }

  bool _validarNombre(String nombre) {
    if (nombre.length < 2 || nombre.length > 50) return false;
    if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(nombre)) return false;
    return RegExp(r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$').hasMatch(nombre);
  }

  bool _validarEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);
  }

  bool _validarTelefono(String telefono) {
    return RegExp(r'^\d{8}$').hasMatch(telefono);
  }
}