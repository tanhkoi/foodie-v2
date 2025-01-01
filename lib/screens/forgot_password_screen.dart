import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Đã gửi liên kết đặt lại mật khẩu đến email của bạn.')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng với email này.';
      } else {
        message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurpleAccent,
              Colors.deepOrangeAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 60),
                _buildLogo(),
                const SizedBox(height: 30),
                Text(
                  'Quên Mật Khẩu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildSendLinkButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Image.asset(
        'assets/images/img.png',
        height: 100,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSendLinkButton() {
    return GestureDetector(
      onTap: _sendPasswordResetEmail,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            'Gửi Liên Kết',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Text(
        'Quay lại đăng nhập',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
