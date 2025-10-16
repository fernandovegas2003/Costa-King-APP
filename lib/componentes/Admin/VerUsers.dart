import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
        'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios');
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
      setState(() => cargando = false);
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
        'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/usuarios/documento/$documento');

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "${usuario['nombreUsuario']} ${usuario['apellidoUsuario']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📄 Documento: ${usuario['nombreTipoDocumento']} ${usuario['numeroDocumento']}"),
              Text("📧 Correo: ${usuario['emailUsuario']}"),
              Text("📱 Teléfono: ${usuario['telefonoUsuario']}"),
              Text("🏠 Dirección: ${usuario['direccionUsuario']}"),
              Text("🎂 Fecha Nacimiento: ${usuario['fechaNacimiento'].toString().split('T')[0]}"),
              Text("⚧ Género: ${usuario['genero'] == 'M' ? 'Masculino' : 'Femenino'}"),
              Text("🧩 Rol: ${usuario['nombreRol']}"),
              Text("🏥 Sede: ${usuario['nombreSede']}"),
              const SizedBox(height: 10),
              Text("📅 Fecha Registro: ${usuario['fechaRegistro'].toString().split('T')[0]}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Lista de Usuarios",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          /// 🌅 Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 📋 Contenido
          cargando
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF01A4B2)),
          )
              : Column(
            children: [
              const SizedBox(height: 20),

              /// 🔍 Barra de búsqueda debajo del AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _buscarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Buscar por número de documento...",
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF01A4B2)),
                      suffixIcon: _buscarController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey),
                        onPressed: () {
                          _buscarController.clear();
                          obtenerUsuarios();
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    onSubmitted: buscarUsuarioPorDocumento,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 📦 Contenedor largo centrado de usuarios
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: buscando
                        ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF01A4B2)),
                    )
                        : usuarios.isEmpty
                        ? const Center(
                      child: Text(
                        "No se encontró ningún usuario",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = usuarios[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                              const Color(0xFF01A4B2),
                              child: Text(
                                usuario['nombreUsuario'][0],
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                            title: Text(
                              "${usuario['nombreUsuario']} ${usuario['apellidoUsuario']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "${usuario['nombreRol']} • ${usuario['nombreSede']}"),
                            trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18),
                            onTap: () =>
                                mostrarDetallesUsuario(
                                    usuario),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
