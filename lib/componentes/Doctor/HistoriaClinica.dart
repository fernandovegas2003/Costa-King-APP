import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // Controladores
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

  // 🔹 Obtener historias anteriores
  Future<void> obtenerHistorias() async {
    setState(() {
      cargando = true;
    });

    final url = Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/paciente/${widget.idPaciente}");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() {
          historias = decoded["data"] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener historias (${res.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  // 🔹 Crear historia clínica
  Future<void> crearHistoria() async {
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

      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Historia clínica creada correctamente ✅")),
        );
        _limpiarCampos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear historia (${res.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _limpiarCampos() {
    tipoSangreCtrl.clear();
    alergiasCtrl.clear();
    enfermedadesCtrl.clear();
    medicamentosCtrl.clear();
    antecedentesFamiliaresCtrl.clear();
    observacionesCtrl.clear();
    actividadFisicaCtrl.clear();
    alimentacionDiariaCtrl.clear();
    suenioCtrl.clear();
    sexualidadCtrl.clear();
    viajesCtrl.clear();
    alcoholCtrl.clear();
    sustanciasCtrl.clear();
    antecedentesPersonalesCtrl.clear();
    diagnosticosPrincipalesCtrl.clear();
    diagnosticosDiferencialesCtrl.clear();
    planManejoCtrl.clear();
    conductaTratamientoCtrl.clear();
    remisionesCtrl.clear();
    examenesCtrl.clear();
    educacionCtrl.clear();
    epicrisisCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mostrandoHistorias
              ? "Historias Clínicas Anteriores"
              : "Crear Historia Clínica",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BCD4),
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
            icon: const Icon(Icons.history, color: Colors.white),
            label: Text(
              mostrandoHistorias ? "Crear Nueva" : "Ver Anteriores",
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : mostrandoHistorias
          ? _buildHistoriasList()
          : _buildFormulario(),
    );
  }

  // 🔹 Formulario completo
  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("🧬 Datos Básicos"),
          _campoTexto("Tipo de Sangre", tipoSangreCtrl),
          _campoTexto("Observaciones", observacionesCtrl, maxLines: 2),

          _tituloSeccion("🏥 Antecedentes Médicos"),
          _campoTexto("Alergias", alergiasCtrl),
          _campoTexto("Enfermedades Crónicas", enfermedadesCtrl),
          _campoTexto("Medicamentos", medicamentosCtrl),
          _campoTexto("Antecedentes Familiares", antecedentesFamiliaresCtrl),
          _campoTexto("Antecedentes Personales", antecedentesPersonalesCtrl),

          _tituloSeccion("💪 Hábitos y Estilo de Vida"),
          _campoTexto("Actividad Física", actividadFisicaCtrl),
          _campoTexto("Alimentación Diaria", alimentacionDiariaCtrl),
          _campoTexto("Sueño", suenioCtrl),
          _campoTexto("Sexualidad", sexualidadCtrl),
          _campoTexto("Viajes", viajesCtrl),
          _campoTexto("Alcohol", alcoholCtrl),
          _campoTexto("Sustancias Psicoactivas", sustanciasCtrl),

          _tituloSeccion("🩺 Diagnóstico y Tratamiento"),
          _campoTexto("Diagnósticos Principales", diagnosticosPrincipalesCtrl, maxLines: 2),
          _campoTexto("Diagnósticos Diferenciales", diagnosticosDiferencialesCtrl, maxLines: 2),
          _campoTexto("Plan de Manejo", planManejoCtrl, maxLines: 2),
          _campoTexto("Conducta / Tratamiento", conductaTratamientoCtrl, maxLines: 2),
          _campoTexto("Remisiones", remisionesCtrl),
          _campoTexto("Exámenes Solicitados", examenesCtrl),
          _campoTexto("Educación al Paciente", educacionCtrl),
          _campoTexto("Epicrisis", epicrisisCtrl, maxLines: 3),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: crearHistoria,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Guardar Historia Clínica"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

// 🔹 Lista de historias anteriores (expandible y organizada)
  Widget _buildHistoriasList() {
    if (historias.isEmpty) {
      return const Center(child: Text("No hay historias clínicas anteriores"));
    }

    return ListView.builder(
      itemCount: historias.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, i) {
        final h = historias[i];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(
              "Historia #${h['idHistoriaClinica']} (${h['fechaCreacion'].toString().substring(0, 10)})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BCD4),
              ),
            ),
            subtitle: Text(
              "Paciente: ${h['nombreUsuario']} ${h['apellidoUsuario']}\nDocumento: ${h['numeroDocumento']}",
              style: const TextStyle(fontSize: 13),
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
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

// 🔹 Widget auxiliar para mostrar bloques organizados
  Widget _bloqueHistoria(String titulo, Map<String, dynamic> campos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BCD4),
            ),
          ),
          const SizedBox(height: 6),
          ...campos.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "${e.key}: ${e.value ?? 'No registrado'}",
              style: const TextStyle(fontSize: 14),
            ),
          )),
          const Divider(thickness: 0.8),
        ],
      ),
    );
  }


  // 🔹 Widgets auxiliares
  Widget _campoTexto(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4)),
      ),
    );
  }
}
