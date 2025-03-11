import 'package:app_monitor/models/photo.dart';

/// Modelo que representa una Evidencia.
class Evidence {
  final int id;
  final String name;
  final String? description;
  final List<Photo> photos;

  Evidence({
    required this.id,
    required this.name,
    this.description,
    required this.photos,
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
    );
  }
}
