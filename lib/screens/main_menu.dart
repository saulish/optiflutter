import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container para los botones dentro de un rectángulo
            Container(
              width: double.infinity,  // Asegura que ocupe todo el ancho disponible
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Aquí puedes agregar la lógica de escanear receta
                        },
                        child: const Text('Escanear Receta'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla de consulta de medicamentos
                          Navigator.pushNamed(context, '/medicationConsultation');
                        },
                        child: const Text('Consulta de Medicamentos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Aquí puedes agregar la lógica de entrega a domicilio
                        },
                        child: const Text('Entrega a Domicilio'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Aquí puedes agregar la lógica de solicitar asistencia
                        },
                        child: const Text('Solicitar Asistencia'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
