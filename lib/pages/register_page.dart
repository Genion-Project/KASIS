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

  Future<void> handleFinalizeRegistration() async {
    final password = passwordController.text;

    if (password.length < 6) {
      showMsg('Password minimal 6 karakter.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.setPassword(
        email: emailController.text.trim(),
        password: password,
      );

      showMsg("Password berhasil disimpan. Silakan login.");

      if (!mounted) return;
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      showMsg('Gagal set password: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Row(
          children: [
            // Left Side - Illustration
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF1565C0), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background decorative elements
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 80,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            SizedBox(height: 40),
                            Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Bergabung dengan sistem manajemen pelanggaran siswa',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Daftar sekarang untuk mulai menggunakan semua fitur aplikasi',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side - Registration Form
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // App Bar for Desktop
                    Container(
                      height: 70,
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Step ${currentPage + 1}/3',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step Indicator for Desktop
                    _buildDesktopStepIndicator(),
                    
                    // Form Content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDataDiriPage(isDesktop: true),
                          _buildKodeVerifikasiPage(isDesktop: true),
                          _buildAkunPage(isDesktop: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopStepIndicator() {
    final steps = [
      {'icon': Icons.person_outline_rounded, 'label': 'Data Diri'},
      {'icon': Icons.verified_user_outlined, 'label': 'Verifikasi'},
      {'icon': Icons.lock_outline_rounded, 'label': 'Keamanan'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Progress Bar
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
                width: (MediaQuery.of(context).size.width * 0.25) * ((currentPage + 1) / steps.length),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final active = i == currentPage;
              final completed = i < currentPage;
              
              return GestureDetector(
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
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: completed || active
                            ? LinearGradient(
                                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                              )
                            : null,
                        color: completed || active ? null : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: active ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                      child: Center(
                        child: Icon(
                          completed ? Icons.check_rounded : steps[i]['icon'] as IconData,
                          color: completed || active ? Colors.white : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      steps[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        color: active ? Color(0xFF1976D2) : Colors.grey[600],
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

  Widget _buildMobileLayout(BuildContext context) {
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
                  _buildDataDiriPage(),
                  _buildKodeVerifikasiPage(),
                  _buildAkunPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    bool isDesktop = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
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
        style: TextStyle(fontSize: isDesktop ? 14 : 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: isDesktop ? 13 : 14),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: isDesktop ? 13 : 14),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
            ),
            child: Icon(icon, color: Color(0xFF1976D2), size: isDesktop ? 18 : 20),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.grey[600],
                    size: isDesktop ? 18 : 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 20, 
            vertical: isDesktop ? 16 : 18
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    bool isDesktop = false,
  }) {
    return Container(
      height: isDesktop ? 50 : 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 12 : 16)),
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
                  fontSize: isDesktop ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDataDiriPage({bool isDesktop = false}) {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Pribadi",
              style: TextStyle(
                fontSize: isDesktop ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isDesktop ? 4 : 8),
            Text(
              "Masukkan data diri Anda dengan lengkap",
              style: TextStyle(
                fontSize: isDesktop ? 14 : 15, 
                color: Colors.grey[600]
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 32),
            _buildTextField(
              controller: namaController,
              label: "Nama Lengkap",
              icon: Icons.person_outline_rounded,
              hint: "Contoh: John Doe",
              isDesktop: isDesktop,
            ),
            _buildTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              hint: "Contoh: john@example.com",
              isDesktop: isDesktop,
            ),
            _buildTextField(
              controller: noTelpController,
              label: "No. Telepon",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: "Contoh: 08123456789",
              isDesktop: isDesktop,
            ),
            SizedBox(height: isDesktop ? 20 : 8),
            _buildButton(
              text: "Lanjutkan",
              isLoading: isLoading,
              onPressed: () async {
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

                setState(() => isLoading = true);
                try {
                  await ApiService.requestOtp(
                    email: emailController.text.trim(),
                    nama: namaController.text.trim(),
                    noTelp: noTelpController.text.trim(),
                  );
                  showMsg("OTP berhasil dikirim ke email");
                  nextPage();
                } catch (e) {
                  showMsg(e.toString().replaceAll('Exception: ', ''), isError: true);
                } finally {
                  setState(() => isLoading = false);
                }
              },
              isDesktop: isDesktop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKodeVerifikasiPage({bool isDesktop = false}) {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kode Verifikasi",
              style: TextStyle(
                fontSize: isDesktop ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isDesktop ? 4 : 8),
            Text(
              "Masukkan kode verifikasi yang Anda terima",
              style: TextStyle(
                fontSize: isDesktop ? 14 : 15, 
                color: Colors.grey[600]
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 32),
            Container(
              padding: EdgeInsets.all(isDesktop ? 16 : 20),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isDesktop ? 12 : 16),
                border: Border.all(color: Color(0xFF1976D2).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded, 
                      color: Colors.white, 
                      size: isDesktop ? 20 : 24
                    ),
                  ),
                  SizedBox(width: isDesktop ? 12 : 16),
                  Expanded(
                    child: Text(
                      "Masukkan kode verifikasi yang telah diberikan oleh admin",
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 14,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 20 : 24),
            _buildTextField(
              controller: kodeController,
              label: "Kode Verifikasi",
              icon: Icons.vpn_key_rounded,
              hint: "Masukkan kode dari admin",
              isDesktop: isDesktop,
            ),
            SizedBox(height: isDesktop ? 20 : 8),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: "Kembali",
                    onPressed: prevPage,
                    isPrimary: false,
                    isDesktop: isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  flex: 2,
                  child: _buildButton(
                    text: "Verifikasi",
                    isLoading: isLoading,
                    onPressed: () async {
                      if (kodeController.text.isEmpty) {
                        showMsg("Masukkan kode verifikasi", isError: true);
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        await ApiService.verifyOtp(
                          email: emailController.text.trim(),
                          otp: kodeController.text.trim(),
                        );
                        showMsg("Verifikasi berhasil!");
                        nextPage();
                      } catch (e) {
                        showMsg(e.toString().replaceAll('Exception: ', ''), isError: true);
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                    isDesktop: isDesktop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAkunPage({bool isDesktop = false}) {
    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Keamanan Akun",
              style: TextStyle(
                fontSize: isDesktop ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isDesktop ? 4 : 8),
            Text(
              "Pilih jabatan dan buat password yang kuat",
              style: TextStyle(
                fontSize: isDesktop ? 14 : 15, 
                color: Colors.grey[600]
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 32),
              // Jabatan dropdown removed
            SizedBox(height: isDesktop ? 16 : 16),
            _buildTextField(
              controller: passwordController,
              label: "Password",
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              hint: "Minimal 6 karakter",
              isDesktop: isDesktop,
            ),
            Container(
              padding: EdgeInsets.all(isDesktop ? 12 : 16),
              margin: EdgeInsets.only(top: isDesktop ? 12 : 0),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(isDesktop ? 10 : 12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined, 
                    color: Colors.amber[800], 
                    size: isDesktop ? 18 : 20
                  ),
                  SizedBox(width: isDesktop ? 8 : 12),
                  Expanded(
                    child: Text(
                      "Password minimal 6 karakter dengan kombinasi huruf dan angka",
                      style: TextStyle(
                        fontSize: isDesktop ? 11 : 12,
                        color: Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 24),
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    text: "Kembali",
                    onPressed: prevPage,
                    isPrimary: false,
                    isDesktop: isDesktop,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  flex: 2,
                  child: _buildButton(
                    text: "Selesai",
                    onPressed: handleFinalizeRegistration,
                    isLoading: isLoading,
                    isDesktop: isDesktop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}