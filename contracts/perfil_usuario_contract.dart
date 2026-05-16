import 'dart:io';

/// Contrato para la pantalla de Perfil de Usuario
/// Define los métodos que debe implementar la vista y el presentador
abstract class PerfilUsuarioContract {
  /// Interfaz de la Vista
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Actualiza la imagen de perfil en la vista
  void updateProfileImage(File image);

  /// Actualiza el nombre del usuario
  void updateNombre(String nombre);

  /// Actualiza el email del usuario
  void updateEmail(String email);

  /// Actualiza el teléfono del usuario
  void updateTelefono(String telefono);

  /// Muestra el diálogo de edición
  void showEditDialog(String title, String field, String currentValue);

  /// Muestra un mensaje de éxito
  void showSuccess(String message);

  /// Muestra un mensaje de error
  void showError(String message);
}

/// Interfaz del Presentador
abstract class Presenter {
  /// Actualiza un campo específico del usuario
  Future<void> updateField(String field, String newValue);

  /// Selecciona y actualiza la foto de perfil
  Future<void> pickAndUpdatePhoto();

  /// Solicita editar un campo
  void requestEditField(String title, String field, String currentValue);

  /// Limpia recursos del presentador
  void dispose();
}
