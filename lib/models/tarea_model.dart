class Tarea {
  final int id;
  final int servicioId;
  final String titulo;
  final String detalle;
  final String responsable;
  final String rendimiento;
  final String medida;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String imagen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tarea({
    required this.id,
    required this.servicioId,
    required this.titulo,
    required this.detalle,
    required this.responsable,
    required this.rendimiento,
    required this.medida,
    this.fechaInicio,
    this.fechaFin,
    required this.imagen,
    this.createdAt,
    this.updatedAt,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      servicioId: json['servicio_id'],
      titulo: json['titulo'],
      detalle: json['detalle'],
      responsable: json['responsable'],
      rendimiento: json['rendimiento'],
      medida: json['medida'],
      fechaInicio:
          json['fecha_inicio'] != null
              ? DateTime.parse(json['fecha_inicio'])
              : null,
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      imagen: json['imagen'],
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
      'servicio_id': servicioId,
      'titulo': titulo,
      'detalle': detalle,
      'responsable': responsable,
      'rendimiento': rendimiento,
      'medida': medida,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'imagen': imagen,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
