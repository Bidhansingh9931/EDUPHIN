import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/pdf_service.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';
import 'package:flutter/material.dart';

class VirtualIdPage extends StatefulWidget {
  const VirtualIdPage({super.key});

  @override
  State<VirtualIdPage> createState() => _VirtualIdPageState();
}

class _VirtualIdPageState extends State<VirtualIdPage> {
  bool _isFlipped = false;
  VirtualIdCardData? _idData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache
    final cachedData = await TeacherCacheService.load('virtual_id');
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _idData = VirtualIdCardData.fromJson(cachedData);
          _isLoading = false;
        });
      }
    }

    // 2. Fetch from API
    try {
      final data = await ApiService.getVirtualIdCard();
      await TeacherCacheService.save('virtual_id', data.toJson());
      if (mounted) {
        setState(() {
          _idData = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (_idData == null) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual ID Card"),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _idData == null) {
      return _buildSkeleton();
    }
    if (_error != null && _idData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text("Error: $_error", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }
    if (_idData == null) {
      return const Center(child: Text("No data found"));
    }

    final data = _idData!;
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIDCard(context, data),
              const SizedBox(height: 32),
              buildResponsiveRow(context, [
                buildActionButton(context, "FLIP CARD", () => setState(() => _isFlipped = !_isFlipped)),
                const SizedBox(height: 12),
                buildActionButton(context, "DOWNLOAD PDF", () => PdfService.generateAndPrintIdCard(data), isPrimary: false),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 480,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 32),
            Container(height: 48, width: 200, color: Colors.white),
          ],
        ),
      ),
    );
  }


  Widget _buildIDCard(BuildContext context, VirtualIdCardData data) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 550),
      child: AspectRatio(
        aspectRatio: 0.63,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
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
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(value)
                    ..setEntry(3, 0, tilt),
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
    final theme = context.theme;
    return Card(
      key: const ValueKey(false),
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Container(
        padding: EdgeInsets.all(context.scale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.scale(24)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: InstituteLogo(
                    logoUrl: data.instituteLogo,
                    size: context.scale(24),
                  ),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.instituteName ?? "N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12))),
                      Text(data.instituteAddress ?? "N/A",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(10), color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: context.scale(30)),
            Text("EMPLOYEE ID",
                style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: context.font(12),
                    color: theme.colorScheme.primary)),
            SizedBox(height: context.scale(16)),
            ProfileAvatar(
              imageUrl: data.photoUrl != null ? ApiService.getStorageUrl(data.photoUrl) : null,
              radius: context.scale(50),
              borderWidth: 2,
            ),
            SizedBox(height: context.scale(20)),
            Container(
              padding: EdgeInsets.all(context.scale(16)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(context.scale(20)),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
              ),
              child: Column(
                children: [
                  Text(data.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                  SizedBox(height: context.scale(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _idInfo("Position", data.position ?? "Teacher"),
                      _idInfo("Employee ID", data.employeeId ?? "N/A"),
                    ],
                  ),
                  SizedBox(height: context.scale(12)),
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
              padding: EdgeInsets.symmetric(vertical: context.scale(8)),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5)),
              ),
              child: Text("Authorized Signature",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic, fontSize: context.font(10), color: theme.colorScheme.onSurfaceVariant)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(VirtualIdCardData data) {
    final theme = context.theme;
    return Card(
      key: const ValueKey(true),
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Container(
        padding: EdgeInsets.all(context.scale(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.scale(24)),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.qr_code_2, size: context.scale(150), color: theme.colorScheme.onSurface),
            SizedBox(height: context.scale(20)),
            Text("Terms & Conditions", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
            SizedBox(height: context.scale(12)),
            Text(
              "1. This card is non-transferable.\n2. In case of loss, report immediately to HR.\n3. Return card upon resignation or termination.",
              style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(10), height: 1.5, color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(data.instituteName != null ? data.instituteName!.split(' ').first.toLowerCase() + ".com" : "iias.com",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontSize: context.font(10))),
          ],
        ),
      ),
    );
  }

  Widget _idInfo(String label, String value) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(9), color: theme.colorScheme.onSurfaceVariant)),
        SizedBox(height: context.scale(2)),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(10))),
      ],
    );
  }
}
