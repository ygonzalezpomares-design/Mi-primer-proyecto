import '../contracts/ajustes_contract.dart';

/// Presentador para la pantalla de Ajustes
/// Maneja la lógica de navegación entre opciones
class AjustesPresenter implements AjustesPresenterContract {
  final AjustesContract _view;

  AjustesPresenter(this._view);

  @override
  void openProfile() {
    _view.navigateToProfile();
  }

  @override
  void openSecurity() {
    _view.navigateToSecurity();
  }

  @override
  void openHelp() {
    _view.navigateToHelp();
  }

  @override
  Future<void> performLogout() async {
    final confirmed = await _view.showLogoutConfirmation();
    if (confirmed) {
      _view.logout();
    }
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
  }
}
