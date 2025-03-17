import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/models/photo.dart';
import 'package:app_monitor/providers/evidence_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla principal que muestra la lista de evidencias con paginación.
class EvidenceListScreen extends StatefulWidget {
  const EvidenceListScreen({Key? key}) : super(key: key);

  @override
  _EvidenceListScreenState createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends State<EvidenceListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    // Obtenemos el provider sin escuchar para inicializar
    final evidenceProvider = Provider.of<EvidenceProvider>(
      context,
      listen: false,
    );
    // Cargamos la primera página si aún no se ha cargado

    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            // Si hay más datos y no se está cargando, cargar la siguiente página
            if (evidenceProvider.hasMore && !evidenceProvider.isLoadMore) {
              evidenceProvider.loadMoreEvidences();
            }
          }
        });
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EvidenceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: const Text(
              "Evidencias Recientes",
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body:
              provider.isLoading && provider.evidences.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(child: Text("Error: ${provider.error}"))
                  : RefreshIndicator(
                    onRefresh: () async => await provider.loadEvidences(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      // Se agrega un ítem extra si se está cargando más
                      itemCount:
                          provider.evidences.length +
                          (provider.isLoadMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.evidences.length) {
                          final evidence = provider.evidences[index];
                          return EvidenceListItem(evidence: evidence);
                        } else {
                          // Indicador de carga para paginación
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
          // Si necesitas el botón flotante para crear nuevas evidencias, puedes activarlo aquí.
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () => _showCreateEvidenceDialog(context),
          //   backgroundColor: Colors.blue,
          //   child: const Icon(Icons.add),
          // ),
        );
      },
    );
  }
}

/// Widget que representa cada post de evidencia similar a Twitter.
class EvidenceListItem extends StatelessWidget {
  final Evidence evidence;

  const EvidenceListItem({Key? key, required this.evidence}) : super(key: key);

  /// Muestra diálogo de confirmación para borrar una evidencia.
  Future<void> _deleteEvidence(BuildContext context, int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirmar eliminación"),
            content: const Text("¿Estás seguro de eliminar esta evidencia?"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            await GoRouter.of(context).push('/details/${evidence.id}');
            Provider.of<EvidenceProvider>(
              context,
              listen: false,
            ).loadEvidences();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EvidenceHeader(
                  evidence: evidence,
                  onDelete: () => _deleteEvidence(context, evidence.id),
                ),
                if (evidence.name != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      evidence.description ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (evidence.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      evidence.description!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                if (evidence.photos != null && evidence.photos!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: EvidencePhotosWidget(photos: evidence.photos!),
                  ),
                const Divider(),
                Text(
                  evidence.formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra el encabezado del post (avatar, nombre, etc.).
class _EvidenceHeader extends StatelessWidget {
  final Evidence evidence;
  final VoidCallback onDelete;

  const _EvidenceHeader({
    Key? key,
    required this.evidence,
    required this.onDelete,
  }) : super(key: key);

  String get twitterHandle =>
      '@${evidence.name.toLowerCase().replaceAll(' ', '')}';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 20,
          child: Text('?', style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Usuario desconocido',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'DNI desconocida',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 1) {
              onDelete();
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: const [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Borrar evidencia'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }
}

/// Widget encargado de mostrar las fotos de la evidencia.
class EvidencePhotosWidget extends StatelessWidget {
  final List<Photo> photos;

  const EvidencePhotosWidget({Key? key, required this.photos})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return _buildImageItem(photos[0].photoPath, height: 200);
    } else if (photos.length == 2) {
      return Row(
        children:
            photos
                .map(
                  (photo) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildImageItem(photo.photoPath, height: 200),
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return _buildImageItem(photos[index].photoPath);
        },
      );
    }
  }

  Widget _buildImageItem(String imageUrl, {double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder:
            (context, url) => Container(
              height: height ?? 100,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => const Icon(Icons.error, color: Colors.red),
      ),
    );
  }
}
