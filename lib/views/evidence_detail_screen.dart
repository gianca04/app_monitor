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

  /// Muestra el diálogo para actualizar la evidencia.
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

  /// Muestra el diálogo para crear una nueva fotografía.
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

  /// Muestra el diálogo para actualizar una fotografía existente.
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

  /// Elimina una fotografía previa confirmación del usuario.
  Future<void> _deletePhoto(BuildContext context, int photoId) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmar eliminación"),
            content: const Text("¿Estás seguro de eliminar esta fotografía?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text("Eliminar"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (confirmed) {
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
    // Si no se pasa ningún id, se muestra un mensaje indicando que no se ha seleccionado evidencia.
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
            iconTheme: const IconThemeData(color: Colors.black),
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
          backgroundColor: Colors.grey[200],
          body:
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : provider.evidence == null
                  ? const Center(child: Text("No se encontró la evidencia"))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EvidenceDetailHeader(evidence: provider.evidence!),
                        const SizedBox(height: 16),
                        _EvidenceDescription(evidence: provider.evidence!),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showCreatePhotoDialog(context),
                            child: const Text("Agregar Fotografía"),
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

/// Widget que muestra el encabezado con el nombre de la evidencia y la fecha.
class _EvidenceDetailHeader extends StatelessWidget {
  final Evidence evidence;
  const _EvidenceDetailHeader({Key? key, required this.evidence})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          evidence.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          evidence.formattedDate,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
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
    return Text(
      evidence.description ?? "Sin descripción",
      style: const TextStyle(fontSize: 16),
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
      return const Text("No hay fotografías");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fotografías:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evidence.photos.length,
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

/// Widget que representa cada tarjeta de fotografía con imagen y acciones.
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen con efecto fadeIn y placeholder.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: GestureDetector(
              onTap: () => _openZoom(context),
              child: CachedNetworkImage(
                imageUrl: photo.photoPath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
              ),
            ),
          ),
          ListTile(
            title: Text("Foto ID: ${photo.id}"),
            subtitle: Text(photo.descripcion ?? ""),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget dedicado a mostrar la imagen con capacidad de zoom.
class ZoomablePhotoPage extends StatelessWidget {
  final String imageUrl;

  const ZoomablePhotoPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zoom de la Foto')),
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
