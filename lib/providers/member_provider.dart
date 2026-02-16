import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

class MemberProvider extends ChangeNotifier {
  final MemberRepository _repository;
  
  MemberProvider({MemberRepository? repository}) 
      : _repository = repository ?? MemberRepository();

  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMembers({bool refresh = false}) async {
    if (_members.isNotEmpty && !refresh) return; // Don't fetch if data exists and not refreshing

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _repository.getMembers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addMember(String nama) async {
    try {
      await _repository.addMember(nama);
      // Refresh list after adding
      await fetchMembers(refresh: true);
    } catch (e) {
      rethrow;
    }
  }
}
