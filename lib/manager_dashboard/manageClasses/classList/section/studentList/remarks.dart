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
      // Using a responsive FloatingActionButton
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddNewRemarksPage()));
        },
        label: const Text("Add New Remark"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Using Flexible to prevent overflow on small screens
            Flexible(
              child: Text(
                "Remarks for ${widget.studentName}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // Using LayoutBuilder for a responsive grid/list
          : LayoutBuilder(
              builder: (context, constraints) {
                // Use GridView for wider screens
                if (constraints.maxWidth > 600) {
                  return GridView.builder(
                    // Increased bottom padding for FAB
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _remarks.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450, // Max width per item
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8, // Adjust for content
                    ),
                    itemBuilder: (context, index) {
                      final remark = _remarks[index];
                      return RemarkCard(remark: remark);
                    },
                  );
                } else {
                  // Use ListView for narrower screens
                  return ListView.separated(
                    // Increased bottom padding for FAB
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: _remarks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final remark = _remarks[index];
                      return RemarkCard(remark: remark);
                    },
                  );
                }
              },
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
    final typeColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // For GridView
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      remark.type,
                      // Using theme for scalable font
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: typeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        // TODO: Implement delete functionality
                      },
                      icon: Icon(Icons.delete, color: theme.colorScheme.error)),
                ],
              ),
              const SizedBox(height: 10),
              // Using theme for scalable font
              Text(remark.description, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Using theme for scalable font
                  Text("Date of Remarks",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor)),
                  Text(remark.remarkDate, style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Using theme for scalable font
                  Text("From Date - To Date",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor)),
                  Text(remark.dateRange, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
