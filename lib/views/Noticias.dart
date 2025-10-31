import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../componentes/navbar/navbar.dart';
import '../componentes/navbar/footer.dart';

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

  static const TextStyle body = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.keppel,
    fontSize: 12,
    fontFamily: _fontFamily,
  );
}

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _showNavbar = true;
  int _selectedIndex = 2;

  Map<String, dynamic> _versiculo = {};

  Map<String, List<Map<String, dynamic>>> _noticiasPorFuente = {
    "El Tiempo": [],
    "La Nación": [],
  };

  String _filtroFuente = "Todas";
  final List<String> _fuentes = ["Todas", "El Tiempo", "La Nación"];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    fetchNoticias();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showNavbar) setState(() => _showNavbar = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showNavbar) setState(() => _showNavbar = true);
    }
  }

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
        _noticiasPorFuente["El Tiempo"] = List<Map<String, dynamic>>.from(
          data["noticias"],
        );
      }
      if (nacionRes.statusCode == 200) {
        final data = json.decode(nacionRes.body);
        _noticiasPorFuente["La Nación"] = List<Map<String, dynamic>>.from(
          data["noticias"],
        );
      }

      setState(() {});
    } catch (e) {
      print("❌ Error fetchNoticias: $e");
    }
  }

  List<Map<String, dynamic>> _filtrarNoticias(
    List<Map<String, dynamic>> noticias,
  ) {
    List<Map<String, dynamic>> filtradas = noticias;

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
        child: Text("No hay noticias disponibles", style: AppTextStyles.body),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filtradas.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final noticia = filtradas[index];

        return GestureDetector(
          onTap: () => _launchUrl(noticia["enlace"]),
          child: Card(
            color: AppColors.white.withOpacity(0.8),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.iceBlue,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.keppel,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.white.withOpacity(0.5),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.paynesGray,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      right: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noticia["titulo"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${noticia["fecha"]} - ${noticia["fuente"]}",
                          style: AppTextStyles.cardDescription,
                        ),
                      ],
                    ),
                  ),
                ),
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
      backgroundColor: AppColors.celeste,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showNavbar ? null : 0,
                child: const CustomNavbar(),
              ),

              Expanded(
                child: Column(
                  children: [
                    if (_versiculo.isNotEmpty)
                      Card(
                        color: AppColors.paynesGray.withOpacity(
                          0.8,
                        ),
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
                                  Icon(
                                    Icons.book,
                                    color: AppColors.aquamarine,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "📖 Versículo del día",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.aquamarine,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _versiculo["texto"] ?? "",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _versiculo["referencia"] ?? "",
                                  style: AppTextStyles.cardDescription.copyWith(
                                    color: AppColors.keppel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _fuentes.map((fuente) {
                          final isSelected = _filtroFuente == fuente;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(fuente),
                              selected: isSelected,
                              selectedColor: AppColors.aquamarine,
                              backgroundColor: AppColors.white.withOpacity(
                                0.3,
                              ),
                              labelStyle: TextStyle(
                                color: AppColors.paynesGray,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: AppColors.keppel.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              onSelected: (_) {
                                setState(() => _filtroFuente = fuente);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

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
      ),

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