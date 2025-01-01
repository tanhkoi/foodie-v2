import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodie/admin/orders_manage.dart';
import 'package:foodie/screens/login_screen.dart';
import 'food_manage.dart';
import 'account_manage.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Xin chào, admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            _buildAdminOption(
              icon: Icons.fastfood,
              title: 'Quản lý đồ ăn',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FoodManageScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildAdminOption(
              icon: Icons.person,
              title: 'Quản lý tài khoản',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountManageScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildAdminOption(
              icon: Icons.receipt_long,
              title: 'Quản lý đơn hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrdersManageScreen()),
                );
              },
            ),
            const Spacer(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurpleAccent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.deepPurpleAccent),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
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
