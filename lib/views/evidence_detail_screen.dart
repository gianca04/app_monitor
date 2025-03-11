import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/models/photo.dart';
import 'package:app_monitor/providers/evidence_detail_provider.dart';
import 'package:app_monitor/helpers/helpers.dart';

class EvidenceDetailScreen extends StatelessWidget {
  final int evidenceId;
  const EvidenceDetailScreen({Key? key, required this.evidenceId})
    : super(key: key);

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

  void _deletePhoto(BuildContext context, int photoId) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text("¿Estás seguro de eliminar esta fotografía?"),
            actions: [
              TextButton(
                child: Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text("Eliminar"),
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
    return Consumer<EvidenceDetailProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Detalles de Evidencia"),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
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
          body:
              provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : provider.evidence == null
                  ? Center(child: Text("No se encontró la evidencia"))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nombre: ${provider.evidence!.name}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Descripción: ${provider.evidence!.description ?? ''}",
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Fotografías:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: provider.evidence!.photos.length,
                          itemBuilder: (context, index) {
                            final photo = provider.evidence!.photos[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    height: 200,
                                    child: CachedNetworkImage(
                                      imageUrl: photo.photoPath,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50,
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
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showUpdatePhotoDialog(
                                              context,
                                              photo,
                                              provider.evidence!,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed:
                                              () => _deletePhoto(
                                                context,
                                                photo.id,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          child: Text("Agregar Fotografía"),
                          onPressed: () => _showCreatePhotoDialog(context),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
