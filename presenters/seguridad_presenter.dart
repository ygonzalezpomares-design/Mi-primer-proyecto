import '../database_helper.dart';
import '../models/user_model.dart';
import '../contracts/seguridad_contract.dart';
import '../utils/auth_utils.dart';

class SeguridadPresenter implements Presenter {
  final SeguridadContract _view;
  final DatabaseHelper _dbHelper;
  final User _currentUser;

  SeguridadPresenter(this._view, this._currentUser)
    : _dbHelper = DatabaseHelper();

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (currentPassword.trim().isEmpty) {
      _view.showError("Debes ingresar tu contraseña actual");
      return;
    }

    if (newPassword.trim().isEmpty) {
      _view.showError("La nueva contraseña no puede estar vacía");
      return;
    }

    if (!_validarPassword(newPassword)) {
      _view.showError(
        "La contraseña debe tener mínimo 8 caracteres, al menos una mayúscula, una minúscula y un número",
      );
      return;
    }

    _view.showLoading();

    try {
      final storedHash = _currentUser.password;
      if (!AuthUtils.verifyPassword(currentPassword, storedHash)) {
        _view.hideLoading();
        _view.showError("La contraseña actual es incorrecta");
        return;
      }

      User updatedUser = User(
        id: _currentUser.id,
        nombre: _currentUser.nombre,
        email: _currentUser.email,
        telefono: _currentUser.telefono,
        password: AuthUtils.hashPassword(newPassword.trim()),
        role: _currentUser.role,
        foto: _currentUser.foto,
      );

      await _dbHelper.updateUser(updatedUser);

      _view.hideLoading();
      _view.closeDialog();
      _view.showSuccess("Contraseña actualizada correctamente");
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cambiar contraseña: ${e.toString()}");
    }
  }
  //Borrar Usuario

  @override
  Future<void> deleteUser(User userToDelete) async {
    // 1. Validar permisos: Solo superadmin o admin pueden eliminar
    if (!AuthUtils.canManageUsers(_currentUser.role)) {
      _view.showError("No tienes permisos para eliminar usuarios");
      return;
    }

    // 2. Impedir que se elimine a sí mismo
    if (userToDelete.id == _currentUser.id) {
      _view.showError("No puedes eliminar tu propia cuenta desde este panel");
      return;
    }

    // 3. Impedir que un admin borre a un superadmin
    if (userToDelete.role.toLowerCase() == 'superadmin') {
      _view.showError("No se puede eliminar al superadministrador del sistema");
      return;
    }

    _view.showLoading();

    try {
      await _dbHelper.deleteUser(userToDelete.id!);

      _view.hideLoading();
      _view.closeDialog(); // Cierra el diálogo de permisos para refrescar
      _view.showSuccess(
        "Usuario ${userToDelete.nombre} eliminado correctamente",
      );

      // Opcional: Recargar la lista automáticamente
      // loadUsersForPermissions();
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al eliminar usuario: ${e.toString()}");
    }
  }

  @override
  Future<void> loadUsersForPermissions() async {
    _view.showLoading();

    try {
      if (!AuthUtils.canManageUsers(_currentUser.role)) {
        _view.hideLoading();
        _view.showError("No tienes permisos para gestionar usuarios");
        return;
      }

      final users = await _dbHelper.getAllUsers();
      _view.hideLoading();
      _view.showPermissionsDialog(users);
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cargar usuarios: ${e.toString()}");
    }
  }

  @override
  Future<void> toggleUserRole(User user) async {
    if (!AuthUtils.canChangeRoles(_currentUser.role)) {
      _view.showError("Solo un superadministrador puede cambiar roles");
      return;
    }

    if (user.role.toLowerCase() == 'superadmin') {
      _view.showError("No puedes modificar el rol de un superadministrador");
      return;
    }

    _view.showLoading();

    try {
      String nuevoRol = user.role.toLowerCase() == 'admin' ? 'user' : 'admin';

      User updatedUser = User(
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        telefono: user.telefono,
        password: user.password,
        role: nuevoRol,
        foto: user.foto,
      );

      await _dbHelper.updateUser(updatedUser);

      _view.hideLoading();
      _view.closeDialog();
      _view.showSuccess("Rol actualizado a: $nuevoRol");
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cambiar rol: ${e.toString()}");
    }
  }

  @override
  Future<void> toggleUserCaptain(User user) async {
    if (!AuthUtils.canManageUsers(_currentUser.role)) {
      _view.showError("No tienes permisos para gestionar usuarios");
      return;
    }

    if (user.role.toLowerCase() == 'superadmin') {
      _view.showError("No puedes cambiar el rol de un administrador");
      return;
    }

    _view.showLoading();

    try {
      String nuevoRol = user.role.toLowerCase() == 'capitan'
          ? 'user'
          : 'capitan';

      User updatedUser = User(
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        telefono: user.telefono,
        password: user.password,
        role: nuevoRol,
        foto: user.foto,
      );

      await _dbHelper.updateUser(updatedUser);

      _view.hideLoading();
      _view.closeDialog();
      _view.showSuccess("Rol actualizado a: $nuevoRol");
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cambiar rol: ${e.toString()}");
    }
  }

  @override
  Future<void> toggleUserArbitro(User user) async {
    if (!AuthUtils.canManageUsers(_currentUser.role)) {
      _view.showError("No tienes permisos para gestionar usuarios");
      return;
    }

    if (user.role.toLowerCase() == 'superadmin') {
      _view.showError("No puedes cambiar el rol de un administrador");
      return;
    }

    _view.showLoading();

    try {
      String nuevoRol = user.role.toLowerCase() == 'arbitro'
          ? 'user'
          : 'arbitro';

      User updatedUser = User(
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        telefono: user.telefono,
        password: user.password,
        role: nuevoRol,
        foto: user.foto,
      );

      await _dbHelper.updateUser(updatedUser);

      _view.hideLoading();
      _view.closeDialog();
      _view.showSuccess("Rol actualizado a: $nuevoRol");
    } catch (e) {
      _view.hideLoading();
      _view.showError("Error al cambiar rol: ${e.toString()}");
    }
  }

  @override
  void openPasswordDialog() {
    _view.showPasswordDialog();
  }

  @override
  void openPermissionsDialog() {
    loadUsersForPermissions();
  }

  @override
  void dispose() {}

  bool _validarPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }
}
