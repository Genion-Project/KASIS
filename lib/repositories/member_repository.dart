import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';
import '../services/api_service.dart';

class MemberRepository {
  final ApiService _apiService;
  
  MemberRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<Member>> getMembers() async {
    const String cacheKey = 'members_cache';
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final url = Uri.parse('${ApiService.baseUrl}/members');
    
    try {
      final response = await http.get(url).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Simpan ke cache
        await prefs.setString(cacheKey, response.body);
        
        final List data = jsonDecode(response.body);
        return data.map((e) => Member.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data members');
      }
    } catch (e) {
      // Coba load dari cache jika API gagal
      if (prefs.containsKey(cacheKey)) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final List data = jsonDecode(cachedData);
          return data.map((e) => Member.fromJson(e)).toList();
        }
      }
      // Jika cache juga gagal/kosong, rethrow error asli
      rethrow;
    }
  }

  Future<void> addMember(String namaSiswa) async {
      await ApiService.addSiswa(namaSiswa);
  }
}
