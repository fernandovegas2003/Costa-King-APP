import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "archivos_local_helper.dart";

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
    color: AppColors.paynesGray,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardDescription = TextStyle(
    color: AppColors.paynesGray,
    fontSize: 13,
    height: 1.4,
    fontFamily: _fontFamily,
  );
}

class ArchivosPage extends StatefulWidget {
  final Map<String, dynamic> cita;
  final String nombrePaciente;
  final int? idRegistroConsulta;

  const ArchivosPage({
    super.key,
    required this.cita,
    required this.nombrePaciente,
    this.idRegistroConsulta,
  });

  @override
  State<ArchivosPage> createState() => _ArchivosPageState();
}

class _ArchivosPageState extends State<ArchivosPage> {
  List<Map<String, dynamic>> _archivos = [];
  bool _cargando = true;
  int? _idHistoriaClinica;

  @override
  void initState() {
    super.initState();
    _cargarHistoriaClinica();
  }

  Future<void> _cargarHistoriaClinica() async {
    final rawIdPaciente = widget.cita['idPaciente'];
    final idPaciente = rawIdPaciente is int
        ? rawIdPaciente
        : int.tryParse('$rawIdPaciente');

    if (idPaciente == null) {
      setState(() => _cargando = false);
      _showSnack('No se encontro historia clinica del paciente', isError: true);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://blesshealth24-7-backprocesosmedicos-1.onrender.com/api/historias-clinicas/paciente/$idPaciente',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final lista = decoded is List
            ? decoded
            : (decoded is Map && decoded['data'] is List)
            ? decoded['data']
            : [];

        if (lista.isNotEmpty) {
          final primero = Map<String, dynamic>.from(lista.first as Map);
          final dynamic idHistoriaRaw = primero['idHistoriaClinica'];
          final idHistoria = idHistoriaRaw is int
              ? idHistoriaRaw
              : int.tryParse('$idHistoriaRaw');

          setState(() {
            _idHistoriaClinica = idHistoria;
          });

          await _cargarArchivos();
        } else {
          setState(() => _cargando = false);
        }
      } else {
        setState(() => _cargando = false);
        _showSnack(
          'No se encontro historia clinica del paciente',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _showSnack('Error al cargar historia clinica: $e', isError: true);
    }
  }

  Future<void> _cargarArchivos() async {
    final locales = await ArchivosLocalHelper.load(_idHistoriaClinica);
    if (!mounted) return;
    setState(() {
      _archivos = locales;
      _cargando = false;
    });
  }

  Future<void> _eliminarArchivoLocal(Map<String, dynamic> archivo) async {
    if (_idHistoriaClinica == null) return;
    await ArchivosLocalHelper.delete(_idHistoriaClinica, archivo);
    await _cargarArchivos();
    _showSnack('Archivo eliminado');
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red[700]
            : AppColors.keppel,
      ),
    );
  }

  bool _esImagen(Map<String, dynamic> archivo) {
    final tipo = (archivo['tipoArchivo'] ?? '').toString();
    return tipo.startsWith('image/');
  }

  void _visualizarArchivo(Map<String, dynamic> archivo) {
    final nombre = archivo['nombreArchivo'] ?? archivo['nombre'] ?? 'Archivo';
    final b64 = archivo['base64Data'];
    final tipo = (archivo['tipoArchivo'] ?? '').toString();

    if (b64 is String && tipo.startsWith('image/')) {
      try {
        final bytes = base64Decode(b64);
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        );
        return;
      } catch (_) {}
    }

    if (b64 is String && tipo.contains('text')) {
      try {
        final bytes = base64Decode(b64);
        final contenido = utf8.decode(bytes);
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              nombre,
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: SelectableText(contenido, style: AppTextStyles.body),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aquamarine,
                  foregroundColor: AppColors.paynesGray,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        return;
      } catch (_) {}
    }

    _showSnack('No se puede previsualizar este tipo de archivo ($tipo)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.celeste,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.paynesGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Archivos Adjuntos",
          style: AppTextStyles.headline.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: AppColors.keppel.withOpacity(0.1),
            child: Text(
              widget.nombrePaciente.toUpperCase(),
              style: AppTextStyles.body.copyWith(
                color: AppColors.keppel,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
          child: _cargando
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.aquamarine),
                      SizedBox(height: 16),
                      Text("Cargando archivos...", style: AppTextStyles.body),
                    ],
                  ),
                )
              : _archivos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off_outlined,
                        size: 60,
                        color: AppColors.paynesGray.withOpacity(0.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay archivos disponibles',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.paynesGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _archivos.length,
                  itemBuilder: (context, index) {
                    final archivo = _archivos[index];
                    final nombreArchivo =
                        archivo['nombreArchivo'] ??
                        archivo['nombre'] ??
                        'Archivo sin nombre';
                    final tipoArchivo =
                        archivo['tipoArchivo'] ??
                        archivo['tipo'] ??
                        'desconocido';
                    final fechaArchivo =
                        archivo['fechaCreacion'] ??
                        archivo['fecha'] ??
                        'Fecha desconocida';

                    return Card(
                      color: AppColors.white.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          tipoArchivo.contains('pdf')
                              ? Icons.picture_as_pdf_outlined
                              : _esImagen(archivo)
                              ? Icons.image_outlined
                              : Icons.insert_drive_file_outlined,
                          color: tipoArchivo.contains('pdf')
                              ? Colors.red[700]
                              : _esImagen(archivo)
                              ? AppColors
                                  .keppel
                              : AppColors.paynesGray,
                        ),
                        title: Text(
                          nombreArchivo,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Tipo: $tipoArchivo\nFecha: $fechaArchivo",
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.paynesGray.withOpacity(0.7),
                          ),
                        ),
                        onTap: () => _visualizarArchivo(archivo),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[700],
                          ),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminarArchivoLocal(archivo),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}