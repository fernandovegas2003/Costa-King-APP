import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _showNavbar = true;
  int _selectedIndex = 2;

  // Versículo
  Map<String, dynamic> _versiculo = {};

  // Noticias por fuente
  Map<String, List<Map<String, dynamic>>> _noticiasPorFuente = {
    "El Tiempo": [],
    "La Nación": [],
  };

  // Filtro por fuente
  String _filtroFuente = "Todas";
  final List<String> _fuentes = ["Todas", "El Tiempo", "La Nación"];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    fetchNoticias();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showNavbar) setState(() => _showNavbar = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showNavbar) setState(() => _showNavbar = true);
    }
  }


  /// Traer noticias
  Future<void> fetchNoticias() async {
    try {
      final tiempoRes = await http.get(
        Uri.parse("https://api-noticias-lecturas.onrender.com/eltiempo"),
      );
      final nacionRes = await http.get(
        Uri.parse("https://api-noticias-lecturas.onrender.com/lanacion"),
      );

      if (tiempoRes.statusCode == 200) {
        final data = json.decode(tiempoRes.body);
        _noticiasPorFuente["El Tiempo"] =
        List<Map<String, dynamic>>.from(data["noticias"]);
      }
      if (nacionRes.statusCode == 200) {
        final data = json.decode(nacionRes.body);
        _noticiasPorFuente["La Nación"] =
        List<Map<String, dynamic>>.from(data["noticias"]);
      }

      setState(() {});
    } catch (e) {
      print("❌ Error fetchNoticias: $e");
    }
  }

  /// Aplica el filtro
  List<Map<String, dynamic>> _filtrarNoticias(List<Map<String, dynamic>> noticias) {
    List<Map<String, dynamic>> filtradas = noticias;

    // Filtro por fuente
    if (_filtroFuente != "Todas") {
      filtradas = filtradas.where((n) => n["fuente"] == _filtroFuente).toList();
    }

    return filtradas;
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  Widget _buildNoticiasList(List<Map<String, dynamic>> noticias) {
    final filtradas = _filtrarNoticias(noticias);

    if (filtradas.isEmpty) {
      return const Center(
        child: Text("No hay noticias disponibles"),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filtradas.length,
      itemBuilder: (context, index) {
        final noticia = filtradas[index];

        return GestureDetector(
          onTap: () => _launchUrl(noticia["enlace"]),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    noticia["imagen"],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticia["titulo"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${noticia["fecha"]} - ${noticia["fuente"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Navbar animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _showNavbar ? null : 0,
              child: const CustomNavbar(),
            ),

            // Contenido scrollable
            Expanded(
              child: Column(
                children: [
                  // 🔹 Versículo
                  if (_versiculo.isNotEmpty)
                    Card(
                      color: Colors.indigo.shade50,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.book, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text(
                                  "📖 Versículo del día",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _versiculo["texto"] ?? "",
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _versiculo["referencia"] ?? "",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🔹 Filtros (ChoiceChip)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _fuentes.map((fuente) {
                        final isSelected = _filtroFuente == fuente;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(fuente),
                            selected: isSelected,
                            selectedColor: Colors.indigo,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) {
                              setState(() => _filtroFuente = fuente);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // 🔹 Lista de noticias (mezcladas)
                  Expanded(
                    child: _buildNoticiasList([
                      ...?_noticiasPorFuente["El Tiempo"],
                      ...?_noticiasPorFuente["La Nación"],
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Footer
      bottomNavigationBar: SafeArea(
        child: CustomFooterNav(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
