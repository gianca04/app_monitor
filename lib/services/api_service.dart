import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/services/api_exception.dart';

class ApiService {
  static const String baseUrl = "http://192.168.10.52:8000/api";

  static Future<List<Evidence>> getEvidences() async {
    final response = await http.get(Uri.parse("$baseUrl/evidences"));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List evidencesJson = jsonData['data'];
      return evidencesJson.map((json) => Evidence.fromJson(json)).toList();
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

  static Future<String> createEvidence(String name, String description) async {
    final response = await http.post(
      Uri.parse("$baseUrl/evidences"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "description": description}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return jsonData['message'];
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
