import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/student/student_virtual_id_model.dart';
import 'package:flutter/material.dart';


class ViewVirtualIdCard extends StatelessWidget {
  const ViewVirtualIdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentCardPage();
  }
}

class StudentCardPage extends StatefulWidget {
  const StudentCardPage({super.key});

  @override
  State<StudentCardPage> createState() => _StudentCardPageState();
}

class _StudentCardPageState extends State<StudentCardPage> {
  bool isLoading = true;
  String? errorMessage;
  StudentVirtualIdData? idData;

  @override
  void initState() {
    super.initState();
    _fetchIdCardData();
  }

  Future<void> _fetchIdCardData() async {
    try {
      final data = await ApiService.getStudentVirtualIdCard();
      setState(() {
        idData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF071233),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF071233),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _fetchIdCardData();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    final student = idData?.student;

    return Scaffold(
      backgroundColor: const Color(0xFF071233),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [

            /// TOP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF3F476B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [

                  const Icon(Icons.school, size: 52, color: Colors.white70),
                  const SizedBox(height: 10),

                  const Text(
                    "Indian Institute of Applied Sciences (IIAS)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 6),
                  const Text("Est. 2025",
                      style: TextStyle(color: Colors.white70)),

                  const SizedBox(height: 4),
                  const Text("9876543210",
                      style: TextStyle(color: Colors.white70)),

                  const SizedBox(height: 4),
                  const Text(
                    "Plot No. 88, Knowledge Park, Mock Industrial Estate, Delhi, New Delhi 102030",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Academic Year: ${student?.academicYear ?? "2025"}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 22),
                  Divider(color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 22),

                  /// Photo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFD3DA),
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/girl_image.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: student?.profileImage != null && student!.profileImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              ApiService.getStorageUrl(student.profileImage),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  /// Student Details
                  buildDetail("Name:", "${student?.firstName ?? ""} ${student?.lastName ?? ""}"),
                  buildDetail("Roll No:", student?.studentRollNo ?? "N/A"),
                  buildDetail("DOB:", student?.dob ?? "N/A"),
                  buildDetail("Contact:", student?.mobile ?? "N/A"),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// STUDENT INFO SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF3F476B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF606C77),
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Text(
                        "Student Information",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        sectionTitle("Address"),
                        Text(
                          "${student?.addressLine1 ?? ""}\n${student?.city ?? ""}, ${student?.state ?? ""} - ${student?.pincode ?? ""}\n${student?.country ?? ""}",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 18),

                        sectionTitle("Guardian Details"),
                        Text("Guardian Name: ${student?.guardianFirstName ?? "N/A"}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Guardian Mobile: ${student?.guardianMobile ?? "N/A"}",
                            style: const TextStyle(color: Colors.white70)),

                        const SizedBox(height: 18),

                        sectionTitle("Institute Information"),
                        const Text("Institute Code: IIAS-MOCK-001",
                            style: TextStyle(color: Colors.white70)),
                        const Text(
                            "Affiliation: Board of Technical Education — AFF (FICT); Affiliation no.: AFF-FIC-2025",
                            style: TextStyle(color: Colors.white70)),
                        const Text("Website: https://iias-example.edu",
                            style: TextStyle(color: Colors.white70)),
                        const Text("Email: contact@iias.com",
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C7782),
                padding:
                const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: const Text(
                "DOWNLOAD PDF",
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.white)),
          Divider(color: Colors.white.withValues(alpha: 0.25))
        ],
      ),
    );
  }
}
