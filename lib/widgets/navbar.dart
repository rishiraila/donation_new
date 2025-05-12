// navbar.dart
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final Function(String)? onLinkTap;
  const Navbar({super.key, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: screenWidth < 800
          ? _buildMobileNavbar(context)
          : _buildDesktopNavbar(context),
    );
  }

  Widget _buildDesktopNavbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'give',
          style: TextStyle(
            color: Colors.red,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            _navButton(context, 'Donate'),
            _navButton(context, 'Fundraiser'),
            _navButton(context, 'Testimonials'),
            _navButton(context, 'Blogs'),
            _navButton(context, 'About Us'),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (onLinkTap != null) {
          onLinkTap!(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildMobileNavbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'give',
          style: TextStyle(
            color: Colors.red,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}
