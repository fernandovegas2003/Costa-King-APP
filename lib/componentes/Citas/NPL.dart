// lib/NPL/NPLScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _obtenerUserId();
  }

  Future<void> _obtenerUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("id") ?? prefs.getString("userId") ?? "";
    });
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
          _procesadoExitoso = false; // Resetear estado al seleccionar nuevo archivo
        });
      }
    } catch (e) {
      _mostrarSnackBar("Error al seleccionar archivo: $e");
    }
  }

  Future<void> _procesarArchivo() async {
    if (_archivoSeleccionado == null) {
      _mostrarSnackBar("Por favor selecciona un archivo primero");
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      _mostrarSnackBar("Error: No se encontró el ID del usuario");
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://nlp-hc-service.canadacentral.cloudapp.azure.com/api/nlp/process'),
      );

      request.fields['userId'] = _userId!;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _archivoSeleccionado!.path,
          filename: _nombreArchivo,
        ),
      );

      var response = await request.send();

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
      }
    } catch (e) {
      setState(() {
        _procesando = false;
      });
      _mostrarSnackBar("Error: $e");
    }
  }

  Future<void> _descargarExcel() async {
    if (_userId == null || _userId!.isEmpty) {
      _mostrarSnackBar("Error: No se encontró el ID del usuario");
      return;
    }

    try {
      // Aquí puedes implementar la descarga del archivo Excel
      // Por ejemplo, usando el paquete download o abriendo el enlace en el navegador
      final url = 'https://nlp-hc-service.canadacentral.cloudapp.azure.com/api/nlp/download-excel?userId=$_userId';

      // Opción 1: Abrir en el navegador
      // await launchUrl(Uri.parse(url));

      // Opción 2: Descargar directamente
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _mostrarDialogoDescargaExito();
      } else {
        _mostrarSnackBar("Error al descargar el Excel: ${response.statusCode}");
      }
    } catch (e) {
      _mostrarSnackBar("Error al descargar: $e");
    }
  }

  void _mostrarDialogoDescargaExito() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Descarga Exitosa"),
          content: const Text("El archivo Excel ha sido descargado exitosamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
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
          // Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/images/Fondo.png",
              fit: BoxFit.cover,
            ),
          ),

          // Contenido principal
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
                  // Icono de NPL
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Color(0xFF01A4B2),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    "Procesamiento de Archivos NPL",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Sube un archivo para procesar y generar un reporte en Excel",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Botón para seleccionar archivo
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

                  // Información del archivo seleccionado
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
                            child: Text(
                              _nombreArchivo!,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: _limpiarSeleccion,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botón de procesar
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
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
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

                  // Botón de descargar (solo cuando el procesamiento fue exitoso)
                  if (_procesadoExitoso) ...[
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _descargarExcel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text("Descargar Excel"),
                        ],
                      ),
                    ),
                  ],

                  // Botón para procesar otro archivo
                  if (_procesadoExitoso) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _limpiarSeleccion,
                      child: const Text(
                        "Procesar otro archivo",
                        style: TextStyle(color: Color(0xFF01A4B2)),
                      ),
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