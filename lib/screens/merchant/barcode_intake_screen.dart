import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../state/app_state.dart';

class BarcodeIntakeScreen extends StatefulWidget {
  final AppState state;

  const BarcodeIntakeScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<BarcodeIntakeScreen> createState() => _BarcodeIntakeScreenState();
}

class _BarcodeIntakeScreenState extends State<BarcodeIntakeScreen> {
  final TextEditingController _barcodeCtrl = TextEditingController(text: "8901030383821");
  final TextEditingController _titleCtrl = TextEditingController(text: "Amul Taaza Milk 500ml");
  final TextEditingController _priceCtrl = TextEditingController(text: "32");
  final TextEditingController _qtyCtrl = TextEditingController(text: "12");
  String selectedCategory = "Dairy & Eggs";

  // Pre-configured master barcode mock database (EAN-13 lookup)
  final Map<String, Map<String, String>> globalSkuCatalog = {
    "8901030383821": {
      "title": "Amul Taaza Homogenised Toned Milk",
      "category": "Dairy & Eggs",
      "price": "32",
      "unit": "500 ml pouch",
      "emoji": "🥛"
    },
    "8901491101837": {
      "title": "Modern 100% Whole Wheat Bread",
      "category": "Bakery",
      "price": "45",
      "unit": "400g pack",
      "emoji": "🍞"
    },
    "8901725181222": {
      "title": "Farm Fresh Farm Brown Eggs (Pack of 6)",
      "category": "Dairy & Eggs",
      "price": "55",
      "unit": "6 pcs",
      "emoji": "🥚"
    },
    "8901058852219": {
      "title": "Fortune Sunlite Refined Sunflower Oil",
      "category": "Oils & Staples",
      "price": "135",
      "unit": "1 Litre pouch",
      "emoji": "🌻"
    },
    "8901262010017": {
      "title": "Tata Salt Vacuum Evaporated Iodized",
      "category": "Oils & Staples",
      "price": "28",
      "unit": "1 kg",
      "emoji": "🧂"
    },
  };

  void _onBarcodeScanSimulated(String code) {
    _barcodeCtrl.text = code;
    if (globalSkuCatalog.containsKey(code)) {
      final match = globalSkuCatalog[code]!;
      setState(() {
        _titleCtrl.text = match["title"]!;
        _priceCtrl.text = match["price"]!;
        selectedCategory = match["category"]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Barcode match: ${match['title']}"),
          backgroundColor: const Color(0xFF00B074),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  Future<void> _processVoicePhrase(String phrase) async {
    try {
      final res = await http.post(
        Uri.parse("http://localhost:8080/v1/merchants/catalog/voice-parse"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"voice_transcript": phrase}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["parsed"] != null) {
          final p = data["parsed"];
          setState(() {
            _titleCtrl.text = p["title"] ?? _titleCtrl.text;
            _priceCtrl.text = (p["price"] ?? 0.0).toString();
            _qtyCtrl.text = (p["quantity"] ?? 10).toString();
            if (p["category"] != null) selectedCategory = p["category"];
            _barcodeCtrl.text = p["barcode"] ?? _barcodeCtrl.text;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🎙️ Voice parsed: ${p['title']} (${p['quantity']}x @ ₹${p['price']})"),
              backgroundColor: const Color(0xFF00B074),
              duration: const Duration(milliseconds: 1500),
            ),
          );
          return;
        }
      }
    } catch (_) {}

    // Fallback parsing
    if (phrase.toLowerCase().contains("maggi")) {
      setState(() {
        _titleCtrl.text = "Maggi 2-Minute Masala Instant Noodles";
        _priceCtrl.text = "56";
        _qtyCtrl.text = "10";
        selectedCategory = "Instant Food";
        _barcodeCtrl.text = "8901058852219";
      });
    } else if (phrase.toLowerCase().contains("atta") || phrase.toLowerCase().contains("aashirvaad")) {
      setState(() {
        _titleCtrl.text = "Aashirvaad Shudh Chakki Atta (5kg)";
        _priceCtrl.text = "245";
        _qtyCtrl.text = "5";
        selectedCategory = "Oils & Staples";
        _barcodeCtrl.text = "8901030383830";
      });
    } else if (phrase.toLowerCase().contains("fortune")) {
      setState(() {
        _titleCtrl.text = "Fortune Sunlite Refined Sunflower Oil";
        _priceCtrl.text = "135";
        _qtyCtrl.text = "10";
        selectedCategory = "Oils & Staples";
        _barcodeCtrl.text = "8901058852219";
      });
    } else if (phrase.toLowerCase().contains("milk") || phrase.toLowerCase().contains("amul")) {
      setState(() {
        _titleCtrl.text = "Amul Taaza Homogenised Toned Milk";
        _priceCtrl.text = "32";
        _qtyCtrl.text = "20";
        selectedCategory = "Dairy & Eggs";
        _barcodeCtrl.text = "8901030383821";
      });
    }
  }

  void _openVoiceIntakeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text("🎙️", style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text("Speak to Add Stock", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Say what you want to add (e.g. 'Add 10 packets of Maggi Noodles at ₹56' or 'Add 10 Fortune Oil at ₹135')",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text("Tap a voice phrase sample to test:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildVoiceChip(ctx, "Add 10 packets of Maggi 2-Minute Noodles at ₹56"),
              _buildVoiceChip(ctx, "Add 20 packets of Amul Taaza Milk at ₹32"),
              _buildVoiceChip(ctx, "Add 5 packets of Aashirvaad Shudh Chakki Atta 5kg at ₹245"),
              _buildVoiceChip(ctx, "Add 10 packets of Fortune Sunflower Oil 1 Litre at ₹135"),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceChip(BuildContext ctx, String phrase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.mic, color: Color(0xFF00B074), size: 18),
        label: Text(phrase, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(ctx);
          _processVoicePhrase(phrase);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Add Items by Scanning Barcode",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera Viewfinder Simulator Box (REQ-MER-01)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF00B074), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Container(
                        height: 2,
                        width: 200,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    child: Text(
                      "Point phone camera at item barcode",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Voice-to-Stock Catalog Intake Assist (REQ-V2-MER-01)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.mic, color: Color(0xFF00B074)),
                label: const Text(
                  "🎙️ Speak to Add Stock (Voice-to-Stock)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: _openVoiceIntakeDialog,
              ),
            ),
            const SizedBox(height: 14),

            // Quick Scan Sample Buttons
            const Text("Try scanning sample items:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: globalSkuCatalog.entries.map((e) {
                return ActionChip(
                  label: Text("${e.value['emoji']} ${e.value['title']!.split(' ').take(2).join(' ')}", style: const TextStyle(fontSize: 11)),
                  onPressed: () => _onBarcodeScanSimulated(e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Item Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _barcodeCtrl,
                    decoration: const InputDecoration(labelText: "Barcode Number", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Selling Price (₹)", border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Quantity in Shop", border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sync to Shelf Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                label: const Text("Put on Shelf (Sell to Nearby Customers)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final code = _barcodeCtrl.text;
                  final match = globalSkuCatalog[code];
                  final emoji = match?["emoji"] ?? "📦";
                  final unit = match?["unit"] ?? "Unit";

                  widget.state.intakeBarcodeItem(
                    barcode: code,
                    title: _titleCtrl.text,
                    category: selectedCategory,
                    price: double.tryParse(_priceCtrl.text) ?? 30.0,
                    quantity: int.tryParse(_qtyCtrl.text) ?? 10,
                    unit: unit,
                    emoji: emoji,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Item added to your shop shelf!"),
                      backgroundColor: Color(0xFF00B074),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
