import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/report_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  
  TransactionProvider({TransactionRepository? repository}) 
      : _repository = repository ?? TransactionRepository();

  ReportModel? _laporan;
  List<TransactionModel> _pemasukan = [];
  List<TransactionModel> _pengeluaran = [];
  bool _isLoading = false;
  String? _error;

  ReportModel? get laporan => _laporan;
  List<TransactionModel> get pemasukan => _pemasukan;
  List<TransactionModel> get pengeluaran => _pengeluaran;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get combinedActivities {
    List<Map<String, dynamic>> activities = [];

    for (var item in _pemasukan) {
      activities.add({
        'title': 'Pemasukan - ${item.description}',
        'amount': item.amount,
        'type': 'pemasukan',
        'tanggal': item.date,
        'waktu': item.time,
      });
    }

    for (var item in _pengeluaran) {
      activities.add({
        'title': 'Pengeluaran - ${item.description}',
        'amount': item.amount,
        'type': 'pengeluaran',
        'tanggal': item.date,
        'waktu': item.time,
      });
    }

    activities.sort((a, b) {
      try {
        final dateA = a['tanggal'] as DateTime;
        final dateB = b['tanggal'] as DateTime;
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return activities.take(10).toList();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch report and both transaction types in parallel
      final results = await Future.wait([
        _repository.getLaporan(),
        _repository.getTransactions(TransactionType.pemasukan),
        _repository.getTransactions(TransactionType.pengeluaran),
      ]);

      _laporan = results[0] as ReportModel;
      _pemasukan = results[1] as List<TransactionModel>;
      _pengeluaran = results[2] as List<TransactionModel>;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Helper method to refresh only report
  Future<void> refreshReport() async {
    try {
      _laporan = await _repository.getLaporan();
      notifyListeners();
    } catch (e) {
      // Silently fail or handle error
    }
  }
}
