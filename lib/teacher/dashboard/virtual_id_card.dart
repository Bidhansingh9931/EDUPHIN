import 'dart:math';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_profile_model.dart';

class VirtualIdCardPage extends StatefulWidget {
  const VirtualIdCardPage({super.key});

  @override
  State<VirtualIdCardPage> createState() => _VirtualIdCardPageState();
}

class _VirtualIdCardPageState extends State<VirtualIdCardPage> {
  bool _isFlipped = false;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual ID Card'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: context.pagePadding,
            child: FutureBuilder<VirtualIdCardData>(
              future: ApiService.getVirtualIdCard(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final idData = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildFlipAnimation(
                          isFlipped: _isFlipped,
                          front: _buildFrontCard(context, idData),
                          back: _buildBackCard(context, idData),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _flipCard,
                        icon: const Icon(Icons.flip_camera_android),
                        label: const Text('Flip Card'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('No data');
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlipAnimation(
      {required bool isFlipped, required Widget front, required Widget back}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        final isFront = value < 90;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(value * (pi / 180));

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isFront
              ? front
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi), // Flip the back view
                  alignment: Alignment.center,
                  child: back,
                ),
        );
      },
    );
  }

  Widget _buildFrontCard(BuildContext context, VirtualIdCardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.school, size: 40, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.instituteName ?? 'IIAS',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(data.instituteAddress ?? '',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: data.photoUrl != null ? NetworkImage(ApiService.baseImageUrl + data.photoUrl!) : null,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                 child: data.photoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(data.name, 
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _buildIdRow(context, 'POSITION', data.position, 'EMPLOYEE ID', data.employeeId),
                  const SizedBox(height: 12),
                  _buildIdRow(context, 'EMPLOYMENT', data.employmentType, 'JOINED', data.joiningDate),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Center(child: Text('Authorized Signature', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, VirtualIdCardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.tertiary, colorScheme.error],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildContactInfo(context, Icons.email, 'EMAIL', data.email),
              _buildContactInfo(context, Icons.phone, 'PHONE', data.phone),
              _buildContactInfo(context, Icons.location_on, 'ADDRESS', data.fullAddress),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emergency Contact', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Name: ${data.emergencyContactName}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Phone: ${data.emergencyContactPhone}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Issue Date: ${data.issueDate}',
                      style: const TextStyle(fontSize: 10, color: Colors.white60)),
                  Text('Library ID: ${data.libraryId}',
                      style: const TextStyle(fontSize: 10, color: Colors.white60)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdRow(BuildContext context, String title1, String? value1, String title2, String? value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildIdField(context, title1, value1)),
        const SizedBox(width: 8),
        Expanded(child: _buildIdField(context, title2, value2, alignRight: true)),
      ],
    );
  }

  Widget _buildIdField(BuildContext context, String title, String? value, {bool alignRight = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value ?? 'N/A', 
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String title, String? value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color?.withValues(alpha: 0.8) ?? theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 2),
                Text(value ?? 'N/A', style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
