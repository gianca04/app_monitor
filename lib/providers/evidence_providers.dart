//
// ==============================
// STATE MANAGEMENT: Provider para Evidencias
// ==============================
//

import 'package:flutter/material.dart';
import 'package:app_monitor/models/evidence.dart';
import 'package:app_monitor/services/api_service.dart';

class EvidenceProvider with ChangeNotifier {
  List<Evidence> _evidences = [];
  String? error;
  bool isLoading = false;

  List<Evidence> get evidences => _evidences;

  Future<void> loadEvidences() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _evidences = await ApiService.getEvidences();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> createEvidence(String name, String description) async {
    try {
      await ApiService.createEvidence(name, description);
      await loadEvidences();
    } catch (e) {
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
