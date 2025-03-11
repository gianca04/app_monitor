//
// ==============================
// STATE MANAGEMENT: Provider para Detalle de Evidencia
// ==============================
//

import 'package:flutter/material.dart';
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/services/api_service.dart';

class EvidenceDetailProvider with ChangeNotifier {
  Evidence? evidence;
  final int evidenceId;
  String? error;
  bool isLoading = false;

  EvidenceDetailProvider(this.evidenceId);

  Future<void> loadEvidence() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      evidence = await ApiService.getEvidence(evidenceId);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateEvidence(String name, String description) async {
    if (evidence == null) return;
    try {
      await ApiService.updateEvidence(evidence!.id, name, description);
      await loadEvidence();
    } catch (e) {
      throw e;
    }
  }

  Future<void> createPhoto(String descripcion, String filePath) async {
    if (evidence == null) return;
    try {
      await ApiService.createPhoto(evidence!.id, descripcion, filePath);
      await loadEvidence();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updatePhoto(
    int photoId,
    String descripcion,
    String? filePath,
  ) async {
    if (evidence == null) return;
    try {
      await ApiService.updatePhoto(
        photoId,
        evidence!.id,
        descripcion,
        filePath,
      );
      await loadEvidence();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deletePhoto(int photoId) async {
    try {
      await ApiService.deletePhoto(photoId);
      await loadEvidence();
    } catch (e) {
      throw e;
    }
  }
}
