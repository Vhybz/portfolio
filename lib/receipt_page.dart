import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _invoiceNumberController = TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
  String _currency = 'GHS';
  
  String _documentSelection = 'RECEIPT';
  
  final List<Map<String, dynamic>> _items = [
    {'name': 'Development Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Design Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Consultation Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Testing Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Deployment Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Maintenance Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Hosting/Server Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Integration Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Revision Fee', 'price': 0.0, 'qty': 1},
    {'name': 'Urgency/Rush Fee', 'price': 0.0, 'qty': 1},
  ];

  double get _total => _items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  void _addItem() {
    setState(() {
      _items.add({'name': '', 'price': 0.0, 'qty': 1});
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (_items.length > 1) {
        _items.removeAt(index);
      } else {
        _items[0] = {'name': '', 'price': 0.0, 'qty': 1};
      }
    });
  }

  void _clearZeroItems() {
    setState(() {
      _items.removeWhere((item) => item['price'] == 0);
      if (_items.isEmpty) {
        _items.add({'name': '', 'price': 0.0, 'qty': 1});
      }
    });
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final random = math.Random();
    final hausaQuotes = [
      'Allah Ya saka da alheri. (May Allah reward you with goodness)',
      'Allah Ya ba da sa’a. (May Allah grant success)',
      'Allah Ya kara arziki. (May Allah increase your wealth)',
    ];
    final christianQuotes = [
      'The Lord bless you and keep you. (Numbers 6:24)',
      'May God supply all your needs according to His riches. (Phil 4:19)',
      'To God be the glory for this partnership.',
    ];
    final ghanaQuotes = [
      'Nyame nhyira wo. (God bless you)',
      'Medaase pii. (Thank you very much)',
      'Aba mu awie. (It is well done)',
    ];

    final hausaQ = hausaQuotes[random.nextInt(hausaQuotes.length)];
    final christianQ = christianQuotes[random.nextInt(christianQuotes.length)];
    final ghanaQ = ghanaQuotes[random.nextInt(ghanaQuotes.length)];

    pw.ImageProvider? signatureImage;
    pw.ImageProvider? logoImage;
    
    try {
      signatureImage = await imageFromAssetBundle('assets/Screenshot 2026-05-08 184734.png');
    } catch (e) {
      debugPrint('Error loading signature: $e');
    }

    try {
      logoImage = await imageFromAssetBundle('assets/images/rev.jpg');
    } catch (e) {
      debugPrint('Error loading logo: $e');
    }

    final billedItems = _items.where((item) => item['price'] > 0).toList();
    if (billedItems.isEmpty && _items.isNotEmpty) {
      billedItems.add(_items.first);
    }

    if (_documentSelection == 'RECEIPT' || _documentSelection == 'BOTH') {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => _buildInvoiceLayout(logoImage, signatureImage, hausaQ, christianQ, ghanaQ, billedItems),
        ),
      );
    }

    if (_documentSelection == 'CONTRACT' || _documentSelection == 'BOTH') {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(40),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ),
          build: (pw.Context context) => _buildContractLayout(logoImage, signatureImage, billedItems),
        ),
      );
    }

    return pdf.save();
  }

  List<pw.Widget> _buildInvoiceLayout(pw.ImageProvider? logo, pw.ImageProvider? signature, String hausa, String christian, String ghana, List<Map<String, dynamic>> items) {
    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  margin: const pw.EdgeInsets.only(right: 15),
                  child: pw.ClipRRect(
                    horizontalRadius: 10,
                    verticalRadius: 10,
                    child: pw.Image(logo, fit: pw.BoxFit.cover),
                  ),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TECH RAVEN', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.red900, letterSpacing: 2)),
                  pw.Text('Software Excellence & Digital Strategy', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                  pw.SizedBox(height: 10),
                  pw.Text('Sunyani, Ghana', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('+233 559 650 921 | techraven11@gmail.com', style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const pw.BoxDecoration(color: PdfColors.red900),
                child: pw.Text('INVOICE', style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BILL TO:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.SizedBox(height: 5),
                pw.Text(_clientController.text.isEmpty ? '[Client Name]' : _clientController.text, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                if (_phoneController.text.isNotEmpty) pw.Text('Phone: ${_phoneController.text}', style: const pw.TextStyle(fontSize: 10)),
                if (_addressController.text.isNotEmpty) pw.Text('Address: ${_addressController.text}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(children: [pw.Text('Invoice #: ', style: pw.TextStyle(color: PdfColors.grey700)), pw.Text(_invoiceNumberController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
              pw.Row(children: [pw.Text('Payment Due: ', style: pw.TextStyle(color: PdfColors.grey700)), pw.Text(DateFormat('MMM dd, yyyy').format(DateTime.now().add(const Duration(days: 15))), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      pw.TableHelper.fromTextArray(
        border: null,
        headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
        headers: ['Description', 'Qty', 'Price', 'Total'],
        data: items.map((item) => [item['name'], item['qty'].toString(), '$_currency ${item['price'].toStringAsFixed(2)}', '$_currency ${(item['price'] * item['qty']).toStringAsFixed(2)}']).toList(),
      ),
      pw.SizedBox(height: 30),
      pw.Row(
        children: [
          pw.Spacer(flex: 5),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal:'), pw.Text('$_currency ${(_total).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
                pw.Divider(),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.red900,
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TOTAL:', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)), pw.Text('$_currency ${_total.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))]),
                ),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 40),
      pw.Container(
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border(left: pw.BorderSide(color: PdfColors.red900, width: 4))),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('TERMS & CONDITIONS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
            pw.SizedBox(height: 8),
            pw.Text('• 40% initial deposit required to commence work.', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('• Balance due upon project completion.', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ),
      pw.Spacer(),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            children: [
              pw.SizedBox(height: 60),
              pw.SizedBox(width: 150, child: pw.Divider(color: PdfColors.grey400)),
              pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Acknowledgement of Receipt', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
            ],
          ),
          pw.Column(
            children: [
              if (signature != null) pw.Image(signature, width: 120) else pw.SizedBox(height: 60),
              pw.SizedBox(width: 150, child: pw.Divider()),
              pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Tech Raven Administration', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Column(
          children: [
            pw.Text(ghana, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text(hausa, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Text(christian, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      ),
    ];
  }

  List<pw.Widget> _buildContractLayout(pw.ImageProvider? logo, pw.ImageProvider? signature, List<Map<String, dynamic>> items) {
    final sectionTitleStyle = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red900);
    final bodyStyle = pw.TextStyle(fontSize: 10, height: 1.5);
    
    return [
      pw.Center(
        child: pw.Column(
          children: [
            if (logo != null) pw.Image(logo, width: 80),
            pw.SizedBox(height: 10),
            pw.Text('MASTER SERVICES AGREEMENT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
            pw.Text('Contract Ref: ${_invoiceNumberController.text}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
      pw.Text('This Master Services Agreement (the "Agreement") is made effective as of ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}, by and between:', style: bodyStyle),
      pw.SizedBox(height: 20),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SERVICE PROVIDER:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text('TECH RAVEN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Address: Sunyani, Ghana', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Contact: +233 559 650 921', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Email: techraven11@gmail.com', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CLIENT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(_clientController.text.isEmpty ? '[CLIENT NAME]' : _clientController.text.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Address: ${_addressController.text.isEmpty ? "[Not Provided]" : _addressController.text}', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Phone: ${_phoneController.text.isEmpty ? "[Not Provided]" : _phoneController.text}', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 30),
      pw.Text('1. PREAMBLE', style: sectionTitleStyle),
      pw.Paragraph(text: 'WHEREAS, the Provider is engaged in the business of providing professional software development, design, and digital strategy services; and WHEREAS, the Client desires to retain the Provider to perform certain services as described herein; NOW, THEREFORE, in consideration of the mutual covenants and promises contained herein, the parties agree as follows:', style: bodyStyle),
      
      pw.SizedBox(height: 20),
      pw.Text('2. SCOPE OF SERVICES', style: sectionTitleStyle),
      pw.Paragraph(text: 'The Provider agrees to provide the following services (the "Project"):', style: bodyStyle),
      ...items.map((item) => pw.Bullet(text: '${item["name"]} - ${item["qty"]} unit(s)', style: bodyStyle)),
      pw.Paragraph(text: 'Any services not explicitly listed above shall be considered out of scope and may require a separate agreement or a change order resulting in additional fees.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('3. PROJECT TIMELINE & MILESTONES', style: sectionTitleStyle),
      pw.Paragraph(text: 'The Project will commence upon receipt of the initial deposit and all necessary client materials. While the Provider aims for timely delivery, any estimated completion dates provided are subject to change based on feedback cycles, client delays, or unforeseen technical challenges.', style: bodyStyle),
      
      pw.SizedBox(height: 20),
      pw.Text('4. COMPENSATION & PAYMENT TERMS', style: sectionTitleStyle),
      pw.Paragraph(text: 'Total Project Fee: $_currency ${_total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      pw.Bullet(text: 'Initial Deposit: A non-refundable deposit of 40% ($_currency ${(_total * 0.4).toStringAsFixed(2)}) is required to secure the Provider\'s resources and initiate work.', style: bodyStyle),
      pw.Bullet(text: 'Milestone Payments: Periodic payments may be requested based on project progress (e.g., 30% upon UI/UX approval).', style: bodyStyle),
      pw.Bullet(text: 'Final Balance: The remaining balance is due immediately upon project completion and prior to final deployment or asset handover.', style: bodyStyle),
      pw.Paragraph(text: 'Late payments exceeding seven (7) business days will incur a late fee of 5% of the outstanding balance per week.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('5. CLIENT RESPONSIBILITIES', style: sectionTitleStyle),
      pw.Paragraph(text: 'The Client agrees to provide timely feedback, required content (text, images, branding), and necessary credentials (hosting, API keys). Failure to provide these within five (5) business days of a request may result in project suspension or rescheduling fees.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('6. INTELLECTUAL PROPERTY RIGHTS', style: sectionTitleStyle),
      pw.Paragraph(text: 'Ownership: Upon final payment and project clearance, the Provider transfers full ownership and intellectual property rights of the custom-developed assets to the Client. Pre-existing code libraries, third-party tools, and the Provider\'s proprietary methodology remain the property of the Provider.', style: bodyStyle),
      pw.Paragraph(text: 'Portfolio Usage: The Client grants the Provider a perpetual, royalty-free license to display the project in the Provider\'s professional portfolio and marketing materials.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('7. CONFIDENTIALITY', style: sectionTitleStyle),
      pw.Paragraph(text: 'Both parties agree to treat all business information, trade secrets, and technical data disclosed during the project as strictly confidential. This obligation extends for a period of three (3) years following the termination of this Agreement.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('8. WARRANTIES & MAINTENANCE', style: sectionTitleStyle),
      pw.Paragraph(text: 'The Provider warrants that the software will perform substantially as described for a period of thirty (30) days post-launch. This warranty excludes issues caused by third-party updates (e.g., Apple/Android OS updates, API changes) or client-side modifications.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('9. LIMITATION OF LIABILITY', style: sectionTitleStyle),
      pw.Paragraph(text: 'The Provider\'s total liability for any claim arising out of this Agreement shall not exceed the total amount of fees paid by the Client to the Provider under this Agreement.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('10. TERMINATION', style: sectionTitleStyle),
      pw.Paragraph(text: 'Either party may terminate this agreement with seven (7) days written notice. If terminated by the Client, the Client shall pay for all work performed up to the termination date. The initial deposit remains non-refundable.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('11. FORCE MAJEURE', style: sectionTitleStyle),
      pw.Paragraph(text: 'Neither party shall be liable for delays or failures in performance resulting from acts beyond their reasonable control, including but not limited to acts of God, war, strikes, or internet service provider failures.', style: bodyStyle),

      pw.SizedBox(height: 20),
      pw.Text('12. GOVERNING LAW & DISPUTE RESOLUTION', style: sectionTitleStyle),
      pw.Paragraph(text: 'This Agreement shall be governed by the laws of Ghana. Any disputes shall first be attempted to be resolved via mediation in Sunyani before pursuing legal action.', style: bodyStyle),

      pw.SizedBox(height: 40),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            children: [
              pw.SizedBox(height: 60),
              pw.SizedBox(width: 180, child: pw.Divider()),
              pw.Text('CLIENT SIGNATURE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              pw.Text('Date: ____________________', style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
          pw.Column(
            children: [
              if (signature != null) pw.Image(signature, width: 120) else pw.SizedBox(height: 60),
              pw.SizedBox(width: 180, child: pw.Divider()),
              pw.Text('PROVIDER SIGNATURE (TECH RAVEN)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              pw.Text('Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PORTAL GENERATOR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          _documentSelector(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.5,
            colors: isDark 
              ? [const Color(0xFF150202), const Color(0xFF050505)]
              : [const Color(0xFFFEF2F2), const Color(0xFFF9FAFB)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.fromLTRB(40, 100, 20, 40),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(5) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Theme.of(context).dividerColor.withAlpha(10)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Configuration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            _currencyDropdown(),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _inputLabel('CLIENT / COMPANY NAME'),
                        TextFormField(
                          controller: _clientController,
                          decoration: _inputDecoration('Enter name'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        _inputLabel('CLIENT PHONE NUMBER'),
                        TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration('e.g. +233 ...'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        _inputLabel('CLIENT ADDRESS'),
                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration('Enter location/address'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        _inputLabel('IDENTIFIER (INV/CTR)'),
                        TextFormField(
                          controller: _invoiceNumberController,
                          decoration: _inputDecoration('TR-ID-001'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PROJECT ITEMS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: _clearZeroItems,
                                  child: const Text('Clean Up', style: TextStyle(color: Colors.orange)),
                                ),
                                IconButton(onPressed: _addItem, icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE50914))),
                              ],
                            ),
                          ],
                        ),
                        ..._items.asMap().entries.map((entry) => _buildItemEntry(entry.key, entry.value)),
                        const SizedBox(height: 40),
                        _buildTotalPreview(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (width > 1000)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 100, 40, 40),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
                  clipBehavior: Clip.antiAlias,
                  child: PdfPreview(
                    build: (format) => _generatePdf(format),
                    canChangePageFormat: false,
                    loadingWidget: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _documentSelector() {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE50914).withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _documentSelection,
          dropdownColor: const Color(0xFF150202),
          style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12),
          onChanged: (String? newValue) {
            setState(() {
              _documentSelection = newValue!;
            });
          },
          items: <String>['RECEIPT', 'CONTRACT', 'BOTH']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _currencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFE50914).withAlpha(10), borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        value: _currency,
        underline: const SizedBox(),
        onChanged: (v) => setState(() => _currency = v!),
        items: ['GHS', r'$', '£', '€'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }

  Widget _buildItemEntry(int index, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: TextFormField(key: ValueKey('name_$index'), initialValue: item['name'], decoration: _inputDecoration('Item'), onChanged: (v) => setState(() => item['name'] = v))),
          const SizedBox(width: 10),
          Expanded(flex: 1, child: TextFormField(key: ValueKey('price_$index'), initialValue: item['price'] == 0 ? '' : item['price'].toString(), decoration: _inputDecoration('Price'), keyboardType: TextInputType.number, onChanged: (v) => setState(() => item['price'] = double.tryParse(v) ?? 0.0))),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeItem(index)),
        ],
      ),
    );
  }

  Widget _buildTotalPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE50914).withAlpha(15), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Investment:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('$_currency ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFE50914))),
        ],
      ),
    );
  }

  Widget _inputLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Theme.of(context).dividerColor.withAlpha(5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8));
}
