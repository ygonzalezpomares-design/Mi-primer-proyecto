/// Contrato para la pantalla de Registro
/// Define los métodos que debe implementar la vista y el presentador
abstract class RegisterContract {
  /// Interfaz de la Vista
  /// Muestra un indicador de carga
  void showLoading();

  /// Oculta el indicador de carga
  void hideLoading();

  /// Navega a la pantalla principal con el usuario registrado
  void navigateToMainScreen(dynamic user);

  /// Muestra un mensaje (error o éxito)
  void showMessage(String message);

  /// Navega de regreso a la pantalla de login
  void navigateBack();
}

/// Interfaz del Presentador
abstract class Presenter {
  /// Registra un nuevo usuario
  Future<void> registerUser({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String confirmPassword,
    required bool aceptaTerminos,
  });

  /// Navega de regreso a login
  void goBackToLogin();

  /// Limpia recursos del presentador
  void dispose();
}
