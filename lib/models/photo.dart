/// Modelo que representa una Fotografía.
class Photo {
  final int id;
  final String photoPath;
  final String? descripcion;

  Photo({required this.id, required this.photoPath, this.descripcion});

  factory Photo.fromJson(Map<String, dynamic> json) {
    String rawPath = json['photo_path'];
    if (!rawPath.startsWith("https")) {
      rawPath = "https://api-monitor.sat-industriales.pe/" + rawPath;
    }
    return Photo(
      id: json['id'],
      photoPath: rawPath,
      descripcion: json['descripcion'],
    );
  }
}
