import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String name;

  HeaderSection({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome, $name",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
