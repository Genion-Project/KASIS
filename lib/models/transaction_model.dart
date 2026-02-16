enum TransactionType { pemasukan, pengeluaran }

class TransactionModel {
  final int id;
  final TransactionType type;
  final double amount;
  final String description; // keterangan
  final DateTime date;
  final String time;
  final int studentId; // siswa_id (optional for pengeluaran)
  final int weekNumber; // minggu_ke (optional)

  final String? title;
  final String? createdBy;
  final String? category;
  final String? paymentMethod;
  final String? proof;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.time,
    required this.studentId,
    required this.weekNumber,
    this.title,
    this.createdBy,
    this.category,
    this.paymentMethod,
    this.proof,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, TransactionType type) {
    return TransactionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      type: type,
      amount: (json['jumlah'] ?? 0).toDouble(),
      description: json['keterangan'] ?? '',
      date: DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now(),
      time: json['waktu'] ?? '',
      studentId: json['siswa_id'] != null ? int.tryParse(json['siswa_id'].toString()) ?? 0 : 0,
      weekNumber: json['minggu_ke'] != null ? int.tryParse(json['minggu_ke'].toString()) ?? 0 : 0,
      title: json['judul'],
      createdBy: json['dibuat_oleh'],
      category: json['kategori'],
      paymentMethod: json['metode_pembayaran'],
      proof: json['bukti_pembayaran'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'jumlah': amount,
      'keterangan': description,
      'tanggal': date.toIso8601String(),
      'waktu': time,
      'siswa_id': studentId,
      'minggu_ke': weekNumber,
      'judul': title,
      'dibuat_oleh': createdBy,
      'kategori': category,
      'metode_pembayaran': paymentMethod,
      'bukti_pembayaran': proof,
    };
  }
}
