// Contrato para la pantalla de Ajustes
// Define los métodos que debe implementar la vista y el presentador

import '../models/user_model.dart';

// Interfaz de la Vista
abstract class AjustesContract {
  /// Navega a la pantalla de perfil de usuario
  void navigateToProfile();

  /// Navega a la pantalla de seguridad
  void navigateToSecurity();

  /// Navega a la pantalla de ayuda y soporte
  void navigateToHelp();

  /// Muestra el diálogo de confirmación de cierre de sesión
  Future<bool> showLogoutConfirmation();

  /// Cierra sesión y navega al login
  void logout();

  /// Actualiza el usuario actual en la vista
  void updateCurrentUser(User updatedUser);
}

/// Interfaz del Presentador
abstract class AjustesPresenterContract {
  /// Abre la pantalla de perfil
  void openProfile();

  /// Abre la pantalla de seguridad
  void openSecurity();

  /// Abre la pantalla de ayuda
  void openHelp();

  /// Cierra la sesión del usuario (con confirmación)
  Future<void> performLogout();

  /// Limpia recursos del presentador
  void dispose();
}
