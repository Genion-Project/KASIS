import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State
  int _currentStep = 0;
  bool isLoading = false;
  String errorMsg = '';
  bool _isPasswordVisible = false;
  
  // Timer for OTP
  Timer? _timer;
  int _start = 60;
  bool canResend = false;

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = 60;
      canResend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
        errorMsg = '';
      });
    }
  }

  // --- Step 1: Request OTP ---
  Future<void> handleRequestOtp() async {
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      setState(() => errorMsg = 'Masukkan email yang valid');
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.forgotPasswordRequest(emailController.text.trim());
      startTimer();
      // Hanya pindah step jika kita masih di step 0 (input email)
      // Jika kita di step 1 (verify), ini adalah Resend, jadi jangan pindah.
      if (_currentStep == 0) {
        _nextStep();
      } else {
        // Jika resend, beri feedback kecil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP baru telah dikirim ke email Anda')),
        );
      }
    } catch (e) {
      setState(() => errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Step 2: Verify OTP ---
  Future<void> handleVerifyOtp() async {
    if (otpController.text.length < 4) {
      setState(() => errorMsg = 'Masukkan kode OTP 6 digit');
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.forgotPasswordVerify(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );
      _nextStep();
    } catch (e) {
      setState(() => errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- Step 3: Reset Password ---
  Future<void> handleResetPassword() async {
    if (passwordController.text.length < 6) {
      setState(() => errorMsg = 'Password minimal 6 karakter');
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.forgotPasswordReset(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: Colors.green, size: 32),
              ),
              SizedBox(height: 16),
              Text('Sukses!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Password berhasil direset. Silakan login dengan password baru.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Login Sekarang', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => errorMsg = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        title: Text(
          'Lupa Password', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: isDesktop ? 480 : double.infinity,
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24, vertical: 24),
          decoration: isDesktop ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ) : null,
          child: Column(
            children: [
              // Progress Indicator
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0),
                  _buildStepLine(0),
                  _buildStepIndicator(1),
                  _buildStepLine(1),
                  _buildStepIndicator(2),
                ],
              ),
              SizedBox(height: 32),

              // Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildRequestStep(),
                    _buildVerifyStep(),
                    _buildResetStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    bool isActive = _currentStep >= step;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF1976D2) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isActive
            ? Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${step + 1}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Color(0xFF1976D2) : Colors.grey[300],
    );
  }

  Widget _buildRequestStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Masukkan Email',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Kami akan mengirimkan kode OTP ke email Anda untuk mereset password.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildTextField(
            controller: emailController,
            label: 'Email Terdaftar',
            icon: Icons.email_outlined,
          ),
          if (errorMsg.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildErrorMsg(),
          ],
          Spacer(),
          _buildButton(
            label: 'Kirim OTP',
            onPressed: handleRequestOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verifikasi OTP',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Masukkan kode OTP yang dikirim ke\n${emailController.text}',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildTextField(
            controller: otpController,
            label: 'Kode OTP',
            icon: Icons.lock_clock_outlined,
            isNumber: true,
          ),
          SizedBox(height: 16),
          Center(
            child: canResend
                ? TextButton(
                    onPressed: handleRequestOtp,
                    child: Text('Kirim Ulang OTP'),
                  )
                : Text(
                    'Kirim ulang dalam $_start detik',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),
          if (errorMsg.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildErrorMsg(),
          ],
          Spacer(),
          _buildButton(
            label: 'Verifikasi',
            onPressed: handleVerifyOtp,
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Buat password baru yang aman untuk akun Anda.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildTextField(
            controller: passwordController,
            label: 'Password Baru',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          if (errorMsg.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildErrorMsg(),
          ],
          Spacer(),
          _buildButton(
            label: 'Simpan Password',
            onPressed: handleResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF1976D2)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorMsg() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMsg,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1976D2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Color(0xFF1976D2).withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
