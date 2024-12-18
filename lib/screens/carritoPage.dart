import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carritoModel.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Medicamentos')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('El carrito está vacío.'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final entry = cart.items.entries.toList()[index];
                      final name = entry.key;
                      final data = entry.value;

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Cantidad: ${data['quantity']}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: cart.clearCart,
                  child: const Text('Vaciar Carrito'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Acción de continuar
                  },
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
