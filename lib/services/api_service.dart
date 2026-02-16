import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/report_model.dart';
import '../models/member_model.dart';

class ApiService {
  static const String baseUrl = 'https://api-kasis.smknurisjkt.org'; // ganti sesuai server

  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // sukses
    } else {
      // jika gagal login
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login gagal');
    }
  }

  static Future<void> addPelanggaran(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/pelanggaran"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    ).timeout(_timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // sukses, biar widget yg kasih feedback
    } else {
      throw Exception("Gagal Menyimpan, Terjadi Kesalahan");
    }
  }

  static Future<List<Map<String, dynamic>>> getPelanggaran() async {
    final response = await http.get(Uri.parse('$baseUrl/pelanggaran')).timeout(_timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Gagal mengambil data pelanggaran");
    }
  }

  /// ✅ TAMBAHAN: Hapus pelanggaran berdasarkan ID
  static Future<bool> deletePelanggaran(int id) async {
    try {
      final url = Uri.parse('$baseUrl/pelanggaran/$id');
      final response = await http.delete(url).timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }



  // Ambil semua members dengan total kas yang sudah dibayar
  static Future<List<Member>> getMembers() async {
    const String cacheKey = 'members_cache';
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final url = Uri.parse('$baseUrl/members');
    
    try {
      final response = await http.get(url).timeout(_timeout);

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
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getMemberPayments(int siswaId) async {
    final url = Uri.parse('$baseUrl/users/$siswaId/payments');
    final response = await http.get(url).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail pembayaran (${response.statusCode}): ${response.body}');
    }

    final List data = jsonDecode(response.body);

    // Mapping data ke bentuk yang bisa langsung dipakai di Flutter
    final List<Map<String, dynamic>> payments = data.map<Map<String, dynamic>>((e) {
      return {
        'week': e['week'],
        'date': e['date'] ?? '-',
        'amount': e['amount'] ?? 2000,
        'description': e['description'] ?? (e['status'] == 'Sudah Bayar' ? 'Sudah Bayar' : '-'),
        'status': e['status'] ?? (e['amount'] > 0 ? 'Sudah Bayar' : 'Belum Bayar'),
      };
    }).toList();

    return payments;
  }

  static Future<ReportModel> getLaporan() async {
    try {
      final url = Uri.parse('$baseUrl/laporan');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReportModel.fromJsonWithFallback(data);
      } else {
        throw Exception('Gagal mengambil laporan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat laporan');
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Tambah siswa
  static Future<Map<String, dynamic>> addSiswa(String namaSiswa) async {
    final url = Uri.parse('$baseUrl/siswa');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama_siswa': namaSiswa}),
    ).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal menambahkan siswa');
    }
  }

  // Generate kas mingguan untuk siswa
  static Future<void> generateKasMingguan(int siswaId) async {
    final url = Uri.parse('$baseUrl/generate_kas/$siswaId');
    final response = await http.post(url).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Gagal generate kas mingguan');
    }
  }

  static Future<void> bayarKas({
    required int siswaId,
    required int mingguKe,
    int jumlah = 2000,
    String keterangan = 'Kas Mingguan',
  }) async {
    final url = Uri.parse('$baseUrl/bayar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': siswaId,
        'minggu_ke': mingguKe,
        'jumlah': jumlah,
        'keterangan': keterangan,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Gagal membayar: ${response.body}');
    }
  }

  /// Ambil rekap pelanggaran (jumlah per siswa + total poin)
  static Future<List<Map<String, dynamic>>> getRekapPelanggaran() async {
    final url = Uri.parse("$baseUrl/pelanggaran");
    final response = await http.get(url).timeout(_timeout);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // Kelompokkan data per siswa
      Map<String, Map<String, dynamic>> grouped = {};
      for (var item in data) {
        final nama = item["nama"];
        final kelas = item["kelas"];
        final poin = item["poin"] ?? 0;

        final key = "$nama-$kelas";
        if (!grouped.containsKey(key)) {
          grouped[key] = {
            "nama": nama,
            "kelas": kelas,
            "jumlah": 0,
            "poin": 0,
          };
        }
        grouped[key]!["jumlah"] += 1;
        grouped[key]!["poin"] += poin;
      }

      return grouped.values.toList();
    } else {
      throw Exception("Gagal memuat data pelanggaran");
    }
  }

  // Ambil semua pemasukan
  static Future<List<TransactionModel>> getPemasukan() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pemasukan")).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionModel.fromJson(json, TransactionType.pemasukan)).toList();
      } else {
        throw Exception("Gagal memuat data pemasukan: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat data pemasukan: $e");
    }
  }

  // Ambil semua pengeluaran
  static Future<List<TransactionModel>> getPengeluaran() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/pengeluaran")).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TransactionModel.fromJson(json, TransactionType.pengeluaran)).toList();
      } else {
        throw Exception("Gagal memuat data pengeluaran: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal memuat data pengeluaran: $e");
    }
  }

  // === Tambah pemasukan ===
  static Future<bool> addPemasukan({
    String? tanggal,
    required int jumlah,
    required String keterangan,
    int? siswaId,
    int? mingguKe,
  }) async {
    try {
      final body = {
        "tanggal": tanggal,
        "jumlah": jumlah,
        "keterangan": keterangan,
        "siswa_id": siswaId,
        "minggu_ke": mingguKe,
      };

      // Hapus key yang null biar tidak dikirim
      body.removeWhere((key, value) => value == null);

      final response = await http.post(
        Uri.parse("$baseUrl/pemasukan"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> addPengeluaran({
    String? tanggal,
    required int jumlah,
    required String keterangan,
  }) async {
    try {
      final body = {
        "tanggal": tanggal,
        "jumlah": jumlah,
        "keterangan": keterangan,
      };

      // hapus key yang null
      body.removeWhere((key, value) => value == null);

      final response = await http.post(
        Uri.parse("$baseUrl/pengeluaran"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // === OTP & Registration ===
  static Future<void> requestOtp({
    required String email,
    required String nama,
    required String noTelp,
  }) async {
    final url = Uri.parse('$baseUrl/request-otp');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'nama': nama,
          'no_telp': noTelp,
        }),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        // Check if response is JSON or HTML
        if (response.body.trim().startsWith('<') || response.body.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server error (${response.statusCode}). Endpoint mungkin tidak tersedia.');
        }
        
        try {
          final body = jsonDecode(response.body);
          throw Exception(body['error'] ?? 'Gagal mengirim OTP');
        } catch (e) {
          throw Exception('Gagal mengirim OTP (${response.statusCode})');
        }
      }
    } catch (e) {
        throw Exception(e.toString());
    }
  }

  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('OTP Salah atau Kadaluarsa');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> setPassword({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/set-password');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        // Check if response is JSON or HTML
        if (response.body.trim().startsWith('<') || response.body.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server error (${response.statusCode}). Endpoint mungkin tidak tersedia.');
        }
        
        try {
          final body = jsonDecode(response.body);
          throw Exception(body['error'] ?? 'Gagal menyimpan password');
        } catch (e) {
          throw Exception('Gagal menyimpan password (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Koneksi gagal: $e');
    }
  }

  // === Forgot Password ===
  static Future<void> forgotPasswordRequest(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password/request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Gagal memproses permintaan');
    }
  }

  static Future<void> forgotPasswordVerify({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'OTP tidak valid');
    }
  }

  static Future<void> forgotPasswordReset({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password/reset');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Gagal reset password');
    }
  }

  static Future<Map<String, dynamic>> batalkanBayar({
    required int siswaId,
    required int mingguKe,
  }) async {
    final url = Uri.parse('$baseUrl/batalkan_bayar');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': siswaId,
          'minggu_ke': mingguKe,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        // berhasil
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // data tidak ditemukan
        return jsonDecode(response.body);
      } else {
        // gagal (500 atau lainnya)
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Gagal membatalkan pembayaran');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}