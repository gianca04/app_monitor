import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/models/photo.dart';
import 'package:app_monitor/providers/evidence_detail_provider.dart';
import 'package:app_monitor/helpers/helpers.dart';

/// Pantalla que muestra el detalle de una evidencia con sus fotografías.
/// Permite actualizar la evidencia, agregar, editar y eliminar fotografías.
class EvidenceDetailScreen extends StatelessWidget {
  final int? evidenceId;
  const EvidenceDetailScreen({Key? key, this.evidenceId}) : super(key: key);

  void _showUpdateEvidenceDialog(BuildContext context, Evidence evidence) {
    showEvidenceFormDialog(
      context,
      title: "Actualizar Evidencia",
      initialName: evidence.name,
      initialDescription: evidence.description ?? "",
      onSubmit: (name, description) async {
        try {
          await Provider.of<EvidenceDetailProvider>(
            context,
            listen: false,
          ).updateEvidence(name, description);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
    );
  }

  void _showCreatePhotoDialog(BuildContext context) {
    showPhotoFormDialog(
      context,
      title: "Crear Fotografía",
      isImageRequired: true,
      onSubmit: (descripcion, imageFile) async {
        try {
          await Provider.of<EvidenceDetailProvider>(
            context,
            listen: false,
          ).createPhoto(descripcion, imageFile!.path);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
    );
  }

  void _showUpdatePhotoDialog(
    BuildContext context,
    Photo photo,
    Evidence evidence,
  ) {
    showPhotoFormDialog(
      context,
      title: "Actualizar Fotografía",
      initialDescription: photo.descripcion ?? "",
      isImageRequired: false,
      onSubmit: (descripcion, imageFile) async {
        try {
          await Provider.of<EvidenceDetailProvider>(
            context,
            listen: false,
          ).updatePhoto(
            photo.id,
            descripcion,
            imageFile != null ? imageFile.path : null,
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
    );
  }

  Future<void> _deletePhoto(BuildContext context, int photoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Confirmar eliminación"),
            content: const Text("¿Estás seguro de eliminar esta fotografía?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Eliminar"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        await Provider.of<EvidenceDetailProvider>(
          context,
          listen: false,
        ).deletePhoto(photoId);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (evidenceId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detalles de Evidencia")),
        body: const Center(
          child: Text("No se ha seleccionado ninguna evidencia."),
        ),
      );
    }

    return Consumer<EvidenceDetailProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              "Detalles de Evidencia",
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    provider.evidence == null
                        ? null
                        : () => _showUpdateEvidenceDialog(
                          context,
                          provider.evidence!,
                        ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[100],
          body:
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : provider.evidence == null
                  ? const Center(child: Text("No se encontró la evidencia"))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EvidenceDetailHeader(evidence: provider.evidence!),
                        const SizedBox(height: 16),
                        _EvidenceDescription(evidence: provider.evidence!),
                        const SizedBox(height: 24),
                        _PhotosSection(
                          evidence: provider.evidence!,
                          onUpdatePhoto:
                              (photo) => _showUpdatePhotoDialog(
                                context,
                                photo,
                                provider.evidence!,
                              ),
                          onDeletePhoto:
                              (photoId) => _deletePhoto(context, photoId),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text("Agregar Fotografía"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _showCreatePhotoDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}

/// Encabezado que muestra el nombre de la evidencia y la fecha de creación.
class _EvidenceDetailHeader extends StatelessWidget {
  final Evidence evidence;
  const _EvidenceDetailHeader({Key? key, required this.evidence})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evidence.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha de creación: ${evidence.formattedDate}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra la descripción de la evidencia.
class _EvidenceDescription extends StatelessWidget {
  final Evidence evidence;
  const _EvidenceDescription({Key? key, required this.evidence})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        evidence.description ?? "Sin descripción",
        style: const TextStyle(fontSize: 16, height: 1.4),
      ),
    );
  }
}

/// Sección que muestra la lista de fotografías asociadas a la evidencia.
class _PhotosSection extends StatelessWidget {
  final Evidence evidence;
  final Function(Photo) onUpdatePhoto;
  final Function(int) onDeletePhoto;

  const _PhotosSection({
    Key? key,
    required this.evidence,
    required this.onUpdatePhoto,
    required this.onDeletePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (evidence.photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text("No hay fotografías")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Fotografías:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evidence.photos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final photo = evidence.photos[index];
            return PhotoCard(
              photo: photo,
              onEdit: () => onUpdatePhoto(photo),
              onDelete: () => onDeletePhoto(photo.id),
            );
          },
        ),
      ],
    );
  }
}

/// Tarjeta que representa cada fotografía, mostrando la imagen y las acciones correspondientes.
class PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PhotoCard({
    Key? key,
    required this.photo,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  void _openZoom(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZoomablePhotoPage(imageUrl: photo.photoPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen con efecto al hacer tap para zoom.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: GestureDetector(
              onTap: () => _openZoom(context),
              child: CachedNetworkImage(
                imageUrl: photo.photoPath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder:
                    (context, url) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Foto ID: ${photo.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Página que permite hacer zoom en la fotografía seleccionada.
class ZoomablePhotoPage extends StatelessWidget {
  final String imageUrl;
  const ZoomablePhotoPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Ampliada'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
