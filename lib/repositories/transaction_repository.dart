import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class TransactionRepository {
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<TransactionModel>> getTransactions(TransactionType type) async {
    final endpoint = type == TransactionType.pemasukan ? 'pemasukan' : 'pengeluaran';
    final url = Uri.parse('${ApiService.baseUrl}/$endpoint');
    
    try {
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionModel.fromJson(json, type)).toList();
      } else {
        throw Exception("Gagal memuat data $endpoint: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat data $endpoint: $e");
    }
  }

  Future<ReportModel> getLaporan() async {
    final url = Uri.parse('${ApiService.baseUrl}/laporan');
    try {
      final response = await http.get(url).timeout(_timeout);
      if (response.statusCode == 200) {
        return ReportModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Gagal mengambil laporan (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal mengambil laporan: $e');
    }
  }
}
