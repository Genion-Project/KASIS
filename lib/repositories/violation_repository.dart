import '../services/api_service.dart';

class ViolationRepository {
  Future<List<Map<String, dynamic>>> getViolations() async {
    return await ApiService.getPelanggaran();
  }

  Future<void> addViolation(Map<String, dynamic> data) async {
    return await ApiService.addPelanggaran(data);
  }

  // Future feature: delete violation
  Future<void> deleteViolation(int id) async {
    // Current API might not support delete yet, but repository is ready
  }
}
