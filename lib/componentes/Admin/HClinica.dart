import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerHistoriasClinicasPage extends StatefulWidget {
  const VerHistoriasClinicasPage({Key? key}) : super(key: key);

  @override
  State<VerHistoriasClinicasPage> createState() =>
      _VerHistoriasClinicasPageState();
}

class _VerHistoriasClinicasPageState extends State<VerHistoriasClinicasPage> {
  List<dynamic> _historias = [];
  bool _loading = true;
  final TextEditingController _buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistorias();
  }

  Future<void> _fetchHistorias() async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _historias = data["data"];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _buscarPorDocumento() async {
    final documento = _buscadorController.text.trim();
    if (documento.isEmpty) {
      _fetchHistorias();
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/documento/$documento"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _historias =
          data["data"] is List ? data["data"] : [data["data"]];
          _loading = false;
        });
      } else {
        setState(() {
          _historias = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _historias = [];
        _loading = false;
      });
    }
  }

  void _mostrarDetalles(Map<String, dynamic> historia) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${historia['nombreUsuario']} ${historia['apellidoUsuario']}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A3B2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Documento: ${historia['numeroDocumento']}"),
                  const Divider(),
                  _infoItem("Tipo de Sangre", historia["tipoSangre"]),
                  _infoItem("Alergias", historia["alergias"]),
                  _infoItem("Enfermedades Crónicas", historia["enfermedadesCronicas"]),
                  _infoItem("Medicamentos", historia["medicamentos"]),
                  _infoItem("Antecedentes Familiares", historia["antecedentesFamiliares"]),
                  _infoItem(
                    "Fecha Creación",
                    historia["fechaCreacion"] != null &&
                        historia["fechaCreacion"].toString().length >= 10
                        ? historia["fechaCreacion"].toString().substring(0, 10)
                        : "No registrada",
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A3B2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$titulo: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: valor ?? "No registrado",
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tieneResultados = _historias.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Historias Clínicas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Fondo original
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Barra de búsqueda con diseño más elegante
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _buscadorController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Buscar historia por documento",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF00A3B2)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF00A3B2)),
                        onPressed: _buscarPorDocumento,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                    ),
                    onSubmitted: (_) => _buscarPorDocumento(),
                  ),
                ),

                const SizedBox(height: 25),

                // Contenedor con efecto glass
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : tieneResultados
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _historias.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Colors.black26,
                        thickness: 0.5,
                        height: 15,
                      ),
                      itemBuilder: (context, index) {
                        final historia = _historias[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _mostrarDetalles(historia),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${historia['nombreUsuario']} ${historia['apellidoUsuario']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF002D40),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Documento: ${historia['numeroDocumento']}",
                                  style: const TextStyle(
                                      color: Colors.black87),
                                ),
                                Text(
                                  "Tipo de Sangre: ${historia['tipoSangre']}",
                                  style: const TextStyle(
                                      color: Colors.black87),
                                ),
                                Text(
                                  "Fecha Creación: ${historia['fechaCreacion'] != null && historia['fechaCreacion'].toString().length >= 10 ? historia['fechaCreacion'].toString().substring(0, 10) : 'No registrada'}",
                                  style: const TextStyle(
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : const Center(
                    child: Text(
                      "No hay historias clínicas registradas",
                      style: TextStyle(
                          fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
