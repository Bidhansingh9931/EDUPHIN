import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../counselor/counselor_models.dart' as counselor;
import '../staff/staff_dashboard/staff_models.dart' as staff;
import '../student/student_virtual_id_model.dart';
import '../accountant/dashboard/accountant_dashboard_model.dart';
import '../teacher/dashboard/teacher_profile_model.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class PdfService {
  static Future<void> generateAndPrintIdCard(dynamic data) async {
    final doc = pw.Document();
    
    String? photoUrl;
    String? logoUrl;
    String name = "N/A";
    String? position;
    String? empId;
    String? joinDate;
    String? instName;
    String? phone;
    String? email;
    String? address;
    String? emergency;
    String? employmentType;

    if (data is counselor.CounselorVirtualIdCardData) {
      photoUrl = data.photoUrl;
      logoUrl = data.instituteLogo;
      name = data.name;
      position = data.position;
      empId = data.employeeId;
      joinDate = data.joiningDate;
      instName = data.instituteName;
      phone = data.phone;
      email = data.email;
      address = data.fullAddress;
      emergency = "${data.emergencyContactName ?? ""} ${data.emergencyContactPhone ?? ""}".trim();
      if (emergency.isEmpty) emergency = null;
      employmentType = data.employmentType;
    } else if (data is staff.StaffVirtualIdCardData) {
      photoUrl = data.userDetail.photo;
      logoUrl = data.instituteLogo;
      name = data.user.name;
      position = data.roleName;
      empId = data.user.id.toString();
      joinDate = data.userDetail.dateOfJoining;
      instName = data.instituteName;
    } else if (data is StudentVirtualIdData) {
      photoUrl = data.student?.profileImage;
      logoUrl = data.instituteLogo;
      name = "${data.student?.firstName ?? ""} ${data.student?.lastName ?? ""}";
      position = "STUDENT";
      empId = data.student?.studentRollNo;
      joinDate = data.student?.academicYear;
      instName = data.instituteName;
    } else if (data is AccountantVirtualIdCardData) {
      photoUrl = data.photoUrl;
      logoUrl = data.instituteLogo;
      name = data.name;
      position = data.position ?? "ACCOUNTANT";
      empId = data.employeeId;
      joinDate = data.joiningDate;
      instName = data.instituteName;
      phone = data.phone;
      email = data.email;
      address = data.fullAddress;
      emergency = "${data.emergencyContactName ?? ""} ${data.emergencyContactPhone ?? ""}";
      employmentType = data.employmentType;
    } else if (data is VirtualIdCardData) {
      photoUrl = data.photoUrl;
      logoUrl = data.instituteLogo;
      name = data.name;
      position = data.position ?? "TEACHER";
      empId = data.employeeId;
      joinDate = data.joiningDate;
      instName = data.instituteName;
      phone = data.phone;
      email = data.email;
      address = data.fullAddress;
      emergency = "${data.emergencyContactName ?? ""} ${data.emergencyContactPhone ?? ""}".trim();
      if (emergency.isEmpty) emergency = null;
      employmentType = data.employmentType;
    }

    final profileImage = await _netImage(ApiService.getStorageUrl(photoUrl));
    final instituteLogo = await _netImage(ApiService.getStorageUrl(logoUrl));
    
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                // Front Side
                _buildPdfCardFront(
                  instName: instName,
                  logo: instituteLogo,
                  profile: profileImage,
                  name: name,
                  position: position,
                  empId: empId,
                  joinDate: joinDate,
                  employmentType: employmentType,
                ),
                // Back Side
                _buildPdfCardBack(
                  phone: phone,
                  email: email,
                  address: address,
                  emergency: emergency,
                  empId: empId,
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  static pw.Widget _buildPdfCardFront({
    String? instName,
    pw.ImageProvider? logo,
    pw.ImageProvider? profile,
    required String name,
    String? position,
    String? empId,
    String? joinDate,
    String? employmentType,
  }) {
    return pw.Container(
      width: 200,
      height: 320,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF2C3550),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
      ),
      child: pw.Column(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              children: [
                if (logo != null)
                  pw.Container(
                    width: 25,
                    height: 25,
                    margin: const pw.EdgeInsets.only(right: 5),
                    child: pw.Image(logo),
                  ),
                pw.Expanded(
                  child: pw.Text(
                    instName?.toUpperCase() ?? "EDUPHIN ACADEMY",
                    style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text("${position ?? 'COUNSELOR'} ID".toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 10),
          if (profile != null)
            pw.Container(
              width: 70,
              height: 70,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                image: pw.DecorationImage(image: profile, fit: pw.BoxFit.cover),
                border: pw.Border.all(color: PdfColors.white, width: 2),
              ),
            ),
          pw.SizedBox(height: 10),
          pw.Text(name.toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text((position ?? "ACCOUNTANT").toUpperCase(), style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
          pw.Spacer(),
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF3D4763),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                _pdfIdRowSmall("POSITION", position ?? "N/A"),
                _pdfIdRowSmall("EMPLOYEE ID", empId ?? "N/A"),
                _pdfIdRowSmall("EMPLOYMENT", employmentType ?? "N/A"),
                _pdfIdRowSmall("JOINING", joinDate ?? "N/A"),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text("Authorized Signature", style: const pw.TextStyle(color: PdfColors.white, fontSize: 6)),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfCardBack({
    String? phone,
    String? email,
    String? address,
    String? emergency,
    String? empId,
  }) {
    return pw.Container(
      width: 200,
      height: 320,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF2C3550),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
      ),
      child: pw.Column(
        children: [
          pw.SizedBox(height: 30),
          pw.Container(
            width: 100,
            height: 100,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: empId ?? "N/A",
              drawText: false,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            margin: const pw.EdgeInsets.all(10),
            padding: const pw.EdgeInsets.all(8),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF3D4763),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfBackRow("Phone", phone ?? "N/A"),
                _pdfBackRow("Email", email ?? "N/A"),
                _pdfBackRow("Address", address ?? "N/A"),
                _pdfBackRow("Emergency", emergency ?? "N/A"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfIdRowSmall(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 6)),
          pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 6, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _pdfBackRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.white, fontSize: 6)),
          pw.Text(value, style: pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static Future<pw.ImageProvider?> _netImage(String? url) async {
    if (url == null || url.isEmpty || url.contains("null")) return null;
    try {
      final token = await ApiService.getToken();
      final bool isStorageUrl = url.contains('/storage/');
      
      final Map<String, String> headers = {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
        'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      };

      // Don't send Authorization header for public storage URLs as it can cause 403 Forbidden
      if (!isStorageUrl && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      } else {
        print("PDF Image Error: ${response.statusCode} for $url");
      }
    } catch (e) {
      print("Error loading image for PDF: $e");
    }
    return null;
  }

  static Future<void> generateSalaryPdf(dynamic salary, String? amountInWords) async {
    final doc = pw.Document();

    // Map different model fields to a unified structure
    String? month;
    String? amount;
    String? status;
    String? paymentDate;

    if (salary is Salary) {
      month = salary.month;
      amount = salary.amount;
      status = salary.status;
      paymentDate = salary.paymentDate;
    } else if (salary is counselor.Salary) {
      month = salary.month;
      amount = salary.amount;
      status = salary.status;
      paymentDate = salary.paymentDate;
    } else if (salary is staff.Salary) {
      month = salary.month;
      amount = salary.amount;
      status = salary.status;
      paymentDate = null; // staff.Salary doesn't have paymentDate
    }

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text("SALARY SLIP", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
                pw.Center(child: pw.Text("For the month of ${month ?? ''}")),
                pw.Divider(height: 30),
                _salaryRow("Basic Salary", "₹${amount ?? '0'}"),
                _salaryRow("Status", (status ?? 'N/A').toUpperCase()),
                _salaryRow("Payment Date", paymentDate ?? 'N/A'),
                pw.Divider(height: 30),
                pw.Text("TOTAL NET SALARY", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                pw.Text("₹${amount ?? '0'}", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 10),
                pw.Text("Amount in words: ${amountInWords ?? ''}", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  static pw.Widget _salaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static Future<void> generateAdmitCardPdf(dynamic details) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (details['institute'] != null) ...[
                pw.Center(
                  child: pw.Text(
                    details['institute']['name']?.toString().toUpperCase() ?? '',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(child: pw.Text(details['institute']['address'] ?? '')),
                pw.SizedBox(height: 20),
              ],
              pw.Center(
                child: pw.Text("ADMIT CARD", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Student Information", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(),
              _pdfRow("Student Name", details['student']?['user']?['name']?.toString() ?? 'N/A'),
              _pdfRow("Roll Number", details['student']?['roll_no']?.toString() ?? 'N/A'),
              _pdfRow("Class / Section", "${details['student']?['class']?['name'] ?? ''} - ${details['student']?['section']?['name'] ?? ''}"),
              pw.SizedBox(height: 20),
              pw.Text("Paper Schedule", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Subject", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Time", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("Venue", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...(details['papers'] as List? ?? []).map((paper) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(paper['subject']?['name'] ?? 'N/A')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(paper['date'] ?? 'N/A')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("${paper['start_time'] ?? ''} - ${paper['end_time'] ?? ''}")),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(paper['venue'] ?? 'N/A')),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label)),
          pw.Text(": "),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
