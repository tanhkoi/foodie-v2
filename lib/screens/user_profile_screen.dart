import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie/constant/app_color.dart';

import 'login_screen.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isLoading = true;

  // Controllers cho các trường
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          _fullNameController.text = userData['fullName'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thay đổi thông tin thành công!')),
      );
    }

    setState(() {
      _isEditing = false;
    });
  }

  bool _validateInput() {
    if (_fullNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền tất cả các trường')),
      );
      return false;
    }

    if (_phoneController.text.length != 10 ||
        !_phoneController.text.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Số điện thoại phải đủ 10 số và bắt đầu bằng số 0')),
      );
      return false;
    }

    if (!_emailController.text.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email phải kết thúc bằng @gmail.com')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: AppColor.profileScreenAppBarIconColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings,
                color: AppColor.profileScreenAppBarIconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/hamburgirl.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30),
                      child: Column(
                        children: [
                          _buildProfileField(
                              'Họ và tên', _fullNameController, _isEditing),
                          const SizedBox(height: 15),
                          _buildProfileField('Email', _emailController, false),
                          const SizedBox(height: 15),
                          _buildProfileField(
                              'Số điện thoại', _phoneController, _isEditing,
                              isPhone: true),
                          const SizedBox(height: 15),
                          _buildProfileField(
                              'Địa chỉ', _addressController, _isEditing),
                          const SizedBox(height: 25),
                          const Divider(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.10,
                          ),
                          _buildEditButton(),
                          const SizedBox(height: 20),
                          _buildLogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, bool isEditable,
      {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        isEditable
            ? TextFormField(
                controller: controller,
                keyboardType:
                    isPhone ? TextInputType.phone : TextInputType.text,
                inputFormatters:
                    isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    borderSide: const BorderSide(
                      color: Color(0xffE1E1E1),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.0),
                  color: const Color(0xffE1E1E1),
                ),
                child: Text(controller.text),
              ),
      ],
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () {
        if (_isEditing) {
          if (_validateInput()) {
            _saveChanges();
          }
        } else {
          setState(() {
            _isEditing = true;
          });
        }
      },
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: _isEditing ? Colors.green : Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            _isEditing ? "Áp dụng" : "Chỉnh sửa",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await _auth.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
          (route) => false,
        );
      },
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Center(
          child: Text(
            "Đăng xuất",
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
