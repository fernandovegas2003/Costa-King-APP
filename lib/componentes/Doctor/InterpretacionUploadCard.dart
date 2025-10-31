import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'archivos_local_helper.dart';

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
    fontSize: 20,
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
}

class InterpretacionUploadCard extends StatefulWidget {
  final int? idHistoriaClinica;
  final VoidCallback? onSaved;

  const InterpretacionUploadCard({
    super.key,
    required this.idHistoriaClinica,
    this.onSaved,
  });

  @override
  State<InterpretacionUploadCard> createState() =>
      _InterpretacionUploadCardState();
}

class _InterpretacionUploadCardState extends State<InterpretacionUploadCard> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _bytesSeleccionados;
  String? _nombreArchivo;
  String? _tipoArchivo;
  bool _guardando = false;

  bool get _puedeGuardar =>
      !_guardando &&
      _bytesSeleccionados != null &&
      widget.idHistoriaClinica != null;

  Future<void> _guardar() async {
    if (!_puedeGuardar) {
      _showSnack(
        'Selecciona un archivo antes de guardar.',
        isError: true,
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await ArchivosLocalHelper.addBytes(
        idHistoriaClinica: widget.idHistoriaClinica,
        nombre:
            _nombreArchivo ??
            'archivo_${DateTime.now().millisecondsSinceEpoch}',
        mimeType: _tipoArchivo ?? 'application/octet-stream',
        bytes: _bytesSeleccionados!,
      );
      setState(() {
        _bytesSeleccionados = null;
        _nombreArchivo = null;
        _tipoArchivo = null;
      });
      widget.onSaved?.call();
      _showSnack('Archivo guardado correctamente.');
    } catch (e) {
      _showSnack(
        'No se pudo guardar el archivo: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      _actualizarSeleccion(
        bytes,
        xfile.name.isNotEmpty ? xfile.name : _nombreTemporal('jpg'),
      );
    } catch (e) {
      _showSnack('No se pudo tomar la foto: $e', isError: true);
    }
  }

  Future<void> _seleccionarGaleria() async {
    try {
      final xfile = await _picker.pickImage(source: ImageSource.gallery);
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      _actualizarSeleccion(
        bytes,
        xfile.name.isNotEmpty ? xfile.name : _nombreTemporal('jpg'),
      );
    } catch (e) {
      _showSnack(
        'Error al seleccionar imagen: $e',
        isError: true,
      );
    }
  }

  Future<void> _seleccionarDocumento() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('El archivo seleccionado no contiene datos.');
      }
      _actualizarSeleccion(file.bytes!, file.name);
    } catch (e) {
      _showSnack(
        'Error al seleccionar documento: $e',
        isError: true,
      );
    }
  }

  void _actualizarSeleccion(Uint8List bytes, String nombre) {
    setState(() {
      _bytesSeleccionados = bytes;
      _nombreArchivo = nombre;
      _tipoArchivo = ArchivosLocalHelper.guessMimeType(nombre);
    });
  }

  String _nombreTemporal(String extension) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'captura_$ts.$extension';
  }

  void _showSnack(String mensaje, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError
            ? Colors.red[700]
            : AppColors.keppel,
      ),
    );
  }

  IconData _iconoPorTipo() {
    final tipo = (_tipoArchivo ?? '').toLowerCase();
    if (tipo.startsWith('image/')) return Icons.image_outlined;
    if (tipo.contains('pdf')) return Icons.picture_as_pdf;
    if (tipo.contains('word') || tipo.contains('msword')) {
      return Icons.description_outlined;
    }
    if (tipo.contains('excel')) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
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
    _showSnack(
      'No se puede previsualizar este tipo de archivo ($tipo)',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombreMostrado = _nombreArchivo ?? 'Sin archivo seleccionado';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white.withOpacity(0.7),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.iceBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.keppel.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _iconoPorTipo(),
                    size: 32,
                    color: AppColors.keppel,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombreMostrado,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _puedeGuardar ? _guardar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aquamarine,
                  foregroundColor: AppColors.paynesGray,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.paynesGray,
                        ),
                      )
                    : Text(
                        'Guardar',
                        style: AppTextStyles.button.copyWith(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _buildOpcionCarga(
              icon: Icons.camera_alt_outlined,
              label: 'Subir foto',
              onTap: _tomarFoto,
            ),
            const SizedBox(height: 12),
            _buildOpcionCarga(
              icon: Icons.photo_library_outlined,
              label: 'Subir galeria',
              onTap: _seleccionarGaleria,
            ),
            const SizedBox(height: 12),
            _buildOpcionCarga(
              icon: Icons.description_outlined,
              label: 'Subir documento',
              onTap: _seleccionarDocumento,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionCarga({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _guardando ? null : onTap,
        icon: Icon(icon, color: AppColors.paynesGray),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.paynesGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.keppel.withOpacity(0.7),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}