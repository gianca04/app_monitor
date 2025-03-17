//
// ==============================
// STATE MANAGEMENT: Provider para Evidencias
// ==============================
//

import 'package:flutter/material.dart';
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/services/api_service.dart';
import 'package:app_monitor/models/paginated_evidences.dart';

class EvidenceProvider with ChangeNotifier {
  List<Evidence> _evidences = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool isLoading = false;
  bool isLoadMore = false;
  String? error;

  // Filtros
  String? search;
  String?
  startDate; // Cambié 'dateFrom' a 'startDate' para que coincida con Laravel
  String? endDate; // Cambié 'dateTo' a 'endDate' para que coincida con Laravel
  String sortOrder = "desc"; // Cambié 'orderBy' a 'sortOrder'

  List<Evidence> get evidences => _evidences;

  // Indica si hay más páginas para cargar
  bool get hasMore => _currentPage < _lastPage;

  /// Actualiza los filtros y recarga la lista (reiniciando la paginación)
  void setFilters({
    String? search,
    String? startDate, // Cambio de nombre para coincidir con Laravel
    String? endDate, // Cambio de nombre para coincidir con Laravel
    String? sortOrder, // Cambio de nombre para coincidir con Laravel
  }) {
    this.search = search;
    this.startDate = startDate;
    this.endDate = endDate;
    if (sortOrder != null) {
      this.sortOrder = sortOrder;
    }
    // Reiniciamos la paginación y vaciamos la lista
    _currentPage = 1;
    _evidences.clear();
    loadEvidences();
  }

  /// Carga la primera página o recarga la lista con los filtros actuales.
  Future<void> loadEvidences({bool loadMore = false}) async {
    if (loadMore) {
      isLoadMore = true;
      // No limpiar la lista en loadMore para conservar las evidencias existentes
    } else {
      isLoading = true;
      _currentPage = 1;
      _evidences.clear();
    }
    error = null;

    try {
      final PaginatedEvidences paginatedResponse =
          await ApiService.getEvidences(
            page: _currentPage,
            search: search,
            startDate: startDate,
            endDate: endDate,
            sortOrder: sortOrder,
          );
      _lastPage = paginatedResponse.lastPage;
      // Agregar las evidencias obtenidas a la lista existente
      _evidences.addAll(paginatedResponse.evidences);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    isLoadMore = false;
    notifyListeners();
  }

  /// Carga la siguiente página si hay más resultados.
  Future<void> loadMoreEvidences() async {
    if (hasMore && !isLoadMore) {
      _currentPage++;
      await loadEvidences(loadMore: true);
    }
  }

  Future<int> createEvidence(String name, String description) async {
    try {
      // Se asume que el ApiService.createEvidence retorna el id de la nueva evidencia.
      final int newEvidenceId = await ApiService.createEvidence(
        name,
        description,
      );
      _evidences.clear();
      await loadEvidences();
      return newEvidenceId;
    } catch (e) {
      // Es recomendable manejar el error o propagarlo para que la UI lo capture.
      throw e;
    }
  }

  Future<void> updateEvidence(int id, String name, String description) async {
    try {
      await ApiService.updateEvidence(id, name, description);
      await loadEvidences();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteEvidence(int id) async {
    try {
      await ApiService.deleteEvidence(id);
      await loadEvidences();
    } catch (e) {
      throw e;
    }
  }
}
