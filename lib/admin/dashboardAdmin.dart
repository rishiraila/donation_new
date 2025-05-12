import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'donors.dart';
import 'donors_details.dart';
import 'reports.dart';


class AdminDashboard extends StatefulWidget {
  // const AdminDashboard({Key? key}) : super(key: key);
   final String adminName;

  const AdminDashboard({Key? key, required this.adminName}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    DashboardTab(),
    DonorsPage(),
    DonorDetailsAdminPage(),
    ReportsPage(),
  ];

  final List<String> _tabTitles = [
    'Dashboard',
    'Donors',
    'Export',
    'Donor Details',
    'Reports',
  ];

  void _onLogout() {
    // Handle logout logic
    Navigator.pop(context); // You can navigate to login page here
  }

  void _onTabSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width < 600) {
      Navigator.pop(context); // close drawer on mobile
    }
  }

  Widget buildSidebar() {
    return Container(
      width: 220,
      color: Colors.red.shade300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome ${widget.adminName}!',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),
          buildTabButton('Dashboard', 0, icon: Icons.dashboard),
          buildTabButton('Donors', 1, icon: Icons.people),
          buildTabButton('Donor Details', 2, icon: Icons.info_outline),
          buildTabButton('Reports', 3, icon: Icons.bar_chart),
          const Spacer(),
          buildTabButton('Logout', -1, icon: Icons.logout, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildTabButton(String title, int index,
    {bool isLogout = false, required IconData icon}) {
  bool isSelected = _selectedIndex == index;

  return Container(
    color: isSelected ? Colors.white : Colors.transparent,
    child: ListTile(
      selected: isSelected,
      leading: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: isLogout ? _onLogout : () => _onTabSelect(index),
    ),
  );
}


  AppBar buildTopBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.red.shade100,
      title: Text('${_tabTitles[_selectedIndex]} - ${widget.adminName}'),

      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _onLogout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile ? buildTopBar() : null,
      drawer: isMobile ? Drawer(child: buildSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) buildTopBar(),
                Expanded(child: _tabs[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
