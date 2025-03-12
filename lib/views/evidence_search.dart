import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_monitor/providers/evidence_providers.dart';
import 'package:app_monitor/models/evidence.dart';

import 'package:app_monitor/models/photo.dart';

class EvidenceSearchScreen extends StatefulWidget {
  const EvidenceSearchScreen({Key? key}) : super(key: key);

  @override
  _EvidenceSearchScreenState createState() => _EvidenceSearchScreenState();
}

class _EvidenceSearchScreenState extends State<EvidenceSearchScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final evidenceProvider = Provider.of<EvidenceProvider>(
      context,
      listen: false,
    );

    // Cargar evidencias si la lista está vacía
    if (evidenceProvider.evidences.isEmpty) {
      evidenceProvider.loadEvidences();
    }

    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            if (evidenceProvider.hasMore && !evidenceProvider.isLoadMore) {
              evidenceProvider.loadMoreEvidences();
            }
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Muestra el modal de filtros
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterModal(),
    );
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
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
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
                      itemCount:
                          provider.evidences.length +
                          (provider.isLoadMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.evidences.length) {
                          final evidence = provider.evidences[index];
                          return EvidenceListItem(evidence: evidence);
                        } else {
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
        );
      },
    );
  }
}

class _EvidenceSearchState extends State<EvidenceSearchScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final evidenceProvider = Provider.of<EvidenceProvider>(
      context,
      listen: false,
    );

    // Cargar evidencias si la lista está vacía
    if (evidenceProvider.evidences.isEmpty) {
      evidenceProvider.loadEvidences();
    }

    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            if (evidenceProvider.hasMore && !evidenceProvider.isLoadMore) {
              evidenceProvider.loadMoreEvidences();
            }
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Muestra el modal de filtros
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterModal(),
    );
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
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
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
                      itemCount:
                          provider.evidences.length +
                          (provider.isLoadMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.evidences.length) {
                          final evidence = provider.evidences[index];
                          return EvidenceListItem(evidence: evidence);
                        } else {
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
        );
      },
    );
  }
}

class _FilterModal extends StatefulWidget {
  @override
  __FilterModalState createState() => __FilterModalState();
}

class __FilterModalState extends State<_FilterModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _sortOrder = "desc";

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EvidenceProvider>(context, listen: false);
    _searchController.text = provider.search ?? '';
    _startDateController.text = provider.startDate ?? '';
    _endDateController.text = provider.endDate ?? '';
    _sortOrder = provider.sortOrder;
  }

  /// Aplica los filtros y recarga la lista
  void _applyFilters() {
    final provider = Provider.of<EvidenceProvider>(context, listen: false);
    provider.setFilters(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      startDate:
          _startDateController.text.isNotEmpty
              ? _startDateController.text
              : null,
      endDate:
          _endDateController.text.isNotEmpty ? _endDateController.text : null,
      sortOrder: _sortOrder,
    );
    Navigator.pop(context); // Cerrar modal
  }

  /// Limpia los filtros y recarga la lista
  void _clearFilters() {
    final provider = Provider.of<EvidenceProvider>(context, listen: false);
    provider.setFilters(
      search: null,
      startDate: null,
      endDate: null,
      sortOrder: "desc",
    );
    _searchController.clear();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _sortOrder = "desc";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filtrar Evidencias",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Buscar por nombre o descripción",
              ),
            ),

            // Campo de fecha de inicio
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: "Fecha de inicio (YYYY-MM-DD)",
              ),
              keyboardType: TextInputType.datetime,
            ),

            // Campo de fecha de fin
            TextField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: "Fecha de fin (YYYY-MM-DD)",
              ),
              keyboardType: TextInputType.datetime,
            ),

            // Ordenamiento
            DropdownButtonFormField<String>(
              value: _sortOrder,
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: "asc",
                  child: Text("Más antiguas primero"),
                ),
                DropdownMenuItem(
                  value: "desc",
                  child: Text("Más recientes primero"),
                ),
              ],
              decoration: const InputDecoration(labelText: "Ordenar por fecha"),
            ),

            const SizedBox(height: 10),

            // Botones de Filtrar y Limpiar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text("Filtrar"),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text("Limpiar filtros"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
