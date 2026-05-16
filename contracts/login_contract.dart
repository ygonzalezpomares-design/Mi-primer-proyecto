// Contrato para la pantalla de Login
// Define los métodos que debe implementar la vista y el presentador

// Interfaz de la Vista
abstract class LoginContractView {
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Navega a la pantalla principal con el usuario autenticado
  void navigateToMainScreen(dynamic user);

  /// Muestra un mensaje de error
  void showError(String message);

  /// Navega a la pantalla de registro
  void navigateToRegister();
}

/// Interfaz del Presentador
abstract class LoginContractPresenter {
  /// Intenta iniciar sesión con email y contraseña
  Future<void> login(String email, String password);

  /// Navega a la pantalla de registro
  void goToRegister();

  /// Limpia recursos del presentador
  void dispose();
}
