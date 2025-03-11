import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/helpers/helpers.dart';
import 'package:app_monitor/providers/evidence_providers.dart';

class EvidenceListScreen extends StatelessWidget {
  const EvidenceListScreen({Key? key}) : super(key: key);

  void _showCreateEvidenceDialog(BuildContext context) {
    showEvidenceFormDialog(
      context,
      title: "Evidencias Recientes",
      onSubmit: (name, description) async {
        try {
          await Provider.of<EvidenceProvider>(
            context,
            listen: false,
          ).createEvidence(name, description);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
    );
  }

  void _deleteEvidence(BuildContext context, int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text("¿Estás seguro de eliminar esta evidencia?"),
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
        await Provider.of<EvidenceProvider>(
          context,
          listen: false,
        ).deleteEvidence(id);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EvidenceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("Evidencias")),
          body:
              provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : provider.evidences.isEmpty
                  ? Center(child: Text("No hay evidencias"))
                  : ListView.builder(
                    itemCount: provider.evidences.length,
                    itemBuilder: (context, index) {
                      final evidence = provider.evidences[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: evidence.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '· 5m',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.more_horiz),
                                      ),
                                    ],
                                  ),
                                  if (evidence.description != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(evidence.description!),
                                    ),
                                  if (evidence.photos != null &&
                                      evidence.photos!.isNotEmpty)
                                    _buildPhotosWidget(evidence.photos!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateEvidenceDialog(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildPhotosWidget(List<Photo> photos) {
    Widget photoDisplay;

    if (photos.length == 1) {
      // Caso: Una sola imagen.
      photoDisplay = Container(
        height: 200,
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(photos[0].photoPath),
          ),
        ),
      );
    } else if (photos.length == 2) {
      // Caso: Dos imágenes en fila.
      photoDisplay = Row(
        children:
            photos.map((photo) {
              return Expanded(
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(photo.photoPath),
                    ),
                  ),
                ),
              );
            }).toList(),
      );
    } else {
      // Caso: Más de dos imágenes en grid.
      photoDisplay = GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(photo.photoPath),
              ),
            ),
          );
        },
      );
    }

    return photoDisplay;
  }
}

class _ActionsRow extends StatelessWidget {
  final Evidence item;
  const _ActionsRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.grey, size: 18),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.red),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [],
      ),
    );
  }
}

/*import 'package:app_monitor/models/evidence.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/helpers/helpers.dart';
import 'package:app_monitor/providers/evidence_providers.dart';

class EvidenceListScreen extends StatelessWidget {
  const EvidenceListScreen({Key? key}) : super(key: key);

  void _showCreateEvidenceDialog(BuildContext context) {
    showEvidenceFormDialog(
      context,
      title: "Evidencias Recientes",
      onSubmit: (name, description) async {
        try {
          await Provider.of<EvidenceProvider>(
            context,
            listen: false,
          ).createEvidence(name, description);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
    );
  }

  void _deleteEvidence(BuildContext context, int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirmar eliminación"),
            content: Text("¿Estás seguro de eliminar esta evidencia?"),
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
        await Provider.of<EvidenceProvider>(
          context,
          listen: false,
        ).deleteEvidence(id);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EvidenceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("Evidencias")),
          body:
              provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : provider.evidences.isEmpty
                  ? Center(child: Text("No hay evidencias"))
                  : ListView.builder(
                    itemCount: provider.evidences.length,
                    itemBuilder: (context, index) {
                      final evidence = provider.evidences[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: evidence.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '· 5m',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.more_horiz),
                                      ),
                                    ],
                                  ),
                                  if (evidence.description != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(evidence.description!),
                                    ),
                                  if (evidence.photos != null)
                                    Container(
                                      height: 200,
                                      margin: const EdgeInsets.only(top: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(evidence.!),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );

                      /*return Card(
                        child: ListTile(
                          
                          
                          title: Text(evidence.name),
                          subtitle: Text(evidence.description ?? ""),
                          
                          
                          
                          
                          
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed:
                                () => _deleteEvidence(context, evidence.id),
                          ),


                          onTap: () async {
                            await context.push('/details/${evidence.id}');
                            // Una vez que regresamos, recargamos la lista de evidencias:
                            Provider.of<EvidenceProvider>(
                              context,
                              listen: false,
                            ).loadEvidences();
                          },
                        ),
                      );
                    */
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateEvidenceDialog(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}

modelo de photo
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
*/
