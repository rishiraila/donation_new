import 'package:flutter/material.dart';

class RaiseFundsSection extends StatelessWidget {
  const RaiseFundsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0), // Top padding
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1EE), // Soft peach background
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT COLUMN
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raise funds for your cause!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Onboard on Give.do and create impact by raising funds for your initiatives',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // RED BUTTON (white text)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Enroll your NGO on give'),
                        ),
                        const SizedBox(width: 16),
                        // WHITE BUTTON (black text)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            side: const BorderSide(color: Colors.black87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Raise funds for a listed NGO'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // RIGHT IMAGES COLUMN
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 280,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 40,
                        top: 30,
                        child: Transform.rotate(
                          angle: -0.05,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/andrej.jpg',
                              width: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Transform.rotate(
                          angle: 0.03,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/jaikishan.jpg',
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
