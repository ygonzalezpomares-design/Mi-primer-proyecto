import '../database_helper.dart';
import '../models/user_model.dart';
import '../contracts/register_contract.dart';
import '../utils/auth_utils.dart';

class RegisterPresenter implements Presenter {
  final RegisterContract _view;
  final DatabaseHelper _dbHelper;

  RegisterPresenter(this._view) : _dbHelper = DatabaseHelper();

  @override
  Future<void> registerUser({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String confirmPassword,
    required bool aceptaTerminos,
  }) async {
    if (nombre.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        telefono.isEmpty) {
      _view.showMessage("Por favor, llena los campos obligatorios");
      return;
    }

    if (!AuthUtils.isValidEmail(email)) {
      _view.showMessage("Ingresa un correo electrónico válido");
      return;
    }

    if (!_validarNombre(nombre)) {
      _view.showMessage(
        "El nombre solo puede contener letras y espacios (2-50 caracteres)",
      );
      return;
    }

    if (!_validarTelefono(telefono)) {
      _view.showMessage("El teléfono debe tener exactamente 8 dígitos");
      return;
    }

    if (!AuthUtils.isValidPassword(password)) {
      _view.showMessage(
        "La contraseña debe tener mínimo 8 caracteres, al menos una mayúscula, una minúscula y un número",
      );
      return;
    }

    if (password != confirmPassword) {
      _view.showMessage("Las contraseñas no coinciden");
      return;
    }

    if (!aceptaTerminos) {
      _view.showMessage("Debes aceptar los términos y condiciones");
      return;
    }

    _view.showLoading();

    try {
      User nuevoUsuario = User(
        nombre: nombre,
        email: email,
        telefono: telefono,
        password: AuthUtils.hashPassword(password),
        role: 'user',
      );

      int resultado = await _dbHelper.registerUser(nuevoUsuario);

      _view.hideLoading();

      if (resultado != 0) {
        _view.navigateToMainScreen(nuevoUsuario);
      } else {
        _view.showMessage("El correo ya existe");
      }
    } catch (e) {
      _view.hideLoading();
      _view.showMessage("Error al registrar: ${e.toString()}");
    }
  }

  @override
  void goBackToLogin() {
    _view.navigateBack();
  }

  @override
  void dispose() {}

  bool _validarNombre(String nombre) {
    if (nombre.length < 2 || nombre.length > 50) return false;
    if (!RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(nombre)) return false;
    return RegExp(r'^[A-ZÁÉÍÓÚÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ\s]*$').hasMatch(nombre);
  }

  bool _validarTelefono(String telefono) {
    return RegExp(r'^\d{8}$').hasMatch(telefono);
  }
}
