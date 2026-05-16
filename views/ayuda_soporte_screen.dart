import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../main.dart';

class AyudaSoporteScreen extends StatefulWidget {
  const AyudaSoporteScreen({super.key});

  @override
  State<AyudaSoporteScreen> createState() => _AyudaSoporteScreenState();
}

class _AyudaSoporteScreenState extends State<AyudaSoporteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ayuda y Soporte",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Soporte técnico",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              title: "Desarrollador de la App",
              subtitle: "Consultas técnicas y errores",
              email: "yasirag@uci.cu",
              icon: Icons.code,
            ),
            const SizedBox(height: 25),
            const Text(
              "Administración",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              title: "Administrador UCI",
              subtitle: "Gestión de cuentas y permisos",
              email: "joekenpo@uci.cu",
              icon: Icons.admin_panel_settings,
            ),
            const SizedBox(height: 25),
            const Text(
              "Documentación",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildDownloadCard(
              title: "Manual de usuario (PDF)",
              subtitle: "Guía básica de funciones y botones",
              icon: Icons.picture_as_pdf,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required String email,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.deepOrange, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: _downloadPdf,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.red, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Icon(Icons.download, color: Colors.blue),
                Text(
                  "Bajar",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final byteData = await rootBundle.load(
        'assets/Manual de usuario tesis.pdf',
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Manual de usuario tesis.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      Navigator.pop(context);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Manual de Usuario UCI Fitness');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
