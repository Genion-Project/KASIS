import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://serururu.pythonanywhere.com/'; // ganti sesuai server

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // sukses
    } else {
      // jika gagal login
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login gagal');
    }
  }

 // Ambil semua members dengan total kas yang sudah dibayar
static Future<List<Map<String, dynamic>>> getMembers() async {
  final url = Uri.parse('$baseUrl/members');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);

    // Debug: tampilkan response mentah di terminal
    print('RAW members: $data');

    final members = data.map((e) => {
      'id': e['id'],
      'name': e['name'],
      'amount': e['total_paid'],
      'avatar': (e['name'] != null && e['name'].isNotEmpty) ? e['name'][0].toUpperCase() : '?',
    }).toList();

    // Debug: tampilkan hasil mapping di terminal
    print('Mapped members: $members');

    return members;
  } else {
    throw Exception('Gagal mengambil data members');
  }
}

static Future<List<Map<String, dynamic>>> getMemberPayments(int siswaId) async {
    final url = Uri.parse('$baseUrl/members/$siswaId/payments');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail pembayaran');
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



static Future<Map<String, dynamic>> getLaporan() async {
    final url = Uri.parse('$baseUrl/laporan');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Debug: tampilkan hasil di terminal
      print('RAW laporan: $data');

      return {
        'total_pemasukan': data['total_pemasukan'] ?? 0,
        'total_pengeluaran': data['total_pengeluaran'] ?? 0,
        'saldo': data['saldo'] ?? 0,
      };
    } else {
      throw Exception('Gagal mengambil laporan');
    }
  }

// Tambah siswa
static Future<Map<String, dynamic>> addSiswa(String namaSiswa) async {
  final url = Uri.parse('$baseUrl/siswa');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'nama_siswa': namaSiswa}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Gagal menambahkan siswa');
  }
}

// Generate kas mingguan untuk siswa
static Future<void> generateKasMingguan(int siswaId) async {
  final url = Uri.parse('$baseUrl/generate_kas/$siswaId');
  final response = await http.post(url);

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
        'siswa_id': siswaId,
        'minggu_ke': mingguKe,
        'jumlah': jumlah,
        'keterangan': keterangan,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal membayar: ${response.body}');
    }
  }


}
