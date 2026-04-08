import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';
import 'package:flutter/material.dart';

class VirtualIdPage extends StatefulWidget {
  const VirtualIdPage({super.key});

  @override
  State<VirtualIdPage> createState() => _VirtualIdPageState();
}

class _VirtualIdPageState extends State<VirtualIdPage> {
  bool _isFlipped = false;
  late Future<VirtualIdCardData> _idDataFuture;

  @override
  void initState() {
    super.initState();
    _idDataFuture = ApiService.getVirtualIdCard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual ID Card"),
      ),
      body: FutureBuilder<VirtualIdCardData>(
        future: _idDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  _buildIDCard(context, data),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isFlipped = !_isFlipped),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("FLIP CARD"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text("DOWNLOAD PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIDCard(BuildContext context, VirtualIdCardData data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 550),
      child: AspectRatio(
        aspectRatio: 0.63,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotate = Tween(begin: 3.14159, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                final isUnder = (ValueKey(_isFlipped) != child!.key);
                var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                tilt *= isUnder ? -1.0 : 1.0;
                final value = isUnder ? (3.14159 + rotate.value) : rotate.value;
                return Transform(
                  transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: _isFlipped ? _buildBackCard(data) : _buildFrontCard(data),
        ),
      ),
    );
  }

  Widget _buildFrontCard(VirtualIdCardData data) {
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey(false),
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.surface, theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.school, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.instituteName ?? "N/A", 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                      Text(data.instituteAddress ?? "N/A", 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: theme.hintColor)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Text("EMPLOYEE ID", style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
              backgroundImage: data.photoUrl != null ? NetworkImage("${ApiService.baseUrl}/storage/${data.photoUrl}") : null,
              child: data.photoUrl == null ? Icon(Icons.person, size: 70, color: theme.colorScheme.primary.withValues(alpha: 0.5)) : null,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(data.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _idInfo("Position", data.position ?? "Teacher"),
                      _idInfo("Employee ID", data.employeeId ?? "N/A"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _idInfo("Employment Type", data.employmentType ?? "Full-time"),
                      _idInfo("Joining Date", data.joiningDate ?? "N/A"),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
              ),
              child: Text("Authorized Signature", textAlign: TextAlign.center, style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(VirtualIdCardData data) {
    final theme = Theme.of(context);
    return Card(
      key: const ValueKey(true),
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.qr_code_2, size: 150),
            const SizedBox(height: 20),
            Text("Terms & Conditions", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "1. This card is non-transferable.\n2. In case of loss, report immediately to HR.\n3. Return card upon resignation or termination.",
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(data.instituteName != null ? data.instituteName!.split(' ').first.toLowerCase() + ".com" : "iias.com", 
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _idInfo(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.hintColor)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }
}
