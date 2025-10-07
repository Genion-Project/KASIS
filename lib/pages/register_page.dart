// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;

  // Step 1
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();

  // Step 2
  final TextEditingController kodeController = TextEditingController();
  final String kodeVerifikasiBenar = "NEXORA2025";

  // Step 3
  final TextEditingController passwordController = TextEditingController();
  String selectedJabatan = "Anggota";
  final List<String> jabatanList = ["Developer", "Ketua OSIS", "Sekretaris", "Bendahara", "Anggota", "Guru"];

  bool isLoading = false;
  int currentPage = 0;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1.0;
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != currentPage) {
        setState(() {
          currentPage = page;
        });
        _animController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    namaController.dispose();
    emailController.dispose();
    noTelpController.dispose();
    kodeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void showMsg(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  bool _validateEmail(String email) {
    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return re.hasMatch(email);
  }

  Future<void> handleRegister() async {
    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final noTelp = noTelpController.text.trim();
    final password = passwordController.text;

    if (nama.isEmpty || email.isEmpty || noTelp.isEmpty || password.isEmpty) {
      showMsg('Lengkapi semua field sebelum mendaftar.', isError: true);
      return;
    }

    if (!_validateEmail(email)) {
      showMsg('Format email tidak valid.', isError: true);
      return;
    }

    if (password.length < 6) {
      showMsg('Password minimal 6 karakter.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.registerUser(
        email: email,
        nama: nama,
        noTelp: noTelp,
        password: password,
        jabatan: selectedJabatan,
      );

      final message = result['message'] ??
          (result['user'] != null ? 'Registrasi berhasil' : 'Registrasi berhasil');
      showMsg(message);

      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      showMsg('Gagal registrasi: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildStepIndicator() {
    final steps = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Data Diri',
        'subtitle': 'Informasi dasar',
      },
      {
        'icon': Icons.verified_user_outlined,
        'label': 'Verifikasi',
        'subtitle': 'Konfirmasi kode',
      },
      {
        'icon': Icons.lock_outline_rounded,
        'label': 'Keamanan',
        'subtitle': 'Password & akses',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 6,
                width: MediaQuery.of(context).size.width * 
                    ((currentPage + 1) / steps.length) * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: List.generate(steps.length, (i) {
              final active = i == currentPage;
              final completed = i < currentPage;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (completed) {
                            _pageController.animateToPage(
                              i,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: active ? 56 : 48,
                              height: active ? 56 : 48,
                              decoration: BoxDecoration(
                                gradient: completed || active
                                    ? LinearGradient(
                                        colors: [
                                          Color(0xFF1976D2),
                                          Color(0xFF1565C0),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: completed || active ? null : Colors.grey[200],
                                shape: BoxShape.circle,
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: Color(0xFF1976D2).withOpacity(0.4),
                                          blurRadius: 16,
                                          offset: Offset(0, 6),
                                        ),
                                      ]
                                    : completed
                                        ? [
                                            BoxShadow(
                                              color: Color(0xFF1976D2).withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                border: active
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: active
                                      ? Border.all(
                                          color: Color(0xFF1976D2).withOpacity(0.3),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: Icon(
                                      completed
                                          ? Icons.check_circle_rounded
                                          : steps[i]['icon'] as IconData,
                                      key: ValueKey(completed),
                                      color: completed || active
                                          ? Colors.white
                                          : Colors.grey[400],
                                      size: active ? 28 : 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: active ? 13 : 12,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                                color: active
                                    ? Color(0xFF1976D2)
                                    : completed
                                        ? Colors.black87
                                        : Colors.grey[500],
                                letterSpacing: 0.3,
                              ),
                              child: Text(
                                steps[i]['label'] as String,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 4),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: active ? 1.0 : 0.6,
                              child: Text(
                                steps[i]['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: active
                                      ? Color(0xFF1976D2).withOpacity(0.7)
                                      : Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(bottom: 48, left: 4, right: 4),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: completed
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                    )
                                  : null,
                              color: completed ? null : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? hint,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !_isPasswordVisible,
        style: TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xFF1976D2), size: 20),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isLoading = false,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              )
            : null,
        color: isPrimary ? null : Colors.white,
        border: isPrimary ? null : Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget buildDataDiriPage() {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Pribadi",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Masukkan data diri Anda dengan lengkap",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            _buildTextField(
              controller: namaController,
              label: "Nama Lengkap",
              icon: Icons.person_outline_rounded,
              hint: "Contoh: John Doe",
            ),
            _buildTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              hint: "Contoh: john@example.com",
            ),
            _buildTextField(
              controller: noTelpController,
              label: "No. Telepon",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: "Contoh: 08123456789",
            ),
            SizedBox(height: 8),
            _buildButton(
              text: "Lanjutkan",
              onPressed: () {
                if (namaController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    noTelpController.text.isEmpty) {
                  showMsg("Lengkapi semua data", isError: true);
                  return;
                }
                if (!_validateEmail(emailController.text.trim())) {
                  showMsg("Email tidak valid", isError: true);
                  return;
                }
                nextPage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildKodeVerifikasiPage() {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kode Verifikasi",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Masukkan kode verifikasi yang Anda terima",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF1976D2).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Masukkan kode verifikasi yang telah diberikan oleh admin",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: kodeController,
              label: "Kode Verifikasi",
              icon: Icons.vpn_key_rounded,
              hint: "Masukkan kode dari admin",
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: "Kembali",
                    onPressed: prevPage,
                    isPrimary: false,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildButton(
                    text: "Verifikasi",
                    onPressed: () {
                      if (kodeController.text.trim() == kodeVerifikasiBenar) {
                        showMsg("Kode verifikasi berhasil!");
                        nextPage();
                      } else {
                        showMsg("Kode verifikasi salah", isError: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAkunPage() {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Keamanan Akun",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Pilih jabatan dan buat password yang kuat",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: selectedJabatan,
                items: jabatanList.map((jab) {
                  IconData icon;
                  switch (jab) {
                    case "Developer":
                      icon = Icons.code_rounded;
                      break;
                    case "Ketua OSIS":
                      icon = Icons.workspace_premium_rounded;
                      break;
                    case "Sekretaris":
                      icon = Icons.edit_note_rounded;
                      break;
                    case "Bendahara":
                      icon = Icons.account_balance_wallet_rounded;
                      break;
                    case "Guru":
                      icon = Icons.school_rounded;
                      break;
                    default:
                      icon = Icons.person_rounded;
                  }
                  return DropdownMenuItem(
                    value: jab,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Color(0xFF1976D2)),
                        SizedBox(width: 12),
                        Text(jab),
                      ],
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: "Jabatan",
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  prefixIcon: Container(
                    margin: EdgeInsets.all(12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_outline_rounded, color: Color(0xFF1976D2), size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                onChanged: (val) {
                  if (val != null) setState(() => selectedJabatan = val);
                },
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              hint: "Minimal 6 karakter",
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.amber[800], size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Password minimal 6 karakter dengan kombinasi huruf dan angka",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: "Kembali",
                    onPressed: prevPage,
                    isPrimary: false,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildButton(
                    text: "Daftar Sekarang",
                    onPressed: handleRegister,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Akun Baru',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: _buildStepIndicator(),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildDataDiriPage(),
                  buildKodeVerifikasiPage(),
                  buildAkunPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}