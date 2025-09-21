// PAGINA DE DONACIONES
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import '../main.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apoya BetterMe'),
        backgroundColor: betterMePrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header con icono y mensaje motivacional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: betterMePrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, size: 60, color: Colors.red),
                  const SizedBox(height: 15),
                  Text(
                    '¡Tu apoyo hace la diferencia!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: betterMePrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Cada donación ayuda a mantener y mejorar la app',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tarjeta de PayPal
            _buildPayPalCard(context),

            const SizedBox(height: 25),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '¿Cómo funciona?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1. Copia tu usuario de PayPal\n'
                    '2. Abre la app de PayPal\n'
                    '3. Pega el usuario y realiza tu donación\n'
                    '4. ¡Gracias por tu apoyo! 🎉',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mensaje de agradecimiento
            Text(
              '¡Gracias por ser parte de la comunidad BetterMe!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayPalCard(BuildContext context) {
    const String paypalUser = 'AlexParkerBM'; // Tu usuario de PayPal

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo de PayPal
            Image.asset(
              'assets/images/paypal_logo.png', // Agrega este asset
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.payment,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 15),
            
            // Usuario de PayPal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paypalUser,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 20),
                    onPressed: () async {
                      await FlutterClipboard.copy(paypalUser);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario copiado al portapapeles'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.content_copy, size: 18),
                    label: const Text('Copiar Usuario'),
                    onPressed: () async {
                      await FlutterClipboard.copy(paypalUser);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario copiado al portapapeles'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Abrir PayPal'),
                    onPressed: () async {
                      final url = Uri.parse('https://paypal.me/$paypalUser');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo abrir PayPal'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: betterMePrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}