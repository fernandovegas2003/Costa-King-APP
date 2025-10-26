// lib/NPL/NPLScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class NPLScreen extends StatefulWidget {
  const NPLScreen({Key? key}) : super(key: key);

  @override
  _NPLScreenState createState() => _NPLScreenState();
}

class _NPLScreenState extends State<NPLScreen> {
  File? _archivoSeleccionado;
  String? _nombreArchivo;
  bool _procesando = false;
  bool _procesadoExitoso = false;
  String? _userId;
  String? _rutaArchivoGuardado;

  @override
  void initState() {
    super.initState();
    _obtenerUserId();
  }

  Future<void> _obtenerUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idPaciente = prefs.getInt("idPaciente");
    final idDoctor = prefs.getInt("idDoctor");

    setState(() {
      if (idPaciente != null) {
        _userId = idPaciente.toString();
      } else if (idDoctor != null) {
        _userId = idDoctor.toString();
      } else {
        _userId = "";
      }
    });

    print("🧾 ID obtenido desde SharedPreferences: $_userId");
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _archivoSeleccionado = File(result.files.single.path!);
          _nombreArchivo = result.files.single.name;
          _procesadoExitoso = false;
        });
      }
    } catch (e) {
      _mostrarSnackBar("Error al seleccionar archivo: $e");
    }
  }

  Future<void> _procesarArchivo() async {
    print("🚀 Entrando a la función de envío...");
    print("📁 Archivo seleccionado: $_archivoSeleccionado");
    print("🧍 ID de usuario actual: $_userId");

    if (_archivoSeleccionado == null) {
      _mostrarSnackBar("Por favor selecciona un archivo primero");
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      _mostrarSnackBar("Error: No se encontró el ID del usuario");
      print("⚠️ _userId está vacío o nulo");
      return;
    }

    if (!_archivoSeleccionado!.existsSync()) {
      _mostrarSnackBar("Error: El archivo seleccionado no existe");
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      print("📤 Preparando solicitud HTTP...");

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://nlp-hc-service.canadacentral.cloudapp.azure.com/api/nlp/process'),
      );

      request.fields['idUsuario'] = _userId!;
      request.fields['idHistoriaClinica'] = '25';
      request.fields['idPaciente'] = _userId!;
      request.fields['generar_excel'] = 'true';

      print("📦 Campos que se envían:");
      request.fields.forEach((key, value) {
        print(" - $key: $value");
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _archivoSeleccionado!.path,
          filename: _nombreArchivo,
        ),
      );
      print("📎 Archivo agregado a la solicitud: ${_archivoSeleccionado!.path}");

      var response = await ioClient.send(request);
      print("✅ Respuesta del servidor: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          _procesando = false;
          _procesadoExitoso = true;
        });
        _mostrarSnackBar("Archivo procesado exitosamente");
      } else {
        setState(() {
          _procesando = false;
        });
        _mostrarSnackBar("Error al procesar el archivo: ${response.statusCode}");

        final responseBody = await response.stream.bytesToString();
        print("📄 Cuerpo de respuesta: $responseBody");
      }

      ioClient.close();

    } catch (e) {
      setState(() {
        _procesando = false;
      });
      print("❌ Error en _procesarArchivo(): $e");
      _mostrarSnackBar("Error: $e");
    }
  }

  Future<void> _descargarExcel() async {
    if (_userId == null || _userId!.isEmpty) {
      _mostrarSnackBar("Error: No se encontró el ID del usuario");
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      final url = 'https://nlp-hc-service.canadacentral.cloudapp.azure.com/api/nlp/download-excel?userId=$_userId';

      print("📥 Iniciando descarga desde: $url");

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);

      var response = await ioClient.get(Uri.parse(url));

      print("📊 Respuesta de descarga: ${response.statusCode}");

      if (response.statusCode == 200) {
        // ✅ GUARDAR ARCHIVO EN DESCARGAS DEL DISPOSITIVO
        final resultadoGuardado = await _guardarArchivoEnDescargasGlobales(response.bodyBytes);

        setState(() {
          _procesando = false;
        });

        if (resultadoGuardado) {
          _mostrarNotificacionDescargaExito();
        } else {
          _mostrarSnackBar("Error al guardar el archivo en Descargas");
        }
      } else {
        setState(() {
          _procesando = false;
        });
        _mostrarSnackBar("Error al descargar el Excel: ${response.statusCode}");
      }

      ioClient.close();

    } catch (e) {
      setState(() {
        _procesando = false;
      });
      print("❌ Error en _descargarExcel(): $e");
      _mostrarSnackBar("Error al descargar: $e");
    }
  }

  Future<bool> _guardarArchivoEnDescargasGlobales(List<int> bytes) async {
    try {
      // ✅ SOLICITAR PERMISOS DE ALMACENAMIENTO
      if (Platform.isAndroid) {
        // En Android 11 o superior se requiere MANAGE_EXTERNAL_STORAGE
        if (await Permission.manageExternalStorage.isGranted == false) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            _mostrarSnackBar("Se necesitan permisos para acceder al almacenamiento");
            return false;
          }
        }
      }


      // ✅ OBTENER RUTA DE DESCARGAS USANDO SOLO path_provider
      Directory downloadsDirectory;

      try {
        if (Platform.isAndroid) {
          // Para Android, intentar obtener directorio de descargas
          // Usamos getExternalStorageDirectory() que apunta a /storage/emulated/0/Android/data/com.example.bless_health24/files
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Crear subcarpeta Download dentro del directorio externo
            downloadsDirectory = Directory('/storage/emulated/0/Download');
            if (!downloadsDirectory.existsSync()) {
              downloadsDirectory.createSync(recursive: true);
            }
            print("📁 Usando directorio externo/Download: ${downloadsDirectory.path}");
          } else {
            throw Exception("No se pudo obtener directorio externo");
          }
        } else {
          // Para iOS, usar directorio de documentos
          downloadsDirectory = await getApplicationDocumentsDirectory();
          print("📁 Usando directorio de documentos: ${downloadsDirectory.path}");
        }
      } catch (e) {
        print("❌ Error obteniendo directorio: $e");
        // Fallback: usar directorio temporal
        downloadsDirectory = Directory.systemTemp;
        print("📁 Usando directorio temporal como fallback: ${downloadsDirectory.path}");
      }

      // ✅ CREAR NOMBRE DEL ARCHIVO
      final fecha = DateTime.now();
      final nombreArchivo = 'Reporte_NLP_${_userId}_${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}_${fecha.hour}${fecha.minute}.xlsx';
      final filePath = '${downloadsDirectory.path}/$nombreArchivo';

      print("💾 Guardando archivo en: $filePath");

      // ✅ GUARDAR ARCHIVO
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // ✅ VERIFICAR QUE SE GUARDÓ CORRECTAMENTE
      if (file.existsSync()) {
        final fileSize = await file.length();
        setState(() {
          _rutaArchivoGuardado = filePath;
        });

        print("✅ Archivo Excel guardado exitosamente");
        print("📊 Tamaño del archivo: $fileSize bytes");
        print("📍 Ruta: $filePath");
        return true;
      } else {
        print("❌ El archivo no se guardó correctamente");
        return false;
      }

    } catch (e) {
      print("❌ Error al guardar archivo: $e");
      return false;
    }
  }

  void _mostrarNotificacionDescargaExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "✅ Descarga completada",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Archivo Excel guardado correctamente",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: "ABRIR ARCHIVO",
          textColor: Colors.white,
          onPressed: () {
            _abrirArchivoDescargado();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _abrirArchivoDescargado() async {
    if (_rutaArchivoGuardado == null) {
      _mostrarSnackBar("No se encontró la ruta del archivo");
      return;
    }

    try {
      final result = await OpenFile.open(_rutaArchivoGuardado!);

      if (result.type != ResultType.done) {
        _mostrarDialogoUbicacionArchivo();
      }
    } catch (e) {
      print("❌ Error al abrir archivo: $e");
      _mostrarDialogoUbicacionArchivo();
    }
  }

  void _mostrarDialogoUbicacionArchivo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download_done, color: Color(0xFF01A4B2)),
              SizedBox(width: 8),
              Text("Archivo Guardado"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("El archivo Excel se ha guardado exitosamente."),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📁 Ubicación del archivo:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (_rutaArchivoGuardado != null)
                      SelectableText(
                        _rutaArchivoGuardado!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Puedes encontrar el archivo en la carpeta de descargas de tu dispositivo o usando un administrador de archivos.",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cerrar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarInstruccionesEncontrarArchivo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF01A4B2),
                foregroundColor: Colors.white,
              ),
              child: Text("¿Cómo encontrarlo?"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarInstruccionesEncontrarArchivo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Encontrar tu archivo Excel"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Para encontrar tu archivo guardado:"),
              SizedBox(height: 16),
              _buildPasoInstruccion(
                icon: Icons.phone_android,
                text: "1. Abre la app 'Archivos' o 'Administrador de archivos'",
              ),
              _buildPasoInstruccion(
                icon: Icons.search,
                text: "2. Busca 'Reporte_NLP_${_userId}' en la búsqueda",
              ),
              _buildPasoInstruccion(
                icon: Icons.folder,
                text: "3. Revisa la carpeta 'Download' o 'Descargas'",
              ),
              _buildPasoInstruccion(
                icon: Icons.open_in_new,
                text: "4. Toca el archivo para abrirlo con Excel",
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "💡 El archivo estará accesible desde cualquier app de archivos",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Entendido"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasoInstruccion({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Color(0xFF01A4B2)),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _limpiarSeleccion() {
    setState(() {
      _archivoSeleccionado = null;
      _nombreArchivo = null;
      _procesadoExitoso = false;
      _rutaArchivoGuardado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Procesamiento NPL",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Color(0xFF01A4B2)),
                  const SizedBox(height: 20),
                  const Text(
                    "Procesamiento de Archivos NPL",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sube un archivo para procesar y generar un reporte en Excel",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _procesando ? null : _seleccionarArchivo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF01A4B2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file),
                        SizedBox(width: 8),
                        Text("Seleccionar Archivo"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (_nombreArchivo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file, color: Color(0xFF01A4B2)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_nombreArchivo!, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                          ),
                          IconButton(icon: Icon(Icons.close, color: Colors.red), onPressed: _limpiarSeleccion),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_archivoSeleccionado != null && !_procesadoExitoso)
                    ElevatedButton(
                      onPressed: _procesando ? null : _procesarArchivo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF01A4B2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _procesando
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text("Procesando..."),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text("Procesar Archivo"),
                        ],
                      ),
                    ),

                  if (_procesadoExitoso) ...[
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _procesando ? null : _descargarExcel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _procesando
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text("Descargando..."),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text("Descargar Excel"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _limpiarSeleccion,
                      child: const Text("Procesar otro archivo", style: TextStyle(color: Color(0xFF01A4B2))),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}