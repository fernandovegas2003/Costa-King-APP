import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color celeste = Color(0xFFBDFFFD);
  static const Color iceBlue = Color(0xFF9FFFF5);
  static const Color aquamarine = Color(0xFF7CFFC4);
  static const Color keppel = Color(0xFF6ABEA7);
  static const Color paynesGray = Color(0xFF5E6973);
  static const Color white = Color(0xFFFFFFFF);
}


class AppTextStyles {
  static const String _fontFamily = 'TuFuenteApp';

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
  
  static const TextStyle button = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );
  
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.keppel,
    fontSize: 17,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 14,
    fontFamily: _fontFamily,
  );
}


class HistoriaClinicaPage extends StatefulWidget {
  final int idPaciente;

  const HistoriaClinicaPage({super.key, required this.idPaciente});

  @override
  State<HistoriaClinicaPage> createState() => _HistoriaClinicaPageState();
}

class _HistoriaClinicaPageState extends State<HistoriaClinicaPage> {
  bool mostrandoHistorias = false;
  bool cargando = false;
  List<dynamic> historias = [];

  final TextEditingController tipoSangreCtrl = TextEditingController();
  final TextEditingController alergiasCtrl = TextEditingController();
  final TextEditingController enfermedadesCtrl = TextEditingController();
  final TextEditingController medicamentosCtrl = TextEditingController();
  final TextEditingController antecedentesFamiliaresCtrl = TextEditingController();
  final TextEditingController observacionesCtrl = TextEditingController();
  final TextEditingController actividadFisicaCtrl = TextEditingController();
  final TextEditingController alimentacionDiariaCtrl = TextEditingController();
  final TextEditingController suenioCtrl = TextEditingController();
  final TextEditingController sexualidadCtrl = TextEditingController();
  final TextEditingController viajesCtrl = TextEditingController();
  final TextEditingController alcoholCtrl = TextEditingController();
  final TextEditingController sustanciasCtrl = TextEditingController();
  final TextEditingController antecedentesPersonalesCtrl = TextEditingController();
  final TextEditingController diagnosticosPrincipalesCtrl = TextEditingController();
  final TextEditingController diagnosticosDiferencialesCtrl = TextEditingController();
  final TextEditingController planManejoCtrl = TextEditingController();
  final TextEditingController conductaTratamientoCtrl = TextEditingController();
  final TextEditingController remisionesCtrl = TextEditingController();
  final TextEditingController examenesCtrl = TextEditingController();
  final TextEditingController educacionCtrl = TextEditingController();
  final TextEditingController epicrisisCtrl = TextEditingController();

  Future<void> obtenerHistorias() async {
    setState(() => cargando = true);
    final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/paciente/${widget.idPaciente}");
    try {
      final res = await http.get(url);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() {
          historias = decoded["data"] ?? [];
        });
      } else {
        _showSnack("Error al obtener historias (${res.statusCode})", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    } finally {
      if(mounted) setState(() => cargando = false);
    }
  }

  Future<void> crearHistoria() async {
    setState(() => cargando = true);
    final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas");
    final data = {
      "idPaciente": widget.idPaciente,
      "tipoSangre": tipoSangreCtrl.text,
      "alergias": alergiasCtrl.text,
      "enfermedadesCronicas": enfermedadesCtrl.text,
      "medicamentos": medicamentosCtrl.text,
      "antecedentesFamiliares": antecedentesFamiliaresCtrl.text,
      "observaciones": observacionesCtrl.text,
      "actividadFisica": actividadFisicaCtrl.text,
      "alimentacionDiaria": alimentacionDiariaCtrl.text,
      "suenio": suenioCtrl.text,
      "sexualidad": sexualidadCtrl.text,
      "viajes": viajesCtrl.text,
      "alcohol": alcoholCtrl.text,
      "sustanciasPsicoactivas": sustanciasCtrl.text,
      "antecedentesPersonales": antecedentesPersonalesCtrl.text,
      "diagnosticosPrincipales": diagnosticosPrincipalesCtrl.text,
      "diagnosticosDiferenciales": diagnosticosDiferencialesCtrl.text,
      "planManejo": planManejoCtrl.text,
      "conductaTratamiento": conductaTratamientoCtrl.text,
      "remisiones": remisionesCtrl.text,
      "examenesSolicitados": examenesCtrl.text,
      "educacionPaciente": educacionCtrl.text,
      "epicrisis": epicrisisCtrl.text
    };
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      
      if (!mounted) return;
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        _showSnack("Historia clínica creada correctamente ✅");
        _limpiarCampos();
      } else {
        _showSnack("Error al crear historia (${res.statusCode})", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    } finally {
      if(mounted) setState(() => cargando = false);
    }
  }

