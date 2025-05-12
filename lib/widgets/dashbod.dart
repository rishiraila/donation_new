import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:my_donation_app/main.dart';
import 'package:donation_app/widgets/donation.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../screens/home_screen.dart';
// import 'package:my_donation_app/donation_form.dart';
// import 'package:my_donation_app/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, );
  }
}

class DashboardPage1 extends StatefulWidget {
  final dynamic donorData;
  final List<dynamic> donationHistory;

  DashboardPage1({required this.donorData, required this.donationHistory});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage1> {
  String selectedPage = "Update Profile";

  // Controllers for form fields
  late TextEditingController mobileController;
  late TextEditingController nameController;
  late TextEditingController purposeController;
  late TextEditingController addressController;
  late TextEditingController areaController;
  late TextEditingController pincodeController;
  late TextEditingController emailController;
  late TextEditingController cityController;
  late TextEditingController documentNumberController;
  String documentType = "Aadhar"; // Default selection

  void signOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ), // ✅ Replace with your main login page
      (route) => false, // ✅ Remove all previous routes
    );
  }

  void updateDonorDetails() async {
    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/update-donor",
    ); // Replace with your backend URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobile": mobileController.text,
        "name": nameController.text,
        "address": addressController.text,
        "area": areaController.text,
        "city": cityController.text,
        "pincode": pincodeController.text,
        "email": emailController.text,
        "document_type": documentType,
        "document_number": documentNumberController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["message"])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update donor details: ${response.body}"),
        ),
      );
    }
  }

  void updateTaxDetails() async {
    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/update-donor",
    ); // Replace with actual endpoint

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "document_type": documentType,
        "document_number": documentNumberController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["message"])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update tax details: ${response.body}"),
        ),
      );
    }
  }

  //   void downloadInvoice(String donationId) async {
  //   if (donationId.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Invalid donation ID. Cannot download invoice.")),
  //     );
  //     return;
  //   }

  //   final String url = "http://localhost:5000/api/donations/invoice?donationId=$donationId"; // ✅ Backend URL

  //   try {
  //     final html.AnchorElement anchor = html.AnchorElement(href: url)
  //       ..setAttribute("download", "Invoice_$donationId.pdf") // ✅ Force browser download
  //       ..style.display = "none"; // Hide the anchor element
  //     html.document.body?.append(anchor); // Append to the DOM
  //     anchor.click(); // Simulate click
  //     anchor.remove(); // Remove the anchor element after use

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Invoice is downloading...")),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }
  void downloadInvoice(String donationId) async {
  final url = 'https://backend-owxp.onrender.com/api/donations/invoice?donationId=$donationId';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    if (kIsWeb) {
      final blob = html.Blob([response.bodyBytes], 'application/pdf');
      final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: downloadUrl)
        ..setAttribute("download", "invoice_$donationId.pdf")
        ..click();
      html.Url.revokeObjectUrl(downloadUrl);
    } else {
      print("This function is only for Flutter Web.");
    }
  } else {
    print("Failed to download invoice: ${response.body}");
  }
}


  @override
  void initState() {
    super.initState();
    fetchDonationHistory();

    // Initialize controllers with data from `donorData`
    mobileController = TextEditingController(
      text: widget.donorData["mobile"] ?? "",
    );
    nameController = TextEditingController(
      text: widget.donorData["name"] ?? "",
    );
    purposeController = TextEditingController(
      text: widget.donorData["donation_purpose"] ?? "",
    );
    addressController = TextEditingController(
      text: widget.donorData["address"] ?? "",
    );
    areaController = TextEditingController(
      text: widget.donorData["area"] ?? "",
    );
    pincodeController = TextEditingController(
      text: widget.donorData["pincode"] ?? "",
    );
    emailController = TextEditingController(
      text: widget.donorData["email"] ?? "",
    );
    cityController = TextEditingController(
      text: widget.donorData["city"] ?? "",
    );
    documentNumberController = TextEditingController(
      text: widget.donorData["document_number"] ?? "",
    );
    documentType =
        widget.donorData["document_type"] ?? "Aadhar"; // Default value
  }

  List<dynamic> donationHistory = []; // ✅ Use a state variable

  void fetchDonationHistory() async {
    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/history?mobile=${widget.donorData["mobile"]}",
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        donationHistory = data["donationHistory"]; // ✅ Update state variable
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch donation history")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      drawer:
          isLargeScreen
              ? null
              : SideBarMenu(
                selectedPage: selectedPage,
                onSelect: (page) {
                  setState(() {
                    selectedPage = page;
                  });
                },
                mobile: widget.donorData["mobile"] ?? "Unknown",
                signOut: signOut,
              ),
      body: Row(
        children: [
          if (isLargeScreen)
            SideBarMenu(
              selectedPage: selectedPage,
              onSelect: (page) {
                setState(() {
                  selectedPage = page;
                });
              },
              mobile: widget.donorData["mobile"] ?? "Unknown",
              signOut: signOut,
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text("Dashboard"),
                  backgroundColor: Colors.red.shade100,

                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Go to Dashboard",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior().copyWith(
                        scrollbars: false,
                      ), // Disable scrollbars
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Card(
                            color: Colors.red.shade50,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity, // Use full width
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedPage,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                  // if (selectedPage == "Update Profile") ...[
                                  //   SizedBox(height: 10),
                                  //   Text(
                                  //     "To avail benefits of 80G, updating PAN and AADHAR is mandatory.",
                                  //     style: TextStyle(color: Colors.red),
                                  //   ),
                                  //   SizedBox(height: 10),
                                  //   buildStyledTextField(
                                  //     "Mobile No*",
                                  //     "Enter mobile number",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Name*",
                                  //     "Enter full name",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Purpose",
                                  //     "Enter purpose",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Flat, House no., Building, Company, Apartment",
                                  //     "Enter address details",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Area, Street, Sector, Landmark",
                                  //     "Enter area details",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Pincode",
                                  //     "Enter pincode",
                                  //   ),
                                  //   buildStyledTextField(
                                  //     "Email",
                                  //     "Enter email",
                                  //   ),
                                  //   buildStyledTextField("City", "Enter city"),
                                  //   buildDropdownField("Document Type", [
                                  //     "Aadhar",
                                  //     "PAN",
                                  //   ]),
                                  //   buildStyledTextField(
                                  //     "Document Number",
                                  //     "Enter document number",
                                  //   ),
                                  //   SizedBox(height: 20),
                                  //   Center(
                                  //     child: ElevatedButton(
                                  //       onPressed: () {},
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor:
                                  //             Colors.red.shade700,
                                  //         foregroundColor: Colors.white,
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(
                                  //             8,
                                  //           ),
                                  //         ),
                                  //         padding: EdgeInsets.symmetric(
                                  //           horizontal: 50,
                                  //           vertical: 15,
                                  //         ),
                                  //       ),
                                  //       child: Text(
                                  //         "Save",
                                  //         style: TextStyle(
                                  //           fontSize: 16,
                                  //           fontWeight: FontWeight.bold,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
                                  if (selectedPage == "Update Profile") ...[
                                    SizedBox(height: 10),
                                    Text(
                                      "To avail benefits of 80G, updating PAN and AADHAR is mandatory.",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    SizedBox(height: 10),
                                    // Use a Column to hold the Rows
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Mobile No*",
                                                mobileController,

                                                // enabled: false,
                                                // readOnly: true,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ), // Add some space between the fields
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Name*",
                                                nameController,
                                                
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ), // Space between rows
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Purpose",
                                                purposeController,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ), // Add some space between the fields
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Address",
                                                addressController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ), // Space between rows
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Area",
                                                areaController,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ), // Add some space between the fields
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Pincode",
                                                pincodeController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ), // Space between rows
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Email",
                                                emailController,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ), // Add some space between the fields
                                            Expanded(
                                              child: buildStyledTextField(
                                                "City",
                                                cityController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ), // Space between rows
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: buildDropdownField(
                                                "Document Type",
                                                ["Aadhar", "PAN"],
                                                documentType,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ), // Add some space between the fields
                                            Expanded(
                                              child: buildStyledTextField(
                                                "Document Number",
                                                documentNumberController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: updateDonorDetails,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade700,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 15,
                                              ),
                                            ),
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (selectedPage == "Tax Detail Update") ...[
                                    SizedBox(height: 10),
                                    Text(
                                      "Please provide your tax details.",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    SizedBox(height: 10),
                                    buildDropdownField("Document Type", [
                                      "Aadhar",
                                      "PAN",
                                    ], documentType),
                                    buildStyledTextField(
                                      "Document Number",
                                      documentNumberController,
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: updateTaxDetails,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.red.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 50,
                                            vertical: 15,
                                          ),
                                        ),
                                        child: Text(
                                          "Save",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (selectedPage == "Donation history") ...[
                                    SizedBox(height: 10),
                                    // Text(
                                    //   "",
                                    //   style: TextStyle(
                                    //     fontSize: 20,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                    SizedBox(height: 20),
                                    widget.donationHistory.isEmpty
                                        ? Center(
                                          child: Text(
                                            "No donation history available.",
                                          ),
                                        )
                                        : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columnSpacing:
                                                12.0, // Adjust column spacing
                                            // ignore: deprecated_member_use
                                            dataRowHeight:
                                                60.0, // Adjust row height
                                            headingRowColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) =>
                                                      Colors.grey.shade300,
                                                ),
                                            columns: [
                                              DataColumn(label: Text("Date")),
                                              DataColumn(label: Text("Name")),
                                              DataColumn(
                                                label: Text("Purpose"),
                                              ),
                                              DataColumn(label: Text("Amount")),
                                              DataColumn(label: Text("Mode")),
                                              DataColumn(
                                                label: Text("Reference ID"),
                                              ),
                                              DataColumn(
                                                label: Text("Donation ID"),
                                              ),
                                              DataColumn(
                                                label: Text("Payment Status"),
                                              ),
                                              DataColumn(
                                                label: Text("Invoice"),
                                              ),
                                            ],
                                            rows:
                                                widget.donationHistory.map<
                                                  DataRow
                                                >((donation) {
                                                  String formattedDate = '';
                                                  if (donation["created_at"] !=
                                                      null) {
                                                    DateTime
                                                    dateTime = DateTime.parse(
                                                      donation["created_at"],
                                                    );
                                                    formattedDate = DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(
                                                      dateTime,
                                                    ); // Format to 'YYYY-MM-DD'
                                                  }
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(formattedDate),
                                                      ), // Use the formatted date
                                                      DataCell(
                                                        Text(
                                                          donation["name"] ??
                                                              "-",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          donation["donation_purpose"] ??
                                                              "-",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          "₹${donation["amount"] ?? "0"}",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          donation["payment_mode"] ??
                                                              "Razorpay",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          donation["razorpay_payment_id"] ??
                                                              "-",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          donation["razorpay_order_id"] ??
                                                              "-",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          donation["status"] ??
                                                              "-",
                                                        ),
                                                      ),
                                                      DataCell(
                                                        ElevatedButton.icon(
                                                          onPressed: () {
                                                            if (donation["id"] !=
                                                                null) {
                                                              downloadInvoice(
                                                                donation["id"]
                                                                    .toString(),
                                                              );
                                                            } else {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "Invalid donation ID. Cannot download invoice.",
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.download,
                                                            size: 16,
                                                          ),
                                                          label: Text(
                                                            "Download",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Widget buildStyledTextField(String label, String hint) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8.0),
  //     child: TextField(
  //        controller: controller,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         hintText: hint,
  //         border: OutlineInputBorder(),
  //         filled: true,
  //         fillColor: Colors.white,
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.red.shade700, width: 2),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.red.shade300, width: 1),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildStyledTextField(String label, TextEditingController controller) {
    bool enabled = true; // Default to enabled
    bool readOnly = false; // Default to not read-only

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller, // ✅ Use the correct controller
        enabled: enabled, // Set enabled state
        readOnly: readOnly, // Set read-only state
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade300, width: 1),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> options,
    String initialValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: initialValue, // Prefill existing value
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
        onChanged: (value) {
          documentType = value!;
        },
      ),
    );
  }
}

class SideBarMenu extends StatelessWidget {
  final Function(String) onSelect;
  final String selectedPage;
  final String mobile;
  final VoidCallback signOut;

  SideBarMenu({
    required this.onSelect,
    required this.selectedPage,
    required this.mobile,
    required this.signOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.red.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.red.shade200),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Keep text left-aligned
              children: [
                Text(
                  "Welcome $mobile",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10), // Spacing between text and image
                Center(
                  // Center the image inside the drawer
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      50,
                    ), // Optional: Circular Image
                    child: Image.asset(
                      '../../assets/andrej.jpg',
                      width: 80, // Set width
                      height: 80, // Set height
                      fit: BoxFit.cover, // Ensure proper fit
                    ),
                  ),
                ),
              ],
            ),
          ),

          buildDrawerButton("Dashboard"),
          buildDrawerButton("Update Profile"),
          buildDrawerButton("Tax Detail Update"),
          buildDrawerButton("Donation history"),
          buildDrawerButton("Sign Out"),
        ],
      ),
    );
  }

  Widget buildDrawerButton(String title) {
    bool isActive = selectedPage == title;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? Colors.red.shade200 : Colors.red.shade600,
          foregroundColor: isActive ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          if (title == "Sign Out") {
            signOut();
          } else {
            onSelect(title);
          }
        },
        child: Align(
          alignment: Alignment.centerLeft, // Align content to the left
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
