import 'package:flutter/material.dart';
import '../repositories/violation_repository.dart';

class ViolationProvider extends ChangeNotifier {
  final ViolationRepository _repository;

  ViolationProvider({ViolationRepository? repository})
      : _repository = repository ?? ViolationRepository();

  List<Map<String, dynamic>> _violations = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get violations => _violations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchViolations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _violations = await _repository.getViolations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Clear violations (e.g. on logout)
  void clear() {
    _violations = [];
    notifyListeners();
  }
}