  void _limpiarCampos() {
    tipoSangreCtrl.clear(); alergiasCtrl.clear(); enfermedadesCtrl.clear();
    medicamentosCtrl.clear(); antecedentesFamiliaresCtrl.clear(); observacionesCtrl.clear();
    actividadFisicaCtrl.clear(); alimentacionDiariaCtrl.clear(); suenioCtrl.clear();
    sexualidadCtrl.clear(); viajesCtrl.clear(); alcoholCtrl.clear();
    sustanciasCtrl.clear(); antecedentesPersonalesCtrl.clear(); diagnosticosPrincipalesCtrl.clear();
    diagnosticosDiferencialesCtrl.clear(); planManejoCtrl.clear(); conductaTratamientoCtrl.clear();
    remisionesCtrl.clear(); examenesCtrl.clear(); educacionCtrl.clear(); epicrisisCtrl.clear();
  }

  void _showSnack(String msg, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : AppColors.keppel,
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.paynesGray),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          mostrandoHistorias
              ? "Historias Anteriores"
              : "Crear Historia Clínica",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              if (!mostrandoHistorias) {
                await obtenerHistorias();
              }
              setState(() {
                mostrandoHistorias = !mostrandoHistorias;
              });
            },
            icon: Icon(
              mostrandoHistorias ? Icons.add_circle_outline : Icons.history, 
              color: AppColors.keppel
            ),
            label: Text(
              mostrandoHistorias ? "Crear Nueva" : "Ver Anteriores",
              style: AppTextStyles.body.copyWith(color: AppColors.keppel, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.iceBlue, AppColors.celeste],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: cargando
            ? Center(child: CircularProgressIndicator(color: AppColors.aquamarine))
            : mostrandoHistorias
                ? _buildHistoriasList()
                : _buildFormulario(),
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("🧬 Datos Básicos"),
          _campoTexto("Tipo de Sangre", tipoSangreCtrl, Icons.bloodtype_outlined),
          _campoTexto("Observaciones", observacionesCtrl, Icons.comment_outlined, maxLines: 2),

          _tituloSeccion("🏥 Antecedentes Médicos"),
          _campoTexto("Alergias", alergiasCtrl, Icons.warning_amber_outlined),
          _campoTexto("Enfermedades Crónicas", enfermedadesCtrl, Icons.local_hospital_outlined),
          _campoTexto("Medicamentos", medicamentosCtrl, Icons.medication_outlined),
          _campoTexto("Antecedentes Familiares", antecedentesFamiliaresCtrl, Icons.family_restroom_outlined),
          _campoTexto("Antecedentes Personales", antecedentesPersonalesCtrl, Icons.person_search_outlined),

          _tituloSeccion("💪 Hábitos y Estilo de Vida"),
          _campoTexto("Actividad Física", actividadFisicaCtrl, Icons.fitness_center_outlined),
          _campoTexto("Alimentación Diaria", alimentacionDiariaCtrl, Icons.restaurant_outlined),
          _campoTexto("Sueño", suenioCtrl, Icons.bedtime_outlined),
          _campoTexto("Sexualidad", sexualidadCtrl, Icons.favorite_border),
          _campoTexto("Viajes", viajesCtrl, Icons.airplanemode_active_outlined),
          _campoTexto("Alcohol", alcoholCtrl, Icons.no_drinks_outlined),
          _campoTexto("Sustancias Psicoactivas", sustanciasCtrl, Icons.smoke_free_outlined),

          _tituloSeccion("🩺 Diagnóstico y Tratamiento"),
          _campoTexto("Diagnósticos Principales", diagnosticosPrincipalesCtrl, Icons.health_and_safety_outlined, maxLines: 2),
          _campoTexto("Diagnósticos Diferenciales", diagnosticosDiferencialesCtrl, Icons.difference_outlined, maxLines: 2),
          _campoTexto("Plan de Manejo", planManejoCtrl, Icons.rule_outlined, maxLines: 2),
          _campoTexto("Conducta / Tratamiento", conductaTratamientoCtrl, Icons.medical_services_outlined, maxLines: 2),
          _campoTexto("Remisiones", remisionesCtrl, Icons.send_outlined),
          _campoTexto("Exámenes Solicitados", examenesCtrl, Icons.science_outlined),
          _campoTexto("Educación al Paciente", educacionCtrl, Icons.school_outlined),
          _campoTexto("Epicrisis", epicrisisCtrl, Icons.description_outlined, maxLines: 3),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: crearHistoria,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aquamarine,
              foregroundColor: AppColors.paynesGray,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text("Guardar Historia Clínica", style: AppTextStyles.button),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoriasList() {
    if (historias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 60, color: AppColors.paynesGray.withOpacity(0.3)),
            SizedBox(height: 16),
            Text(
              "No hay historias clínicas anteriores",
              style: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: historias.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, i) {
        final h = historias[i];
        return Card(
          color: AppColors.white.withOpacity(0.7),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            iconColor: AppColors.keppel,
            collapsedIconColor: AppColors.keppel,
            title: Text(
              "Historia #${h['idHistoriaClinica']} (${h['fechaCreacion'].toString().substring(0, 10)})",
              style: AppTextStyles.cardTitle,
            ),
            subtitle: Text(
              "Paciente: ${h['nombreUsuario']} ${h['apellidoUsuario']}\nDocumento: ${h['numeroDocumento']}",
              style: AppTextStyles.cardDescription.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
            ),
            children: [
              _bloqueHistoria("🧬 Datos Básicos", {
                "Tipo de Sangre": h["tipoSangre"],
                "Observaciones": h["observaciones"],
              }),
              _bloqueHistoria("🏥 Antecedentes Médicos", {
                "Alergias": h["alergias"],
                "Enfermedades Crónicas": h["enfermedadesCronicas"],
                "Medicamentos": h["medicamentos"],
                "Antecedentes Familiares": h["antecedentesFamiliares"],
                "Antecedentes Personales": h["antecedentesPersonales"],
              }),
              _bloqueHistoria("💪 Hábitos y Estilo de Vida", {
                "Actividad Física": h["actividadFisica"],
                "Alimentación Diaria": h["alimentacionDiaria"],
                "Sueño": h["suenio"],
                "Sexualidad": h["sexualidad"],
                "Viajes": h["viajes"],
                "Alcohol": h["alcohol"],
                "Sustancias Psicoactivas": h["sustanciasPsicoactivas"],
              }),
              _bloqueHistoria("🩺 Diagnóstico y Tratamiento", {
                "Diagnósticos Principales": h["diagnosticosPrincipales"],
                "Diagnósticos Diferenciales": h["diagnosticosDiferenciales"],
                "Plan de Manejo": h["planManejo"],
                "Conducta / Tratamiento": h["conductaTratamiento"],
                "Remisiones": h["remisiones"],
                "Exámenes Solicitados": h["examenesSolicitados"],
                "Educación al Paciente": h["educacionPaciente"],
                "Epicrisis": h["epicrisis"],
              }),
              const SizedBox(height: 10),
              Text(
                "📅 Última actualización: ${h['fechaUltimaActualizacion'] ?? 'Sin cambios'}",
                style: AppTextStyles.cardDescription.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _bloqueHistoria(String titulo, Map<String, dynamic> campos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16, color: AppColors.keppel),
          ),
          const SizedBox(height: 6),
          ...campos.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.cardDescription,
                    children: [
                      TextSpan(text: "${e.key}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "${e.value ?? 'No registrado'}"),
                    ]
                  ),
                )
              )),
          Divider(color: AppColors.keppel.withOpacity(0.5), thickness: 0.8),
        ],
      ),
    );
  }

  Widget _campoTexto(String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(color: AppColors.paynesGray.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: AppColors.paynesGray, size: 20),
          filled: true,
          fillColor: AppColors.white.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.keppel, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        texto,
        style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
      ),
    );
  }
}