import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashbod.dart';
import '../admin/loginAdmin.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> checkMobileAndLogin() async {
    String mobile = mobileController.text.trim();

    if (mobile.isEmpty) {
      showSnackbar("Please enter your mobile number");
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await http.post(
        Uri.parse("https://backend-owxp.onrender.com/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mobile": mobile}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData.containsKey("donor")) {
        navigateToDashboard(
          responseData["donor"],
          responseData["donationHistory"],
        );
      } else {
        showSnackbar("Mobile number not registered");
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void navigateToDashboard(
    Map<String, dynamic> donorData,
    List<dynamic> donationHistory,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => DashboardPage1(
              donorData: donorData,
              donationHistory: donationHistory,
            ),
      ),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminAuthScreen()),
              );
            },
            icon: Icon(Icons.admin_panel_settings, color: redAccent, size: 20),
            label: Text(
              "Admin Login",
              style: TextStyle(
                color: redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
      body:
          isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
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
          _buildLoginForm(context, true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left image collage
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.red.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enlarged Collage
                SizedBox(
                  width: 500,
                  height: 360,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background image
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
                      // Foreground image
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
                SizedBox(height: 0),
                // Paragraph under collage
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Every child deserves access to quality education and a brighter future. "
                    "Your support helps us bring hope, technology, and opportunity to underserved communities.",
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

        // Right login form
        Expanded(
          flex: 1,
          child: Center(child: _buildLoginForm(context, false)),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isMobile) {
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
              color: Colors.red.shade500,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               color: Colors.red.shade500
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Login with your registered mobile number",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 20),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_error.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error,
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : checkMobileAndLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.red.shade300,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _loading
                        ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
