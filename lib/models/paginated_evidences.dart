// Agrega este modelo en un archivo (por ejemplo: models/paginated_evidences.dart)
import 'package:app_monitor/models/evidence.dart';

class PaginatedEvidences {
  final List<Evidence> evidences;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  PaginatedEvidences({
    required this.evidences,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
  });

  factory PaginatedEvidences.fromJson(Map<String, dynamic> json) {
    final List evidencesJson = json['data'];
    List<Evidence> evidencesList =
        evidencesJson.map((e) => Evidence.fromJson(e)).toList();
    return PaginatedEvidences(
      evidences: evidencesList,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}
