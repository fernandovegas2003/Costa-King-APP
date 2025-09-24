import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ArchivosLocalHelper {
  static const String _prefsPrefix = 'archivos_';

  static String _buildKey(int? idHistoriaClinica) {
    final suffix = idHistoriaClinica?.toString() ?? 'sin_historia';
    return '$_prefsPrefix$suffix';
  }

  static Future<List<Map<String, dynamic>>> load(int? idHistoriaClinica) async {
    if (idHistoriaClinica == null) {
      return <Map<String, dynamic>>[];
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_buildKey(idHistoriaClinica));
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  static Future<void> _save(
    int? idHistoriaClinica,
    List<Map<String, dynamic>> items,
  ) async {
    if (idHistoriaClinica == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buildKey(idHistoriaClinica), jsonEncode(items));
  }

  static Future<Map<String, dynamic>> addBytes({
    required int? idHistoriaClinica,
    required String nombre,
    required String mimeType,
    required List<int> bytes,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('El archivo no contiene datos');
    }

    final archivo = <String, dynamic>{
      'nombreArchivo': nombre,
      'tipoArchivo': mimeType,
      'fechaCreacion': DateTime.now().toIso8601String(),
      'origen': 'local',
      'base64Data': base64Encode(bytes),
    };

    final actuales = await load(idHistoriaClinica);
    actuales.add(archivo);
    await _save(idHistoriaClinica, actuales);
    return archivo;
  }

  static Future<void> delete(
    int? idHistoriaClinica,
    Map<String, dynamic> archivo,
  ) async {
    final actuales = await load(idHistoriaClinica);
    actuales.removeWhere(
      (item) =>
          item['nombreArchivo'] == archivo['nombreArchivo'] &&
          item['fechaCreacion'] == archivo['fechaCreacion'] &&
          item['base64Data'] == archivo['base64Data'],
    );
    await _save(idHistoriaClinica, actuales);
  }

  static String guessMimeType(String nombreArchivo) {
    final lower = nombreArchivo.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return 'application/msword';
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return 'application/vnd.ms-excel';
    }
    return 'application/octet-stream';
  }
}
