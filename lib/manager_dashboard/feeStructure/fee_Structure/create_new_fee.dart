import 'package:flutter/material.dart';

class CreateNewFeePage extends StatefulWidget {
  const CreateNewFeePage({super.key});

  @override
  State<CreateNewFeePage> createState() => _CreateNewFeePageState();
}

class _CreateNewFeePageState extends State<CreateNewFeePage> {
  final _formKey = GlobalKey<FormState>();
  final _feeNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _applyTo = "institute";
  String _isOptional = "Yes";

  @override
  void dispose() {
    _feeNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: SizedBox(
                width: 200,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final result = {
                        'feeName': _feeNameController.text,
                        'amount': _amountController.text,
                        'description': _descriptionController.text,
                        'applyTo': _applyTo,
                        'isOptional': _isOptional == 'Yes',
                      };
                      Navigator.pop(context, result);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        "Add Fee",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface, fontSize: 20),
                      ),
                    ],
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
                width: 150,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: theme.cardColor,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: theme.colorScheme.onSurface, fontSize: 20),
                  ),
                )),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create New Fee"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 115),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Apply fee to:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // -------- Button 1 --------
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _applyTo = "institute");
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _applyTo == "institute"
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _applyTo == "institute"
                                        ? const Color(0xFF60A5FA)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Entire\nInstitute",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // -------- Button 2 --------
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _applyTo = "class");
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _applyTo == "class"
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _applyTo == "class"
                                        ? const Color(0xFF60A5FA)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Class\nSpecific",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fee Name",
                            style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _feeNameController,
                            validator: (value) =>
                                value!.isEmpty ? 'Fee name cannot be empty' : null,
                            decoration: InputDecoration(
                              hintText: "e.g., Annual Tuition Fee",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Amount",
                            style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Amount cannot be empty' : null,
                            decoration: InputDecoration(
                              hintText: "75,000",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Description",
                            style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Enter a brief description",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Is Optional?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // -------- Button 1 --------
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isOptional = "Yes");
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isOptional == "Yes"
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _isOptional == "Yes"
                                        ? const Color(0xFF60A5FA)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Yes",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // -------- Button 2 --------
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isOptional = "No");
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isOptional == "No"
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _isOptional == "No"
                                        ? const Color(0xFF60A5FA)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "No",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
