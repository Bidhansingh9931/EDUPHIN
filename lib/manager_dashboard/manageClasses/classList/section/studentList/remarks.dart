import 'package:flutter/material.dart';

import 'add_new_remarks.dart';

// Data model for a Remark
class Remark {
  final String type; // "Positive" or "Negative"
  final String description;
  final String remarkDate;
  final String dateRange;

  Remark({
    required this.type,
    required this.description,
    required this.remarkDate,
    required this.dateRange,
  });
}

class RemarksPage extends StatefulWidget {
  final String studentName;
  const RemarksPage({super.key, this.studentName = "Aarav Sharma"});

  @override
  State<StatefulWidget> createState() => _RemarksPageState();
}

class _RemarksPageState extends State<RemarksPage> {
  bool _isLoading = true;
  final List<Remark> _remarks = [];

  @override
  void initState() {
    super.initState();
    _fetchRemarks();
  }

  Future<void> _fetchRemarks() async {
    // Simulate API call. Replace with your actual API fetching logic.
    await Future.delayed(const Duration(seconds: 2));

    final List<Remark> fetchedRemarks = [
      Remark(
        type: "Positive",
        description: "Excellent performance in the recent mathematics quiz. Showed great problem solving skills.",
        remarkDate: "20 Oct 2023",
        dateRange: "15 Oct 2023 - 20 Oct 2023",
      ),
      Remark(
        type: "Negative",
        description: "Frequently late to the first period class. Needs to improve punctuality.",
        remarkDate: "18 Oct 2023",
        dateRange: "10 Oct 2023 - 18 Oct 2023",
      ),
      Remark(
        type: "Positive",
        description: "Actively participates in class discussions and helps other students.",
        remarkDate: "15 Oct 2023",
        dateRange: "1 Oct 2023 - 15 Oct 2023",
      ),
      Remark(
        type: "Negative",
        description: "Incomplete homework assignment submitted for the science project.",
        remarkDate: "12 Oct 2023",
        dateRange: "10 Oct 2023 - 12 Oct 2023",
      ),
    ];

    if (mounted) {
      setState(() {
        _remarks.addAll(fetchedRemarks);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("Remarks for ${widget.studentName}")),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewRemarksPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline_sharp, color: Colors.white, size: 25),
                      SizedBox(width: 5),
                      Text(
                        "Add New Remark",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  )),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.separated(
                      itemCount: _remarks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final remark = _remarks[index];
                        return RemarkCard(remark: remark);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a single remark card
class RemarkCard extends StatelessWidget {
  final Remark remark;

  const RemarkCard({super.key, required this.remark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = remark.type == "Positive";
    final typeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    remark.type,
                    style: TextStyle(color: typeColor, fontSize: 16),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    // TODO: Implement delete functionality
                  },
                  icon: const Icon(Icons.delete)),
            ],
          ),
          const SizedBox(height: 5),
          Text(remark.description),
          Divider(
            color: Colors.white,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date of Remarks", style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110), fontSize: 14)),
              Text(remark.remarkDate, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("From Date - To Date", style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(110), fontSize: 14)),
              Text(remark.dateRange, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
