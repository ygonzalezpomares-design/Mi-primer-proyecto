import 'package:flutter/material.dart';
import '../inicio/mainscreen.dart';
import 'register_screen.dart';
import '../models/user_model.dart';
import '../presenters/login_presenter.dart';
import '../contracts/login_contract.dart';
import '../widgets/common_widgets.dart';

class AppColors {
  static const Color fondo = Color(0xFF0066FF);
  static const Color blancoInput = Color(0xFFFFFFFF);
  static const Color deepOrange = Colors.deepOrange;
  static const Color textoBlanco = Color(0xFFFFFFFF);
  static const Color textoOscuro = Color(0xFF333333);
  static const Color textoInactivo = Color(0xFFA0A0A0);
  static const Color primario = Color(0xFF1A5F7A);
  static const Color secundario = Colors.deepOrange;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginContractView {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  late LoginPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _presenter.dispose();
    super.dispose();
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void navigateToMainScreen(dynamic user) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user as User)),
    );
  }

  @override
  void showError(String message) {
    if (!mounted) return;
    MessageOverlay.showError(context, message);
  }

  @override
  void navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _onLoginPressed() {
    _presenter.login(_emailController.text.trim(), _passController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textoBlanco,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  hintText: "Correo electrónico",
                  icon: Icons.email_outlined,
                  isObscure: false,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passController,
                  hintText: "Contraseña",
                  icon: Icons.lock_outline,
                  isObscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textoInactivo,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepOrange,
                      foregroundColor: AppColors.textoBlanco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Iniciar sesión",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "¿No tienes una cuenta? ",
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: () => _presenter.goToRegister(),
                child: const Text(
                  "Regístrate aquí",
                  style: TextStyle(
                    color: AppColors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isObscure,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blancoInput,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: AppColors.textoOscuro),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textoInactivo),
          prefixIcon: Icon(icon, color: AppColors.textoInactivo),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
