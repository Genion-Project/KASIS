class Member {
  final int id;
  final String nama;
  final double totalPaid;
  final String? avatarInitials;

  Member({
    required this.id,
    required this.nama,
    required this.totalPaid,
    this.avatarInitials,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    // Coba berbagai kemungkinan nama field untuk total kas
    double totalPaid = 0.0;
    if (json.containsKey('total_paid')) {
      totalPaid = double.tryParse(json['total_paid'].toString()) ?? 0.0;
    } else if (json.containsKey('totalPaid')) {
      totalPaid = double.tryParse(json['totalPaid'].toString()) ?? 0.0;
    } else if (json.containsKey('amount')) {
      totalPaid = double.tryParse(json['amount'].toString()) ?? 0.0;
    } else if (json.containsKey('total_kas')) {
      totalPaid = double.tryParse(json['total_kas'].toString()) ?? 0.0;
    } else if (json.containsKey('total')) { // Added 'total' just in case
      totalPaid = double.tryParse(json['total'].toString()) ?? 0.0;
    }
    
    return Member(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['name'] ?? 'Unknown Member',
      totalPaid: totalPaid,
      avatarInitials: json['name'] != null ? json['name'][0].toUpperCase() : '?',
    );
  }
}
