class User {
  final int id;
  final String nama;
  final String email;
  final String role; // jabatan
  final String? noTelp;
  final String? avatarUrl;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.noTelp,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['jabatan'] ?? 'Siswa',
      noTelp: json['no_telp'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'jabatan': role,
      'no_telp': noTelp,
      'avatar_url': avatarUrl,
    };
  }
}
