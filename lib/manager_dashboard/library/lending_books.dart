import 'package:flutter/material.dart';

class LendingBooksScreen extends StatefulWidget {
  const LendingBooksScreen({super.key});

  @override
  State<LendingBooksScreen> createState() => _LendingBooksScreenState();
}

class _LendingBooksScreenState extends State<LendingBooksScreen> {
  List<LendingBook> lendingBooks = [];
  bool isLoading = true; // To show a loader while fetching data

  @override
  void initState() {
    super.initState();
    _fetchLendingBooks();
  }

  // TODO: Replace this with your actual API call
  Future<void> _fetchLendingBooks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> dummyData = [
      {
        "title": "The Principles of Quantum Mechanics",
        "issueNo": "B00123",
        "issuedAt": "15 Jul 2024",
        "dueDate": "30 Jul 2024",
        "overdueDays": 0,
        "status": "Pending"
      },
      {
        "title": "Introduction to Algorithms",
        "issueNo": "B00124",
        "issuedAt": "01 Jul 2024",
        "dueDate": "16 Jul 2024",
        "overdueDays": 10,
        "status": "Overdue"
      },
      {
        "title": "The Art of Computer Programming",
        "issueNo": "B00125",
        "issuedAt": "20 Jun 2024",
        "dueDate": "05 Jul 2024",
        "overdueDays": 0,
        "status": "Returned"
      },
      {
        "title": "Cosmos",
        "issueNo": "B00126",
        "issuedAt": "10 Jul 2024",
        "dueDate": "25 Jul 2024",
        "overdueDays": 0,
        "status": "Pending"
      },
    ];

    if (mounted) {
      setState(() {
        lendingBooks =
            dummyData.map((data) => LendingBook.fromJson(data)).toList();
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.amber;
      case "Overdue":
        return Colors.redAccent;
      case "Returned":
        return Colors.greenAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Lending Books",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              itemCount: lendingBooks.length,
              itemBuilder: (context, index) {
                final b = lendingBooks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xff0F1A2B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${index + 1}.  ${b.title}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            b.status,
                            style: TextStyle(
                              color: getStatusColor(b.status),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                info("Book Issue Number", b.issueNo),
                                info("Due Date", b.dueDate),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                info("Issued At", b.issuedAt),
                                info(
                                  "Days Overdue",
                                  b.overdueDays.toString(),
                                  highlight: b.overdueDays > 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget info(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: highlight ? Colors.redAccent : Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LendingBook {
  final String title;
  final String issueNo;
  final String issuedAt;
  final String dueDate;
  final int overdueDays;
  final String status;

  LendingBook({
    required this.title,
    required this.issueNo,
    required this.issuedAt,
    required this.dueDate,
    required this.overdueDays,
    required this.status,
  });

  factory LendingBook.fromJson(Map<String, dynamic> json) {
    return LendingBook(
      title: json['title'] as String,
      issueNo: json['issueNo'] as String,
      issuedAt: json['issuedAt'] as String,
      dueDate: json['dueDate'] as String,
      overdueDays: json['overdueDays'] as int,
      status: json['status'] as String,
    );
  }
}
