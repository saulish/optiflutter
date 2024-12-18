import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'carritoModel.dart';
import 'carritoPage.dart';

class MedicineSearchPage extends StatefulWidget {
  const MedicineSearchPage({Key? key}) : super(key: key);

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _allMedicines;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref().child('medicamentos').get();
      if (snapshot.exists) {
        final rawData = snapshot.value;
        if (rawData is Map) {
          setState(() {
            _allMedicines = rawData.map(
              (key, value) => MapEntry(
                key.toString(),
                value is Map ? Map<String, dynamic>.from(value) : value,
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error al cargar los medicamentos: $e');
    }
  }

  void _searchMedicines() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty || _allMedicines == null) return;

    List<Map<String, dynamic>> results = [];
    _allMedicines!.forEach((name, data) {
      if (data is! Map<String, dynamic>) return;

      final nameLower = name.toLowerCase();
      final code = data['codigo']?.toString()?.toLowerCase() ?? '';
      if (nameLower.contains(query) || code.contains(query)) {
        results.add({
          'name': name,
          'code': code,
          'locations': data,
        });
      }
    });

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda de Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el nombre o código del medicamento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchMedicines,
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final medicine = _searchResults[index];
                return ListTile(
                  title: Text(medicine['name']),
                  subtitle: Text('Código: ${medicine['code']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      cart.addItem(medicine);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
