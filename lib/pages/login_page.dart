// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/main_screen.dart'; // ganti sesuai lokasi MainScreen kamu

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMsg = '';
  bool _isPasswordVisible = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final result = await ApiService.login(emailController.text, passwordController.text);
      final user = result['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', user['nama'] ?? '');
      await prefs.setString('jabatan', user['jabatan'] ?? '');

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      }
    } catch (e) {
      if (mounted) setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header
                Container(
                  height: height * 0.3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[600]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.account_balance_wallet_outlined, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text('Selamat Datang', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Silakan masuk ke akun Anda', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(emailController, 'Email', Icons.email_outlined, false),
                        SizedBox(height: 16),
                        _buildTextField(passwordController, 'Password', Icons.lock_outline, true),
                        SizedBox(height: 24),
                        if (errorMsg.isNotEmpty) _buildErrorMsg(),
                        if (errorMsg.isNotEmpty) SizedBox(height: 16),
                        _buildLoginButton(),
                        SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Dengan masuk, Anda menyetujui syarat dan ketentuan',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600]),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorMsg() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(errorMsg, style: TextStyle(color: Colors.red[700], fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[700]!]),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : login,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
