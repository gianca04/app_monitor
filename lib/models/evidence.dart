import 'package:app_monitor/models/photo.dart';
import 'package:intl/intl.dart';

/// Modelo que representa una Evidencia.
class Evidence {
  final int id;
  final String name;
  final String? description;
  final List<Photo> photos;
  final DateTime createdAt;

  Evidence({
    required this.id,
    required this.name,
    this.description,
    required this.photos,
    required this.createdAt,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    List<Photo> photos = [];
    if (json['photos'] != null) {
      photos =
          (json['photos'] as List)
              .map((photoJson) => Photo.fromJson(photoJson))
              .toList();
    }
    return Evidence(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photos: photos,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Retorna la fecha formateada de forma legible.
  String get formattedDate {
    // Puedes ajustar el formato según tus necesidades.
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt);
  }
}
