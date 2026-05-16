import '../database_helper.dart';
import '../contracts/login_contract.dart';
import '../utils/auth_utils.dart';

class LoginPresenter implements LoginContractPresenter {
  final LoginContractView _view;
  final DatabaseHelper _dbHelper;

  LoginPresenter(this._view) : _dbHelper = DatabaseHelper();

  @override
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _view.showError("Por favor, llena todos los campos");
      return;
    }

    if (!AuthUtils.isValidEmail(email)) {
      _view.showError("Ingresa un correo electrónico válido");
      return;
    }

    _view.showLoading();

    try {
      // Intentar login
      bool loginExitoso = await _dbHelper.login(email, password);

      if (loginExitoso) {
        // Obtener el usuario completo
        final user = await _dbHelper.getUserByEmail(email);

        if (user != null) {
          _view.hideLoading();
          _view.navigateToMainScreen(user);
        } else {
          _view.hideLoading();
          _view.showError("Error al obtener información del usuario");
        }
      } else {
        _view.hideLoading();
        _view.showError("Correo o contraseña incorrectos");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al iniciar sesión: ${e.toString()}");
    }
  }

  @override
  void goToRegister() {
    _view.navigateToRegister();
  }

  @override
  void dispose() {
  }
}
