/// Modelo que representa una Fotografía.
class Photo {
  final int id;
  final String photoPath;
  final String? descripcion;

  Photo({required this.id, required this.photoPath, this.descripcion});

  factory Photo.fromJson(Map<String, dynamic> json) {
    String rawPath = json['photo_path'];
    if (!rawPath.startsWith("http")) {
      rawPath = "http://192.168.10.52:8000/" + rawPath;
    }
    return Photo(
      id: json['id'],
      photoPath: rawPath,
      descripcion: json['descripcion'],
    );
  }
}
