import 'dart:convert';
import 'package:app_monitor/models/paginated_evidences.dart';
import 'package:http/http.dart' as http;
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/services/api_exception.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class APIException implements Exception {
  final String message;
  APIException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = "http://app-monitor.sat-industriales.pe/api";

  static Future<PaginatedEvidences> getEvidences({
    int page = 1,
    String? search,
    String?
    startDate, // Cambié 'dateFrom' a 'startDate' para que coincida con Laravel
    String?
    endDate, // Cambié 'dateTo' a 'endDate' para que coincida con Laravel
    String sortOrder = "desc", // Cambié 'orderBy' a 'sortOrder'
  }) async {
    // Construir los parámetros de consulta de forma dinámica
    final Map<String, String> queryParameters = {
      'page': page.toString(),
      'sort_order': sortOrder, // Cambié 'order_by' a 'sort_order'
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParameters['start_date'] = startDate; // Laravel espera 'start_date'
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParameters['end_date'] = endDate; // Laravel espera 'end_date'
    }

    final uri = Uri.parse(
      "$baseUrl/evidences",
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedEvidences.fromJson(jsonData);
    } else {
      throw APIException("Error al cargar las evidencias");
    }
  }

  static Future<Evidence> getEvidence(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/evidences/$id"));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Evidence.fromJson(jsonData);
    } else {
      throw APIException("Error al cargar la evidencia");
    }
  }

  // En ApiService
  static Future<int> createEvidence(String name, String description) async {
    final response = await http.post(
      Uri.parse("$baseUrl/evidences"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "description": description}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // Se asume que el backend retorna el nuevo ID en 'id'
      return jsonData['data']['id'];
    } else {
      throw APIException("Error al crear la evidencia");
    }
  }

  static Future<String> updateEvidence(
    int id,
    String name,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/evidences/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "description": description}),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
    } else {
      throw APIException("Error al actualizar la evidencia");
    }
  }

  static Future<String> deleteEvidence(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/evidences/$id"));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
    } else {
      throw APIException("Error al eliminar la evidencia");
    }
  }

  static Future<String> createPhoto(
    int evidenceId,
    String descripcion,
    String filePath,
  ) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/photos"));
    request.fields["evidence_id"] = evidenceId.toString();
    request.fields["descripcion"] = descripcion;
    request.files.add(await http.MultipartFile.fromPath("photo", filePath));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
    } else {
      throw APIException("Error al crear la fotografía");
    }
  }

  static Future<String> updatePhoto(
    int id,
    int evidenceId,
    String descripcion,
    String? filePath,
  ) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/photos/$id"),
    );
    request.fields["evidence_id"] = evidenceId.toString();
    request.fields["descripcion"] = descripcion;
    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath("photo", filePath));
    }
    request.headers["X-HTTP-Method-Override"] = "PUT";
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
    } else {
      throw APIException("Error al actualizar la fotografía");
    }
  }

  static Future<String> deletePhoto(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/photos/$id"));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
    } else {
      throw APIException("Error al eliminar la fotografía");
    }
  }
}
