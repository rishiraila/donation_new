import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'donors.dart';

class DonorDetailsAdminPage extends StatefulWidget {
  @override
  State<DonorDetailsAdminPage> createState() => _DonorDetailsAdminPageState();
}

class _DonorDetailsAdminPageState extends State<DonorDetailsAdminPage> {
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> filteredData = [];

  final searchController = TextEditingController();
  String selectedSearchField = 'name';

  final Map<String, String> searchOptions = {
    'name': 'Name',
    'mobile': 'Mobile',
    'email': 'Email',
    'donation_purpose': 'Purpose',
    'created_at': 'Date',
  };

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 25, 50];
  String sortBy = 'id';
  bool sortAsc = true;

  String selectedSortDuration = 'All';

  @override
  void initState() {
    super.initState();
    fetchAllDonors();
  }

  Future<void> fetchAllDonors() async {
    int currentPage = 1;
    int pageSize = 100;
    bool hasMore = true;
    List<Map<String, dynamic>> allFetchedData = [];

    while (hasMore) {
      final res = await http.get(
        Uri.parse('https://backend-owxp.onrender.com/api/admin/donors?page=$currentPage&limit=$pageSize'),
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final donors = List<Map<String, dynamic>>.from(jsonData['donors']);

        allFetchedData.addAll(donors);

        if (donors.length < pageSize) {
          hasMore = false;
        } else {
          currentPage++;
        }
      } else {
        print("Failed to fetch donors");
        hasMore = false;
      }
    }

    setState(() {
      allData = allFetchedData;
      applyFilters();
    });
  }

  void applyFilters() {
    double? minAmount = double.tryParse(minCtrl.text);
    double? maxAmount = double.tryParse(maxCtrl.text);
    final now = DateTime.now();

    DateTime? startDate = startDateCtrl.text.isNotEmpty ? DateTime.tryParse(startDateCtrl.text) : null;
    DateTime? endDate = endDateCtrl.text.isNotEmpty ? DateTime.tryParse(endDateCtrl.text) : null;
    String searchValue = searchController.text.toLowerCase();

    filteredData = allData.where((d) {
      final amount = double.tryParse(d['amount'].toString()) ?? 0;
      final createdAt = DateTime.tryParse(d['created_at'] ?? '');

      bool matchesDuration = true;
      if (createdAt != null) {
        switch (selectedSortDuration) {
          case 'This Week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(Duration(days: 6));
            matchesDuration = createdAt.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                              createdAt.isBefore(endOfWeek.add(Duration(days: 1)));
            break;
          case 'This Month':
            matchesDuration = createdAt.month == now.month && createdAt.year == now.year;
            break;
          case 'This Year':
            matchesDuration = createdAt.year == now.year;
            break;
        }
      }

      bool matchesCustomDate = true;
      if (createdAt != null) {
        if (startDate != null && createdAt.isBefore(startDate)) matchesCustomDate = false;
        if (endDate != null && createdAt.isAfter(endDate)) matchesCustomDate = false;
      }

      bool matchesSearch = true;
      if (searchValue.isNotEmpty) {
        final fieldValue = (d[selectedSearchField] ?? '').toString().toLowerCase();
        matchesSearch = fieldValue.contains(searchValue);
      }

      return matchesDuration &&
             matchesCustomDate &&
             matchesSearch &&
             (minAmount == null || amount >= minAmount) &&
             (maxAmount == null || amount <= maxAmount);
    }).toList();

    applySorting();
  }

  void applySorting() {
    filteredData.sort((a, b) {
      final aVal = a[sortBy];
      final bVal = b[sortBy];
      if (aVal is num && bVal is num) {
        return sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      } else {
        return sortAsc
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      }
    });
    setState(() {});
  }

  void sortByColumn(String key) {
    setState(() {
      if (sortBy == key) {
        sortAsc = !sortAsc;
      } else {
        sortBy = key;
        sortAsc = true;
      }
      applySorting();
    });
  }

  Future<void> exportFilteredData(String format) async {
    final uri = Uri.parse('https://backend-owxp.onrender.com/api/admin/export');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'format': format, 'data': filteredData}),
    );

    if (response.statusCode == 200) {
      final blob = response.bodyBytes;
      final contentType = response.headers['content-type'] ?? 'application/octet-stream';
      final blobUrl = Uri.dataFromBytes(blob, mimeType: contentType).toString();
      await launchUrl(Uri.parse(blobUrl));
    } else {
      print('Export failed');
    }
  }

  Widget buildCompactDatePicker(BuildContext context, TextEditingController controller, String hint) {
    return SizedBox(
      width: 140,
      height: 40,
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, size: 16),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12),
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          isDense: true,
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: Colors.white,
                  textTheme: TextTheme(bodyMedium: TextStyle(fontSize: 12)),
                ),
                child: SizedBox(width: 300, height: 300, child: child!),
              );
            },
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().substring(0, 10);
            applyFilters();
          }
        },
      ),
    );
  }

  int getSortIndex() {
    switch (sortBy) {
      case 'id':
        return 0;
      case 'name':
        return 1;
      case 'mobile':
        return 2;
      case 'email':
        return 3;
      case 'amount':
        return 4;
      case 'donation_purpose':
        return 5;
      case 'address':
        return 6;
      case 'created_at':
        return 7;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Donors")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => exportFilteredData('excel'),
                      icon: Icon(Icons.download),
                      label: Text("Export Excel"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => exportFilteredData('pdf'),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Export PDF"),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: selectedSortDuration,
                      items: ['All', 'This Week', 'This Month', 'This Year']
                          .map((e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedSortDuration = value;
                            applyFilters();
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        buildCompactDatePicker(context, startDateCtrl, 'Start Date'),
                        SizedBox(width: 8),
                        buildCompactDatePicker(context, endDateCtrl, 'End Date'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSearchField,
                      isDense: true,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                      icon: Icon(Icons.arrow_drop_down),
                      items: searchOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedSearchField = value;
                            applyFilters();
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  rowsPerPage: rowsPerPage,
                  availableRowsPerPage: rowsPerPageOptions,
                  onRowsPerPageChanged: (value) => setState(() => rowsPerPage = value!),
                  sortColumnIndex: getSortIndex(),
                  sortAscending: sortAsc,
                  columns: [
                    DataColumn(label: Text("Sr.no"), onSort: (_, __) => sortByColumn('id')),
                    DataColumn(label: Text("Name"), onSort: (_, __) => sortByColumn('name')),
                    DataColumn(label: Text("Mobile"), onSort: (_, __) => sortByColumn('mobile')),
                    DataColumn(label: Text("Email"), onSort: (_, __) => sortByColumn('email')),
                    DataColumn(label: Text("Amount"), onSort: (_, __) => sortByColumn('amount')),
                    DataColumn(label: Text("Purpose"), onSort: (_, __) => sortByColumn('donation_purpose')),
                    DataColumn(label: Text("Address"), onSort: (_, __) => sortByColumn('address')),
                    DataColumn(label: Text("Date"), onSort: (_, __) => sortByColumn('created_at')),
                  ],
                  source: DonorDataTableSource(filteredData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonorDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  DonorDataTableSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final d = data[index];
    return DataRow(
      cells: [
        DataCell(Text(d['id'].toString())),
        DataCell(Text(d['name'] ?? '')),
        DataCell(Text(d['mobile'] ?? '')),
        DataCell(Text(d['email'] ?? '')),
        DataCell(Text("₹${d['amount']}")),
        DataCell(Text(d['donation_purpose'] ?? '')),
        DataCell(Text(d['address'] ?? '')),
        DataCell(Text(d['created_at']?.toString().substring(0, 10) ?? '')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}
