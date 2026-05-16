import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthUtils {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  static bool hasPermission(String userRole, String requiredRole) {
    switch (requiredRole) {
      case 'superadmin':
        return userRole.toLowerCase() == 'superadmin';
      case 'admin':
        return userRole.toLowerCase() == 'superadmin' ||
            userRole.toLowerCase() == 'admin';
      case 'captain':
        return userRole.toLowerCase() == 'superadmin' ||
            userRole.toLowerCase() == 'admin' ||
            userRole.toLowerCase() == 'captain';
      case 'user':
        return true;
      default:
        return false;
    }
  }

  static bool canManageUsers(String userRole) {
    return userRole.toLowerCase() == 'superadmin' ||
        userRole.toLowerCase() == 'admin';
  }

  static bool canChangeRoles(String userRole) {
    return userRole.toLowerCase() == 'superadmin';
  }
}