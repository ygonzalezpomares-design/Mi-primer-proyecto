import '../models/user_model.dart';

/// Contrato para la pantalla de Seguridad
/// Define los métodos que debe implementar la vista y el presentador
abstract class SeguridadContract {
  /// Interfaz de la Vista

  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Muestra el diálogo de cambio de contraseña
  void showPasswordDialog();

  /// Muestra el diálogo de gestión de permisos con lista de usuarios
  void showPermissionsDialog(List<User> users);

  /// Muestra un mensaje de éxito
  void showSuccess(String message);

  /// Muestra un mensaje de error
  void showError(String message);

  /// Cierra el diálogo actual
  void closeDialog();
}

/// Interfaz del Presentador
abstract class Presenter {
  /// Cambia la contraseña del usuario actual
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Carga la lista de usuarios para gestión de permisos
  Future<void> loadUsersForPermissions();

  /// Borrar Usuario
  Future<void> deleteUser(User user);

  /// Cambia el rol de un usuario (alterna entre admin y user)
  Future<void> toggleUserRole(User user);

  /// Cambia el rol de un usuario (alterna entre capitan y user)
  Future<void> toggleUserCaptain(User user);

  /// Cambia el rol de un usuario (alterna entre arbitro y user)
  Future<void> toggleUserArbitro(User user);

  /// Abre el diálogo de cambio de contraseña
  void openPasswordDialog();

  /// Abre el diálogo de gestión de permisos
  void openPermissionsDialog();

  /// Limpia recursos del presentador
  void dispose();
}
