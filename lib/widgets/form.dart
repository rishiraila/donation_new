import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationForm extends StatefulWidget {
  const DonationForm({super.key});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  late Razorpay _razorpay;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController documentNumberController = TextEditingController();
  String? selectedDocumentType = "Aadhar";
  String? orderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final data = {
      "razorpay_payment_id": response.paymentId,
      "razorpay_order_id": orderId ?? "",
      "razorpay_signature": response.signature ?? "",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "amount": amountController.text.trim(),
      "donation_purpose": purposeController.text.trim(),
      "area": areaController.text.trim(),
      "city": cityController.text.trim(),
      "pincode": pincodeController.text.trim(),
      "document_type": selectedDocumentType,
      "document_number": documentNumberController.text.trim(),
      "address": addressController.text.trim(),
      "email": emailController.text.trim(),
    };

    final responseApi = await http.post(
      Uri.parse("https://backend-owxp.onrender.com/api/donations/verify-payment"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (responseApi.statusCode == 200) {
      _showDialog("Success", "Thank you for your donation of ₹${amountController.text}!");
    } else {
      _showDialog("Error", "Payment was successful but storing donation failed.");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showDialog("Payment Failed", response.message ?? "Unknown error");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
  }

  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.post(
      Uri.parse("https://backend-owxp.onrender.com/api/donations/create-order"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "mobile": mobileController.text,
        "amount": amountController.text,
        "donation_purpose": purposeController.text,
        "address": addressController.text,
        "area": areaController.text,
        "city": cityController.text,
        "pincode": pincodeController.text,
        "document_type": selectedDocumentType,
        "document_number": documentNumberController.text,
        "email": emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["order"]?["id"] != null) {
        orderId = data["order"]["id"];
        openCheckout();
      } else {
        _showDialog("Error", "Order ID not found.");
      }
    } else {
      _showDialog("Error", "Order creation failed.");
    }
  }

  void openCheckout() {
    if (orderId == null || orderId!.isEmpty) {
      _showDialog("Error", "Order ID is missing.");
      return;
    }

    _razorpay.open({
      "key": "rzp_test_K2K20arHghyhnD",
      "amount": int.parse(amountController.text) * 100,
      "name": nameController.text,
      "description": "Donation",
      "order_id": orderId,
      "prefill": {
        "contact": mobileController.text,
        "email": emailController.text,
      },
      "external": {
        "wallets": ["paytm"],
      }
    });
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Center(
    child: Container(
      width: 1200,
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (resized)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/jaikishan.jpg',
              height: 340,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 40),

          // Form Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '“The meaning of life is to find your gift. The purpose of life is to give it away.”',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 18,
                    children: [
                      _buildField(nameController, "Name"),
                      _buildField(amountController, "Amount", inputType: TextInputType.number),
                      _buildField(mobileController, "Phone", inputType: TextInputType.phone),
                      _buildField(emailController, "Email", inputType: TextInputType.emailAddress),
                      _buildField(purposeController, "Purpose"),
                      _buildField(addressController, "Address"),
                      _buildField(areaController, "Area"),
                      _buildField(cityController, "City"),
                      _buildField(pincodeController, "Pincode", inputType: TextInputType.number),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          value: selectedDocumentType,
                          decoration: const InputDecoration(
                            labelText: "Document Type",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: ["Aadhar", "PAN", "Passport"].map((doc) {
                            return DropdownMenuItem(value: doc, child: Text(doc));
                          }).toList(),
                          onChanged: (value) => setState(() => selectedDocumentType = value),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                      _buildField(documentNumberController, "Document Number"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  ),
                  child: const Text(
                    'Donate',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}