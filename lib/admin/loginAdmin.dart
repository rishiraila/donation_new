import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './dashboardAdmin.dart';

class AdminAuthScreen extends StatefulWidget {
  @override
  _AdminAuthScreenState createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    final url = _isLogin
        ? 'https://backend-owxp.onrender.com/api/admin/login'
        : 'https://backend-owxp.onrender.com/api/admin/register';

    final body = _isLogin
        ? {
            'mobile': _mobileController.text.trim(),
            'password': _passwordController.text.trim(),
          }
        : {
            'name': _nameController.text.trim(),
            'mobile': _mobileController.text.trim(),
            'password': _passwordController.text.trim(),
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_isLogin && data['success'] == true) {
          String adminName = data['admin']['name'] ?? 'Admin';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(adminName: adminName),
            ),
          );
        } else if (!_isLogin && data['success'] == true) {
          setState(() {
            _isLogin = true;
            _error = 'Registration successful! Please log in.';
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Something went wrong';
          });
        }
      } else {
        setState(() {
          _error = data['message'] ?? 'Something went wrong';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Server error: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final redAccent = Color(0xFFE31C25);

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: redAccent),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: redAccent),
            SizedBox(width: 8),
            // Text(
            //   _isLogin ? "Admin Login" : "Admin Registration",
            //   style: TextStyle(
            //     color: redAccent,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/jaikishan.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          _buildForm(true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Collage
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.red.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 500,
                  height: 360,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 40,
                        top: 20,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: Container(
                            width: 260,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage('assets/jaikishan.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 160,
                        top: 120,
                        child: Transform.rotate(
                          angle: 0.05,
                          child: Container(
                            width: 260,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage('assets/larm.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Empowering changemakers through secure admin access. "
                    "Manage donations and impact lives with confidence.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Form
        Expanded(
          flex: 1,
          child: Center(child: _buildForm(false)),
        ),
      ],
    );
  }

  Widget _buildForm(bool isMobile) {
    final redAccent = Color(0xFFE31C25);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Container(
        width: isMobile ? double.infinity : 400,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: redAccent.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? "Welcome Back, Admin!" : "Register as Admin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: redAccent,
                ),
              ),
              SizedBox(height: 10),
              if (!_isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Name required' : null,
                ),
              if (!_isLogin) SizedBox(height: 20),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Mobile number required' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.length < 6 ? 'Min 6 characters' : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: redAccent,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isLogin ? 'Login' : 'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _error = '';
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already registered? Login',
                  style: TextStyle(color: redAccent),
                ),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
