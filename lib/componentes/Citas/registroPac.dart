import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HistoriaUsuario.dart';


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
    fontSize: 15,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel, // 🎨 Color
    fontSize: 17,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray, // 🎨 Color
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}

class OpcionesCitaScreen extends StatefulWidget {
  const OpcionesCitaScreen({Key? key}) : super(key: key);

  @override
  State<OpcionesCitaScreen> createState() => _OpcionesCitaScreenState();
}

class _OpcionesCitaScreenState extends State<OpcionesCitaScreen> {
  bool _loading = false;

  Future<void> _verRegistroCita() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final idCita = prefs.getInt("idCita");

    if (idCita == null) {
      _mostrarResultadoEnDialogo(
        "Error",
        "No se encontró el ID de la cita en la sesión.",
        true,
      );
      setState(() => _loading = false);
      return;
    }

    final response = await http.get(
      Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/registros-consultas/cita/$idCita",
      ),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["data"] != null && data["data"].isNotEmpty) {
        final registro = data["data"][0];
        _mostrarRegistroEnDialogo(
          registro,
        ); 
      } else {
        _mostrarResultadoEnDialogo(
          "Sin Registro",
          "No hay registro de consulta para esta cita.",
          false,
        );
      }
    } else {
      _mostrarResultadoEnDialogo(
        "Error de Conexión",
        "Error al obtener los datos. Código: ${response.statusCode}",
        true,
      );
    }
  }


  void _mostrarRegistroEnDialogo(Map<String, dynamic> registro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white, // 🎨 Color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Registro de la Cita",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 🎨 Estilo
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "👤 Paciente: ${registro["nombrePaciente"]}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "🩺 Médico: ${registro["nombreMedico"]}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "🏥 Especialidad: ${registro["especialidadMedico"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Divider(
                color: AppColors.keppel.withOpacity(0.5),
                height: 20,
              ), // 🎨 Color
              Text(
                "📝 Motivo: ${registro["motivoConsulta"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "🤒 Síntomas: ${registro["sintomas"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Divider(
                color: AppColors.keppel.withOpacity(0.5),
                height: 20,
              ), // 🎨 Color
              Text(
                "💓 Presión Arterial: ${registro["presionArterial"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "❤️ Frecuencia Cardíaca: ${registro["frecuenciaCardiaca"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "⚖️ Peso: ${registro["peso"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "📏 Altura: ${registro["altura"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "📉 IMC: ${registro["imc"] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 
              foregroundColor: AppColors.paynesGray, // 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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


  Future<void> _verHistoriasClinicas() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final idPaciente = prefs.getInt("idPaciente");

    if (idPaciente == null) {
      _mostrarResultadoEnDialogo(
        "Error",
        "No se encontró el ID del paciente.",
        true,
      );
      setState(() => _loading = false);
      return;
    }

    final url =
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/paciente/$idPaciente";
    final response = await http.get(Uri.parse(url));

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["data"] != null && data["data"].isNotEmpty) {
        final historias = data["data"];
      
        _mostrarListaHistorias(historias);
      } else {
        _mostrarResultadoEnDialogo(
          "Sin registros",
          "Este paciente no tiene historias clínicas.",
          false,
        );
      }
    } else {
      _mostrarResultadoEnDialogo(
        "Error",
        "No se pudo obtener la información. Código: ${response.statusCode}",
        true,
      );
    }
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: AppTextStyles.cardDescription.copyWith(
                fontWeight: FontWeight.bold,
              ), // 
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: AppTextStyles.cardDescription, //
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarListaHistorias(List<dynamic> historias) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Historias Clínicas",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: historias.length,
            itemBuilder: (context, index) {
              final h = historias[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColors.iceBlue.withOpacity(0.5), 
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                child: ListTile(
                  title: Text(
                    "Historia #${h['idHistoriaClinica']}",
                    style: AppTextStyles.cardTitle, //
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🩸 Tipo de Sangre: ${h['tipoSangre'] ?? 'N/A'}",
                        style: AppTextStyles.cardDescription,
                      ), // 
                      Text(
                        "🤧 Alergias: ${h['alergias'] ?? 'N/A'}",
                        style: AppTextStyles.cardDescription,
                      ), // 
                      Text(
                        "🏥 Enfermedades: ${h['enfermedadesCronicas'] ?? 'N/A'}",
                        style: AppTextStyles.cardDescription,
                      ), // 
                      Text(
                        "📅 Fecha: ${h['fechaCreacion']?.substring(0, 10) ?? 'N/A'}}",
                        style: AppTextStyles.cardDescription.copyWith(
                          fontSize: 12,
                          color: AppColors.paynesGray.withOpacity(0.7),
                        ),
                      ), 
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context); 
                    _mostrarDetalleHistoria(h);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, //
              foregroundColor: AppColors.paynesGray, //
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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


  void _mostrarDetalleHistoria(Map<String, dynamic> h) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white, // 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Historia #${h['idHistoriaClinica']}",
          style: AppTextStyles.headline.copyWith(fontSize: 20), // 
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🧍 Paciente: ${h['nombreUsuario'] ?? ''} ${h['apellidoUsuario'] ?? ''}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "🩸 Tipo de Sangre: ${h['tipoSangre'] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              const SizedBox(height: 8),
              Text(
                "💊 Medicamentos: ${h['medicamentos'] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "🧬 Diagnósticos: ${h['diagnosticosPrincipales'] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              Text(
                "📄 Plan de Manejo: ${h['planManejo'] ?? 'N/A'}",
                style: AppTextStyles.body,
              ), // 🎨 Estilo
              const SizedBox(height: 10),
              Text(
                "🕒 Fecha: ${h['fechaCreacion']?.substring(0, 10) ?? 'N/A'}",
                style: AppTextStyles.cardDescription.copyWith(
                  fontSize: 13,
                  color: AppColors.paynesGray.withOpacity(0.7),
                ),
              ), // 🎨 
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine, // 🎨 
              foregroundColor: AppColors.paynesGray, // 🎨 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  
  void _mostrarResultadoEnDialogo(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white, // 🎨 Color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: AppTextStyles.headline.copyWith(
            // 🎨 Estilo
            color: isError ? Colors.red[700] : AppColors.keppel,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.body, // 🎨 Estilo
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isError
                  ? Colors.red[700]
                  : AppColors.aquamarine, // 🎨 Color
              foregroundColor: isError
                  ? AppColors.white
                  : AppColors.paynesGray, // 🎨 Color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Aceptar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste, // 🎨 Color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🎨 Color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ), // 🎨 Color
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Opciones de la Cita",
          style: AppTextStyles.headline, // 🎨 Estilo
        ),
        centerTitle: true,
      ),
      body: Container(
        // 🎨 GRADIENTE DE FONDO
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
        
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    (Scaffold.of(context).appBarMaxHeight ?? 0) -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Center(
                    
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.5), // 🎨 Color
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.paynesGray.withOpacity(
                              0.1,
                            ), // 🎨
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _loading
                          ? Column(
                              // 
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.aquamarine,
                                ), // 
                                SizedBox(height: 16),
                                Text("Cargando...", style: AppTextStyles.body),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Seleccione una opción",
                                  style: AppTextStyles.headline.copyWith(
                                    fontSize: 18,
                                  ), // 
                                ),
                                const SizedBox(height: 25),

                                
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.aquamarine, // 
                                    foregroundColor:
                                        AppColors.paynesGray, // 
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ), // 🎨 Redondeado
                                    minimumSize: Size(
                                      double.infinity,
                                      50,
                                    ), // 🎨 Ancho completo
                                  ),
                                  onPressed: _verRegistroCita,
                                  icon: const Icon(
                                    Icons.medical_services_outlined,
                                  ),
                                  label: Text(
                                    "Ver Registro de Cita",
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 16,
                                    ),
                                  ), // 🎨 Estilo
                                ),
                                const SizedBox(height: 20),

                                // 🎨 Botón Secundario
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.keppel, // 🎨 Color
                                    foregroundColor:
                                        AppColors.white, // 🎨 Color
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ), // 
                                    minimumSize: Size(
                                      double.infinity,
                                      50,
                                    ), //
                                  ),
                                  onPressed: _verHistoriasClinicas,
                                  icon: const Icon(Icons.description_outlined),
                                  label: Text(
                                    "Historias Clínicas",
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.white,
                                      fontSize: 16,
                                    ),
                                  ), 
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
