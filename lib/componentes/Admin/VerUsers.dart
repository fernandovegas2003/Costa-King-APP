import 'package:flutter/material.dart';
import 'dart:convert';
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

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray, // 
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, //
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

class VerUsuariosPage extends StatefulWidget {
  const VerUsuariosPage({Key? key}) : super(key: key);

  @override
  State<VerUsuariosPage> createState() => _VerUsuariosPageState();
}

class _VerUsuariosPageState extends State<VerUsuariosPage> {
  List<dynamic> usuarios = [];
  bool cargando = true;
  final TextEditingController _buscarController = TextEditingController();
  bool buscando = false;

  @override
  void initState() {
    super.initState();
    obtenerUsuarios();
  }


  Future<void> obtenerUsuarios() async {
    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios',
    );
    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          usuarios = data["data"];
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> buscarUsuarioPorDocumento(String documento) async {
    if (documento.isEmpty) {
      obtenerUsuarios();
      return;
    }

    setState(() {
      buscando = true;
    });

    final url = Uri.parse(
      'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios/documento/$documento',
    );

    try {
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        if (data["success"] && data["data"] != null) {
          setState(() {
            usuarios = [data["data"]];
          });
        } else {
          setState(() {
            usuarios = [];
          });
        }
      } else {
        setState(() {
          usuarios = [];
        });
      }
    } catch (e) {
      setState(() {
        usuarios = [];
      });
    } finally {
      setState(() {
        buscando = false;
      });
    }
  }

 
  void mostrarDetallesUsuario(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "${usuario['nombreUsuario']} ${usuario['apellidoUsuario']}",
          style: AppTextStyles.headline.copyWith(
            color: AppColors.keppel,
            fontSize: 20,
          ), //
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoItem(
                "📄 Documento:",
                "${usuario['nombreTipoDocumento']} ${usuario['numeroDocumento']}",
              ),
              _infoItem("📧 Correo:", usuario['emailUsuario']),
              _infoItem("📱 Teléfono:", usuario['telefonoUsuario']),
              _infoItem("🏠 Dirección:", usuario['direccionUsuario']),
              _infoItem(
                "🎂 Nacimiento:",
                usuario['fechaNacimiento'].toString().split('T')[0],
              ),
              _infoItem(
                "⚧ Género:",
                usuario['genero'] == 'M' ? 'Masculino' : 'Femenino',
              ),
              _infoItem("🧩 Rol:", usuario['nombreRol']),
              _infoItem("🏥 Sede:", usuario['nombreSede']),
              const SizedBox(height: 10),
              _infoItem(
                "📅 Registro:",
                usuario['fechaRegistro'].toString().split('T')[0],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 Color
              foregroundColor: AppColors.paynesGray, // 🎨 Color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body.copyWith(fontSize: 14), // 🎨 Estilo
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, // 
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), 
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Lista de Usuarios",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 🎨 Estilo
        ),
        centerTitle: true,
      ),
      body: Container(
  
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

           
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.7), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.paynesGray.withOpacity(
                          0.1,
                        ), // 🎨 Color
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _buscarController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                    ), // 
                    decoration: InputDecoration(
                      hintText: "Buscar por número de documento...",
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.paynesGray.withOpacity(0.7),
                      ), // 
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.keppel,
                      ), // 
                      suffixIcon: _buscarController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red[700],
                              ), //
                              onPressed: () {
                                _buscarController.clear();
                                obtenerUsuarios();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: buscarUsuarioPorDocumento,
                  ),
                ),
              ),

              const SizedBox(height: 25),

 
              Expanded(
                child: (cargando || buscando)
                    ? Center(
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.aquamarine,
                            ), //
                            SizedBox(height: 16),
                            Text(
                              buscando
                                  ? "Buscando usuario..."
                                  : "Cargando usuarios...",
                              style: AppTextStyles.body,
                            ), // 
                          ],
                        ),
                      )
                    : usuarios.isEmpty
                    ? Center(
                        // 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 60,
                              color: AppColors.paynesGray.withOpacity(0.3),
                            ), // 
                            SizedBox(height: 16),
                            Text(
                              "No se encontró ningún usuario",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paynesGray.withOpacity(0.7),
                              ), // 🎨 Estilo
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: usuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = usuarios[index];
                          // 🎨 TARJETA DE USUARIO REDISEÑADA
                          return Card(
                            color: AppColors.white.withOpacity(0.7), // 🎨 Color
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.keppel, // 🎨 Color
                                child: Text(
                                  usuario['nombreUsuario'][0],
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ), // 
                                ),
                              ),
                              title: Text(
                                "${usuario['nombreUsuario']} ${usuario['apellidoUsuario']}",
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: AppColors.paynesGray,
                                ), // 
                              ),
                              subtitle: Text(
                                "${usuario['nombreRol']} • ${usuario['nombreSede']}",
                                style:
                                    AppTextStyles.cardDescription, // 
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: AppColors.keppel, //
                              ),
                              onTap: () => mostrarDetallesUsuario(usuario),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
