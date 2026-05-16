import 'package:flutter/material.dart';
import '../views/dashboard_screen.dart';
import '../views/equipo_screen.dart';
import '../views/jueces_screen.dart';
import '../views/ejercicios_screen.dart';
import '../views/ajustes_screen.dart';
import '../models/user_model.dart';

// Definimos una estructura sencilla para manejar los items de navegación
class _NavItemData {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavItemData(this.icon, this.label, this.screen);
}

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<_NavItemData> _navItems;

  @override
  void initState() {
    super.initState();
    _buildMenuByRole();
  }

  void _buildMenuByRole() {
    final rol = widget.user.role.toLowerCase();
    final ajustes = AjustesScreen(user: widget.user);

    // Definimos qué ve cada quién de forma dinámica
    if (rol == 'superadmin' || rol == 'admin') {
      _navItems = [
        _NavItemData(Icons.home_outlined, "Inicio", const DashboardScreen()),
        _NavItemData(Icons.group_outlined, "Equipos", const EquipoScreen()),
        _NavItemData(
          Icons.assignment_turned_in,
          "Jueces",
          const JuecesScreen(),
        ),
        _NavItemData(
          Icons.fitness_center_outlined,
          "Ejercicios",
          const EjerciciosScreen(),
        ),
        _NavItemData(Icons.settings_outlined, "Ajustes", ajustes),
      ];
    } else if (rol == 'capitan') {
      _navItems = [
        _NavItemData(Icons.home_outlined, "Inicio", const DashboardScreen()),
        _NavItemData(Icons.group_outlined, "Equipos", const EquipoScreen()),
        _NavItemData(Icons.settings_outlined, "Ajustes", ajustes),
      ];
    } else if (rol == 'arbitro') {
      _navItems = [
        _NavItemData(Icons.home_outlined, "Inicio", const DashboardScreen()),
        _NavItemData(
          Icons.assignment_turned_in,
          "Jueces",
          const JuecesScreen(),
        ),
        _NavItemData(Icons.settings_outlined, "Ajustes", ajustes),
      ];
    } else {
      // Juez o cualquier otro
      _navItems = [
        _NavItemData(Icons.home_outlined, "Inicio", const DashboardScreen()),
        _NavItemData(Icons.settings_outlined, "Ajustes", ajustes),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      // Mostramos las pantallas basadas en la lista generada
      body: IndexedStack(
        index: _selectedIndex,
        children: _navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          top: 10,
          bottom: bottomPadding > 0 ? bottomPadding : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // Generamos los botones dinámicamente
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return _navItem(item.icon, item.label, index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
