import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Kiểm tra các trường thông tin
    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền tất cả các trường')),
      );
      return;
    }

    // Ràng buộc kiểm tra số điện thoại
    if (phone.length != 10 || !phone.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Số điện thoại phải đủ 10 số và bắt đầu bằng số 0')),
      );
      return;
    }

    // Ràng buộc kiểm tra định dạng email
    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email phải kết thúc bằng @gmail.com')),
      );
      return;
    }

    // Ràng buộc kiểm tra độ dài mật khẩu
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải từ 6 ký tự trở lên')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Tạo người dùng mới trên Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'address': '',
        'role': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tạo độ trễ 2 giây trước khi hiển thị thông báo
      await Future.delayed(const Duration(seconds: 2));

      // Hiển thị thông báo đăng ký thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );

      // Chuyển về trang đăng nhập
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng.';
      } else {
        message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 60),
                _buildLogo(),
                const SizedBox(height: 30),
                Text(
                  'Đăng Ký',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                _buildTextField(_fullNameController, 'Họ Tên', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(_phoneController, 'Số Điện Thoại', Icons.phone,
                    isPhone: true),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Mật Khẩu', Icons.lock,
                    isObscure: true),
                const SizedBox(height: 20),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
      TextEditingController controller, String hintText, IconData icon,
      {bool isObscure = false, bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters:
            isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _signUp,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Text(
            'Đăng Ký',
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
      child: RichText(
        text: TextSpan(
          text: 'Đã có tài khoản? ',
          style: const TextStyle(color: Colors.white, fontSize: 16),
          children: <TextSpan>[
            TextSpan(
              text: 'Đăng nhập ngay!',
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
