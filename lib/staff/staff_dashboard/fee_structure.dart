import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import 'staff_models.dart';

class StaffFeeStructurePage extends StatefulWidget {
  const StaffFeeStructurePage({super.key});

  @override
  State<StaffFeeStructurePage> createState() => _StaffFeeStructurePageState();
}

class _StaffFeeStructurePageState extends State<StaffFeeStructurePage> {
  late Future<List<Fee>> _feesFuture;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  void _loadFees() {
    setState(() {
      _feesFuture = ApiService.getStaffFees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Fees Structure"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadFees(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: FutureBuilder<List<Fee>>(
                future: _feesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(100)),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(100)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: context.scale(48), color: theme.colorScheme.error),
                            SizedBox(height: context.scale(16)),
                            Text("Error: ${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.colorScheme.error)),
                            SizedBox(height: context.scale(16)),
                            FilledButton.tonal(onPressed: _loadFees, child: const Text("Retry")),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(100)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            SizedBox(height: context.scale(16)),
                            Text("No fee structure available",
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }

                  final fees = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fees.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: context.spacing,
                          mainAxisSpacing: context.spacing,
                          mainAxisExtent: context.scale(140),
                        ),
                        itemBuilder: (context, index) {
                          final fee = fees[index];
                          return _buildFeeCard(context, fee.name, "₹${fee.amount}", fee.description ?? "");
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeCard(BuildContext context, String name, String amount, String desc) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(16),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: context.scale(8)),
              Text(
                amount, 
                style: TextStyle(
                  color: theme.colorScheme.primary, 
                  fontWeight: FontWeight.bold,
                  fontSize: context.font(18),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (desc.isNotEmpty) ...[
            Text(
              desc, 
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(13),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
