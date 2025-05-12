import 'package:flutter/material.dart';

const List<Map<String, dynamic>> fundraisers = [
  {
    'image': 'assets/national.jpg',
    'title': 'Help abandoned grandparents fight hunger and also receive...',
    'org': 'by Share and Care Children’s Welfare Society',
    'donations': '19944',
    'daysLeft': '2',
    'raised': '₹2,40,09,553',
    'goal': '₹3,00,00,000',
    'progress': 0.8,
  },
  {
    'image': 'assets/larm.jpg',
    'title': 'Your donation can help 40 blind girls get food, shelter and care...',
    'org': 'by Blind Welfare Society',
    'donations': '6324',
    'daysLeft': '2',
    'raised': '₹1,20,00,000',
    'goal': '₹1,80,00,000',
    'progress': 0.67,
  },
  {
    'image': 'assets/jaikishan.jpg',
    'title': 'Help provide shelter, food, clothes and medical support to...',
    'org': 'by Maitri',
    'donations': '21956',
    'daysLeft': '3',
    'raised': '₹2,41,11,580',
    'goal': '₹4,00,00,000',
    'progress': 0.6,
  },
];

class FundraiserCardList extends StatelessWidget {
  const FundraiserCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 64) / 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32), // Top margin added
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support a fundraiser',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Pick a cause close to your heart and donate now',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 420,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: fundraisers.map((fundraiser) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    bool isHovered = false;

                    return MouseRegion(
                      onEnter: (_) => setState(() => isHovered = true),
                      onExit: (_) => setState(() => isHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: isHovered
                            ? (Matrix4.identity()..scale(1.03))
                            : Matrix4.identity(),
                        width: cardWidth,
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: isHovered ? 12 : 6,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.asset(
                                    fundraiser['image'],
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE082),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Tax Benefits Available',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fundraiser['title'],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fundraiser['org'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.people,
                                          size: 14, color: Colors.black45),
                                      const SizedBox(width: 4),
                                      Text('${fundraiser['donations']} Donations',
                                          style: const TextStyle(fontSize: 12)),
                                      const Spacer(),
                                      const Icon(Icons.timer,
                                          size: 14, color: Colors.black45),
                                      const SizedBox(width: 4),
                                      Text('${fundraiser['daysLeft']} Days Left',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: fundraiser['progress'],
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.orange,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${fundraiser['raised']} raised of ${fundraiser['goal']}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Donate Now'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
