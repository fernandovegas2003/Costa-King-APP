import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HistoriaUsuario.dart';

class OpcionesCitaScreen extends StatefulWidget {
  const OpcionesCitaScreen({Key? key}) : super(key: key);

  @override
  State<OpcionesCitaScreen> createState() => _OpcionesCitaScreenState();
}

class _OpcionesCitaScreenState extends State<OpcionesCitaScreen> {
  bool _loading = false;

  // =============================
  // 🔹 VER REGISTRO DE CITA
  // =============================
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

    final response = await http.get(Uri.parse(
        "https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/registros-consultas/cita/$idCita"));

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["data"] != null && data["data"].isNotEmpty) {
        final registro = data["data"][0];
        _mostrarRegistroEnDialogo(registro); // <-- Se llama al método definido abajo
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

  // =============================
  // 🔹 MOSTRAR REGISTRO (AlertDialog resumido)
  // =============================
  void _mostrarRegistroEnDialogo(Map<String, dynamic> registro) {
    const _textStyle = TextStyle(
        decoration: TextDecoration.none, color: Colors.black87, fontSize: 15);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Registro de la Cita",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("👤 Paciente: ${registro["nombrePaciente"]}", style: _textStyle),
              Text("🩺 Médico: ${registro["nombreMedico"]}", style: _textStyle),
              Text("🏥 Especialidad: ${registro["especialidadMedico"] ?? 'N/A'}", style: _textStyle),
              const SizedBox(height: 10),
              Text("📝 Motivo: ${registro["motivoConsulta"] ?? 'N/A'}", style: _textStyle),
              Text("🤒 Síntomas: ${registro["sintomas"] ?? 'N/A'}", style: _textStyle),
              const SizedBox(height: 10),
              Text("💓 Presión Arterial: ${registro["presionArterial"] ?? 'N/A'}", style: _textStyle),
              Text("❤️ Frecuencia Cardíaca: ${registro["frecuenciaCardiaca"] ?? 'N/A'}", style: _textStyle),
              Text("⚖️ Peso: ${registro["peso"] ?? 'N/A'}", style: _textStyle),
              Text("📏 Altura: ${registro["altura"] ?? 'N/A'}", style: _textStyle),
              Text("📉 IMC: ${registro["imc"] ?? 'N/A'}", style: _textStyle),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cerrar",
              style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
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

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Historias Clínicas del Paciente",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: historias.length,
                      itemBuilder: (context, index) {
                        final historia = historias[index];
                        return Card(
                          elevation: 4,
                          shadowColor: Colors.black26,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalleHistoriaClinicaScreen(
                                    idHistoriaClinica:
                                    historia["idHistoriaClinica"],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Historia #${historia["idHistoriaClinica"]}",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _infoText("Tipo de Sangre",
                                      historia["tipoSangre"] ?? "N/A"),
                                  _infoText("Alergias",
                                      historia["alergias"] ?? "No registradas"),
                                  _infoText(
                                      "Enfermedades Crónicas",
                                      historia["enfermedadesCronicas"] ??
                                          "No registradas"),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Fecha de creación: ${historia["fechaCreacion"]?.substring(0, 10) ?? "N/A"}",
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
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
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // =============================
  // 🔹 MOSTRAR LISTA DE HISTORIAS EN DIALOG
  // =============================
  void _mostrarListaHistorias(List<dynamic> historias) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Historias Clínicas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    "Historia #${h['idHistoriaClinica']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🩸 Tipo de Sangre: ${h['tipoSangre'] ?? 'N/A'}"),
                      Text("🤧 Alergias: ${h['alergias'] ?? 'N/A'}"),
                      Text("🏥 Enfermedades: ${h['enfermedadesCronicas'] ?? 'N/A'}"),
                      Text("📅 Fecha: ${h['fechaCreacion']?.substring(0, 10) ?? 'N/A'}"),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context); // cerrar lista
                    _mostrarDetalleHistoria(h);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar",
                style:
                TextStyle(color: Colors.white, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }

  // =============================
  // 🔹 MOSTRAR DETALLE (resumido)
  // =============================
  void _mostrarDetalleHistoria(Map<String, dynamic> h) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Historia #${h['idHistoriaClinica']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🧍 Paciente: ${h['nombreUsuario'] ?? ''} ${h['apellidoUsuario'] ?? ''}"),
              Text("🩸 Tipo de Sangre: ${h['tipoSangre'] ?? 'N/A'}"),
              const SizedBox(height: 8),
              Text("💊 Medicamentos: ${h['medicamentos'] ?? 'N/A'}"),
              Text("🧬 Diagnósticos: ${h['diagnosticosPrincipales'] ?? 'N/A'}"),
              Text("📄 Plan de Manejo: ${h['planManejo'] ?? 'N/A'}"),
              const SizedBox(height: 10),
              Text("🕒 Fecha: ${h['fechaCreacion']?.substring(0, 10) ?? 'N/A'}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar",
                style:
                TextStyle(color: Colors.white, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }

  // =============================
  // 🔹 MENSAJE DE RESULTADO
  // =============================
  void _mostrarResultadoEnDialogo(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isError ? Colors.red : Colors.blue,
            decoration: TextDecoration.none,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(decoration: TextDecoration.none),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isError ? Colors.red : Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar",
                style: TextStyle(color: Colors.white, decoration: TextDecoration.none)),
          ),
        ],
      ),
    );
  }

  // =============================
  // 🔹 INTERFAZ
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Opciones de la Cita",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/Fondo.png", fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Seleccione una opción",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _verRegistroCita,
                          icon: const Icon(Icons.medical_services,
                              color: Colors.white),
                          label: const Text("Ver Registro de Cita",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _verHistoriasClinicas,
                          icon: const Icon(Icons.description,
                              color: Colors.white),
                          label: const Text("Historias Clínicas",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
