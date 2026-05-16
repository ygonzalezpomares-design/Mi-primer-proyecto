import 'package:flutter/material.dart';
import '../inicio/mainscreen.dart';
import '../models/user_model.dart';
import '../presenters/register_presenter.dart';
import '../contracts/register_contract.dart';
import '../widgets/common_widgets.dart';
import 'package:ucifitness_app/main.dart';

class RegisterScreen extends StatefulWidget {
  final User? user;

  const RegisterScreen({super.key, this.user});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    implements RegisterContract {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _isObscure = true;
  bool _aceptaTerminos = false;
  bool _isLoading = false;

  late RegisterPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = RegisterPresenter(this);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user as User)),
      (route) => false,
    );
  }

  @override
  void showMessage(String message) {
    if (!mounted) return;
    MessageOverlay.showError(context, message);
  }

  @override
  void navigateBack() {
    Navigator.pop(context);
  }

  void _onRegisterPressed() {
    _presenter.registerUser(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      confirmPassword: _confirmPassCtrl.text.trim(),
      aceptaTerminos: _aceptaTerminos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 10),
              const Text(
                "Únete a UCIFitness",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildInput(
                controller: _nombreCtrl,
                hint: "Nombre completo",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _emailCtrl,
                hint: "Correo electrónico",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _telCtrl,
                hint: "Número de teléfono",
                icon: Icons.phone_android_outlined,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _passCtrl,
                hint: "Contraseña",
                icon: Icons.lock_outline,
                isPass: true,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _confirmPassCtrl,
                hint: "Confirmar contraseña",
                icon: Icons.lock_reset_outlined,
                isPass: true,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (val) => setState(() => _aceptaTerminos = val!),
                    side: const BorderSide(color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Acepto los términos y condiciones de UCIFitness",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onRegisterPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepOrange,
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
                          "Crear cuenta",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _presenter.goBackToLogin(),
          child: const Text.rich(
            TextSpan(
              text: "¿Ya tienes una cuenta? ",
              style: TextStyle(color: Colors.white70),
              children: [
                TextSpan(
                  text: "Inicia sesión",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPass = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass ? _isObscure : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textoInactivo),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                )
              : null,
        ),
      ),
    );
  }
}
