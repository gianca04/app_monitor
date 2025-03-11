class Servicio {
  final int id;
  final String? oc;
  final String descripcion;
  final String cliente;
  final String responsables;
  final String estado;
  final String? observacion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Servicio({
    required this.id,
    this.oc,
    required this.descripcion,
    required this.cliente,
    required this.responsables,
    required this.estado,
    this.observacion,
    this.createdAt,
    this.updatedAt,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      oc: json['oc'],
      descripcion: json['descripcion'],
      cliente: json['cliente'],
      responsables: json['responsables'],
      estado: json['estado'],
      observacion: json['observacion'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oc': oc,
      'descripcion': descripcion,
      'cliente': cliente,
      'responsables': responsables,
      'estado': estado,
      'observacion': observacion,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
