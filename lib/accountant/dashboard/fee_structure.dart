import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'accountant_dashboard_model.dart';

class FeeStructurePage extends StatefulWidget {
  const FeeStructurePage({super.key});

  @override
  State<FeeStructurePage> createState() => _FeeStructurePageState();
}

class _FeeStructurePageState extends State<FeeStructurePage> {
  bool _isLoading = true;
  List<Fee> _instituteFees = [];
  List<Fee> _classFees = [];

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  Future<void> _fetchFees() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAccountantFees();
      if (mounted) {
        setState(() {
          _instituteFees = (data['institute_fees'] as List).map((e) => Fee.fromJson(e)).toList();
          _classFees = (data['class_fees'] as List).map((e) => Fee.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching fees: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFee(Fee fee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Fee"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("REMOVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final targetId = fee.encryptedId ?? fee.id.toString();
        await ApiService.deleteAccountantFee(targetId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fee removed successfully")));
          _fetchFees();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee Structures"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchFees),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, "Institute-Wide"),
                  const SizedBox(height: 16),
                  _buildResponsiveGrid(_instituteFees, true),
                  if (_instituteFees.isEmpty) _buildEmptyState(context, "No institute-wide fees found"),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, "Class-Specific"),
                  const SizedBox(height: 16),
                  _buildResponsiveGrid(_classFees, false),
                  if (_classFees.isEmpty) _buildEmptyState(context, "No class-specific fees found"),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFeeDialog,
        icon: const Icon(Icons.add),
        label: const Text("CREATE NEW FEE"),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title.toUpperCase(), 
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Theme.of(context).colorScheme.primary));
  }

  Widget _buildResponsiveGrid(List<Fee> fees, bool isInstitute) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 2 : 1,
        mainAxisExtent: 180,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: fees.length,
      itemBuilder: (context, index) => _buildFeeCard(fees[index], isInstitute),
    );
  }

  Widget _buildFeeCard(Fee fee, bool isInstitute) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(isInstitute ? Icons.account_balance : Icons.school, color: theme.colorScheme.primary, size: 20),
                ),
                Text("₹${fee.amount}", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(fee.feeName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (!isInstitute) Text(fee.className ?? 'N/A', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const Spacer(),
            Row(
              children: [
                _buildSmallBadge(context, fee.isOptional ? "OPTIONAL" : "MANDATORY", fee.isOptional ? theme.colorScheme.secondary : Colors.green),
                const Spacer(),
                IconButton(onPressed: () => _showEditFeeDialog(fee), icon: const Icon(Icons.edit_outlined, size: 20), color: theme.colorScheme.primary),
                IconButton(onPressed: () => _deleteFee(fee), icon: const Icon(Icons.delete_outline, size: 20), color: theme.colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, color: Theme.of(context).hintColor.withValues(alpha: 0.3), size: 64),
            const SizedBox(height: 16),
            Text(msg, style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }

  void _showAddFeeDialog() async {
    setState(() => _isLoading = true);
    try {
      final classes = await ApiService.getAccountantFeeCreateData();
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FeeFormDialog(title: "Create Fee Structure", buttonLabel: "SAVE STRUCTURE", classes: classes, onSuccess: _fetchFees),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditFeeDialog(Fee fee) async {
    setState(() => _isLoading = true);
    try {
      final targetId = fee.encryptedId ?? fee.id.toString();
      final editData = await ApiService.getAccountantFeeEditData(targetId);
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FeeFormDialog(
            title: "Update Fee Structure",
            buttonLabel: "UPDATE STRUCTURE",
            classes: editData['classes'],
            fee: Fee.fromJson(editData['fee']),
            onSuccess: _fetchFees,
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class FeeFormDialog extends StatefulWidget {
  final String title;
  final String buttonLabel;
  final List<dynamic> classes;
  final Fee? fee;
  final VoidCallback onSuccess;

  const FeeFormDialog({super.key, required this.title, required this.buttonLabel, required this.classes, this.fee, required this.onSuccess});

  @override
  State<FeeFormDialog> createState() => _FeeFormDialogState();
}

class _FeeFormDialogState extends State<FeeFormDialog> {
  final _feeNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  dynamic _selectedClassId;
  bool _isOptional = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.fee != null) {
      _feeNameController.text = widget.fee!.feeName;
      _amountController.text = widget.fee!.amount;
      _descController.text = widget.fee!.description ?? '';
      _selectedClassId = widget.fee!.classId;
      _isOptional = widget.fee!.isOptional;
    }
  }

  @override
  void dispose() {
    _feeNameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_feeNameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'fee_name': _feeNameController.text,
        'amount': _amountController.text,
        'description': _descController.text,
        'class_id': _selectedClassId,
      };
      if (_isOptional) data['is_optional'] = '1';

      if (widget.fee == null) {
        await ApiService.storeAccountantFee(data);
      } else {
        final targetId = widget.fee!.encryptedId ?? widget.fee!.id.toString();
        await ApiService.updateAccountantFee(targetId, data);
      }

      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel(context, "Apply Assignment"),
            _buildDropdownField(widget.classes),
            const SizedBox(height: 20),
            _buildLabel(context, "Fee Name *"),
            TextField(controller: _feeNameController, decoration: const InputDecoration(hintText: "e.g., Admission Fee")),
            const SizedBox(height: 20),
            _buildLabel(context, "Amount (₹) *"),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "0.00")),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Mark as Optional?"),
                const Spacer(),
                Switch(value: _isOptional, onChanged: (v) => setState(() => _isOptional = v)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : Text(widget.buttonLabel),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12, fontWeight: FontWeight.bold)));
  }

  Widget _buildDropdownField(List<dynamic> classes) {
    return DropdownButtonFormField<dynamic>(
      value: _selectedClassId,
      isExpanded: true,
      hint: const Text("Institute-Wide"),
      items: [
        const DropdownMenuItem<dynamic>(value: null, child: Text("Institute-Wide")),
        ...classes.map((cls) => DropdownMenuItem<dynamic>(value: cls['id'], child: Text(cls['name']?.toString() ?? 'Class'))),
      ],
      onChanged: (val) => setState(() => _selectedClassId = val),
    );
  }
}
