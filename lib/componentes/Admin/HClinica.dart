import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🎨 TU PALETA DE COLORES PROFESIONAL
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
    color: AppColors.keppel, // 
    fontSize: 17,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, //
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

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
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas",
        ),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body); //
        setState(() {
          _historias = data["data"];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buscarPorDocumento() async {
    final documento = _buscadorController.text.trim();
    if (documento.isEmpty) {
      _fetchHistorias();
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/documento/$documento",
        ),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body); //
        setState(() {
          _historias = data["data"] is List ? data["data"] : [data["data"]];
          _loading = false;
        });
      } else {
        setState(() {
          _historias = [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historias = [];
          _loading = false;
        });
      }
    }
  }



  void _mostrarDetalles(Map<String, dynamic> historia) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.white, 
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${historia['nombreUsuario']} ${historia['apellidoUsuario']}",
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.keppel,
                      fontSize: 22,
                    ), // 
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Documento: ${historia['numeroDocumento']}",
                    style: AppTextStyles.body,
                  ), // 
                  Divider(
                    color: AppColors.keppel.withOpacity(0.5),
                    height: 20,
                    thickness: 1,
                  ), // 
                  _infoItem("Tipo de Sangre", historia["tipoSangre"]),
                  _infoItem("Alergias", historia["alergias"]),
                  _infoItem(
                    "Enfermedades Crónicas",
                    historia["enfermedadesCronicas"],
                  ),
                  _infoItem("Medicamentos", historia["medicamentos"]),
                  _infoItem(
                    "Antecedentes Familiares",
                    historia["antecedentesFamiliares"],
                  ),
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
                        backgroundColor: AppColors.aquamarine, // 
                        foregroundColor: AppColors.paynesGray, // 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  // 🎨 HELPER DE INFO REDISEÑADO
  Widget _infoItem(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$titulo: ",
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ), // 
          children: [
            TextSpan(
              text: valor ?? "No registrado",
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.normal,
              ), // 
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
      backgroundColor: AppColors.celeste, // 
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), // 🎨 Color
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Historias Clínicas",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
               
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.7), // 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.paynesGray.withOpacity(
                          0.1,
                        ), // 
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _buscadorController,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                    ), // 
                    decoration: InputDecoration(
                      hintText: "Buscar historia por documento",
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.paynesGray.withOpacity(0.7),
                      ), // 
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.keppel,
                      ), //
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.keppel,
                        ), 
                        onPressed: _buscarPorDocumento,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                    onSubmitted: (_) => _buscarPorDocumento(),
                  ),
                ),
                const SizedBox(height: 25),

               
                Expanded(
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.aquamarine,
                          ),
                        ) 
                      : tieneResultados
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.7), 
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: AppColors.white,
                            ), 
                          ),
                          padding: const EdgeInsets.all(18),
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _historias.length,
                            separatorBuilder: (_, __) => Divider(
                              color: AppColors.keppel.withOpacity(
                                0.5,
                              ), 
                              thickness: 0.5,
                              height: 15,
                            ),
                            itemBuilder: (context, index) {
                              final historia = _historias[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _mostrarDetalles(historia),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 5,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${historia['nombreUsuario']} ${historia['apellidoUsuario']}",
                                        style: AppTextStyles
                                            .cardTitle, // 
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "Documento: ${historia['numeroDocumento']}",
                                        style: AppTextStyles
                                            .cardDescription, //
                                      ),
                                      Text(
                                        "Tipo de Sangre: ${historia['tipoSangre']}",
                                        style: AppTextStyles
                                            .cardDescription, // 
                                      ),
                                      Text(
                                        "Fecha Creación: ${historia['fechaCreacion'] != null && historia['fechaCreacion'].toString().length >= 10 ? historia['fechaCreacion'].toString().substring(0, 10) : 'No registrada'}",
                                        style: AppTextStyles.cardDescription
                                            .copyWith(
                                              // 
                                              color: AppColors.paynesGray
                                                  .withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            "No hay historias clínicas registradas",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.paynesGray.withOpacity(0.7),
                            ), // 
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
