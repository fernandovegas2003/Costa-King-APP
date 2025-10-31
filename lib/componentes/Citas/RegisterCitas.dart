import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const String _fontFamily =
      'TuFuenteApp'; 

  static const TextStyle headline = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonPrimary = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSecondary = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _numDocController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _fechaNacController = TextEditingController();

  List<dynamic> _sedes = [];
  List<dynamic> _tiposDocumento = [];

  int? _tipoDocSeleccionado;
  int? _sedeSeleccionada;
  String? _genero;

  bool _isPageLoading = true; 
  bool _isRegistering = false; 
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosAuxiliares();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarAdvertencia());
  }

  void _mostrarAdvertencia() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Aviso Importante",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ), 
        content: Text(
          "Esto no reemplaza una cita médica.\n"
          "Son solo recomendaciones.\n\n"
          "No nos hacemos responsables por el mal uso del mismo.",
          style: AppTextStyles.body.copyWith(fontSize: 15), 
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, 
              foregroundColor: AppColors.paynesGray, 
            ),
            child: const Text(
              "Aceptar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarDatosAuxiliares() async {
     try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios/auxiliares",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _tiposDocumento = data['data']['tiposDocumento'];
            _sedes = data['data']['sedes'];
            _isPageLoading = false;
          });
        } else {
          throw Exception('Error en la respuesta de la API');
        }
      } else {
         throw Exception('Error de conexión con el servidor');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPageLoading = false);
        _showSnack("Error al cargar datos: $e", isError: true);
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);

    final url = Uri.parse(
      "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tipoDocumento": _tipoDocSeleccionado,
          "numeroDocumento": _numDocController.text.trim(),
          "nombreUsuario": _nombreController.text.trim(),
          "apellidoUsuario": _apellidoController.text.trim(),
          "emailUsuario": _emailController.text.trim(),
          "pwdUsuario": _pwdController.text.trim(), 
          "telefonoUsuario": _telefonoController.text.trim(),
          "direccionUsuario": _direccionController.text.trim(),
          "idRol": 1, 
          "idSede": _sedeSeleccionada,
          "fechaNacimiento": _fechaNacController.text.trim(),
          "genero": _genero,
        }),
      );

      if (!mounted) return;
      setState(() => _isRegistering = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body); 
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✅ ${data["mensaje"] ?? 'Registro exitoso. Ahora inicia sesión'}",
              ),
              backgroundColor: AppColors.keppel,
            ), 
          );
          Navigator.pop(context); 
        } else {
          _showSnack(
            "⚠️ Error: ${data["mensaje"] ?? response.body}",
            isError: true,
          );
        }
      } else {
        _showSnack(
          "❌ Error ${response.statusCode}: ${response.body}",
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRegistering = false);
        _showSnack("⚠️ Excepción: $e", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
      ),
    );
  }

  InputDecoration _formFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.paynesGray.withAlpha(179),
      ),
      prefixIcon: Icon(icon, color: AppColors.paynesGray, size: 20),
      filled: true,
      fillColor: AppColors.white.withAlpha(128),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.keppel, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.red[700],
        fontWeight: FontWeight.bold,
      ), 
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        style: AppTextStyles.body,
        items: items,
        onChanged: onChanged,
        validator: (v) => v == null ? "Requerido" : null,
        decoration: _formFieldDecoration(label, icon),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: _formFieldDecoration(
          label,
          icon,
        ).copyWith(suffixIcon: suffixIcon),
        validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Registro de Usuario",
          style: AppTextStyles.headline, 
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isPageLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.aquamarine),
                ) 
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDropdown<int>(
                            label: "Tipo de Documento",
                            icon: Icons.badge_outlined,
                            value: _tipoDocSeleccionado,
                            items: _tiposDocumento
                                .map(
                                  (doc) => DropdownMenuItem<int>(
                                    value: doc["idTipoDocumento"],
                                    child: Text(doc["nombreTipoDocumento"]),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _tipoDocSeleccionado = value);
                            },
                          ),
                          _buildTextField(
                            label: "Número Documento",
                            icon: Icons.credit_card_outlined,
                            controller: _numDocController,
                          ),
                          _buildTextField(
                            label: "Nombre",
                            icon: Icons.person_outline,
                            controller: _nombreController,
                          ),
                          _buildTextField(
                            label: "Apellido",
                            icon: Icons.person_outline,
                            controller: _apellidoController,
                          ),
                          _buildTextField(
                            label: "Correo electrónico",
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextField(
                            label: "Contraseña",
                            icon: Icons.lock_outline,
                            controller: _pwdController,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.paynesGray,
                              ),
                              onPressed: () {
                                setState(() { _isPasswordVisible = !_isPasswordVisible; });
                              },
                            ),
                          ),
                          _buildTextField(
                            label: "Teléfono",
                            icon: Icons.phone_outlined,
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextField(
                            label: "Dirección",
                            icon: Icons.home_outlined,
                            controller: _direccionController,
                          ),
                          _buildTextField(
                            label: "Fecha de Nacimiento (YYYY-MM-DD)",
                            icon: Icons.calendar_today_outlined,
                            controller: _fechaNacController,
                          ),
                          _buildDropdown<String>(
                            label: "Género",
                            icon: Icons.wc_outlined,
                            value: _genero,
                            items: [
                              DropdownMenuItem(
                                value: "M",
                                child: Text("Masculino"),
                              ),
                              DropdownMenuItem(
                                value: "F",
                                child: Text("Femenino"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _genero = value);
                            },
                          ),
                          _buildDropdown<int>(
                            label: "Seleccione la sede",
                            icon: Icons.location_city_outlined,
                            value: _sedeSeleccionada,
                            items: _sedes
                                .map(
                                  (sede) => DropdownMenuItem<int>(
                                    value: sede["idSede"],
                                    child: Text(sede["nombreSede"]),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _sedeSeleccionada = value ?? 1);
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isRegistering ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.aquamarine, 
                              foregroundColor: AppColors.paynesGray, 
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), 
                              ),
                              elevation: 3,
                            ),
                            child: _isRegistering
                                ? const CircularProgressIndicator(
                                    color: AppColors.paynesGray,
                                  )
                                : Text(
                                    "Registrarse",
                                    style: AppTextStyles
                                        .buttonPrimary, 
                                  ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isRegistering
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.keppel, 
                              foregroundColor: AppColors.white, 
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), 
                              ),
                            ),
                            child: Text(
                              "Volver a Login",
                              style: AppTextStyles.buttonSecondary, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
