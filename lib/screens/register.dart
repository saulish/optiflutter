import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _curpController = TextEditingController();
  final _nssController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final FocusNode _curpFocusNode = FocusNode();
  final FocusNode _nssFocusNode = FocusNode();

  List<String> _clinicas = [];
  String? _selectedClinica;

  bool _isCurpValid = true;
  bool _isNssValid = true;

  @override
  void initState() {
    super.initState();
    _loadClinicas();

    // Validar CURP al perder el foco
    _curpFocusNode.addListener(() async {
      if (!_curpFocusNode.hasFocus) {
        final curp = _curpController.text.trim();
        if (curp.isNotEmpty) {
          final snapshot = await _dbRef.child('curps').child(curp).get();
          setState(() {
            _isCurpValid = !snapshot.exists; // CURP válido si no existe
          });

          if (!_isCurpValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El CURP ya está registrado.')),
            );
          }
        }
      }
    });

    // Validar NSS al perder el foco
    _nssFocusNode.addListener(() async {
      if (!_nssFocusNode.hasFocus) {
        final nss = _nssController.text.trim();
        if (nss.isNotEmpty) {
          final snapshot = await _dbRef.child('nss').child(nss).get();
          setState(() {
            _isNssValid = !snapshot.exists; // NSS válido si no existe
          });

          if (!_isNssValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El NSS ya está registrado.')),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _curpFocusNode.dispose();
    _nssFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _curpController.dispose();
    _nssController.dispose();
    super.dispose();
  }

  void _loadClinicas() async {
    final snapshot = await _dbRef.child('clinicas').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _clinicas = data.entries
            .where((entry) => entry.value == 1) // Solo clínicas disponibles
            .map((entry) => entry.key)
            .toList();
      });
    }
  }

Future<void> checkIfEmailExists(String email) async {
  try {
    // Obtener métodos de inicio de sesión asociados al correo
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    if (signInMethods.isNotEmpty) {
      // El correo ya está registrado
      print('El correo ya está registrado.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo ya está registrado.')),
      );
    } else {
      // El correo no está registrado
      print('El correo no está registrado.');
    }
  } catch (e) {
    print('Error al verificar el correo: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hubo un problema al verificar el correo.')),
    );
  }
}

void _register() async {
  if (!_isCurpValid || !_isNssValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Corrige los campos marcados antes de continuar.')),
    );
    return;
  }

  try {
    // Validaciones locales antes de intentar registrar al usuario
    if (_curpController.text.length != 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El CURP debe tener 18 caracteres')),
      );
      return;
    }
    if (_nssController.text.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El NSS no puede tener más de 12 caracteres')),
      );
      return;
    }
    if (_selectedClinica == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una clínica')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Intentar registrar al usuario en Firebase Auth
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generar clave segura para almacenar el email en la base de datos
      final emailKey = email.replaceAll('.', '_').replaceAll('@', '_');

      // Guardar datos del usuario en Realtime Database
      await _dbRef.child('usuarios').child(emailKey).set({
        'nombre': '${_nameController.text.trim()} ${_lastNameController.text.trim()}',
        'curp': _curpController.text.trim(),
        'nss': _nssController.text.trim(),
        'clinica': _selectedClinica,
      });

      // Guardar CURP y NSS en nodos separados
      await _dbRef.child('curps').child(_curpController.text.trim()).set(emailKey);
      await _dbRef.child('nss').child(_nssController.text.trim()).set(emailKey);

      // Navegar a la pantalla principal tras el registro exitoso
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de Firebase Auth
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está registrado.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo ingresado no es válido.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'La creación de cuentas no está habilitada.';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es muy débil. Usa al menos 6 caracteres.';
          break;
        default:
          errorMessage = 'Ocurrió un error al registrarse.';
      }

      // Mostrar mensaje al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }
  } catch (e) {
    // Otros errores generales
    print('Error al registrarse: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error inesperado al registrarse.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _curpController,
                focusNode: _curpFocusNode,
                decoration: InputDecoration(
                  labelText: 'CURP',
                  errorText: !_isCurpValid ? 'CURP ya registrado' : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nssController,
                focusNode: _nssFocusNode,
                decoration: InputDecoration(
                  labelText: 'NSS',
                  errorText: !_isNssValid ? 'NSS ya registrado' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClinica,
                items: _clinicas
                    .map((clinica) => DropdownMenuItem(
                          value: clinica,
                          child: Text(clinica),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClinica = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Clínica'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
